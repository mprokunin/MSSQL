select @@SERVERNAME, @@VERSION
set transaction isolation level read uncommitted
go
use P_REQ
-- Get fragmentation info for all indexes above a certain size in the current database  (Query 69) (Index Fragmentation)
-- Note: This query could take some time on a very large database
SELECT DB_NAME(ps.database_id) AS [Database Name], SCHEMA_NAME(o.[schema_id]) AS [Schema Name],
OBJECT_NAME(ps.OBJECT_ID) AS [Object Name], i.[name] AS [Index Name], ps.index_id, 
ps.index_type_desc, ps.avg_fragmentation_in_percent, 
ps.fragment_count, ps.page_count, i.fill_factor, i.has_filter, 
i.filter_definition, i.[allow_page_locks]
FROM sys.dm_db_index_physical_stats(DB_ID(),NULL, NULL, NULL , N'LIMITED') AS ps
INNER JOIN sys.indexes AS i WITH (NOLOCK)
ON ps.[object_id] = i.[object_id] 
AND ps.index_id = i.index_id
INNER JOIN sys.objects AS o WITH (NOLOCK)
ON i.[object_id] = o.[object_id]
WHERE ps.database_id = DB_ID()
AND ps.page_count > 2500
ORDER BY ps.avg_fragmentation_in_percent DESC OPTION (RECOMPILE);

--sp_helpdb
--use P_HRM3
--go
SELECT OBJECT_NAME(ind.OBJECT_ID) AS TableName, 
ind.name AS IndexName, indexstats.index_type_desc AS IndexType, 
indexstats.avg_fragmentation_in_percent 
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) indexstats 
INNER JOIN sys.indexes ind 
ON ind.object_id = indexstats.object_id 
AND ind.index_id = indexstats.index_id 
WHERE  (1=1)
--and indexstats.avg_fragmentation_in_percent > 10 
--and (ind.object_id) = object_id('_AccumRg9290')

and (ind.object_id) in ( 
object_id('_InfoRg43942'), 
object_id('_InfoRg43726'), 
object_id('_Reference464'), 
object_id('_Document43643')

)

ORDER BY indexstats.avg_fragmentation_in_percent DESC
go

exec sp_spaceused _InfoRg43942 
exec sp_spaceused _InfoRg43726 

exec sp_spaceused _Document43643 

update statistics _Reference464 
update statistics _InfoRg43942 with sample 35 PERCENT
update statistics _InfoRg43726  with sample 35 PERCENT
update statistics _Document43643   with sample 35 PERCENT

DBCC FREESYSTEMCACHE ('SQL Plans') 



'AccRgAT028644'
'AccRgAT128663'
'AccRgAT228664'
'AccRgAT328665'
'AccRgCT28666'
select db_name()

EXECUTE master.dbo.IndexOptimize
@Databases = 'P_AST',
@FragmentationMedium = 'INDEX_REBUILD_OFFLINE',
@FragmentationHigh = 'INDEX_REBUILD_OFFLINE',
@UpdateStatistics = 'ALL',
@Indexes = 'P_AST.dbo._AccumRg9303',--,P_AST.dbo._AccumRgT9315,P_AST.dbo._Document237,P_AST.dbo._AccumRgT9302,P_AST.dbo._AccumRg9290,_Document237',
@LogToTable = 'Y'
go


EXECUTE master.dbo.IndexOptimize
@Databases = 'P_AST',
--@FragmentationMedium = 'INDEX_REBUILD_OFFLINE',
--@FragmentationHigh = 'INDEX_REBUILD_OFFLINE',
@LogToTable = 'Y',
@Execute='Y'

sp_spaceused _InfoRg9394
EXECUTE master.dbo.IndexOptimize
@Databases = 'P_AST',
@FragmentationMedium = 'INDEX_REBUILD_OFFLINE',
@FragmentationHigh = 'INDEX_REBUILD_OFFLINE',
@UpdateStatistics = 'ALL',
@Indexes = 'P_AST.dbo._AccumRgT9315,P_AST.dbo._AccumRgT9315,P_AST.dbo._Document237,P_AST.dbo._AccumRgT9302,P_AST.dbo._AccumRg9290',
@LogToTable = 'Y'
go

EXECUTE master.dbo.IndexOptimize
@Databases = 'P_AST',
@FragmentationMedium = 'INDEX_REBUILD_OFFLINE',
@FragmentationHigh = 'INDEX_REBUILD_OFFLINE',
@UpdateStatistics = 'ALL',
@Indexes = 'P_AST.dbo._Document237',--,P_AST.dbo._AccumRgT9315,P_AST.dbo._Document237,P_AST.dbo._AccumRgT9302,P_AST.dbo._AccumRg9290,_Document237',
@LogToTable = 'Y'
go
EXECUTE master.dbo.IndexOptimize
@Databases = 'P_AST',
@FragmentationMedium = 'INDEX_REBUILD_OFFLINE',
@FragmentationHigh = 'INDEX_REBUILD_OFFLINE',
@UpdateStatistics = 'ALL',
@Indexes = 'P_AST.dbo._AccumRgT9302',--,P_AST.dbo._AccumRgT9315,P_AST.dbo._Document237,P_AST.dbo._AccumRgT9302,P_AST.dbo._AccumRg9290,_Document237',
@LogToTable = 'Y'
go
EXECUTE master.dbo.IndexOptimize
@Databases = 'P_AST',
@FragmentationMedium = 'INDEX_REBUILD_OFFLINE',
@FragmentationHigh = 'INDEX_REBUILD_OFFLINE',
@UpdateStatistics = 'ALL',
@Indexes = 'P_AST.dbo._AccumRg9290',--,P_AST.dbo._AccumRgT9315,P_AST.dbo._Document237,P_AST.dbo._AccumRgT9302,P_AST.dbo._AccumRg9290,_Document237',
@LogToTable = 'Y'
go


EXECUTE master.dbo.IndexOptimize
@Databases = 'P_AST',
@FragmentationMedium = 'INDEX_REBUILD_OFFLINE',
@FragmentationHigh = 'INDEX_REBUILD_OFFLINE',
@UpdateStatistics = 'ALL',
@Indexes = 'P_AST.dbo._AccumRg9290._AccumRg9290_ByPeriod',--,P_AST.dbo._AccumRgT9315,P_AST.dbo._Document237,P_AST.dbo._AccumRgT9302,P_AST.dbo._AccumRg9290,_Document237',
@LogToTable = 'Y'
go



_AccumRg9303 T4
_AccumRgT9315 T3
_Document237 T5
_AccumRgT9302 T8
_AccumRg9290 T9
_Document237 T10

select object_id('_AccumRg9290')
select top 100 object_name(object_id), * from sys.indexes  


select top 100 * from master..CommandLog where DatabaseName='P_AST' and ObjectName like '_AccumRg9290%' order by StartTime desc
select top 100 'ALTER INDEX [' + name + '] ON [P_AST].[dbo].[_AccumRgT9302] REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = OFF)' 
	from sysindexes where id=object_id('_AccumRgT9302') and first is not NULL
ALTER INDEX [_AccumRgT9302_ByDims] ON [P_AST].[dbo].[_AccumRgT9302] REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = OFF)
ALTER INDEX [_AccumRgT9302_ByDims9299] ON [P_AST].[dbo].[_AccumRgT9302] REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = OFF)
ALTER INDEX [_AccumRgT9302_ByDims9300] ON [P_AST].[dbo].[_AccumRgT9302] REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = OFF)
ALTER INDEX [_AccumRgT9302_ByDims9301] ON [P_AST].[dbo].[_AccumRgT9302] REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = OFF)

ALTER INDEX [_AccumRgT9315_ByDims] ON [P_AST].[dbo].[_AccumRgT9315] REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = OFF)
ALTER INDEX [_AccumRgT9315_ByDims9312] ON [P_AST].[dbo].[_AccumRgT9315] REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = OFF)
ALTER INDEX [_AccumRgT9315_ByDims9313] ON [P_AST].[dbo].[_AccumRgT9315] REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = OFF)
ALTER INDEX [_AccumRgT9315_ByDims9314] ON [P_AST].[dbo].[_AccumRgT9315] REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = OFF)

ALTER INDEX [_AccumRg9290_ByPeriod] ON [P_AST].[dbo].[_AccumRg9290] REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = OFF)
ALTER INDEX [_AccumRg9290_ByRecorder] ON [P_AST].[dbo].[_AccumRg9290] REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = OFF)
ALTER INDEX [_AccumRg9290_ByDims9301] ON [P_AST].[dbo].[_AccumRg9290] REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = OFF)
ALTER INDEX [_AccumRg9290_ByDims9298] ON [P_AST].[dbo].[_AccumRg9290] REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = OFF)
ALTER INDEX [_AccumRg9290_ByDims9300] ON [P_AST].[dbo].[_AccumRg9290] REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = OFF)
ALTER INDEX [_AccumRg9290_ByDims9299] ON [P_AST].[dbo].[_AccumRg9290] REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = OFF)
ALTER INDEX [_AccumRg9290_dba] ON [P_AST].[dbo].[_AccumRg9290] REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = OFF)

update statistics [dbo].[_AccumRg9290]
sp_who [icaton\prokunin]
select * from master..sysprocesses where blocked > 0 or spid=235
sp_whoisactive

sp_helpindex [_AccumRg9290]

ALTER INDEX [_AccumRg9303_ByPeriod] ON [P_AST].[dbo].[_AccumRg9303] REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = OFF)
go
ALTER INDEX [_AccumRg9303_ByRecorder] ON [P_AST].[dbo].[_AccumRg9303] REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = OFF)
go
ALTER INDEX [_AccumRg9303_ByDims9311] ON [P_AST].[dbo].[_AccumRg9303] REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = OFF)
go
ALTER INDEX [_AccumRg9303_ByDims9312] ON [P_AST].[dbo].[_AccumRg9303] REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = OFF)
go
ALTER INDEX [_AccumRg9303_ByDims9313] ON [P_AST].[dbo].[_AccumRg9303] REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = OFF)
go
ALTER INDEX [_AccumRg9303_ByDims9314] ON [P_AST].[dbo].[_AccumRg9303] REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = OFF)
go



set transaction isolation level read uncommitted
go
SELECT distinct top 30 'ALTER INDEX ALL  on ' + OBJECT_NAME(ind.OBJECT_ID) + ' REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = OFF)', indexstats.avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) indexstats 
INNER JOIN sys.indexes ind 
ON ind.object_id = indexstats.object_id 
AND ind.index_id = indexstats.index_id 
WHERE  (1=1)
and indexstats.avg_fragmentation_in_percent > 50 
--and (ind.object_id) = object_id('_AccumRg9290')
/*
and (ind.object_id) in ( 
object_id('_AccumRg9303'), 
object_id('_AccumRgT9315'), 
object_id('_Document237'), 
object_id('_AccumRgT9302'), 
object_id('_AccumRg9290'),
object_id('_Document237')
)
*/
ORDER BY indexstats.avg_fragmentation_in_percent DESC
go


ALTER INDEX ALL  on _InfoRg9394 REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = OFF)
ALTER INDEX ALL  on _Reference88 REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = OFF)
ALTER INDEX ALL  on _InfoRg9559 REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = OFF)
ALTER INDEX ALL  on _AccumRg9875 REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = OFF)

ALTER INDEX ALL  on _Document9275 REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = OFF)
ALTER INDEX ALL  on _InfoRg7223 REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = OFF)
ALTER INDEX ALL  on _Reference88_VT9599 REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = OFF)
ALTER INDEX ALL  on _DocumentJournal6902 REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = OFF)

ALTER INDEX ALL  on _Acc10626 REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = OFF)
ALTER INDEX ALL  on _Acc10626_ExtDim10628 REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = OFF)
ALTER INDEX ALL  on _Acc8 REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = OFF)
ALTER INDEX ALL  on _Acc8_ExtDim9162 REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = OFF)
ALTER INDEX ALL  on _Acc9 REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = OFF)
ALTER INDEX ALL  on _Acc9_ExtDim9173 REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = OFF)
ALTER INDEX ALL  on _AccChngR9166 REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = OFF)
ALTER INDEX ALL  on _AccChngR9181 REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = OFF)
ALTER INDEX ALL  on _AccOpt REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = OFF)

ALTER INDEX ALL  on _Document9271 REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = OFF)

ALTER INDEX ALL  on _InfoRg9374 REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = OFF)
ALTER INDEX ALL  on _InfoRg8222 REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = OFF)
ALTER INDEX ALL  on _Reference85 REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = OFF)

ALTER INDEX ALL  on _AccumRgTn10928 REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = OFF)
ALTER INDEX ALL  on _AccumRg9888 REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = OFF)
ALTER INDEX ALL  on _Document9271 REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = OFF)
ALTER INDEX ALL  on _AccumRgT9887 REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = OFF)
ALTER INDEX ALL  on _Reference91 REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = OFF)

ALTER INDEX ALL  on _InfoRg9551 REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = OFF)
ALTER INDEX ALL  on _SeqB9156 REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = OFF)

ALTER INDEX ALL  on _Reference94 REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = OFF)
ALTER INDEX ALL  on _DocumentJournal6947 REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = OFF)
ALTER INDEX ALL  on _AccumRg9888 REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = OFF)
ALTER INDEX ALL  on _Reference92_VT9610 REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = OFF)

ALTER INDEX ALL  on _InfoRg10946 REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = OFF)
ALTER INDEX ALL  on _InfoRg9414 REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = OFF)
ALTER INDEX ALL  on _InfoRg8222 REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = OFF)
ALTER INDEX ALL  on _Reference92_VT9610 REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = OFF)
ALTER INDEX ALL  on _InfoRg9551 REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = OFF)
ALTER INDEX ALL  on _InfoRg10830 REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = OFF)
ALTER INDEX ALL  on _InfoRg9535 REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = OFF)


ALTER INDEX ALL  on _AccumRg10886 REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = OFF)