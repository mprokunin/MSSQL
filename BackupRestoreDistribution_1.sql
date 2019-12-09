BACKUP DATABASE [t2] TO  
DISK = N'E:\Backup\t2.bak' WITH NOFORMAT, NOINIT,  
NAME = N't2-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO
BACKUP LOG [t2] TO  
DISK = N'E:\Backup\t2.trn'
WITH NOFORMAT, NOINIT,  NAME = N't2-Log Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO

BACKUP DATABASE [distribution] TO  
DISK = N'E:\Backup\distribution.bak' WITH NOFORMAT, NOINIT,  
NAME = N'disribution-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO
BACKUP LOG [distribution] TO  
DISK = N'E:\Backup\distribution.trn'
WITH NOFORMAT, NOINIT,  NAME = N'distribution-Log Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO



:connect new node
EXEC sys.sp_adddistributor  
    @distributor = 'SQL105\REPL',  
    @password = 'Hfcghjcnhfybntkm'; -- see distributor_admin pass in Keepas


sp_adddistributiondb 'distribution'

USE [master]
RESTORE DATABASE [distribution] FROM  
DISK = N'E:\Backup\distribution.bak' WITH  FILE = 1,  
MOVE N'distribution' TO N'J:\REP_FDAT\distribution.mdf',  
MOVE N'distribution_log' TO N'R:\REP_FLOG\distribution.ldf',  
NORECOVERY,  NOUNLOAD,  REPLACE,  STATS = 5
GO

RESTORE LOG [distribution] FROM  
DISK = N'E:\backup\distribution2019-09-01_11_05_00.trn' WITH  FILE = 1,  
NORECOVERY,  NOUNLOAD,  REPLACE,  STATS = 5
GO

:Connect SQL205\REPL


-- Wait for the replica to start communicating
begin try
declare @conn bit
declare @count int
declare @replica_id uniqueidentifier 
declare @group_id uniqueidentifier
set @conn = 0
set @count = 30 -- wait for 5 minutes 

if (serverproperty('IsHadrEnabled') = 1)
	and (isnull((select member_state from master.sys.dm_hadr_cluster_members where upper(member_name COLLATE Latin1_General_CI_AS) = upper(cast(serverproperty('ComputerNamePhysicalNetBIOS') as nvarchar(256)) COLLATE Latin1_General_CI_AS)), 0) <> 0)
	and (isnull((select state from master.sys.database_mirroring_endpoints), 1) = 0)
begin
    select @group_id = ags.group_id from master.sys.availability_groups as ags where name = N'REPHADR'
	select @replica_id = replicas.replica_id from master.sys.availability_replicas as replicas where upper(replicas.replica_server_name COLLATE Latin1_General_CI_AS) = upper(@@SERVERNAME COLLATE Latin1_General_CI_AS) and group_id = @group_id
	while @conn <> 1 and @count > 0
	begin
		set @conn = isnull((select connected_state from master.sys.dm_hadr_availability_replica_states as states where states.replica_id = @replica_id), 1)
		if @conn = 1
		begin
			-- exit loop when the replica is connected, or if the query cannot find the replica status
			break
		end
		waitfor delay '00:00:10'
		set @count = @count - 1
	end
end
end try
begin catch
	-- If the wait loop fails, do not stop execution of the alter database statement
end catch
ALTER DATABASE [Distribution] SET HADR AVAILABILITY GROUP = [REPHADR];
go

--EXEC sp_adddistributiondb 'distribution';


EXEC sys.sp_adddistpublisher  
    @publisher = 'AL-SQL05\BO',  
    @distribution_db = 'distribution',  
    @working_directory = '\\AL-SQL03\repldata',  
	@security_mode = 1 

EXEC sys.sp_adddistpublisher  
    @publisher = 'AL-SQL05\SQL02',  
    @distribution_db = 'distribution',  
    @working_directory = '\\AL-SQL03\repldata',  
	@security_mode = 1 

	
EXEC sys.sp_adddistpublisher  
    @publisher = 'SQL105\AB',  
    @distribution_db = 'distribution',  
    @working_directory = '\\AL-SQL03\repldata',  
	@security_mode = 1 

EXEC sys.sp_adddistpublisher  
    @publisher = 'SQL205\AB',  
    @distribution_db = 'distribution',  
    @working_directory = '\\AL-SQL03\repldata',  
	@security_mode = 1 
EXEC sys.sp_adddistpublisher  
    @publisher = 'AL-SQL03\AOLFRONT\MIF',  
    @distribution_db = 'distribution',  
    @working_directory = '\\AL-SQL03\repldata',  
	@security_mode = 1 

EXEC sys.sp_adddistpublisher  
    @publisher = 'SQL105\MIF',  
    @distribution_db = 'distribution',  
    @working_directory = '\\AL-SQL03\repldata',  
	@security_mode = 1 

EXEC sys.sp_adddistpublisher  
    @publisher = 'SQL205\MIF',  
    @distribution_db = 'distribution',  
    @working_directory = '\\AL-SQL03\repldata',  
	@security_mode = 1 
-- Linked servers have beem created

