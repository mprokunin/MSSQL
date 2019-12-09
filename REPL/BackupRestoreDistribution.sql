:connect AL-SQL03\REPL

alter database [distribution] set recovery full
go
BACKUP DATABASE [distribution] TO  
DISK = N'D:\TMP\distribution.bak' WITH NOFORMAT, NOINIT,  NAME = N'distribution-Full Database Backup', 
SKIP, NOREWIND, NOUNLOAD, COMPRESSION,  STATS = 10
GO
-----------
:connect AL-SQL05\REPL
-- Copy Backup file to AL-SQL05 V:\
RESTORE filelistonly FROM  DISK = N'V:\TMP\distribution.bak' WITH  FILE = 1

USE [master]
RESTORE DATABASE [distribution] FROM  
DISK = N'V:\TMP\distribution.bak' WITH  FILE = 1,  
MOVE N'distribution' TO N'V:\REP_FDAT\distribution.ldf',  
MOVE N'distribution_log' TO N'F:\REP_FLOG\distribution.ldf',  
NORECOVERY,  NOUNLOAD,  REPLACE,  STATS = 5
GO

:connect AL-SQL03\REPL

BACKUP LOG [distribution] TO  
DISK = N'D:\TMP\distribution.trn' 
WITH NOFORMAT, NOINIT,  NAME = N'distribution-LOH Database Backup', 
SKIP, NOREWIND, NOUNLOAD, COMPRESSION,  STATS = 10
GO

:connect AL-SQL05\REPL

USE [master]
RESTORE LOG [distribution] FROM  
DISK = N'V:\TMP\distribution.trn' WITH  FILE = 1,  
NORECOVERY,  NOUNLOAD,  REPLACE,  STATS = 5
GO
