-- List of compressed tables
SELECT [t].[name] AS [Table], [p].[partition_number] AS [Partition],
	[p].[data_compression],
    [p].[data_compression_desc] AS [Compression]
FROM [sys].[partitions] AS [p]
INNER JOIN sys.tables AS [t] ON [t].[object_id] = [p].[object_id]
WHERE [p].[index_id] in (0,1)
and [p].[data_compression] > 0

-- List of compressed indexes
SELECT [t].[name] AS [Table], [i].[name] AS [Index],  
    [p].[partition_number] AS [Partition],
    [p].[data_compression],[p].[data_compression_desc] AS [Compression]
FROM [sys].[partitions] AS [p]
INNER JOIN sys.tables AS [t] ON [t].[object_id] = [p].[object_id]
INNER JOIN sys.indexes AS [i] ON [i].[object_id] = [p].[object_id] AND [i].[index_id] = [p].[index_id]
WHERE [p].[index_id] > 1
and [p].[data_compression] > 0

sp_who [rimos_nt_01\mprokunin]
sp_whoisactive 70

dbcc inputbuffer(98)
select * from sys.databases
ALTER DATABASE [CasePro] SET DELAYED_DURABILITY = ALLOWED WITH NO_WAIT
