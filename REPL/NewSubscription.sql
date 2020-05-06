-----------------BEGIN: Script to be run at Publisher 'TSQL03\SQL2008'-----------------
use [TDB]
exec sp_addsubscription @publication = N'TDB_Pub', @subscriber = N'tsql03\bo', @destination_db = N'TDB', @sync_type = N'replication support only', @subscription_type = N'pull', @update_mode = N'read only'
GO
--Commands completed successfully.
-----------------END: Script to be run at Publisher 'TSQL03\SQL2008'-----------------

-----------------BEGIN: Script to be run at Subscriber 'tsql03\bo'-----------------
use [TDB]
exec sp_addpullsubscription @publisher = N'TSQL03\SQL2008', @publication = N'TDB_Pub', @publisher_db = N'TDB', @independent_agent = N'True', @subscription_type = N'pull', @description = N'', @update_mode = N'read only', @immediate_sync = 0
-- Commands completed successfully.

exec sp_addpullsubscription_agent @publisher = N'TSQL03\SQL2008', @publisher_db = N'TDB', @publication = N'TDB_Pub', @distributor = N'TSQL03\BO', @distributor_security_mode = 1, @distributor_login = N'', @distributor_password = null, @enabled_for_syncmgr = N'False', @frequency_type = 64, @frequency_interval = 0, @frequency_relative_interval = 0, @frequency_recurrence_factor = 0, @frequency_subday = 0, @frequency_subday_interval = 0, @active_start_time_of_day = 0, @active_end_time_of_day = 235959, @active_start_date = 20190408, @active_end_date = 99991231, @alt_snapshot_folder = N'', @working_directory = N'', @use_ftp = N'False', @job_login = null, @job_password = null, @publication_type = 0
GO
--Job 'TSQL03\SQL2008-TDB-TDB_Pub-TSQL03\BO-TDB-CB403486-E507-444B-BD02-18FEEE23BE18' started successfully.
-----------------END: Script to be run at Subscriber 'tsql03\bo'-----------------

