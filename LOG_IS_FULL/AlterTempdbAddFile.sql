USE [master]
GO
ALTER DATABASE [tempdb] ADD LOG FILE ( NAME = N'templog_1', FILENAME = N'E:\LOG\templog_1.ldf' , SIZE = 8192KB , FILEGROWTH = 65536KB )
GO
