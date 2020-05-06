 declare @StopDate datetime = '2018-12-02 22:00:00'

-- Select big (>100 pages) non-compressed tables

--if not exists (select 1 from tempdb..sysobjects where type='U' and name = 'TableList')
if not exists (select 1 from tempdb..sysobjects where type='U' and name = 'IndexList')
--	drop table tempdb.guest.TableList
SELECT 
    p.data_compression, t.object_id, i.index_id, SCHEMA_NAME(t.schema_id) as SchemaName,
	t.NAME AS TableName,
    i.name as IndexName,
    case 
      when i.index_id = 0 then 'Heap'
      when i.index_id = 1 then 'Clustered Index/b-tree'
      when i.index_id > 1 then 'Non-clustered Index/b-tree'
    end as 'Type',

    sum(p.rows) as RowCounts,
    sum(a.total_pages) as TotalPages, 
    sum(a.used_pages) as UsedPages, 
    sum(a.data_pages) as DataPages,
    (sum(a.total_pages) * 8) / 1024 as TotalSpaceMB, 
    (sum(a.used_pages) * 8) / 1024 as UsedSpaceMB, 
    (sum(a.data_pages) * 8) / 1024 as DataSpaceMB,
	0 as Reindexed
--	into tempdb.guest.TableList
	into tempdb.guest.IndexList
FROM 
    sys.tables t
INNER JOIN      
    sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN 
    sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN 
    sys.allocation_units a ON p.partition_id = a.container_id
WHERE 
    t.NAME NOT LIKE 'dt%' AND
    i.OBJECT_ID > 255 
--	AND       i.index_id <= 1
	AND       i.index_id > 1
	and p.data_compression = 0
	and a.total_pages > 100
GROUP BY 
    p.data_compression, t.schema_id, t.NAME, t.object_id, i.index_id, i.name

declare @StopDate datetime = '2018-12-02 22:00:00'

----------- Reindex all heap non-compressed tables/clustered indexes
DECLARE @SchemaName varchar(255), @TableName varchar(255), @ExeStr varchar(max), @CurDate datetime, @RC int;
select @Curdate =getdate()

DECLARE TableCursor CURSOR FOR 
--	SELECT SchemaName, TableName FROM tempdb.guest.TableList 
	SELECT SchemaName, TableName FROM tempdb.guest.IndexList 
	where Reindexed = 0
	order by TotalPages  --  desc

OPEN TableCursor 
select @RC = 0;
FETCH NEXT FROM TableCursor INTO @SchemaName, @TableName 
WHILE @@FETCH_STATUS = 0 and @Curdate < @StopDate -- and @RC < 10
 
BEGIN 
	
	select @ExeStr = 'alter table [' + @SchemaName + '].[' + @TableName + '] REBUILD PARTITION = ALL; update tempdb.guest.IndexList set Reindexed=1 where SchemaName= ''' + @SchemaName + ''' and TableName = ''' + @TableName + ''';' 
print @ExeStr
	exec (@ExeStr)
	select @RC = @RC + 1
	select @Curdate = getdate()
	FETCH NEXT FROM TableCursor INTO @SchemaName, @TableName 
END 

CLOSE TableCursor 
DEALLOCATE TableCursor 
go

 
alter table [dbo].[Asset] REBUILD PARTITION = ALL; update tempdb.guest.TableList set Reindexed=1 where SchemaName= 'dbo' and TableName = 'Asset'; 
USE [RMDWH]
GO
ALTER INDEX [PK_Asset] ON [dbo].[Asset] REBUILD PARTITION = ALL WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
USE [RMDWH]
GO
ALTER INDEX [PK_MPortfolio] ON [dbo].[MPortfolio] REBUILD PARTITION = ALL WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO


ALTER INDEX [PK_MPortfolio_new] ON [dbo].[Portfolio] REBUILD PARTITION = ALL WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
alter table [dbo].[Portfolio] drop CONSTRAINT [PK_Portfolio_new] 
go
/****** Object:  Index [PK_Portfolio_new]    Script Date: 02.12.2018 18:07:35 ******/
ALTER TABLE [dbo].[Portfolio] ADD  CONSTRAINT [PK_Portfolio_new] PRIMARY KEY CLUSTERED 
(
	[PortfolioDate] ASC,
	[VaultID] ASC,
	[CpID] ASC,
	[AssetID] ASC,
	[RecCreateDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

select Reindexed,* from tempdb.guest.TableList order by TotalSpaceMB desc
select Reindexed,* from tempdb.guest.TableList where TableName='Portfolio'
update tempdb.guest.TableList set Reindexed=1  where TableName='Portfolio'


exec msdb..sp__dbinfo 1

select * from ##IndexList order by TotalSpaceMB
select * from tempdb.guest.TableList where Reindexed = 0
select Reindexed, * from tempdb.guest.TableList order by UsedSpaceMB desc
sp_who [icaton\prokunin]
select * from sys.sysprocesses where loginame <> 'sa' and cmd <> 'AWAITING COMMAND'
	(loginame = 'icaton\prokunin')
 or (loginame = 'icaton\prokunin')
--blocked > 0
exec msdb..sp__dbinfo