
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
GO

WITH XMLNAMESPACES
(DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
SELECT cp.plan_handle
,qp.query_plan
,c.value('@StatementText', 'varchar(255)') AS StatementText
,c.value('@StatementType', 'varchar(255)') AS StatementType
,c.value('CursorPlan[1]/@CursorName', 'varchar(255)') AS CursorName
,c.value('CursorPlan[1]/@CursorActualType', 'varchar(255)') AS CursorActualType
,c.value('CursorPlan[1]/@CursorRequestedType', 'varchar(255)') AS CursorRequestedType
,c.value('CursorPlan[1]/@CursorConcurrency', 'varchar(255)') AS CursorConcurrency
,c.value('CursorPlan[1]/@ForwardOnly', 'varchar(255)') AS ForwardOnly
FROM sys.dm_exec_cached_plans AS cp
CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) AS qp
CROSS APPLY qp.query_plan.nodes('//StmtCursor') t(c)
WHERE qp.query_plan.exist('//StmtCursor') = 1
