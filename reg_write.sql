EXEC xp_instance_regwrite N'HKEY_LOCAL_MACHINE', 
N'Software\Microsoft\MSSQLServer\MSSQLServer',
N'BackupDirectory', REG_SZ, N'E:\InvalidPath'
GO