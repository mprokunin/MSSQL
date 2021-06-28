-- Cached_plans
SELECT objtype AS [CacheType],
    COUNT_BIG(*) AS [Total Plans],
    SUM(CAST(size_in_bytes AS DECIMAL(18, 2))) / 1024 / 1024 AS [Total MBs],
    AVG(usecounts) AS [Avg Use Count],
    SUM(CAST((CASE WHEN usecounts = 1 THEN size_in_bytes
        ELSE 0
        END) AS DECIMAL(18, 2))) / 1024 / 1024 AS [Total MBs – USE Count 1],
    SUM(CASE WHEN usecounts = 1 THEN 1
        ELSE 0
        END) AS [Total Plans – USE Count 1]
FROM sys.dm_exec_cached_plans
GROUP BY objtype
ORDER BY [Total MBs – USE Count 1] DESC
GO


dbcc memorystatus

SELECT TOP 10 
	d.object_id, 
	DB_NAME(d.database_id),
	OBJECT_NAME(object_id, database_id) 'proc name', 
	d.cached_time, 
	d.last_execution_time, 
	d.total_elapsed_time, 
	d.total_elapsed_time/d.execution_count AS [avg_elapsed_time],  
    d.last_elapsed_time, 
	d.execution_count, d.*
FROM sys.dm_exec_procedure_stats AS d  
	where object_id = OBJECT_ID('AgrLoadById_TravelInsuranceProcessBasket_Opt_191209151119')
ORDER BY
	[total_worker_time] DESC;  

select db_name()
sp_helpdb
select top 100 * FROM sys.dm_exec_procedure_stats AS d  where d.database_id = DB_ID('IrisInsuranceDB-performance') and object_id = OBJECT_ID('AgrLoadById_TravelInsuranceProcessBasket_Opt_191209151119')
exec sp_who
use IrisInsuranceDB
select top 100 OBJECT_NAME(object_id),* FROM sys.dm_exec_procedure_stats AS d  where d.database_id = DB_ID('IrisInsuranceDB') and object_id = 973896674 -- AgrLoadById_TravelInsuranceProcessBasket_Opt_191224122610
select top 100 * from IrisInsuranceDB.dbo.sysobjects where name like 'AgrLoadById_TravelInsuranceProcessBasket_Opt_%' order by crdate desc