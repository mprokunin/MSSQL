-----------------BEGIN: Script to be run at Publisher 'SQL105\AB'-----------------
use [Test_1112]
exec sp_addsubscription @publication = N'Test_PUB', @subscriber = N'SQL206', @destination_db = N'Test_10', @sync_type = N'replication support only', @subscription_type = N'pull', @update_mode = N'read only'
GO
-----------------END: Script to be run at Publisher 'SQL105\AB'-----------------

-----------------BEGIN: Script to be run at Subscriber 'SQL206'-----------------
use [Test_10]
exec sp_addpullsubscription @publisher = N'SQL105\AB', @publication = N'Test_PUB', @publisher_db = N'Test_1112', @independent_agent = N'True', @subscription_type = N'pull', @description = N'', @update_mode = N'read only', @immediate_sync = 0

exec sp_addpullsubscription_agent @publisher = N'SQL105\AB', @publisher_db = N'Test_1112', @publication = N'Test_PUB', @distributor = N'REPHADR', @distributor_security_mode = 1, @distributor_login = N'', @distributor_password = null, @enabled_for_syncmgr = N'False', @frequency_type = 64, @frequency_interval = 0, @frequency_relative_interval = 0, @frequency_recurrence_factor = 0, @frequency_subday = 0, @frequency_subday_interval = 0, @active_start_time_of_day = 0, @active_end_time_of_day = 235959, @active_start_date = 20191022, @active_end_date = 99991231, @alt_snapshot_folder = N'', @working_directory = N'', @use_ftp = N'False', @job_login = null, @job_password = null, @publication_type = 0
GO
-----------------END: Script to be run at Subscriber 'SQL206'-----------------

