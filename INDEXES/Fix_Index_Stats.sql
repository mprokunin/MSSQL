-- Fix statistics info
insert into master.dbo.index_stats (tab, obj, index_name, statsupdated)
SELECT object_name(object_id) as tab, object_id,  name AS index_name,
STATS_DATE(OBJECT_ID, index_id) AS StatsUpdated
FROM sys.indexes
where object_id > 100