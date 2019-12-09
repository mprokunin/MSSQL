-----------------BEGIN: Script to be run at Publisher 'AL-SQL05\BO'-----------------
-- Dropping the transactional subscriptions
use [Test_1112]
exec sp_dropsubscription @publication = N'Test_1112_Pub', @subscriber = N'BROWN', @destination_db = N'Test_10', @article = N'all'
GO
use [Test_1112]
exec sp_dropsubscription @publication = N'Test_1112_Pub', @subscriber = N'SQL206', @destination_db = N'Test_10', @article = N'all'
GO

use [Test_1112]
exec sp_addsubscription @publication = N'Test_1112_Pub', @subscriber = N'BROWN', @destination_db = N'Test_10', @sync_type = N'replication support only', @subscription_type = N'pull', @update_mode = N'read only'
GO
use [Test_1112]
exec sp_addsubscription @publication = N'Test_1112_Pub', @subscriber = N'SQL206', @destination_db = N'Test_10', @sync_type = N'replication support only', @subscription_type = N'pull', @update_mode = N'read only'
GO

-----------------END: Script to be run at Publisher 'AL-SQL05\BO'-----------------

-----------------BEGIN: Script to be run at Subscriber 'BROWN'-----------------
use [Test_10]
exec sp_subscription_cleanup  @publisher = N'AL-SQL05\BO',  @publisher_db = N'Test_1112', @publication = N'Test_1112_Pub' --    [ , [ @reserved = ] 'reserved']  
exec sp_addpullsubscription @publisher = N'AL-SQL05\BO', @publication = N'Test_1112_Pub', @publisher_db = N'Test_1112', @independent_agent = N'True', @subscription_type = N'pull', @description = N'', @update_mode = N'read only', @immediate_sync = 0

exec sp_addpullsubscription_agent @publisher = N'AL-SQL05\BO', @publisher_db = N'Test_1112', @publication = N'Test_1112_Pub', @distributor = N'REPHADR', @distributor_security_mode = 1, @distributor_login = N'', @distributor_password = null, @enabled_for_syncmgr = N'False', @frequency_type = 64, @frequency_interval = 0, @frequency_relative_interval = 0, @frequency_recurrence_factor = 0, @frequency_subday = 0, @frequency_subday_interval = 0, @active_start_time_of_day = 0, @active_end_time_of_day = 235959, @active_start_date = 20190820, @active_end_date = 99991231, @alt_snapshot_folder = N'', @working_directory = N'', @use_ftp = N'False', @job_login = null, @job_password = null, @publication_type = 0
GO
-----------------END: Script to be run at Subscriber 'BROWN'-----------------

-----------------BEGIN: Script to be run at Subscriber 'SQL206'-----------------
use [Test_10]
exec sp_subscription_cleanup  @publisher = N'AL-SQL05\BO',  @publisher_db = N'Test_1112', @publication = N'Test_1112_Pub' --    [ , [ @reserved = ] 'reserved']  
exec sp_addpullsubscription @publisher = N'AL-SQL05\BO', @publication = N'Test_1112_Pub', @publisher_db = N'Test_1112', @independent_agent = N'True', @subscription_type = N'pull', @description = N'', @update_mode = N'read only', @immediate_sync = 0

exec sp_addpullsubscription_agent @publisher = N'AL-SQL05\BO', @publisher_db = N'Test_1112', @publication = N'Test_1112_Pub', @distributor = N'REPHADR', @distributor_security_mode = 1, @distributor_login = N'', @distributor_password = null, @enabled_for_syncmgr = N'False', @frequency_type = 64, @frequency_interval = 0, @frequency_relative_interval = 0, @frequency_recurrence_factor = 0, @frequency_subday = 0, @frequency_subday_interval = 0, @active_start_time_of_day = 0, @active_end_time_of_day = 235959, @active_start_date = 20190820, @active_end_date = 99991231, @alt_snapshot_folder = N'', @working_directory = N'', @use_ftp = N'False', @job_login = null, @job_password = null, @publication_type = 0
GO
-----------------END: Script to be run at Subscriber 'SQL206'-----------------

