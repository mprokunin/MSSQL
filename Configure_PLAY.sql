:connect PLAYSERV303\SQL2012
-- Connect to Distributor
-- Configure current server (PLAYSERV303\SQL2012) as distributor
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
--

EXEC sys.sp_adddistributor  
    @distributor = 'PLAYSERV303\SQL2012',  
    @password = 'CbkmysqGfhjkm'; 
exec xp_fixeddrives

-- Add Distribution Database at Distributor
USE master;  
GO  
select @@VERSION -- 2016 SP2
EXEC sys.sp_adddistributiondb  
    @database = 'distribution',  
	@data_folder = 'E:\DATA',
	@data_file = 'distribution.mdf',
	@log_folder = 'E:\DATA',
	@log_file = 'distribution.ldf',
	@login = 'dist_login',
	@password = 'dist_pass',
	@max_distretention = 200,		-- 200 hours
	@history_retention = 400,		-- 400 hours
	@deletebatchsize_xact = 10000,
	@deletebatchsize_cmd = 4000,
	@security_mode = 0;				-- Sql Server Auth
--sp_helpdb distribution


-- Add remote publisher for primary node
USE master;  
GO  

--EXEC sys.sp_dropdistpublisher      @publisher = 'PLAYSERV01',  	@no_checks = 0,	@ignore_distributor = 1;
use [distribution] 
if (not exists (select * from sysobjects where name = 'UIProperties' and type = 'U ')) 
    create table UIProperties(id int) 
if (exists (select * from ::fn_listextendedproperty('SnapshotFolder', 'user', 'dbo', 'table', 'UIProperties', null, null))) 
    EXEC sp_updateextendedproperty N'SnapshotFolder', N'\\playserv01\e$\data\repldata', 'user', dbo, 'table', 'UIProperties'
else
    EXEC sp_addextendedproperty N'SnapshotFolder', N'\\playserv01\e$\data\repldata', 'user', dbo, 'table', 'UIProperties'
GO 

--sp_help UIProperties

-- create new publisher

EXEC sys.sp_adddistpublisher  
    @publisher = 'playserv01',  
    @distribution_db = 'distribution',  
    @working_directory = '\\playserv01\e$\DATA\repldata',  
	@security_mode = 0,
    @login = 'dist_login',  
    @password = 'dist_pass'; 

sp_helpdistributor
sp_helpdistpublisher


select PUBLISHINGSERVERNAME();
--PLAYSERV303\SQL2012




:connect PALYSERV01
-- Connect to publisher (active node)
--Configure the publisher at the original publisher (tsql03\sql2008)

--exec sp_dropdistributor @no_checks = 1, @ignore_distributor = 1
use master
go
EXEC sys.sp_adddistributor  
    @distributor = 'PLAYSERV303\SQL2012',  
    @password = 'CbkmysqGfhjkm'; 
-- You have updated the Publisher property 'active' successfully.

-- Enable database for replication
USE master;  
GO  
EXEC sys.sp_replicationdboption  
    @dbname = 'TSTDB',  
    @optname = 'publish',  
    @value = 'true';  

EXEC sys.sp_replicationdboption  
    @dbname = 'TSTDB',  
    @optname = 'merge publish',  
    @value = 'true';  
-- Command(s) completed successfully.



---------------------------------------------------------------------------
use [TSTDB]
exec sp_replicationdboption @dbname = N'TSTDB', @optname = N'publish', @value = N'true'
GO
use [TSTDB]
GO
sp_configure 'remote proc trans', 0
reconfigure with override

exec [TSTDB].sys.sp_addlogreader_agent @job_login = N'servicetest\sqluser', @job_password = 'rhbgnjuhfabz1', @publisher_security_mode = 1, @job_name = null
GO
-- Adding the transactional publication
use [TSTDB]
exec sp_addpublication @publication = N'TSTDB_Pub', @description = N'Transactional publication of database ''TSTDB'' from Publisher ''PLAYSERV01''.', @sync_method = N'concurrent', @retention = 0, @allow_push = N'true', @allow_pull = N'true', @allow_anonymous = N'false', @enabled_for_internet = N'false', @snapshot_in_defaultfolder = N'true', @compress_snapshot = N'false', @ftp_port = 21, @allow_subscription_copy = N'false', @add_to_active_directory = N'false', @repl_freq = N'continuous', @status = N'active', @independent_agent = N'true', @immediate_sync = N'false', @allow_sync_tran = N'false', @allow_queued_tran = N'false', @allow_dts = N'false', @replicate_ddl = 1, @allow_initialize_from_backup = N'false', @enabled_for_p2p = N'false', @enabled_for_het_sub = N'false'
GO


exec sp_addpublication_snapshot @publication = N'TSTDB_Pub', @frequency_type = 1, @frequency_interval = 1, @frequency_relative_interval = 1, @frequency_recurrence_factor = 0, @frequency_subday = 8, @frequency_subday_interval = 1, @active_start_time_of_day = 0, @active_end_time_of_day = 235959, @active_start_date = 0, @active_end_date = 0, @job_login = N'servicetest\sqluser', @job_password = null, @publisher_security_mode = 1


use [TSTDB]
exec sp_addarticle @publication = N'TSTDB_Pub', @article = N'tab1', @source_owner = N'dbo', @source_object = N'tab1', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'tab1', @destination_owner = N'dbo', @vertical_partition = N'true', @ins_cmd = N'CALL sp_MSins_dbotab1', @del_cmd = N'CALL sp_MSdel_dbotab1', @upd_cmd = N'SCALL sp_MSupd_dbotab1'

-- Adding the article's partition column(s)
exec sp_articlecolumn @publication = N'TSTDB_Pub', @article = N'tab1', @column = N'col1', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'TSTDB_Pub', @article = N'tab1', @column = N'col2', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1

-- Adding the article synchronization object
exec sp_articleview @publication = N'TSTDB_Pub', @article = N'tab1', @view_name = N'SYNC_tab1_1__256', @filter_clause = null, @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
GO







-- Create the replication publication, articles
-- Adding the transactional publication
use [TSTDB]
-- @allow_initialize_from_backup = N'true', @immediate_sync = N'false',
exec sp_addpublication 
	@publication = N'TST_Pub', 
	@description = N'Transactional publication of database ''TSTDB'' from Publisher ''PLAYSERV01''.', 
	@sync_method = N'concurrent', 
	@retention = 0, 
	@allow_push = N'true', 
	@allow_pull = N'true', 
	@allow_anonymous = N'false', 
	@enabled_for_internet = N'false', 
	@snapshot_in_defaultfolder = N'true', 
	@compress_snapshot = N'false', 
	@ftp_port = 21, 
	@allow_subscription_copy = N'false', 
	@add_to_active_directory = N'false', 
	@repl_freq = N'continuous', 
	@status = N'active', 
	@independent_agent = N'true', 
	@immediate_sync = N'false', 
	@allow_sync_tran = N'false', 
	@allow_queued_tran = N'false', 
	@allow_dts = N'false', 
	@replicate_ddl = 1, 
	@allow_initialize_from_backup = N'true', 
	@enabled_for_p2p = N'false', 
	@enabled_for_het_sub = N'false'
GO
--Job 'TSQL03\SQL2008-TDB-1' started successfully.
--Warning: The logreader agent job has been implicitly created and will run under the SQL Server Agent Service Account.

sp_helppublication


exec sp_addpublication_snapshot @publication = N'TDB_Pub', @frequency_type = 1, @frequency_interval = 1, @frequency_relative_interval = 1, @frequency_recurrence_factor = 0, @frequency_subday = 8, @frequency_subday_interval = 1, @active_start_time_of_day = 0, @active_end_time_of_day = 235959, @active_start_date = 0, @active_end_date = 0, @job_login = null, @job_password = null, @publisher_security_mode = 1


-- Add articles (tables etc)
use [TDB]
exec sp_addarticle @publication = N'TDB_Pub', @article = N'Table_1', @source_owner = N'dbo', @source_object = N'Table_1', @type = N'logbased', @description = N'', @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'Table_1', @destination_owner = N'dbo', @vertical_partition = N'true', @ins_cmd = N'CALL sp_MSins_dboTable_1', @del_cmd = N'CALL sp_MSdel_dboTable_1', @upd_cmd = N'SCALL sp_MSupd_dboTable_1'

-- Adding the article's partition column(s)
exec sp_articlecolumn @publication = N'TDB_Pub', @article = N'Table_1', @column = N'col1', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'TDB_Pub', @article = N'Table_1', @column = N'col2', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1

-- Adding the article synchronization object
exec sp_articleview @publication = N'TDB_Pub', @article = N'Table_1', @view_name = N'SYNC_Table_1_1__61', @filter_clause = null, @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
GO



-- Create subscriptions.
-----------------BEGIN: Script to be run at Publisher 'TSQL03\SQL2008'-----------------
use [TDB]
exec sp_addsubscription @publication = N'TDB_Pub', @subscriber = N'tsql03\BO', @destination_db = N'TDB', 
	@subscription_type = N'Push', @sync_type = N'automatic', @article = N'all', @update_mode = N'read only', @subscriber_type = 0
exec sp_addpushsubscription_agent @publication = N'TDB_Pub', @subscriber = N'tsql03\bo', @subscriber_db = N'TDB', @job_login = null, @job_password = null, @subscriber_security_mode = 0, @subscriber_login = N'dist_login', @subscriber_password = null, @frequency_type = 64, @frequency_interval = 0, @frequency_relative_interval = 0, @frequency_recurrence_factor = 0, @frequency_subday = 0, @frequency_subday_interval = 0, @active_start_time_of_day = 0, @active_end_time_of_day = 235959, @active_start_date = 20190409, @active_end_date = 99991231, @enabled_for_syncmgr = N'False', @dts_package_location = N'Distributor'
GO
-----------------END: Script to be run at Publisher 'TSQL03\SQL2008'-----------------


-- OR
/*
-- Adding the transactional pull subscription
use [TDB];
exec sp_addpullsubscription @publisher = N'TSQL03\SQL2008', @publication = N'TDB_Pub', @publisher_db = N'TDB', @independent_agent = N'True', @subscription_type = N'pull', @description = N'', @update_mode = N'read only', @immediate_sync = 0;
exec sp_addpullsubscription_agent @publisher = N'TSQL03\SQL2008', @publisher_db = N'TDB', @publication = N'TDB_Pub', @distributor = N'TSQL03\BO', @distributor_security_mode = 1, @distributor_login = N'', @distributor_password = N'', @enabled_for_syncmgr = N'False', @frequency_type = 64, @frequency_interval = 0, @frequency_relative_interval = 0, @frequency_recurrence_factor = 0, @frequency_subday = 0, @frequency_subday_interval = 0, @active_start_time_of_day = 0, @active_end_time_of_day = 235959, @active_start_date = 0, @active_end_date = 0, @alt_snapshot_folder = N'', @working_directory = N'', @use_ftp = N'False', @job_login = null, @job_password = null, @publication_type = 0
GO
*/



























-------------------------------------------------
-- Configure HA
-------------------------------------------------
	-- Add remote publisher for secondary node
USE master;  
GO  
EXEC sys.sp_adddistpublisher  
    @publisher = 'tsql05\sql2008',  
    @distribution_db = 'distribution',  
    @working_directory = '\\tsql03\repldata',  
	@security_mode = 0,
    @login = 'dist_login',  
    @password = '12345678'; 

EXEC sys.sp_adddistributor  
    @distributor = 'tsql03\bo',  
    @password = '12345678'; 

:connect tsql05\SQL2008
-- Connect to secondary replica host (passive node)
-- Configure the publisher at the original publisher (tsql05\sql2008)

EXEC sys.sp_adddistributor  
    @distributor = 'tsql03\bo',  
    @password = '12345678'; 
-- You have updated the Publisher property 'active' successfully.
EXEC sys.sp_addlinkedserver   
    @server = 'tsql03\bo';  


:connect tsql03\bo 
-- At distributor
-- Redirect the Original Publisher to the AG Listener Name

USE distribution;  
GO  
EXEC sys.sp_redirect_publisher   
@original_publisher = 'tsql03\sql2008',  
    @publisher_db = 'TDB',  
    @redirected_publisher = 'testhadr';  





-- Run the Replication Validation Stored Procedure to Verify the Configuration
/*
USE distribution;  
GO  
DECLARE @redirected_publisher sysname;  
EXEC sys.sp_validate_replica_hosts_as_publishers  
    @original_publisher = 'tsql03\sql2008',  
    @publisher_db = 'TDB',  
    @redirected_publisher = @redirected_publisher output;
select @redirected_publisher 
*/
-- 
exec sp_get_redirected_publisher @original_publisher = 'tsql03\sql2008',  
    @publisher_db = 'TDB',  
	@bypass_publisher_validation = 0;
/*
exec sp_get_redirected_publisher @original_publisher = 'tsql05\sql2008',  
    @publisher_db = 'TDB',  
	@bypass_publisher_validation = 0;

*/
Select * From MSRedirected_Publishers;
-- 
use distribution;
DECLARE @redirected_publisher sysname;  
EXEC sys.sp_validate_redirected_publisher   
    @original_publisher = 'tsql03\sql2008',  
    @publisher_db = 'TDB',  
    @redirected_publisher = @redirected_publisher output;
select @redirected_publisher;

use distribution;
DECLARE @redirected_publisher sysname;  
EXEC sys.sp_validate_redirected_publisher   
    @original_publisher = 'tsql05\sql2008',  
    @publisher_db = 'TDB',  
    @redirected_publisher = @redirected_publisher output;
select @redirected_publisher; 

-- Remove replication on tsql03\sql2008
--use TDB
--exec sp_removedbreplication


EXEC sp_helpdistributiondb;  
