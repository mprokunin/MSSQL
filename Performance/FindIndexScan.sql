
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
GO

DECLARE @op sysname = 'Index Scan';
DECLARE @IndexName sysname = 'PK_Product_ProductID';

;WITH XMLNAMESPACES(DEFAULT N'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
SELECT
cp.plan_handle
,operators.value('(IndexScan/Object/@Schema)[1]','sysname') AS SchemaName
,operators.value('(IndexScan/Object/@Table)[1]','sysname') AS TableName
,operators.value('(IndexScan/Object/@Index)[1]','sysname') AS IndexName
,operators.value('@PhysicalOp','nvarchar(50)') AS PhysicalOperator
,cp.usecounts
,qp.query_plan
FROM sys.dm_exec_cached_plans cp
CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) qp
CROSS APPLY query_plan.nodes('//RelOp') rel(operators)
WHERE operators.value('@PhysicalOp','nvarchar(50)') IN ('Clustered Index Scan','Index Scan')
AND operators.value('(IndexScan/Object/@Index)[1]','sysname') = QUOTENAME(@IndexName,'[');
