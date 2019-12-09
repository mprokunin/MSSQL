use [Test_1112]
exec sp_replicationdboption @dbname = N'Test_1112', @optname = N'publish', @value = N'true'
GO
-- Adding the transactional publication
use [Test_1112]
exec sp_addpublication @publication = N'Test_PUB', @description = N'Transactional publication of database ''Test_1112'' from Publisher ''SQL105\AB''.', @sync_method = N'concurrent', @retention = 0, @allow_push = N'true', @allow_pull = N'true', @allow_anonymous = N'false', @enabled_for_internet = N'false', @snapshot_in_defaultfolder = N'true', @compress_snapshot = N'false', @ftp_port = 21, @allow_subscription_copy = N'false', @add_to_active_directory = N'false', @repl_freq = N'continuous', @status = N'active', @independent_agent = N'true', @immediate_sync = N'false', @allow_sync_tran = N'false', @allow_queued_tran = N'false', @allow_dts = N'false', @replicate_ddl = 0, @allow_initialize_from_backup = N'false', @enabled_for_p2p = N'false', @enabled_for_het_sub = N'false'
GO


exec sp_addpublication_snapshot @publication = N'Test_PUB', @frequency_type = 1, @frequency_interval = 1, @frequency_relative_interval = 1, @frequency_recurrence_factor = 0, @frequency_subday = 8, @frequency_subday_interval = 1, @active_start_time_of_day = 0, @active_end_time_of_day = 235959, @active_start_date = 0, @active_end_date = 0, @job_login = null, @job_password = null, @publisher_security_mode = 1


use [Test_1112]
exec sp_addarticle @publication = N'Test_PUB', @article = N'test1', @source_owner = N'dbo', @source_object = N'test1', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'test1', @destination_owner = N'dbo', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_dbotest1', @del_cmd = N'CALL sp_MSdel_dbotest1', @upd_cmd = N'SCALL sp_MSupd_dbotest1'
GO




