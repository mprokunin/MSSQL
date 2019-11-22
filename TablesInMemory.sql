-- In Memeory table sizes
use QUIK_DBM
go
SELECT object_name(object_id) AS Name, *  
FROM sys.dm_db_xtp_table_memory_stats
order by Name
GO


select name, delayed_durability_desc from sys.databases
alter database QUIK_DB set  delayed_durability = forced;

select top 1000 * from limit_cod$
sp_help '[dbo].[PLUGIN_PERMS_INFO]'
sp_help '[dbo].[PLUGIN_PERMS_INFO_old]'
