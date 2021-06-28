ALTER EVENT SESSION [PlanCacheRemoval] ON SERVER 
DROP EVENT sqlserver.query_cache_removal_statistics, 
DROP EVENT sqlserver.rpc_completed, 
DROP EVENT sqlserver.sp_cache_miss, 
DROP EVENT sqlserver.sp_cache_remove,
DROP EVENT sqlserver.sp_cache_hit,
DROP EVENT sqlserver.sp_cache_insert

ALTER EVENT SESSION [PlanCacheRemoval] ON SERVER 
ADD EVENT sqlserver.query_cache_removal_statistics(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.is_system,sqlserver.nt_username,sqlserver.sql_text)
    WHERE ([sqlserver].[database_name]=N'IrisInsuranceDB-performance')), 
ADD EVENT sqlserver.rpc_completed(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.is_system,sqlserver.nt_username,sqlserver.sql_text)
    WHERE ([sqlserver].[database_name]=N'IrisInsuranceDB-performance')), 
ADD EVENT sqlserver.sp_cache_miss(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.is_system,sqlserver.nt_username,sqlserver.sql_text)
    WHERE ([sqlserver].[database_name]=N'IrisInsuranceDB-performance')), 
ADD EVENT sqlserver.sp_cache_remove(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.is_system,sqlserver.nt_username,sqlserver.sql_text)
    WHERE ([sqlserver].[database_name]=N'IrisInsuranceDB-performance')),
ADD EVENT sqlserver.sp_cache_hit(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.is_system,sqlserver.nt_username,sqlserver.sql_text)
    WHERE ([sqlserver].[database_name]=N'IrisInsuranceDB-performance')),
ADD EVENT sqlserver.sp_cache_insert(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.is_system,sqlserver.nt_username,sqlserver.sql_text)
    WHERE ([sqlserver].[database_name]=N'IrisInsuranceDB-performance'))
GO


ALTER EVENT SESSION [PlanCacheRemoval] ON SERVER 
DROP EVENT sqlserver.rpc_completed, 
DROP EVENT sqlserver.rpc_starting



CREATE EVENT SESSION PlanCacheRemoval
ON SERVER
ADD EVENT sqlserver.query_cache_removal_statistics
(WHERE (sqlserver.database_name = N'IrisInsuranceDB-performance')),
ADD EVENT sqlserver.rpc_completed
(WHERE (sqlserver.database_name = N'IrisInsuranceDB-performance')),
ADD EVENT sqlserver.rpc_starting
(WHERE (sqlserver.database_name = N'IrisInsuranceDB-performance')),
ADD EVENT sqlserver.sp_cache_hit
(WHERE (sqlserver.database_name = N'IrisInsuranceDB-performance')),
ADD EVENT sqlserver.sp_cache_insert
(WHERE (sqlserver.database_name = N'IrisInsuranceDB-performance')),
ADD EVENT sqlserver.sp_cache_miss
(WHERE (sqlserver.database_name = N'IrisInsuranceDB-performance')),
ADD EVENT sqlserver.sp_cache_remove
(WHERE (sqlserver.database_name = N'IrisInsuranceDB-performance')),
ADD EVENT sqlserver.sp_statement_completed
(WHERE (sqlserver.database_name = N'IrisInsuranceDB-performance')),
ADD EVENT sqlserver.sp_statement_starting
(WHERE (sqlserver.database_name = N'IrisInsuranceDB-performance')),
ADD EVENT sqlserver.sql_batch_completed
(WHERE (sqlserver.database_name = N'IrisInsuranceDB-performance')),
ADD EVENT sqlserver.sql_batch_starting
(WHERE (sqlserver.database_name = N'IrisInsuranceDB-performance'))
ADD TARGET package0.event_file
(SET filename = N'G:\MSSQL13.MSSQLSERVER\MSSQL\PerfData\PlanCacheRemoval.xel')
WITH (TRACK_CAUSALITY = ON);
