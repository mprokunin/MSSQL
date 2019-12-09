/****** Scripting replication configuration. Script Date: 08.04.2019 19:41:26 ******/
/****** Please Note: For security reasons, all password parameters were scripted with either NULL or an empty string. ******/

/****** Begin: Script to be run at Distributor ******/

/****** Installing the server as a Distributor. Script Date: 08.04.2019 19:41:26 ******/
use master
exec sp_adddistributor @distributor = N'TSQL03\BO', @password = N''
GO

-- Adding the agent profiles
-- Updating the agent profile defaults
exec sp_MSupdate_agenttype_default @profile_id = 1
GO
exec sp_MSupdate_agenttype_default @profile_id = 2
GO
exec sp_MSupdate_agenttype_default @profile_id = 4
GO
exec sp_MSupdate_agenttype_default @profile_id = 6
GO
exec sp_MSupdate_agenttype_default @profile_id = 11
GO

-- Adding the distribution databases
use master
exec sp_adddistributiondb @database = N'distribution', @data_folder = N'E:\DATA', @data_file = N'distribution.mdf', @data_file_size = 13, @log_folder = N'E:\DATA', @log_file = N'distribution.ldf', @log_file_size = 9, @min_distretention = 0, @max_distretention = 72, @history_retention = 48, @deletebatchsize_xact = 5000, @deletebatchsize_cmd = 2000, @security_mode = 1
GO

-- Adding the distribution publishers
exec sp_adddistpublisher @publisher = N'TSQL03\SQL2008', @distribution_db = N'distribution', @security_mode = 1, @working_directory = N'\\tsql03\repldata', @trusted = N'false', @thirdparty_flag = 0, @publisher_type = N'MSSQLSERVER'
GO
exec sp_adddistpublisher @publisher = N'TSQL05\SQL2008', @distribution_db = N'distribution', @security_mode = 1, @working_directory = N'\\tsql03\repldata', @trusted = N'false', @thirdparty_flag = 0, @publisher_type = N'MSSQLSERVER'
GO

/****** End: Script to be run at Distributor ******/


-- Execute the following statements at the Subscriber to create subscriptions in database
------------------------------------------------------------------------------------------
-- Adding the transactional pull subscription

/****** Begin: Script to be run at Subscriber ******/
use [TDB]
exec sp_addpullsubscription @publisher = N'TSQL03\SQL2008', @publication = N'TDB_Pub', @publisher_db = N'TDB', @independent_agent = N'True', @subscription_type = N'pull', @description = N'', @update_mode = N'read only', @immediate_sync = 0

exec sp_addpullsubscription_agent @publisher = N'TSQL03\SQL2008', @publisher_db = N'TDB', @publication = N'TDB_Pub', @distributor = N'TSQL03\BO', @distributor_security_mode = 1, @distributor_login = N'', @distributor_password = N'', @enabled_for_syncmgr = N'False', @frequency_type = 64, @frequency_interval = 0, @frequency_relative_interval = 0, @frequency_recurrence_factor = 0, @frequency_subday = 0, @frequency_subday_interval = 0, @active_start_time_of_day = 0, @active_end_time_of_day = 235959, @active_start_date = 0, @active_end_date = 0, @alt_snapshot_folder = N'', @working_directory = N'', @use_ftp = N'False', @job_login = null, @job_password = null, @publication_type = 0
GO
/****** End: Script to be run at Subscriber ******/

/****** Begin: Script to be run at Publisher ******/
/*use [TDB]
-- Parameter @sync_type is scripted as 'automatic', please adjust when appropriate.
exec sp_addsubscription @publication = N'TDB_Pub', @subscriber = N'TSQL03\BO', @destination_db = N'TDB', @sync_type = N'Automatic', @subscription_type = N'pull', @update_mode = N'read only'
*/
/****** End: Script to be run at Publisher ******/

------------------------------------------------------------------------------------------

-- Execute the following statements at the Publisher(s) to create subscriptions in database.
-- For subscriptions to Oracle Publications, the script needs to be run at the Distributor in the context of the distribution database. 
------------------------------------------------------------------------------------------
-- Adding the transactional pull subscription

/****** Begin: Script to be run at Publisher ******/
use [TDB]
-- Parameter @sync_type is scripted as 'automatic', please adjust when appropriate.
exec sp_addsubscription @publication = N'TDB_Pub', @subscriber = N'TSQL03\BO', @destination_db = N'TDB', @sync_type = N'Automatic', @subscription_type = N'pull', @update_mode = N'read only'
GO
/****** End: Script to be run at Publisher ******/

/****** Begin: Script to be run at Subscriber ******/
/*use [TDB]
exec sp_addpullsubscription @publisher = N'TSQL03\SQL2008', @publication = N'TDB_Pub', @publisher_db = N'TDB', @independent_agent = N'True', @subscription_type = N'pull', @description = N'', @update_mode = N'read only', @immediate_sync = 0

exec sp_addpullsubscription_agent @publisher = N'TSQL03\SQL2008', @publisher_db = N'TDB', @publication = N'TDB_Pub', @distributor = N'TSQL03\BO', @distributor_security_mode = 1, @distributor_login = N'', @distributor_password = N'', @enabled_for_syncmgr = N'False', @frequency_type = 64, @frequency_interval = 0, @frequency_relative_interval = 0, @frequency_recurrence_factor = 0, @frequency_subday = 0, @frequency_subday_interval = 0, @active_start_time_of_day = 0, @active_end_time_of_day = 235959, @active_start_date = 0, @active_end_date = 0, @alt_snapshot_folder = N'', @working_directory = N'', @use_ftp = N'False', @job_login = null, @job_password = null, @publication_type = 0
*/
/****** End: Script to be run at Subscriber ******/

------------------------------------------------------------------------------------------


