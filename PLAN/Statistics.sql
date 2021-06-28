select @@VERSION

SELECT cplan.usecounts, cplan.objtype, qtext.text, qplan.query_plan
FROM sys.dm_exec_cached_plans AS cplan
CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS qtext
CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS qplan
where text like 'create proc%'
ORDER BY cplan.usecounts DESC

select top 100 * from sys.sql_modules where object_id = object_ud('SP NAME HERE')

select sql_text.text, stats.sql_handle, stats.plan_generation_num, 
stats.creation_time, stats.execution_count, sql_text.dbid, sql_text.objectid
from sys.dm_exec_query_stats stats
cross apply sys.dm_exec_sql_text(sql_handle) as sql_text
where stats.plan_generation_num > 1 and sql_text.objectid is not null

