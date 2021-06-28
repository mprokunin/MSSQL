use [master]
go
alter database [AUTO] set recovery simple  with rollback immediate
go

-- Очистить очередь писем от MSSQL (при необходиомсти)
exec msdb.dbo.sysmail_delete_mailitems_sp @sent_before =  '2020-12-25 04:20:00'
go
exec msdb.dbo.sysmail_stop_sp
go
exec msdb.dbo.sysmail_start_sp
go


-- Kill backuper if running (also check and kill old jobs at COMMVAULT)
select top 500 db_name(dbid) as 'DB',loginame, * from sys.sysprocesses where cmd like '%BACKUP%' 
go
exec sp_who [RIMOS_NT_01\backoper]
go
--
--kill 209
go

-- Kill old backup jobs at COMMVAULT except FULL backup
USE [AUTO]
GO
DBCC SHRINKFILE (N'AUTO_log' , 0, TRUNCATEONLY)
GO
alter database [AUTO] set recovery full with rollback immediate
go

-- Resume FULL at COMMVAULT
-- Check if backuper is running
sp_helpdb [AUTO]
go
select top 500 db_name(dbid) as 'DB',loginame, * from sys.sysprocesses where cmd like '%BACKUP%'  -- 1 642 979 608
go
exec sp_who [RIMOS_NT_01\backoper]
go
-- Check free space in log of AUTO
exec msdb..sp__dbinfo 1
go
-- Check free space at drive
exec xp_fixeddrives
go

-- Get VLF Counts for all databases on the instance (Query 33) (VLF Counts)
SELECT [name] AS [Database Name], [VLF Count]
FROM sys.databases AS db WITH (NOLOCK)
CROSS APPLY (SELECT file_id, COUNT(*) AS [VLF Count]
		     FROM sys.dm_db_log_info(db.database_id)
			 GROUP BY file_id) AS li
ORDER BY [VLF Count] DESC OPTION (RECOMPILE);
------
