-- Enabling the replication database
use master
exec sp_replicationdboption @dbname = N'TDB', @optname = N'publish', @value = N'true'
GO

exec [TDB].sys.sp_addlogreader_agent @job_login = null, @job_password = null, @publisher_security_mode = 0, 
	@publisher_login = N'dist_login', @publisher_password = N'dist_pass'
GO
-- Enabling the replication database
use master
exec sp_replicationdboption @dbname = N'TDB', @optname = N'merge publish', @value = N'true'
GO

-- Adding the transactional publication
use [TDB]
exec sp_addpublication @publication = N'TDB_Pub', @description = N'Transactional publication of database ''TDB'' from Publisher ''TSQL03\SQL2008''.', @sync_method = N'concurrent', @retention = 0, @allow_push = N'true', @allow_pull = N'true', @allow_anonymous = N'false', @enabled_for_internet = N'false', @snapshot_in_defaultfolder = N'true', @compress_snapshot = N'false', @ftp_port = 21, @ftp_login = N'anonymous', @allow_subscription_copy = N'false', @add_to_active_directory = N'false', @repl_freq = N'continuous', @status = N'active', @independent_agent = N'true', @immediate_sync = N'false', @allow_sync_tran = N'false', @autogen_sync_procs = N'false', @allow_queued_tran = N'false', @allow_dts = N'false', @replicate_ddl = 1, @allow_initialize_from_backup = N'true', @enabled_for_p2p = N'false', @enabled_for_het_sub = N'false'
GO


exec sp_addpublication_snapshot @publication = N'TDB_Pub', @frequency_type = 1, @frequency_interval = 0, @frequency_relative_interval = 0, @frequency_recurrence_factor = 0, @frequency_subday = 0, @frequency_subday_interval = 0, @active_start_time_of_day = 0, @active_end_time_of_day = 235959, @active_start_date = 0, @active_end_date = 0, @job_login = null, @job_password = null, @publisher_security_mode = 1
exec sp_grant_publication_access @publication = N'TDB_Pub', @login = N'sa'
GO
exec sp_grant_publication_access @publication = N'TDB_Pub', @login = N'NT SERVICE\Winmgmt'
GO
exec sp_grant_publication_access @publication = N'TDB_Pub', @login = N'NT SERVICE\SQLWriter'
GO

--sp_helpdistributor @distributor = 'PLAYSERV303\SQL2012'
