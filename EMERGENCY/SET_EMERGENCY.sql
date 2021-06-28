USE [master]

RESTORE DATABASE [IrisFilesDB2] FROM  DISK = N'D:\Files.bak' WITH  FILE = 1,  
MOVE N'IrisFilesDB' TO N'K:\IrisFiles\IrisFilesDB.mdf',  
MOVE N'IrisFilesDB_log' TO N'N:\LOG\IrisFilesDB_log.ldf',  
MOVE N'FileStreamData' TO N'K:\IrisFiles\IrisFilesDB',  NOUNLOAD,  STATS = 5, norecovery

GO


ALTER DATABASE [IrisBox] SET EMERGENCY;
GO

ALTER DATABASE [IrisBox]  set single_user
GO

DBCC CHECKDB ([IrisBox], REPAIR_ALLOW_DATA_LOSS) WITH ALL_ERRORMSGS;
GO 

ALTER DATABASE [IrisBox] set multi_user
GO 
