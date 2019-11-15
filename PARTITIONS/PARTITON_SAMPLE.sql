USE [master]
GO

--Drop if the DB already exists 
If exists(Select name from sys.databases where name = 'Staging_TST')
Begin
   Drop database Staging_TST
End
Go

--Create the DB
CREATE DATABASE [Staging_TST]
CONTAINMENT = NONE
ON PRIMARY ( NAME = N'Staging_TST', FILENAME = N'E:\DATA\Staging_TST.mdf' , SIZE = 28672KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB ) 
LOG ON ( NAME = N'Staging_TST_log', FILENAME = N'E:\DATA\Staging_TST_log.ldf' , SIZE = 470144KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
go

--Remove physical database files for 3 partitioning
If (Exists(Select name from sys.database_files where name='Staging_TST_01'))
Begin
   Alter Database Staging_TST
   Remove file Staging_TST_01
End
Go

If (Exists(Select name from sys.database_files where name='Staging_TST_02'))
Begin
   Alter Database Staging_TST
   Remove file Staging_TST_02
End
Go

If (Exists(Select name from sys.database_files where name='Staging_TST_03'))
Begin
   Alter Database Staging_TST
   Remove file Staging_TST_03
End
Go

----Remove file groups for 3 partitioning
If (Exists(Select name from sys.filegroups where name='Staging_TSTFG_01'))
Begin
   Alter Database Staging_TST
   Remove Filegroup Staging_TSTFG_01
End
Go

If (Exists(Select name from sys.filegroups where name='Staging_TSTFG_02'))
Begin
   Alter Database Staging_TST
   Remove Filegroup Staging_TSTFG_02
End
Go

If (Exists(Select name from sys.filegroups where name='Staging_TSTFG_03'))
Begin
   Alter Database Staging_TST
   Remove Filegroup Staging_TSTFG_03
End
Go

Use Master
go

--Create FileGroups for partitioning
ALTER DATABASE Staging_TST
ADD FILEGROUP Staging_TSTFG_01 
GO

ALTER DATABASE Staging_TST
ADD FILE 
(
NAME = [Staging_TST_01], 
FILENAME = 'E:\DATA\Staging_TST_01.ndf', 
SIZE = 12428 KB, 
MAXSIZE = UNLIMITED, 
FILEGROWTH = 12428 KB
) TO FILEGROUP Staging_TSTFG_01
GO


ALTER DATABASE Staging_TST
ADD FILEGROUP Staging_TSTFG_02 
GO

ALTER DATABASE Staging_TST
ADD FILE 
(
NAME = [Staging_TST_02], 
FILENAME = 'D:\DATA\Staging_TST_02.ndf', 
SIZE = 12428 KB, 
MAXSIZE = UNLIMITED, 
FILEGROWTH = 12428 KB
) TO FILEGROUP Staging_TSTFG_02
GO

ALTER DATABASE Staging_TST
ADD FILEGROUP Staging_TSTFG_03 
GO

ALTER DATABASE Staging_TST
ADD FILE 
(
NAME = [Staging_TST_03], 
FILENAME = 'D:\DATA\Staging_TST_03.ndf', 
SIZE = 12428 KB, 
MAXSIZE = UNLIMITED, 
FILEGROWTH = 12428 KB
) TO FILEGROUP Staging_TSTFG_03
GO

ALTER DATABASE Staging_TST
ADD FILEGROUP Staging_TSTFG_04
GO

ALTER DATABASE Staging_TST
ADD FILE 
(
NAME = [Staging_TST_04], 
FILENAME = 'D:\DATA\Staging_TST_04.ndf', 
SIZE = 12428 KB, 
MAXSIZE = UNLIMITED, 
FILEGROWTH = 12428 KB
) TO FILEGROUP Staging_TSTFG_04
GO

ALTER DATABASE Staging_TST
ADD FILEGROUP Staging_TSTFG_05
GO

ALTER DATABASE Staging_TST
ADD FILE 
(
NAME = [Staging_TST_05], 
FILENAME = 'D:\DATA\Staging_TST_05.ndf', 
SIZE = 12428 KB, 
MAXSIZE = UNLIMITED, 
FILEGROWTH = 12428 KB
) TO FILEGROUP Staging_TSTFG_05
GO

Use Staging_TST
go

CREATE PARTITION FUNCTION TradeDate_PF (Datetime) 
AS RANGE LEFT FOR VALUES ('20180101', '20180107', '20180114', '20180121'); 
GO

CREATE PARTITION SCHEME TradeDate_PS
AS PARTITION TradeDate_PF 
TO (Staging_TSTFG_01,Staging_TSTFG_02,Staging_TSTFG_03,Staging_TSTFG_04,Staging_TSTFG_05);
GO

--Creating TradeDate table
CREATE TABLE TradeDate (
OrderID INT IDENTITY NOT NULL,
OrderDate DATETIME NOT NULL,
CustomerID INT NOT NULL, 
OrderStatus CHAR(1) NOT NULL DEFAULT 'P',
ShippingDate DATETIME
);
Go

ALTER TABLE TradeDate ADD CONSTRAINT PK_Orders PRIMARY KEY Clustered (OrderID, OrderDate)
ON TradeDate_PS (OrderDate);
Go



CREATE TABLE TradeDate_TMP (
OrderID INT IDENTITY NOT NULL,
OrderDate DATETIME NOT NULL,
CustomerID INT NOT NULL, 
OrderStatus CHAR(1) NOT NULL DEFAULT 'P',
ShippingDate DATETIME
);
Go

ALTER TABLE TradeDate_TMP ADD CONSTRAINT PK_Orders_Work PRIMARY KEY Clustered (OrderID, OrderDate)
ON TradeDate_PS (OrderDate);
Go

------------- Procedure to get Partition Details
create procedure sp_partitioninfo as
begin
SELECT
OBJECT_SCHEMA_NAME(pstats.object_id) AS SchemaName
,OBJECT_NAME(pstats.object_id) AS TableName
,ps.name AS PartitionSchemeName
,ds.name AS PartitionFilegroupName
,pf.name AS PartitionFunctionName
,CASE pf.boundary_value_on_right WHEN 0 THEN 'Range Left' ELSE 'Range Right' END AS PartitionFunctionRange
,CASE pf.boundary_value_on_right WHEN 0 THEN 'Upper Boundary' ELSE 'Lower Boundary' END AS PartitionBoundary
,prv.value AS PartitionBoundaryValue
,c.name AS PartitionKey
,CASE 
WHEN pf.boundary_value_on_right = 0 
THEN c.name + ' > ' + CAST(ISNULL(LAG(prv.value) OVER(PARTITION BY pstats.object_id ORDER BY pstats.object_id, pstats.partition_number), 'Infinity') AS VARCHAR(100)) + ' and ' + c.name + ' <= ' + CAST(ISNULL(prv.value, 'Infinity') AS VARCHAR(100)) 
ELSE c.name + ' >= ' + CAST(ISNULL(prv.value, 'Infinity') AS VARCHAR(100)) + ' and ' + c.name + ' < ' + CAST(ISNULL(LEAD(prv.value) OVER(PARTITION BY pstats.object_id ORDER BY pstats.object_id, pstats.partition_number), 'Infinity') AS VARCHAR(100))
END AS PartitionRange
,pstats.partition_number AS PartitionNumber
,pstats.row_count AS PartitionRowCount
,p.data_compression_desc AS DataCompression
FROM sys.dm_db_partition_stats AS pstats
INNER JOIN sys.partitions AS p ON pstats.partition_id = p.partition_id
INNER JOIN sys.destination_data_spaces AS dds ON pstats.partition_number = dds.destination_id
INNER JOIN sys.data_spaces AS ds ON dds.data_space_id = ds.data_space_id
INNER JOIN sys.partition_schemes AS ps ON dds.partition_scheme_id = ps.data_space_id
INNER JOIN sys.partition_functions AS pf ON ps.function_id = pf.function_id
INNER JOIN sys.indexes AS i ON pstats.object_id = i.object_id AND pstats.index_id = i.index_id AND dds.partition_scheme_id = i.data_space_id AND i.type <= 1 /* Heap or Clustered Index */
INNER JOIN sys.index_columns AS ic ON i.index_id = ic.index_id AND i.object_id = ic.object_id AND ic.partition_ordinal > 0
INNER JOIN sys.columns AS c ON pstats.object_id = c.object_id AND ic.column_id = c.column_id
LEFT JOIN sys.partition_range_values AS prv ON pf.function_id = prv.function_id AND pstats.partition_number = (CASE pf.boundary_value_on_right WHEN 0 THEN prv.boundary_id ELSE (prv.boundary_id+1) END)
ORDER BY TableName, PartitionNumber;
end
Go

CREATE VIEW [dbo].[PartitionRanges] AS
select pf.name as [partition_function],
       ps.name as [partition_scheme],
       1 as [partition_number],
       case when prv.value is null then NULL else '<' end as [relation],
       prv.value as [boundary_value],
       type_name(pp.system_type_id) as [type],
       fg.name as [filegroup],
       case when ps.name is null then NULL else N'IN USE' end as [status]
  from sys.partition_functions pf
  join sys.partition_parameters pp on pp.function_id = pf.function_id
  left join sys.partition_schemes ps on ps.function_id = pf.function_id
  left join sys.destination_data_spaces dds
    on dds.partition_scheme_id = ps.data_space_id and dds.destination_id = 1 
  left join sys.filegroups fg on fg.data_space_id = dds.data_space_id
  left join sys.partition_range_values prv
    on prv.function_id = pf.function_id and prv.parameter_id = 1 and
       prv.boundary_id = 1
 where pf.boundary_value_on_right = 1
 union all
select pf.name as [partition_function],
       ps.name as [partition_scheme],
       prv.boundary_id + cast(pf.boundary_value_on_right as int) as [partition_number],
       case when pf.boundary_value_on_right = 0 then '<=' else '>=' end as [relation],
       prv.value as [boundary_value],
       type_name(pp.system_type_id) as [type],
       fg.name as [filegroup],
       case when ps.name is null then NULL else N'IN USE' end as [status]
  from sys.partition_functions pf
  join sys.partition_range_values prv on
       prv.function_id = pf.function_id and prv.parameter_id = 1
  join sys.partition_parameters pp on pp.function_id = pf.function_id
  left join sys.partition_schemes ps on ps.function_id = pf.function_id
  left join sys.destination_data_spaces dds
    on dds.partition_scheme_id = ps.data_space_id and
       dds.destination_id = prv.boundary_id + cast(pf.boundary_value_on_right as int)
  left join sys.filegroups fg on fg.data_space_id = dds.data_space_id
 union all
select pf.name as [partition_function],
       ps.name as [partition_scheme],
       pf.fanout as [partition_number],
       case when prv.value is null then NULL else '>' end as [relation],
       prv.value as [boundary_value],
       type_name(pp.system_type_id) as [type],
       fg.name as [filegroup],
       case when ps.name is null then NULL else N'IN USE' end as [status]
  from sys.partition_functions pf
  join sys.partition_parameters pp on pp.function_id = pf.function_id
  left join sys.partition_schemes ps on ps.function_id = pf.function_id
  left join sys.destination_data_spaces dds
    on dds.partition_scheme_id = ps.data_space_id and dds.destination_id = pf.fanout 
  left join sys.filegroups fg on fg.data_space_id = dds.data_space_id
  left join sys.partition_range_values prv
    on prv.function_id = pf.function_id and prv.parameter_id = 1 and
       prv.boundary_id = pf.fanout - 1
 where pf.boundary_value_on_right = 0
 union all
select pf.name as [partition_function],
       ps.name as [partition_scheme],
       NULL, NULL, NULL, NULL,
       fg.name as [filegroup],
       case when dds.destination_id = pf.fanout + 1
            then N'NEXT USED' else N'NOT USED'
       end as [status]
  from sys.partition_functions pf
  join sys.partition_schemes ps on ps.function_id = pf.function_id
  join sys.destination_data_spaces dds
    on dds.partition_scheme_id = ps.data_space_id and
       dds.destination_id > pf.fanout
  join sys.filegroups fg on fg.data_space_id = dds.data_space_id 
go



create procedure sp_ShiftWindow 
as
begin
ALTER TABLE TradeDate SWITCH PARTITION 1 TO TradeDate_TMP PARTITION 1
truncate table TradeDate_TMP

declare @MIN_RANGE sql_variant, @MAX_RANGE sql_variant, @NEW_FG sysname, @EXESTR varchar(max)
set @NEW_FG=(select top 1 filegroup from PartitionRanges where partition_function='TradeDate_PF' and boundary_value is not null  order by boundary_value)
select @EXESTR = 'Alter Partition Scheme TradeDate_PS NEXT USED ' + @NEW_FG
exec (@EXESTR)
set @MAX_RANGE=(select top 1 boundary_value from PartitionRanges where partition_function='TradeDate_PF' order by boundary_value desc)
select @EXESTR = 'Alter Partition function TradeDate_PF() split range (''' + convert(varchar(23), dateadd(WEEK, 1, convert(datetime, @MAX_RANGE))) + ''')'
exec (@EXESTR)
set @MIN_RANGE=(select top 1 boundary_value from PartitionRanges where partition_function='TradeDate_PF' and boundary_value is not null order by boundary_value)
select @EXESTR = 'Alter Partition function TradeDate_PF() merge range (''' + convert(varchar(23), @MIN_RANGE) + ''')' 
exec (@EXESTR)
end
-----------------

exec sp_partitioninfo
------------- New Month	

INSERT INTO [dbo].[TradeDate]([OrderDate],[CustomerID],[OrderStatus],[ShippingDate])
VALUES(DateAdd(d, ROUND(DateDiff(d, '2017-11-01', '2018-01-31') * RAND(CHECKSUM(NEWID())), 0),DATEADD(second,CHECKSUM(NEWID())%48000, '2017-11-01')),ABS(CHECKSUM(NewId())) % 1000,'P',DateAdd(d, ROUND(DateDiff(d, '2017-11-01', '2018-01-31') * RAND(CHECKSUM(NEWID())), 0),DATEADD(second,CHECKSUM(NEWID())%48000, '2017-11-01')))
GO 1000



exec sp_ShiftWindow
exec dbo.sp_partitioninfo
select * from [PartitionRanges]
Go

INSERT INTO [dbo].[TradeDate]([OrderDate],[CustomerID],[OrderStatus],[ShippingDate])
VALUES(DateAdd(d, ROUND(DateDiff(d, '2017-12-01', '2018-02-28') * RAND(CHECKSUM(NEWID())), 0),DATEADD(second,CHECKSUM(NEWID())%48000, '2017-12-01')),ABS(CHECKSUM(NewId())) % 1000,'P',DateAdd(d, ROUND(DateDiff(d, '2017-12-01', '2018-02-28') * RAND(CHECKSUM(NEWID())), 0),DATEADD(second,CHECKSUM(NEWID())%48000, '2017-12-01')))
GO 100


ALTER TABLE Orders SWITCH PARTITION 1 TO Orders_Work PARTITION 1
Truncate table Orders_Work
Go

Alter Partition Function OrderPartitionFunction() MERGE RANGE ('20180901'); -- (min)

--------------------------- Split partition
Alter Partition Scheme OrderPartitionScheme NEXT USED Staging_TSTFG_01
Go
Alter Partition function OrderPartitionFunction() split range ('20180301') -- Add new period (max +1 month )
Go
Alter Partition Function OrderPartitionFunction() MERGE RANGE ('20171201'); -- (min)
Go

Execute dbo.sp_partitioninfo
Go
	
----------------------------------------------------------------
------------- New Month	
INSERT INTO [dbo].[Orders]([OrderDate],[CustomerID],[OrderStatus],[ShippingDate])
VALUES(DateAdd(d, ROUND(DateDiff(d, '2018-01-01', '2018-03-31') * RAND(CHECKSUM(NEWID())), 0),DATEADD(second,CHECKSUM(NEWID())%48000, '2018-01-01')),ABS(CHECKSUM(NewId())) % 1000,'P',DateAdd(d, ROUND(DateDiff(d, '2018-01-01', '2018-03-31') * RAND(CHECKSUM(NEWID())), 0),DATEADD(second,CHECKSUM(NEWID())%48000, '2018-01-01')))
GO 1000


ALTER TABLE Orders SWITCH PARTITION 1 TO Orders_Work PARTITION 1
Go
Truncate table Orders_Work
Go

Execute dbo.sp_partitioninfo
Go

--------------------------- Split partition
Alter Partition Scheme OrderPartitionScheme NEXT USED Staging_TSTFG_02
Go
Alter Partition function OrderPartitionFunction() split range ('20180401')
Go
Alter Partition Function OrderPartitionFunction() MERGE RANGE ('20180101');
Go

Execute dbo.sp_partitioninfo
Go

----------------------------------------------------------------
------------- New Month	
INSERT INTO [dbo].[Orders]([OrderDate],[CustomerID],[OrderStatus],[ShippingDate])
VALUES(DateAdd(d, ROUND(DateDiff(d, '2018-03-01', '2018-05-31') * RAND(CHECKSUM(NEWID())), 0),DATEADD(second,CHECKSUM(NEWID())%48000, '2018-03-01')),ABS(CHECKSUM(NewId())) % 1000,'P',DateAdd(d, ROUND(DateDiff(d, '2018-03-01', '2018-05-31') * RAND(CHECKSUM(NEWID())), 0),DATEADD(second,CHECKSUM(NEWID())%48000, '2018-03-01')))
GO 1000

ALTER TABLE Orders SWITCH PARTITION 1 TO Orders_Work PARTITION 1
Go
Truncate table Orders_Work
Go

Execute dbo.sp_partitioninfo
Go

--------------------------- Split partition
Alter Partition Scheme OrderPartitionScheme NEXT USED Staging_TSTFG_03
Go
Alter Partition function OrderPartitionFunction() split range ('20180501')
Go
Alter Partition Function OrderPartitionFunction() MERGE RANGE ('20180201');
Go

execute sp_partitioninfo


----------------------------------------------------------------
------------- Next Month	
INSERT INTO [dbo].[Orders]([OrderDate],[CustomerID],[OrderStatus],[ShippingDate])
VALUES(DateAdd(d, ROUND(DateDiff(d, '2018-04-01', '2018-06-30') * RAND(CHECKSUM(NEWID())), 0),DATEADD(second,CHECKSUM(NEWID())%48000, '2018-04-01')),ABS(CHECKSUM(NewId())) % 1000,'P',DateAdd(d, ROUND(DateDiff(d, '2018-04-01', '2018-06-30') * RAND(CHECKSUM(NEWID())), 0),DATEADD(second,CHECKSUM(NEWID())%48000, '2018-03-01')))
GO 1000

ALTER TABLE Orders SWITCH PARTITION 1 TO Orders_Work PARTITION 1
Go
Truncate table Orders_Work
Go

Execute dbo.sp_partitioninfo
Go
--------------------------- Split partition
Alter Partition Scheme OrderPartitionScheme NEXT USED Staging_TSTFG_01
Go
Alter Partition function OrderPartitionFunction() split range ('20180601')
Go
Alter Partition Function OrderPartitionFunction() MERGE RANGE ('20180301');
Go

Execute dbo.sp_partitioninfo
Go

----------------------------------------------------------------
------------- Next Month	
INSERT INTO [dbo].[Orders]([OrderDate],[CustomerID],[OrderStatus],[ShippingDate])
VALUES(DateAdd(d, ROUND(DateDiff(d, '2018-05-01', '2018-07-31') * RAND(CHECKSUM(NEWID())), 0),DATEADD(second,CHECKSUM(NEWID())%48000, '2018-05-01')),ABS(CHECKSUM(NewId())) % 1000,'P',DateAdd(d, ROUND(DateDiff(d, '2018-05-01', '2018-07-31') * RAND(CHECKSUM(NEWID())), 0),DATEADD(second,CHECKSUM(NEWID())%48000, '2018-05-01')))
GO 1000

ALTER TABLE Orders SWITCH PARTITION 1 TO Orders_Work PARTITION 1
Go
Truncate table Orders_Work
Go

Execute dbo.sp_partitioninfo
--------------------------- Split partition
Alter Partition Scheme OrderPartitionScheme NEXT USED Staging_TSTFG_02
Go
Alter Partition function OrderPartitionFunction() split range ('20180701')
Go
Alter Partition Function OrderPartitionFunction() MERGE RANGE ('20180401');
Go

execute sp_partitioninfo

----------------------------------------------------------------
------------- Next Month	
INSERT INTO [dbo].[Orders]([OrderDate],[CustomerID],[OrderStatus],[ShippingDate])
VALUES(DateAdd(d, ROUND(DateDiff(d, '2018-06-01', '2018-08-31') * RAND(CHECKSUM(NEWID())), 0),DATEADD(second,CHECKSUM(NEWID())%48000, '2018-06-01')),ABS(CHECKSUM(NewId())) % 1000,'P',DateAdd(d, ROUND(DateDiff(d, '2018-06-01', '2018-08-31') * RAND(CHECKSUM(NEWID())), 0),DATEADD(second,CHECKSUM(NEWID())%48000, '2018-06-01')))
GO 1000

ALTER TABLE Orders SWITCH PARTITION 1 TO Orders_Work PARTITION 1
Go
Truncate table Orders_Work
Go

Execute dbo.sp_partitioninfo
--------------------------- Split partition
Alter Partition Scheme OrderPartitionScheme NEXT USED Staging_TSTFG_03
Go
Alter Partition function OrderPartitionFunction() split range ('20180801')
Go
Alter Partition Function OrderPartitionFunction() MERGE RANGE ('20180501');
Go

execute sp_partitioninfo

----------------------------------------------------------------
------------- Next Month	
INSERT INTO [dbo].[Orders]([OrderDate],[CustomerID],[OrderStatus],[ShippingDate])
VALUES(DateAdd(d, ROUND(DateDiff(d, '2018-07-01', '2018-09-30') * RAND(CHECKSUM(NEWID())), 0),DATEADD(second,CHECKSUM(NEWID())%48000, '2018-07-01')),ABS(CHECKSUM(NewId())) % 1000,'P',DateAdd(d, ROUND(DateDiff(d, '2018-07-01', '2018-09-30') * RAND(CHECKSUM(NEWID())), 0),DATEADD(second,CHECKSUM(NEWID())%48000, '2018-07-01')))
GO 1000

ALTER TABLE Orders SWITCH PARTITION 1 TO Orders_Work PARTITION 1
Go
Truncate table Orders_Work
Go

Execute dbo.sp_partitioninfo
--------------------------- Split partition
Alter Partition Scheme OrderPartitionScheme NEXT USED Staging_TSTFG_01
Go
Alter Partition function OrderPartitionFunction() split range ('20180901')
Go
Alter Partition Function OrderPartitionFunction() MERGE RANGE ('20180601');
Go

execute sp_partitioninfo

----------------------------------------------

--SET @Day = cast((select top 1 [value] from sys.partition_range_values
select cast((select top 1 [value] from sys.partition_range_values
       where function_id = (select function_id 
               from sys.partition_functions
               where name = 'OrderPartitionFunction')
      order by boundary_id DESC) as datetime)
