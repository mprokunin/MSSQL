-- select @@SERVERNAME -- REN-MSKSQL19
--use [IrisInsuranceDB-performance]
--select * from sys.objects where name like '%AgrLoadById_TravelInsuranceProcessBasket_Opt_191209151119%' 
CREATE EVENT SESSION PlanCacheRemoval
ON SERVER
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

ADD EVENT sqlserver.rpc_starting
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


---Test
exec AgrLoadById_TravelInsuranceProcessBasket_Opt_191209151119 1764800,0