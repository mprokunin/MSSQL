--------------------------------------------------------------------------------- 
---------- Backup History
SELECT top 1000
CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS Server, 
msdb.dbo.backupset.database_name, master.sys.databases.recovery_model_desc,
msdb.dbo.backupset.backup_start_date, 
msdb.dbo.backupset.backup_finish_date, 
msdb.dbo.backupset.expiration_date, 
CASE msdb..backupset.type 
WHEN 'D' THEN 'Database' 
WHEN 'I' THEN 'Differential database' 
WHEN 'L' THEN 'Log' 
WHEN 'F' THEN 'File or filegroup'
WHEN 'G' THEN 'Differential file'
WHEN 'P' THEN 'Partial'
WHEN 'Q' THEN 'Differential partial'
END AS backup_type, 
msdb.dbo.backupset.backup_size, msdb.dbo.backupset.compressed_backup_size, 
msdb.dbo.backupmediafamily.logical_device_name, 
msdb.dbo.backupmediafamily.physical_device_name, 
msdb.dbo.backupset.name AS backupset_name, 
msdb.dbo.backupset.description 
FROM msdb.dbo.backupmediafamily 
INNER JOIN msdb.dbo.backupset ON msdb.dbo.backupmediafamily.media_set_id = msdb.dbo.backupset.media_set_id 
INNER JOIN master.sys.databases on msdb.dbo.backupset.database_name = master.sys.databases.name
WHERE 1=1 --and (convert(date, msdb.dbo.backupset.backup_start_date, 102) >= GETDATE() - 7) 
--and msdb.dbo.backupset.database_name like 'EOSAGO_LOG'  
--and msdb.dbo.backupset.database_name like 'IrisInsuranceDB'  
--and msdb.dbo.backupset.database_name like 'xbrl_tax32%' 
--and msdb.dbo.backupset.database_name like 'jira_update_latin_v8%' 
--and msdb..backupset.type = 'D'
--and description like 'Streaming Full Copy Only%'
--and msdb.dbo.backupmediafamily.physical_device_name like '0135148b-9e30-4d7d-ae70-adc2c433c1af%'
ORDER BY 
--msdb.dbo.backupset.database_name, 
--msdb.dbo.backupset.backup_finish_date desc
msdb.dbo.backupset.backup_start_date desc


--------------------------------------------------------------------------------- 
sp_helpdb
exec sp_who [RIMOS_NT_01\backoper]
------------- %% Complete
SELECT session_id as SPID, command, a.text AS Query, start_time, percent_complete, dateadd(second,estimated_completion_time/1000, getdate()) as estimated_completion_time 
	FROM sys.dm_exec_requests r CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) a -- WHERE r.command in ('BACKUP DATABASE','RESTORE DATABASE')
------------- 

exec sp_whoisactive 88
select * from master..sysprocesses where spid=128
--kill  67
alter database [DI_STAT] set recovery simple with rollback immediate

exec sp_who [RIMOS_NT_01\mprokunin]
--alter login [RIMOS_NT_01\backoper] disable
sp_helplogins [RIMOS_NT_01\backoper]
alter login [RIMOS_NT_01\backoper] enable
select @@SERVERNAME

select login_time,* from master..sysprocesses where loginame = 'RIMOS_NT_01\backoper'
select login_time,* from master..sysprocesses where loginame = 'RIMOS_NT_01\mprokunin'
select login_time,* from master..sysprocesses where dbid=5 and cmd <> 'AWAITING COMMAND'
select name, log_reuse_wait_desc, * from master.sys.databases order by 1
sp_who 63
exec xp_fixeddrives
exec msdb..sp__dbinfo 1
--------------------------------------------------------------------------------- 
dbcc opentran(DWH_ACT_PREP)
select * from master..sysprocesses where spid = 185
select * from master..sysprocesses where loginame <> 'sa'

dbcc inputbuffer(128)
exec msdb..sp__dbinfo 1
sp_helpdb
alter database DI_STAT add file 
--------------------------------------------------------------------------------- 
-- LSN
SELECT 
s.database_name,
CAST(CAST(s.backup_size / 1000000 AS INT) AS VARCHAR(14)) + ' ' + 'MB' AS bkSize,
CAST(DATEDIFF(second, s.backup_start_date,
s.backup_finish_date) AS VARCHAR(4)) + ' ' + 'Seconds' TimeTaken,
s.backup_start_date,
CAST(s.first_lsn AS VARCHAR(50)) AS first_lsn,
CAST(s.last_lsn AS VARCHAR(50)) AS last_lsn,
CAST(s.database_backup_lsn AS VARCHAR(50)) AS database_backup_lsn,
CAST(s.checkpoint_lsn AS VARCHAR(50)) AS checkpoint_lsn,
CASE s.[type] WHEN 'D' THEN 'Full'
WHEN 'I' THEN 'Differential'
WHEN 'L' THEN 'Transaction Log'
END AS BackupType,
s.recovery_model
FROM msdb.dbo.backupset s
INNER JOIN msdb.dbo.backupmediafamily m ON s.media_set_id = m.media_set_id
WHERE s.database_name = 'EOSAGO_LOG'-- DB_NAME() 
ORDER BY backup_start_date DESC, backup_finish_date
GO

---------- Which Databases have no Backup History
SELECT top 200 
CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS Server, 
sd.name,
bs.database_name, 
bs.backup_start_date, 
bs.backup_finish_date, 
bs.expiration_date, 
CASE bs.type 
WHEN 'D' THEN 'Database' 
WHEN 'I' THEN 'Differential database' 
WHEN 'L' THEN 'Log' 
WHEN 'F' THEN 'File or filegroup'
WHEN 'G' THEN 'Differential file'
WHEN 'P' THEN 'Partial'
WHEN 'Q' THEN 'Differential partial'
END AS backup_type, 
bs.backup_size, bs.compressed_backup_size, 
msdb.dbo.backupmediafamily.logical_device_name, 
msdb.dbo.backupmediafamily.physical_device_name, 
bs.name AS backupset_name, 
bs.description 
FROM master.sys.databases sd
LEFT OUTER JOIN msdb.dbo.backupset bs on sd.name = bs.database_name
INNER JOIN msdb.dbo.backupmediafamily ON msdb.dbo.backupmediafamily.media_set_id = bs.media_set_id 
WHERE 1=1 --and (convert(date, bs.backup_start_date, 102) >= GETDATE() - 7) 
--and bs.database_name ='master'
and bs.database_name like 'IrisInsuranceDB-performance'
--and msdb..backupset.type = 'D'
--and description like 'Streaming Full Copy Only%'
ORDER BY 
--sd.name
--bs.backup_finish_date desc
bs.backup_start_date desc


select * from msdb.dbo.backupset

---------------------------
--------------------------------------------------------------------------------- 
---------- Was Last Full or Diff Backup done in two Weeks
SELECT top 1000
msdb.dbo.backupset.database_name as DBName, master.sys.databases.state_desc as DB_Status,
--max(msdb.dbo.backupset.backup_finish_date), 
case when datediff(dd, max(msdb.dbo.backupset.backup_finish_date), getdate()) < 14
then 'Yes'
else 'No'
end
FROM msdb.dbo.backupmediafamily 
INNER JOIN msdb.dbo.backupset ON msdb.dbo.backupmediafamily.media_set_id = msdb.dbo.backupset.media_set_id 
INNER JOIN master.sys.databases on msdb.dbo.backupset.database_name = master.sys.databases.name
WHERE 1=1 
--and msdb.dbo.backupset.database_name like 'P_HRM3'
and msdb..backupset.type in( 'D', 'I')
--and physical_device_name like 'quik_sql_cod_arch_00__aecdfcac_55e7_4bc9_ae89_fff257c3d946%'
group by msdb.dbo.backupset.database_name, master.sys.databases.state_desc
ORDER BY msdb.dbo.backupset.database_name


select datediff(dd, max(msdb.dbo.backupset.backup_finish_date), getdate())

-- Who keep the log from truncation
select name, log_reuse_wait, log_reuse_wait_desc, is_cdc_enabled from sys.databases order by 1
SELECT name, log_reuse_wait, log_reuse_wait_desc, is_cdc_enabled FROM sys.databases WHERE name = 'AtonBase';

exec msdb..sp__dbinfo 1

RESTORE LOG AdventureWorks FROM DISK = 'c:\adventureworks_log.bak'   
WITH STOPATMARK = 'lsn:15000000040000037'  
GO  

SELECT DATABASEPROPERTYEX('AtonBase', 'IsPublished');
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
exec AtonBase..sp_repltrans 
exec AtonBase..sp_replcmds @maxtrans = 10


select @@SERVERNAME

sp__helplogins [icaton\crsservice]
sp_who [rimos_nt_01\backoper]
--kill 612
sp_who 462
restore database [IrisFilesDB-performance]

select * from sys.sysprocesses where spid=63

------------- %% Complete
SELECT session_id as SPID, command, a.text AS Query, start_time, percent_complete, dateadd(second,estimated_completion_time/1000, getdate()) as estimated_completion_time 
	FROM sys.dm_exec_requests r CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) a WHERE r.command in ('BACKUP DATABASE','RESTORE DATABASE')
------------- 

dbcc inputbuffer(612) -- BACKUP DATABASE [AtonBase] TO virtual_device = 'AtonBase_00__6df75fe7_f275_419c_915b_72a4a737b8a2_' WITH name = 'Backup Exec SQL Server Agent', description = 'Streaming Full', CHECKSUM, COMPRESSION
dbcc inputbuffer(189) -- BACKUP DATABASE [Cuts] TO virtual_device = 'Cuts_00__7c55e1ff_800f_4777_bfff_431dd9e00111_' WITH name = 'Backup Exec SQL Server Agent', description = 'Streaming Full', CHECKSUM, COMPRESSION
dbcc inputbuffer(211) -- (@_msparam_0 nvarchar(4000))        select * into #tmpag_availability_groups from master.sys.availability_groups                   select group_id, replica_id, replica_server_name,create_date, modify_date, endpoint_url, read_only_routing_url, primary_role_allow_connections, secondary_role_allow_connections, availability_mode,failover_mode, session_timeout, backup_priority, owner_sid, seeding_mode into #tmpar_availability_replicas from master.sys.availability_replicas                  select group_id, replica_id, role,operational_state,recovery_health,synchronization_health,connected_state, last_connect_error_number,last_connect_error_description, last_connect_error_timestamp into #tmpar_availability_replica_states from master.sys.dm_hadr_availability_replica_states                select * into #tmpar_ags from master.sys.dm_hadr_availability_group_states        select ar.group_id, ar.replica_id, ar.replica_server_name, ar.availability_mode, (case when UPPER(ags.primary_replica) = UPPER(ar.replica_server_name) then 1 else 0 end) as role, ars.synchronization_health into #tmpar_availabilty_mode from #tmpar_availability_replicas as ar        left join #tmpar_ags as ags on ags.group_id = ar.group_id        left join #tmpar_availability_replica_states as ars on ar.group_id = ars.group_id and ar.replica_id = ars.replica_id        select am1.replica_id, am1.role, (case when (am1.synchronization_health is null) then 3 else am1.synchronization_health end) as sync_state, (case when (am1.availability_mode is NULL) or (am3.availability_mode is NULL) then null when (am1.role = 1) then 1 when (am1.availability_mode = 0 or am3.availability_mode = 0) then 0 else 1 end) as effective_availability_mode        into #tmpar_replica_rollupstate from #tmpar_availabilty_mode as am1 left join (select group_id, role, availability_mode from #tmpar_availabilty_mode as am2 where am2.role = 1) as am3 on am1.group_id = am3.group_id        drop table #tmpar_availabilty_mode        drop table #tmpar_ags                select replica_id,join_state into #tmpar_availability_replica_cluster_states from master.sys.dm_hadr_availability_replica_cluster_states         SELECT AR.replica_server_name AS [Name], 'Server[@Name=' + quotename(CAST(          serverproperty(N'Servername')         AS sysname),'''') + ']' + '/AvailabilityGroup[@Name=' + quotename(AG.name,'''') + ']' + '/AvailabilityReplica[@Name=' + quotename(AR.replica_server_name,'''') + ']' AS [Urn], ISNULL(arstates.role, 3) AS [Role], ISNULL(AR.primary_role_allow_connections, 4) AS [ConnectionModeInPrimaryRole], ISNULL(AR.secondary_role_allow_connections, 3) AS [ConnectionModeInSecondaryRole], ISNULL(arstates.connected_state, 2) AS [ConnectionState], (case when arrollupstates.sync_state = 3 then 3 when (arrollupstates.effective_availability_mode = 1 or arrollupstates.role = 1) then arrollupstates.sync_state when arrollupstates.sync_state = 2 then 1 else 0 end) AS [RollupSynchronizationState], ISNULL(arcs.join_state, 99) AS [JoinState] FROM #tmpag_availability_groups AS AG INNER JOIN #tmpar_availability_replicas AS AR ON (AR.replica_server_name IS NOT NULL) AND (AR.group_id=AG.group_id) LEFT OUTER JOIN #tmpar_availability_replica_states AS arstates ON AR.replica_id = arstates.replica_id LEFT OUTER JOIN #tmpar_replica_rollupstate AS arrollupstates ON AR.replica_id = arrollupstates.replica_id LEFT OUTER JOIN #tmpar_availability_replica_cluster_states AS arcs ON AR.replica_id = arcs.replica_id WHERE (AG.name=@_msparam_0) ORDER BY [Name] ASC         DROP TABLE #tmpar_availability_replicas                DROP TABLE #tmpar_availability_replica_states                DROP TABLE #tmpar_replica_rollupstate                DROP TABLE #tmpar_availability_replica_cluster_states                drop table #tmpag_availability_groups        

select @@SERVERNAME
sp_helpdb d_ner
exec xp_fixeddrives
exec msdb..sp__dbinfo 1
dbcc opentran(AtonBase)
exec msdb..sp__dbinfo


backup database [IrisFilesDB] TO  
disk='E:\TMP\IrisFilesDB.bak'
with COMPRESSION, STATS=5 
go
USE [master]
RESTORE DATABASE [IrisFilesDB-performance] 
FROM  DISK = N'E:\TMP\IrisFilesDB.bak' WITH  FILE = 1,  
MOVE N'IrisFilesDB' TO N'E:\IrisFilesDB-performance.mdf',  
MOVE N'IrisFilesDB_log' TO N'F:IrisFilesDB-performance_log.ldf',  
MOVE N'FileStreamData' TO N'E:IrisFilesDB-performance',  NOUNLOAD,  STATS = 5, REPLACE
GO

USE [AtonBase]
GO
DBCC SHRINKFILE (N'AtonBase_Log' , 0, TRUNCATEONLY)
GO

-- Get VLF Counts for all databases on the instance (Query 34) (VLF Counts)
SELECT [name] AS [Database Name], [VLF Count] 
FROM sys.databases AS db WITH (NOLOCK)
CROSS APPLY (SELECT file_id, COUNT(*) AS [VLF Count] 
			 FROM sys.dm_db_log_info(db.database_id) 
             GROUP BY file_id) AS li
ORDER BY [VLF Count] DESC  OPTION (RECOMPILE);
------

exec msdb..sp__dbinfo 3
dbcc opentran(AtonBase)

------------ Restore history
DECLARE @dbname sysname, @days int
SET @dbname = NULL --substitute for whatever database name you want
SET @days = -30 --previous number of days, script will default to 30
SELECT
 rsh.destination_database_name AS [Database],
 rsh.user_name AS [Restored By],
 CASE WHEN rsh.restore_type = 'D' THEN 'Database'
  WHEN rsh.restore_type = 'F' THEN 'File'
  WHEN rsh.restore_type = 'G' THEN 'Filegroup'
  WHEN rsh.restore_type = 'I' THEN 'Differential'
  WHEN rsh.restore_type = 'L' THEN 'Log'
  WHEN rsh.restore_type = 'V' THEN 'Verifyonly'
  WHEN rsh.restore_type = 'R' THEN 'Revert'
  ELSE rsh.restore_type 
 END AS [Restore Type],
 rsh.restore_date AS [Restore Started],
 bmf.physical_device_name AS [Restored From], 
 rf.destination_phys_name AS [Restored To]
FROM msdb.dbo.restorehistory rsh
 INNER JOIN msdb.dbo.backupset bs ON rsh.backup_set_id = bs.backup_set_id
 INNER JOIN msdb.dbo.restorefile rf ON rsh.restore_history_id = rf.restore_history_id
 INNER JOIN msdb.dbo.backupmediafamily bmf ON bmf.media_set_id = bs.media_set_id
WHERE rsh.restore_date >= DATEADD(dd, ISNULL(@days, -30), GETDATE()) --want to search for previous days
AND destination_database_name = ISNULL(@dbname, destination_database_name) --if no dbname, then return all
and rsh.destination_database_name = 'IrisFilesDB-performance'
ORDER BY rsh.restore_history_id DESC
GO

select top 100 * from msdb.dbo.restorehistory
select top 100 * from msdb.dbo.sysjobhistory where run_date = '20200330'

----------------------
backup log Cuts to disk='X:\Backup\Cuts_2018072121_1009.trn'
with compression,copy_only

sp_helpdb 
select * from master..sysprocesses where dbid = DB_ID('IrisInsuranceDB-performance')
--kill 142
alter database [IrisInsuranceDB-performance] set multi_user with rollback immediate
alter login [iris-temporary] enable
sp_who [iris-temporary]
sp_who [rimos_nt_01\backoper]
select top 100 * from sys.sysprocesses where spid=83

dbcc opentran(ESBLOG)
select @@SERVERNAME
exec msdb..sp__dbinfo 

select name, recovery_model_desc, is_cdc_enabled, log_reuse_wait_desc,source_database_id,
	* from master.sys.databases order by 1
restore database [IrisFilesDB-performance]


use AtonBAse 
checkpoint

use AtonBase_copy
SELECT publisher,publisher_db,publication,time, distribution_agent,transaction_timestamp 
FROM dbo.MSreplication_subscriptions

USE mif
GO  
EXEC sys.sp_cdc_enable_db  
GO  
use mif
EXEC sys.sp_cdc_add_job 'capture'
EXEC sys.sp_cdc_drop_job 'capture'
EXEC sys.sp_cdc_add_job 'cleanup'
EXEC sys.sp_cdc_drop_job 'cleanup'

GO
EXEC sys.sp_cdc_disable_db  
GO
GO


select name, object_name(id) from syscolumns where name = 'msrepl_tran_version'

select * from sysobjects where repinfo > 0

select 278725965824/1024/1024/1024

select log_reuse_wait_desc, * from master.sys.databases order by name


--restore headeronly from disk='C:\BACKUP\CasePro_sys.bak'

restore database [IrisFilesDB-performance]