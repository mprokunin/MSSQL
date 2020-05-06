-- Dropping the transactional publication
use [mif]
exec sp_droppublication @publication = N'Mif_Pub'
GO



/****** Scripting removing replication objects. Script Date: 25.04.2019 17:24:09 ******/
/****** Please Note: For security reasons, all password parameters were scripted with either NULL or an empty string. ******/

-- Disabling the replication database
use master
exec sp_replicationdboption @dbname = N'TDB', @optname = N'publish', @value = N'false'
GO

-- Disabling the replication database
use master
exec sp_replicationdboption @dbname = N'TDB', @optname = N'merge publish', @value = N'false'
GO


/****** Uninstalling the server as a Distributor. Script Date: 25.04.2019 17:24:09 ******/
use master
exec sp_dropdistributor @no_checks = 1, @ignore_distributor = 1
GO


exec msdb..sp__dbinfo 1
