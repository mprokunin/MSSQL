USE [master]
RESTORE DATABASE [t2] FROM  DISK = N'D:\Backup\t2.bak' WITH  FILE = 1,  
MOVE N't2' TO N'D:\DATA_REPL\t2.mdf',  
MOVE N't2_log' TO N'D:\LOG_REPL\t2_log.ldf',  
NORECOVERY,  NOUNLOAD,  STATS = 5
GO
RESTORE LOG [t2] FROM  DISK = N'D:\Backup\t2.bak' WITH  FILE = 1,  NORECOVERY, STATS=5
GO


