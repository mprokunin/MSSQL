use master
go
EXEC sys.sp_adddistributor  
    @distributor = 'REPHADR',  
    @password = 'Hfcghjcnhfybntkm'; -- see distributor_admin pass in Keepas
-- You have updated the Publisher property 'active' successfully.

-- Enabling the replication database
exec sp_replicationdboption @dbname = N'TDB', @optname = N'publish', @value = N'true'
GO

exec [TDB].sys.sp_addlogreader_agent @job_login = null, @job_password = null, @publisher_security_mode = 1
GO
-- Enabling the replication database
use master
exec sp_replicationdboption @dbname = N'TDB', @optname = N'merge publish', @value = N'true'
GO

-- Adding the transactional publication
use [TDB];
exec sp_addpublication @publication = N'TDB_Pub', @description = N'Transactional publication of database ''TDB'' from Publisher ''SQL105\MIF''.', @sync_method = N'concurrent', @retention = 0, @allow_push = N'true', @allow_pull = N'true', @allow_anonymous = N'false', @enabled_for_internet = N'false', @snapshot_in_defaultfolder = N'true', @compress_snapshot = N'false', @ftp_port = 21, @ftp_login = N'anonymous', @allow_subscription_copy = N'false', @add_to_active_directory = N'false', @repl_freq = N'continuous', @status = N'active', @independent_agent = N'true', @immediate_sync = N'false', @allow_sync_tran = N'false', @autogen_sync_procs = N'false', @allow_queued_tran = N'false', @allow_dts = N'false', @replicate_ddl = 0, @allow_initialize_from_backup = N'false', @enabled_for_p2p = N'false', @enabled_for_het_sub = N'false'
GO


exec sp_addpublication_snapshot @publication = N'TDB_Pub', @frequency_type = 1, @frequency_interval = 0, @frequency_relative_interval = 0, @frequency_recurrence_factor = 0, @frequency_subday = 0, @frequency_subday_interval = 0, @active_start_time_of_day = 0, @active_end_time_of_day = 235959, @active_start_date = 0, @active_end_date = 0, @job_login = null, @job_password = null, @publisher_security_mode = 1
exec sp_grant_publication_access @publication = N'TDB_Pub', @login = N'sa'
GO
exec sp_grant_publication_access @publication = N'TDB_Pub', @login = N'ICATON\SQL Admin'
GO
exec sp_grant_publication_access @publication = N'TDB_Pub', @login = N'ICATON\kirillov'
GO
exec sp_grant_publication_access @publication = N'TDB_Pub', @login = N'ICATON\Prokunin'
GO
exec sp_grant_publication_access @publication = N'TDB_Pub', @login = N'NT SERVICE\MSSQL$SQL2008'
GO
exec sp_grant_publication_access @publication = N'TDB_Pub', @login = N'NT SERVICE\Winmgmt'
GO
exec sp_grant_publication_access @publication = N'TDB_Pub', @login = N'NT SERVICE\SQLWriter'
GO
exec sp_grant_publication_access @publication = N'TDB_Pub', @login = N'NT SERVICE\SQLAgent$SQL2008'

GO

-- Adding the transactional articles
use [TDB]
exec sp_addarticle @publication = N'TDB_Pub', @article = N'Table_1', @source_owner = N'dbo', @source_object = N'Table_1', @type = N'logbased', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'none', @destination_table = N'Table_1', @destination_owner = N'dbo', @status = 24, @vertical_partition = N'true', @ins_cmd = N'CALL [sp_MSins_dboTable_1]', @del_cmd = N'CALL [sp_MSdel_dboTable_1]', @upd_cmd = N'SCALL [sp_MSupd_dboTable_1]'

-- Adding the article's partition column(s)
exec sp_articlecolumn @publication = N'TDB_Pub', @article = N'Table_1', @column = N'col1', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'TDB_Pub', @article = N'Table_1', @column = N'col2', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1

-- Adding the article synchronization object
exec sp_articleview @publication = N'TDB_Pub', @article = N'Table_1', @view_name = N'SYNC_Table_1_1__61', @filter_clause = N'', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
GO
--exec sp_droparticle @publication = N'TDB_Pub', @article = N'Table_1'

-- Adding the transactional subscriptions
use [TDB]
exec sp_addsubscription @publication = N'TDB_Pub', @subscriber = N'TSQL03\BO', @destination_db = N'TDB', @subscription_type = N'Pull', @sync_type = N'replication support only', @article = N'all', @update_mode = N'read only', @subscriber_type = 0
GO

