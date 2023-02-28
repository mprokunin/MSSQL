SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
GO

;WITH XMLNAMESPACES(DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
,PlanMissingIndexes
AS (
SELECT query_plan, usecounts
FROM sys.dm_exec_cached_plans cp
CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) qp
WHERE qp.query_plan.exist('//MissingIndexes') = 1
)
, MissingIndexes
AS (
SELECT TOP 20
stmt_xml.value('(QueryPlan/MissingIndexes/MissingIndexGroup/MissingIndex/@Database)[1]', 'sysname') AS DatabaseName
,stmt_xml.value('(QueryPlan/MissingIndexes/MissingIndexGroup/MissingIndex/@Schema)[1]', 'sysname') AS SchemaName
,stmt_xml.value('(QueryPlan/MissingIndexes/MissingIndexGroup/MissingIndex/@Table)[1]', 'sysname') AS TableName
,stmt_xml.value('(QueryPlan/MissingIndexes/MissingIndexGroup/@Impact)[1]', 'float') AS impact
,pmi.usecounts
,STUFF((SELECT DISTINCT ', ' + c.value('(@Name)[1]', 'sysname')
FROM stmt_xml.nodes('//ColumnGroup') AS t(cg)
CROSS APPLY cg.nodes('Column') AS r(c)
WHERE cg.value('(@Usage)[1]', 'sysname') = 'EQUALITY'
FOR  XML PATH('')), 1, 2, '') AS equality_columns
,STUFF((SELECT DISTINCT ', ' + c.value('(@Name)[1]', 'sysname')
FROM stmt_xml.nodes('//ColumnGroup') AS t(cg)
CROSS APPLY cg.nodes('Column') AS r(c)
WHERE cg.value('(@Usage)[1]', 'sysname') = 'INEQUALITY'
FOR  XML PATH('')), 1, 2, '') AS inequality_columns
,STUFF((SELECT DISTINCT ', ' + c.value('(@Name)[1]', 'sysname')
FROM stmt_xml.nodes('//ColumnGroup') AS t(cg)
CROSS APPLY cg.nodes('Column') AS r(c)
WHERE cg.value('(@Usage)[1]', 'sysname') = 'INCLUDE'
FOR  XML PATH('')), 1, 2, '') AS include_columns
,query_plan
,stmt_xml.value('(@StatementText)[1]', 'varchar(4000)') AS sql_text
FROM PlanMissingIndexes pmi
CROSS APPLY query_plan.nodes('//StmtSimple') AS stmt(stmt_xml)
WHERE stmt_xml.exist('QueryPlan/MissingIndexes') = 1
)
SELECT DatabaseName
,SchemaName
,TableName
,equality_columns
,inequality_columns
,include_columns
,usecounts
,impact
,query_plan
,CAST('<?query --' + CHAR(13) + sql_text + CHAR(13) + ' --?>' AS xml) AS SQLText
,CAST('<?query --' + CHAR(13) + 'CREATE NONCLUSTERED INDEX IX_'
         + REPLACE(REPLACE(REPLACE(SchemaName,'_',''),'[',''),']','')+'_'
         + REPLACE(REPLACE(REPLACE(TableName,'_',''),'[',''),']','')+'_'
         + COALESCE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(equality_columns,'_',''),'[',''),']',''),',',''),' ',''),'')
         + COALESCE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(COALESCE(inequality_columns,''),'_',''),'[',''),']',''),',',''),' ',''),'')
         + ' ON '
         + SchemaName + '.' + TableName + '('
             + STUFF(COALESCE(',' + equality_columns,'') + COALESCE(',' + inequality_columns,''), 1, 1, '') + ')'
             + COALESCE(' INCLUDE (' + include_columns + ')','')  + CHAR(13) + ' --?>' AS xml) AS PotentialDDL
FROM MissingIndexes
ORDER BY DatabaseName
,SUM(usecounts) OVER(PARTITION BY DatabaseName
,SchemaName
,TableName) DESC
,SUM(usecounts) OVER(PARTITION BY TableName
,equality_columns
,inequality_columns) DESC
,usecounts DESC
