CREATE EVENT SESSION [PlanCacheRemoval] ON SERVER 
ADD EVENT sqlserver.sp_cache_hit(SET collect_cached_text=(0)
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.is_system,sqlserver.nt_username,sqlserver.plan_handle,sqlserver.sql_text)
    WHERE ([sqlserver].[database_name]=N'IrisInsuranceDB-performance' AND [sqlserver].[nt_domain]=N'mprokunin')),
ADD EVENT sqlserver.sp_cache_insert(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.is_system,sqlserver.nt_username,sqlserver.plan_handle,sqlserver.sql_text)
    WHERE ([sqlserver].[database_name]=N'IrisInsuranceDB-performance' AND [sqlserver].[nt_domain]=N'mprokunin')),
ADD EVENT sqlserver.sp_cache_miss(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.is_system,sqlserver.nt_username,sqlserver.plan_handle,sqlserver.sql_text)
    WHERE ([sqlserver].[database_name]=N'IrisInsuranceDB-performance' AND [sqlserver].[nt_domain]=N'mprokunin')),
ADD EVENT sqlserver.sp_cache_remove(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.is_system,sqlserver.nt_username,sqlserver.plan_handle,sqlserver.sql_text)
    WHERE ([sqlserver].[database_name]=N'IrisInsuranceDB-performance' AND [sqlserver].[nt_domain]=N'mprokunin')),
ADD EVENT sqlserver.sp_statement_completed(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.is_system,sqlserver.nt_username,sqlserver.plan_handle,sqlserver.sql_text)
    WHERE ([sqlserver].[equal_i_sql_unicode_string]([sqlserver].[database_name],N'IrisInsuranceDB-performance') AND [sqlserver].[nt_domain]=N'mprokunin')),
ADD EVENT sqlserver.sp_statement_starting(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.is_system,sqlserver.nt_username,sqlserver.plan_handle,sqlserver.sql_text)
    WHERE ([sqlserver].[equal_i_sql_unicode_string]([sqlserver].[database_name],N'IrisInsuranceDB-performance') AND [sqlserver].[nt_domain]=N'mprokunin')),
ADD EVENT sqlserver.sql_batch_completed(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.is_system,sqlserver.nt_username,sqlserver.plan_handle,sqlserver.sql_text)
    WHERE ([sqlserver].[equal_i_sql_unicode_string]([sqlserver].[database_name],N'IrisInsuranceDB-performance') AND [sqlserver].[nt_domain]=N'mprokunin')),
ADD EVENT sqlserver.sql_batch_starting(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.is_system,sqlserver.nt_username,sqlserver.plan_handle,sqlserver.sql_text)
    WHERE ([sqlserver].[equal_i_sql_unicode_string]([sqlserver].[database_name],N'IrisInsuranceDB-performance') AND [sqlserver].[nt_domain]=N'mprokunin')),
ADD EVENT sqlserver.sql_statement_completed(SET collect_statement=(1)
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.context_info,sqlserver.database_name,sqlserver.is_system,sqlserver.nt_username,sqlserver.plan_handle,sqlserver.sql_text)
    WHERE ([sqlserver].[equal_i_sql_unicode_string]([sqlserver].[database_name],N'IrisInsuranceDB-performance') AND [sqlserver].[nt_domain]=N'mprokunin')),
ADD EVENT sqlserver.sql_statement_recompile(SET collect_object_name=(1),collect_statement=(1)
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.context_info,sqlserver.database_name,sqlserver.is_system,sqlserver.nt_username,sqlserver.plan_handle,sqlserver.sql_text)
    WHERE ([sqlserver].[equal_i_sql_unicode_string]([sqlserver].[database_name],N'IrisInsuranceDB-performance') AND [sqlserver].[nt_domain]=N'mprokunin')),
ADD EVENT sqlserver.sql_statement_starting(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.is_system,sqlserver.nt_username,sqlserver.plan_handle,sqlserver.sql_text)
    WHERE ([sqlserver].[equal_i_sql_unicode_string]([sqlserver].[database_name],N'IrisInsuranceDB-performance') AND [sqlserver].[nt_domain]=N'mprokunin'))
ADD TARGET package0.event_file(SET filename=N'G:\MSSQL13.MSSQLSERVER\MSSQL\PerfData\PlanCacheRemoval.xel')
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=ON,STARTUP_STATE=OFF)
GO


