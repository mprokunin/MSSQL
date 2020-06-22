-- Add New Partition
use [REN_LOG]
go
declare @path varchar(100) = 'J:\renlog.data\REN_LOG_', @partname1 char(8), @partname2 char(8), @exestr varchar(max) = '', @i int =1;
select @partname1 = convert(char(8), dateadd(dd, @i, getdate()), 112)
select @partname2 = convert(char(8), dateadd(dd, @i+1, getdate()), 112)
select @exestr = 'ALTER DATABASE [REN_LOG] ADD FILEGROUP [REN_LOG_FG_' + @partname1 + ']'
--select @exestr
exec (@exestr)
select @exestr = 'ALTER DATABASE [REN_LOG] ADD FILE (NAME = [REN_LOG_' + @partname1 + '], FILENAME = ''' + @path + @partname1 + '.ndf'', SIZE = 10240 KB, FILEGROWTH = 10240 KB) TO FILEGROUP [REN_LOG_FG_' + @partname1 + ']'
--select @exestr
exec (@exestr)
select @exestr = 'Alter Partition Scheme Daily_PS NEXT USED [REN_LOG_FG_' + @partname1 + ']'
--select @exestr
exec (@exestr)
select @exestr = 'Alter Partition function Daily_PF() split range (''' + @partname2 + ''')'
--select @exestr
exec (@exestr)
go

---- Remove Old Partition
ALTER TABLE [Message] SWITCH PARTITION 1 TO [Message_TMP] PARTITION 1
go
truncate table [Message_TMP]
go
ALTER TABLE [MessageParamCompressed] SWITCH PARTITION 1 TO [MessageParamCompressed_TMP] PARTITION 1 
go
truncate table [MessageParamCompressed_TMP]
go
ALTER TABLE [MessageParamText] SWITCH PARTITION 1 TO [MessageParamText_TMP] PARTITION 1 
go
truncate table [MessageParamText_TMP]
go

declare @MIN_RANGE sql_variant, @OLD_FG sysname, @EXESTR varchar(max)
set @MIN_RANGE=(select top 1 boundary_value from PartitionRanges where partition_function='Daily_PF' and boundary_value is not null order by boundary_value)
select convert(char(8), dateadd(dd, -1, convert(datetime, @MIN_RANGE)), 112)
select @EXESTR = 'Alter Partition function Daily_PF() merge range (''' + convert(varchar(23), @MIN_RANGE) + ''')' 
exec (@EXESTR)
--select  (@EXESTR)
select @EXESTR = 'alter database REN_LOG remove file REN_LOG_' + convert(char(8), dateadd(dd, -1, convert(datetime, @MIN_RANGE)), 112)
--select  (@EXESTR)
exec (@EXESTR)
