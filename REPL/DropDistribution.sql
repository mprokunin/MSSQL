
/****** Scripting removing replication objects. Script Date: 09.04.2019 20:09:34 ******/
/****** Please Note: For security reasons, all password parameters were scripted with either NULL or an empty string. ******/

-- Dropping the distribution publishers
exec sp_dropdistpublisher @publisher = N'TSQL03\SQL2008'
GO
exec sp_dropdistpublisher @publisher = N'TSQL05\SQL2008'
GO

-- Dropping the distribution databases
use master
exec sp_dropdistributiondb @database = N'distribution'
GO

/****** Uninstalling the server as a Distributor. Script Date: 09.04.2019 20:09:34 ******/
use master
exec sp_dropdistributor @no_checks = 1, @ignore_distributor = 1
GO
