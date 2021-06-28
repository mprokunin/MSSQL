CREATE EVENT SESSION [PlanCacheRemoval] ON SERVER 
ADD EVENT sqlserver.query_cache_removal_statistics(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.is_system,sqlserver.nt_username,sqlserver.plan_handle,sqlserver.sql_text)
    WHERE ([sqlserver].[database_name]=N'IrisInsuranceDB-performance')),
ADD EVENT sqlserver.sp_cache_hit(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.is_system,sqlserver.nt_username,sqlserver.plan_handle,sqlserver.sql_text)
    WHERE ([sqlserver].[database_name]=N'IrisInsuranceDB-performance')),
ADD EVENT sqlserver.sp_cache_insert(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.is_system,sqlserver.nt_username,sqlserver.plan_handle,sqlserver.sql_text)
    WHERE ([sqlserver].[database_name]=N'IrisInsuranceDB-performance')),
ADD EVENT sqlserver.sp_cache_miss(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.is_system,sqlserver.nt_username,sqlserver.plan_handle,sqlserver.sql_text)
    WHERE ([sqlserver].[database_name]=N'IrisInsuranceDB-performance')),
ADD EVENT sqlserver.sp_cache_remove(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.is_system,sqlserver.nt_username,sqlserver.plan_handle,sqlserver.sql_text)
    WHERE ([sqlserver].[database_name]=N'IrisInsuranceDB-performance')),
ADD EVENT sqlserver.sp_statement_completed(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.is_system,sqlserver.nt_username,sqlserver.plan_handle,sqlserver.sql_text)
    WHERE ([sqlserver].[database_name]=N'IrisInsuranceDB-performance')),
ADD EVENT sqlserver.sp_statement_starting(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.is_system,sqlserver.nt_username,sqlserver.plan_handle,sqlserver.sql_text)
    WHERE ([sqlserver].[database_name]=N'IrisInsuranceDB-performance')),
ADD EVENT sqlserver.sql_batch_completed(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.is_system,sqlserver.nt_username,sqlserver.plan_handle,sqlserver.sql_text)
    WHERE ([sqlserver].[database_name]=N'IrisInsuranceDB-performance')),
ADD EVENT sqlserver.sql_batch_starting(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.is_system,sqlserver.nt_username,sqlserver.plan_handle,sqlserver.sql_text)
    WHERE ([sqlserver].[database_name]=N'IrisInsuranceDB-performance'))
ADD TARGET package0.event_file(SET filename=N'G:\MSSQL13.MSSQLSERVER\MSSQL\PerfData\PlanCacheRemoval.xel')
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=ON,STARTUP_STATE=OFF)
GO



--- Read data collected
--drop table #t
SELECT event_data = CONVERT(XML, event_data) 
  INTO #t
  FROM sys.fn_xe_file_target_read_file(N'G:\MSSQL13.MSSQLSERVER\MSSQL\PerfData\PlanCacheRemoval*.xel', NULL, NULL, NULL);

--select top 100 * from #t

-- Ring Buffer
  ;WITH cte AS 
(
  SELECT ed = CONVERT(XML, target_data) 
    FROM sys.dm_xe_session_targets xet
    INNER JOIN sys.dm_xe_sessions xe
    ON xe.[address] = xet.event_session_address
    WHERE xe.name = N'system_health'
    AND xet.target_name = N'ring_buffer'
)
SELECT event_data = x.ed.query('.') 
  INTO #t
  FROM cte
  CROSS APPLY cte.ed.nodes(N'RingBufferTarget/event') AS x(ed);
  

SELECT top 10
  ts    = event_data.value(N'(event/@timestamp)[1]', N'datetime'),
  [action] = event_data.value(N'(event/@name)[1]', N'sysname'),
  [sql] = event_data.value(N'(event/action[@name="sql_text"]/value)[1]', N'nvarchar(max)'),
  [plan_hadle]  = event_data.value(N'(event/action[@name="plan_handle"]/value)[1]', N'varbinary(8)'),
  [client_hostname]  = event_data.value(N'(event/action[@name="client_hostname"]/value)[1]', N'nvarchar(max)')
  
FROM #t
WHERE 
  event_data.value(N'(event/@name)[1]', N'sysname') = N'sp_cache_remove'
--  or 
--  event_data.value(N'(event/@name)[1]', N'sysname') = N'sp_statement_completed'
  
--  AND event_data.value(N'(event/data[@name="severity"]/value)[1]', N'int') = 20;

exec tempdb..sp_spaceused #t

