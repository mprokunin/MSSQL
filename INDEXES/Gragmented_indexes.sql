--sp_helpdb
use AB_Hist
go
set transaction isolation level read uncommitted
go
SELECT OBJECT_NAME(ind.OBJECT_ID) AS TableName, 
ind.name AS IndexName, indexstats.index_type_desc AS IndexType, 
indexstats.avg_fragmentation_in_percent 
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) indexstats 
INNER JOIN sys.indexes ind 
ON ind.object_id = indexstats.object_id 
AND ind.index_id = indexstats.index_id 
WHERE (1=1) 
--and indexstats.avg_fragmentation_in_percent > 30 
--and (ind.object_id) =1193107341
ORDER BY indexstats.avg_fragmentation_in_percent DESC
go


select object_id('Operation')
select top 100 object_name(object_id), * from sys.indexes  


sp_who [icaton\prokunin]
select * from master..sysprocesses where blocked > 0 or spid=235
sp_whoisactive