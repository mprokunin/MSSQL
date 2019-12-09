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

