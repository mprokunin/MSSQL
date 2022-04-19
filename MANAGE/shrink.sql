USE [msdb]  
GO  
EXEC dbo.sp_purge_jobhistory 
GO  

USE [msdb]
GO
DBCC SHRINKFILE (N'MSDBLog' , 0, TRUNCATEONLY)
GO
DBCC SHRINKFILE (N'MSDBData' , 56)
GO
