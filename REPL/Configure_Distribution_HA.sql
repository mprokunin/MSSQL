-- Configure Distribution in AG
:connect tsql03\REPL
-- Connect to Distributor (primary node)

-- Configure current server (tsql03\bo) as distributor
USE master;  
GO
--exec sp_dropdistributor @no_checks = 1, @ignore_distributor = 1
-- sp_helpdistpublisher   
--exec master.dbo.sp_serveroption @server=N'TSQL03\SQL2008', @optname=N'dist', @optvalue=N'true'
--sp_dropdistributiondb @database= 'distribution'  
--select * from sysprocesses where dbid = db_id('distribution')
--kill 69
--exec sp_dropdistributor @no_checks = 0, @ignore_distributor=0
-- sp_who distributor_admin
-- kill 60
--sp_droplogin distributor_admin
--select @@servername
EXEC sys.sp_adddistributor  
    @distributor = 'tsql03\REPL',  
    @password = 'xxxxxxxxxxxxxxxxx'; 


-- Add Distribution Database at Distributor
USE master;  
GO  
EXEC sys.sp_adddistributiondb  
    @database = 'distribution',  
	@data_folder = 'E:\REPL',
	@data_file = 'distribution.mdf',
	@log_folder = 'E:\REPL',
	@log_file = 'distribution.ldf',
--	@login = 'dist_login',
--	@password = '12345678',
	@max_distretention = 200,		-- 200 hours
	@history_retention = 400,		-- 400 hours
	@deletebatchsize_xact = 10000,	-- 2016
	@deletebatchsize_cmd = 4000,	-- 2016
	@security_mode = 1;	

alter database distribution set recovery full;

EXEC sys.sp_replicationdboption  
    @dbname = 'distribution',  
    @optname = 'sync with backup',  
    @value = 'true';  
select DATABASEPROPERTYEX ( 'distribution', 'IsSyncWithBackup' )  

EXEC sys.sp_adddistpublisher  
    @publisher = 'tsql03\sql2008',  
    @distribution_db = 'distribution',  
    @working_directory = '\\tsql03\repldata',  
	@security_mode = 1 

EXEC sys.sp_adddistpublisher  
    @publisher = 'tsql05\sql2008',  
    @distribution_db = 'distribution',  
    @working_directory = '\\tsql03\repldata',  
	@security_mode = 1 

--sp_helpdistpublisher




:connect tsql05\REPL

--select @@servername
use master;
--exec sp_dropdistributor @no_checks = 1 , @ignore_distributor = 1

EXEC sys.sp_adddistributor  
    @distributor = 'tsql05\REPL',  
    @password = 'xxxxxxxxxxxxxxxx'; 


------------------------
-- Backup distribution DB and put in to AG group t2hadr


----------------------
:connect tsql05\REPL
-- Connect to secondary replica, FAILOVER!!!

EXEC sp_adddistributiondb 'distribution';

EXEC sys.sp_adddistpublisher  
    @publisher = 'tsql03\sql2008',  
    @distribution_db = 'distribution',  
    @working_directory = '\\tsql03\repldata',  
	@security_mode = 1 

EXEC sys.sp_adddistpublisher  
    @publisher = 'tsql05\sql2008',  
    @distribution_db = 'distribution',  
    @working_directory = '\\tsql03\repldata',  
	@security_mode = 1 

-- Linked servers have beem created



--------------------------------------------
-- Publications
--------------------------------------------
:connect tsql03\SQL2008
-- Connect to publisher (active node)
USE master;  
GO  

--Configure the publisher at the original publisher (tsql03\sql2008)

--exec sp_dropdistributor @no_checks = 1, @ignore_distributor = 1

EXEC sys.sp_adddistributor  
    @distributor = 't2hadr',  
    @password = 'Hfcghjcnhfybntkm'; 
-- You have updated the Publisher property 'active' successfully.



:connect tsql05\SQL2008
-- Connect to publisher (no need to failober to pavssive node)
USE master;  
GO  

--Configure the publisher at the original publisher (tsql03\sql2008)
--exec sp_dropdistributor @no_checks = 1, @ignore_distributor = 1

EXEC sys.sp_adddistributor  
    @distributor = 't2hadr',  
    @password = 'Hfcghjcnhfybntkm'; 
-- You have updated the Publisher property 'active' successfully.


-- Mark Database for publication
:connect tsql03\SQL2008
--EXEC sys.sp_replicationdboption @dbname = 'TDB', @optname = 'publish', @value = 'false';  
use master;
EXEC sys.sp_replicationdboption  
    @dbname = 'TDB',  
    @optname = 'publish',  
    @value = 'true';  

EXEC sys.sp_replicationdboption  
    @dbname = 'TDB',  
    @optname = 'merge publish',  
    @value = 'true';  
-- Command(s) completed successfully.

EXEC sys.sp_replicationdboption  
    @dbname = 'TDB',  
    @optname = 'sync with backup',  
    @value = 'false';   -- False - do not wait for log backup


---------------------------------------------------------------------------
-- Create the replication publication, articles
-- Adding the transactional publication
use [TDB];
-- @allow_initialize_from_backup = N'true', @immediate_sync = N'false',
exec sp_addpublication @publication = N'TDB_Pub', 
	@description = N'Transactional publication of database ''TDB'' from Publisher ''TSQL03\SQL2008''.', 
	@sync_method = N'concurrent', @retention = 0, @allow_push = N'true', @allow_pull = N'true', @allow_anonymous = N'false', 
	@enabled_for_internet = N'false', @snapshot_in_defaultfolder = N'true', @compress_snapshot = N'false', @ftp_port = 21, 
	@allow_subscription_copy = N'false', @add_to_active_directory = N'false', @repl_freq = N'continuous', @status = N'active', 
	@independent_agent = N'true', @immediate_sync = N'false', @allow_sync_tran = N'false', @allow_queued_tran = N'false', 
	@allow_dts = N'false', @replicate_ddl = 1, @allow_initialize_from_backup = N'true', @enabled_for_p2p = N'false', 
	@enabled_for_het_sub = N'false';
--Job 'TSQL03\SQL2008-TDB-1' started successfully.
--Warning: The logreader agent job has been implicitly created and will run under the SQL Server Agent Service Account.

--Create the Snapshot Agent for the specified publication.
exec sp_addpublication_snapshot 
	@publication = N'TDB_Pub', 
	@frequency_type = 1, 
	@frequency_interval = 1, 
	@frequency_relative_interval = 1, 
	@frequency_recurrence_factor = 0, 
	@frequency_subday = 8, 
	@frequency_subday_interval = 1, 
	@active_start_time_of_day = 0, 
	@active_end_time_of_day = 235959, 
	@active_start_date = 0, 
	@active_end_date = 0, 
	@job_login = null, 
	@job_password = null, 
	@publisher_security_mode = 1
-- Commands completed successfully.
-- Job TSQL03\SQL2008-TDB-TDB_Pub-1 will be created on Distributor

-- Add articles (tables etc)
use [TDB]
exec sp_addarticle @publication = N'TDB_Pub', @article = N'Table_1', @source_owner = N'dbo', @source_object = N'Table_1', @type = N'logbased', @description = N'', @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'Table_1', @destination_owner = N'dbo', @vertical_partition = N'true', @ins_cmd = N'CALL sp_MSins_dboTable_1', @del_cmd = N'CALL sp_MSdel_dboTable_1', @upd_cmd = N'SCALL sp_MSupd_dboTable_1'
-- Commands completed successfully.

-- Adding the article's partition column(s)
exec sp_articlecolumn @publication = N'TDB_Pub', @article = N'Table_1', @column = N'col1', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1;

exec sp_articlecolumn @publication = N'TDB_Pub', @article = N'Table_1', @column = N'col2', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1;

-- Commands completed successfully.

-- Adding the article synchronization object
exec sp_articleview @publication = N'TDB_Pub', @article = N'Table_1', @view_name = N'SYNC_Table_1_1__61', @filter_clause = null, @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
GO




-- Create subscriptions (with manual init)
-----------------BEGIN: Script to be run at Publisher 'TSQL03\SQL2008'-----------------
use [TDB]
--exec sp_dropsubscription @publication = N'TDB_Pub', @subscriber = N'tsql05\bo', @destination_db = N'TDB', @article = N'all'
GO

exec sp_addsubscription @publication = N'TDB_Pub', @subscriber = N'tsql03\bo', @destination_db = N'TDB', 
	@sync_type = N'replication support only', @subscription_type = N'pull', @update_mode = N'read only'
GO
--Commands completed successfully.








----------------BEGIN: Script to be run at Subscriber 'tsql03\bo'-----------------
:connect TSQL03\BO

use [TDB];
--sp_removedbreplication
--exec sp_droppullsubscription @publisher = N'TSQL03\SQL2008', @publisher_db = N'TDB', @publication = N'TDB_Pub'

--exec sp_addpullsubscription @publisher = N'testhadr', @publication = N'TDB_Pub', @publisher_db = N'TDB', @independent_agent = N'True', @subscription_type = N'pull', @description = N'', @update_mode = N'read only', @immediate_sync = 0
exec sp_addpullsubscription @publisher = N'TSQL03\SQL2008', @publication = N'TDB_Pub', @publisher_db = N'TDB', @independent_agent = N'True', @subscription_type = N'pull', @description = N'', @update_mode = N'read only', @immediate_sync = 0

--exec sp_addpullsubscription_agent @publisher = N'testhadr', @publisher_db = N'TDB', @publication = N'TDB_Pub', @distributor = N'TSQL03\BO', @distributor_security_mode = 1, @distributor_login = N'', @distributor_password = null, @enabled_for_syncmgr = N'False', @frequency_type = 64, @frequency_interval = 0, @frequency_relative_interval = 0, @frequency_recurrence_factor = 0, @frequency_subday = 0, @frequency_subday_interval = 0, @active_start_time_of_day = 0, @active_end_time_of_day = 235959, @active_start_date = 20190508, @active_end_date = 99991231, @alt_snapshot_folder = N'', @working_directory = N'', @use_ftp = N'False', @job_login = null, @job_password = null, @publication_type = 0
exec sp_addpullsubscription_agent @publisher = N'TSQL03\SQL2008', @publisher_db = N'TDB', @publication = N'TDB_Pub', @distributor = N't2hadr', @distributor_security_mode = 1, @distributor_login = N'', @distributor_password = null, @enabled_for_syncmgr = N'False', @frequency_type = 64, @frequency_interval = 0, @frequency_relative_interval = 0, @frequency_recurrence_factor = 0, @frequency_subday = 0, @frequency_subday_interval = 0, @active_start_time_of_day = 0, @active_end_time_of_day = 235959, @active_start_date = 20190508, @active_end_date = 99991231, @alt_snapshot_folder = N'', @working_directory = N'', @use_ftp = N'False', @job_login = null, @job_password = null, @publication_type = 0
/*
exec sp_addpullsubscription_agent 
	@publisher = N'TSQL03\SQL2008', @publisher_db = N'TDB', 
	@publication = N'TDB_Pub', 
	@distributor = N't2hadr', 
	@distributor_security_mode = 0, @distributor_login = N'distributor_admin', @distributor_password = 'Hfcghjcnhfybntkm', 
	@enabled_for_syncmgr = N'False', 
	@frequency_type = 64, 
	@frequency_interval = 0, @frequency_relative_interval = 0, @frequency_recurrence_factor = 0, @frequency_subday = 0, 
	@frequency_subday_interval = 0, 
	@active_start_time_of_day = 0, 
	@active_end_time_of_day = 235959, 
	@active_start_date = 20190508, @active_end_date = 99991231, @alt_snapshot_folder = N'', @working_directory = N'', 
	@use_ftp = N'False', @job_login = null, @job_password = null, @publication_type = 0
GO
*/
--Job 'TSQL03\SQL2008-TDB-TDB_Pub-TSQL03\BO-TDB-8285EA0C-6261-4708-8B84-EA5E0D82453D' started successfully. (at subscriber)
-----------------END: Script to be run at Subscriber 'tsql03\bo'-----------------






-------------------------------------------------
-- Configure HA for Publisher
-------------------------------------------------
/*
:connect tsql05\SQL2008
-- Connect to secondary replica host (passive node)
-- Configure the publisher at the original publisher (tsql05\sql2008)

*/
-- You have updated the Publisher property 'active' successfully.



:connect tsql03\REPL
-- At active node of distributor
-- Redirect the Original Publisher to the AG Listener Name
EXEC sys.sp_addlinkedserver   
    @server = 'tsql03\bo';  


USE distribution;  
GO  
EXEC sys.sp_redirect_publisher   
@original_publisher = 'tsql03\sql2008',  
    @publisher_db = 'TDB',  
    @redirected_publisher = 'testhadr';  




USE distribution;  
GO  

-- Run the Replication Validation Stored Procedure to Verify the Configuration
/*
DECLARE @redirected_publisher sysname;  
EXEC sys.sp_validate_replica_hosts_as_publishers  
    @original_publisher = 'tsql03\sql2008',  
    @publisher_db = 'TDB',  
    @redirected_publisher = @redirected_publisher output;
select @redirected_publisher 
*/
-- 
Select * From MSRedirected_Publishers;
--original_publisher	publisher_db	redirected_publisher
--tsql03\sql2008		TDB				testhadr
 
 -- Run locally at Dsitributor
use distribution;
exec sp_get_redirected_publisher @original_publisher = 'tsql03\sql2008',  
    @publisher_db = 'TDB',  
	@bypass_publisher_validation = 0;

--redirected_publisher	error_number	error_severity	error_message
--testhadr				0				0				NULL

/*
exec sp_get_redirected_publisher @original_publisher = 'tsql05\sql2008',  
    @publisher_db = 'TDB',  
	@bypass_publisher_validation = 0;

*/
 
use distribution;
DECLARE @redirected_publisher sysname;  
EXEC sys.sp_validate_redirected_publisher   
    @original_publisher = 'tsql03\sql2008',  
    @publisher_db = 'TDB',  
    @redirected_publisher = @redirected_publisher output;
select @redirected_publisher;
--testhadr
 
--- 
-- Run locally on distributor!!!
use distribution;
DECLARE @redirected_publisher sysname;  
exec sp_validate_replica_hosts_as_publishers   
    @original_publisher =  'tsql03\sql2008',  
	@publisher_db =  'TDB',   
    @redirected_publisher =  @redirected_publisher output  
select @redirected_publisher;
--testhadr


--(1 row affected)



-- Remove replication on tsql03\sql2008
--use TDB
--exec sp_removedbreplication


EXEC sp_helpdistributiondb;  

