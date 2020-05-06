-- Enabling the replication database
use master
exec sp_replicationdboption @dbname = N'TDB', @optname = N'publish', @value = N'true'
GO
--The replication option 'publish' of database 'TDB' has already been set to true.

-- Enabling the replication database
use master
exec sp_replicationdboption @dbname = N'TDB', @optname = N'merge publish', @value = N'true'
GO
--The replication option 'merge publish' of database 'TDB' has already been set to true.

-- Adding the transactional publication
use [TDB]
exec sp_addpublication @publication = N'TDB_Pub', @description = N'Transactional publication of database ''TDB'' from Publisher ''TSQL03\SQL2008''.', @sync_method = N'concurrent', @retention = 0, @allow_push = N'true', @allow_pull = N'true', @allow_anonymous = N'false', @enabled_for_internet = N'false', @snapshot_in_defaultfolder = N'true', @compress_snapshot = N'false', @ftp_port = 21, @allow_subscription_copy = N'false', @add_to_active_directory = N'false', @repl_freq = N'continuous', @status = N'active', @independent_agent = N'true', @immediate_sync = N'false', @allow_sync_tran = N'false', @allow_queued_tran = N'false', @allow_dts = N'false', @replicate_ddl = 1, @allow_initialize_from_backup = N'false', @enabled_for_p2p = N'false', @enabled_for_het_sub = N'false'
GO
--Job 'TSQL03\SQL2008-TDB-1' started successfully.
--Warning: The logreader agent job has been implicitly created and will run under the SQL Server Agent Service Account.

exec sp_addpublication_snapshot @publication = N'TDB_Pub', @frequency_type = 1, @frequency_interval = 1, @frequency_relative_interval = 1, @frequency_recurrence_factor = 0, @frequency_subday = 8, @frequency_subday_interval = 1, @active_start_time_of_day = 0, @active_end_time_of_day = 235959, @active_start_date = 0, @active_end_date = 0, @job_login = null, @job_password = null, @publisher_security_mode = 1


use [TDB]
exec sp_addarticle @publication = N'TDB_Pub', @article = N'Table_1', @source_owner = N'dbo', @source_object = N'Table_1', @type = N'logbased', @description = N'', @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'Table_1', @destination_owner = N'dbo', @vertical_partition = N'true', @ins_cmd = N'CALL sp_MSins_dboTable_1', @del_cmd = N'CALL sp_MSdel_dboTable_1', @upd_cmd = N'SCALL sp_MSupd_dboTable_1'

-- Adding the article's partition column(s)
exec sp_articlecolumn @publication = N'TDB_Pub', @article = N'Table_1', @column = N'col1', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'TDB_Pub', @article = N'Table_1', @column = N'col2', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1

-- Adding the article synchronization object
exec sp_articleview @publication = N'TDB_Pub', @article = N'Table_1', @view_name = N'SYNC_Table_1_1__61', @filter_clause = null, @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
GO




