/****** Scripting replication configuration. Script Date: 09.04.2019 20:07:47 ******/
/****** Please Note: For security reasons, all password parameters were scripted with either NULL or an empty string. ******/

/****** Begin: Script to be run at Distributor ******/

/****** Installing the server as a Distributor. Script Date: 09.04.2019 20:07:47 ******/
use master
exec sp_adddistributor @distributor = N'SQL202\PBX', @password = N'12345678'
GO
select @@version

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
exec sp_adddistributiondb @database = N'distribution', @data_folder = N'D:\DATA', @data_file = N'distribution.mdf', @data_file_size = 13, @log_folder = N'D:\LOG', @log_file = N'distribution.ldf', @log_file_size = 9, @min_distretention = 0, @max_distretention = 72, @history_retention = 48
--, @deletebatchsize_xact = 5000
--, @deletebatchsize_cmd = 2000
-- Options above for 2016 
, @security_mode = 1
GO

-- Adding the distribution publishers
--EXEC sys.sp_dropdistpublisher      @publisher = 'tsql03\sql2008',  	@no_checks = 0,	@ignore_distributor = 1;
--EXEC sys.sp_dropdistpublisher      @publisher = 'tsql05\sql2008',  	@no_checks = 0,	@ignore_distributor = 1;
exec sp_adddistpublisher @publisher = N'TSQL03\SQL2008', @distribution_db = N'distribution', @security_mode = 1, @working_directory = N'\\tsql03\repldata', @trusted = N'false', @thirdparty_flag = 0, @publisher_type = N'MSSQLSERVER'
GO
exec sp_adddistpublisher @publisher = N'TSQL05\SQL2008', @distribution_db = N'distribution', @security_mode = 1, @working_directory = N'\\tsql03\repldata', @trusted = N'false', @thirdparty_flag = 0, @publisher_type = N'MSSQLSERVER'
GO
select PUBLISHINGSERVERNAME();

/****** End: Script to be run at Distributor ******/


