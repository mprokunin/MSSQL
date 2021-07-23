dbcc memorystatus

select @@SERVERNAME, @@VERSION 
go

--  You can see the memory nodes presented to SQL Server 
select * from sys.dm_os_memory_nodes

SELECT 
     EventTime,
     record.value('(/Record/ResourceMonitor/Notification)[1]', 'varchar(max)') as [Type],
     record.value('(/Record/ResourceMonitor/IndicatorsProcess)[1]', 'int') as [IndicatorsProcess],
     record.value('(/Record/ResourceMonitor/IndicatorsSystem)[1]', 'int') as [IndicatorsSystem],
     record.value('(/Record/MemoryRecord/AvailablePhysicalMemory)[1]', 'bigint') AS [Avail Phys Mem, Kb],
     record.value('(/Record/MemoryRecord/AvailableVirtualAddressSpace)[1]', 'bigint') AS [Avail VAS, Kb] FROM (
     SELECT
         DATEADD (ss, (-1 * ((cpu_ticks / CONVERT (float, ( cpu_ticks / ms_ticks ))) - [timestamp])/1000), GETDATE()) AS EventTime,
         CONVERT (xml, record) AS record
     FROM sys.dm_os_ring_buffers
     CROSS JOIN sys.dm_os_sys_info
     WHERE ring_buffer_type = 'RING_BUFFER_RESOURCE_MONITOR') AS tab ORDER BY EventTime DESC;

-----------------------
-- Performance counters (Stolen Memory)
SELECT counter_name, instance_name, mb = cntr_value/1024.0
  FROM sys.dm_os_performance_counters 
  WHERE (counter_name = N'Cursor memory usage' and instance_name <> N'_Total')
  OR (instance_name = N'' AND counter_name IN 
       (N'Connection Memory (KB)', N'Granted Workspace Memory (KB)', 
        N'Lock Memory (KB)', N'Optimizer Memory (KB)', N'Stolen Server Memory (KB)', 
        N'Log Pool Memory (KB)', N'Free Memory (KB)')
  ) ORDER BY mb DESC;


-- Memory Clerk Usage for instance  (Query 45) (Memory Clerk Usage)
-- Look for high value for CACHESTORE_SQLCP (Ad-hoc query plans)
SELECT TOP(10) mc.[type] AS [Memory Clerk Type], 
       CAST((SUM(mc.pages_kb)/1024.0) AS DECIMAL (15,2)) AS [Memory Usage (MB)] 
FROM sys.dm_os_memory_clerks AS mc WITH (NOLOCK)
GROUP BY mc.[type]  
ORDER BY SUM(mc.pages_kb) DESC OPTION (RECOMPILE);

select
type,
convert(numeric(10,0), sum(virtual_memory_reserved_kb)/1024.0) as [VM Reserved MB],
convert(numeric(10,0), sum(virtual_memory_committed_kb)/1024.0) as [VM Committed MB],
sum(awe_allocated_kb) as [AWE Allocated],
sum(shared_memory_reserved_kb) as [SM Reserved],
sum(shared_memory_committed_kb) as [SM Committed]
, convert(numeric(10,0), sum(pages_kb)/1024.0) as [Pages_MB]
--,sum(multi_pages_kb) as [MultiPage Allocator], -- for 2008
--sum(single_pages_kb) as [SinlgePage Allocator]
from
sys.dm_os_memory_clerks
group by type
order by [VM Committed MB] desc

-- The following query returns information about currently allocated memory:
SELECT 
  physical_memory_in_use_kb/1024 AS sql_physical_memory_in_use_MB, 
	large_page_allocations_kb/1024 AS sql_large_page_allocations_MB, 
	locked_page_allocations_kb/1024 AS sql_locked_page_allocations_MB,
	virtual_address_space_reserved_kb/1024 AS sql_VAS_reserved_MB, 
	virtual_address_space_committed_kb/1024 AS sql_VAS_committed_MB, 
	virtual_address_space_available_kb/1024 AS sql_VAS_available_MB,
	page_fault_count AS sql_page_fault_count,
	memory_utilization_percentage AS sql_memory_utilization_percentage, 
	process_physical_memory_low AS sql_process_physical_memory_low, 
	process_virtual_memory_low AS sql_process_virtual_memory_low
FROM sys.dm_os_process_memory; 


-- thread stack size
-- First, make sure this is zero, and not some custom number (if it is not 0, find out why, and fix it):
SELECT value_in_use, *
  FROM sys.configurations 
  WHERE name = N'max worker threads';

-- But you can also see how much memory is being taken up by thread stacks using:
SELECT stack_size_in_bytes/1024.0/1024/1024 as stack_size_in_GB
  FROM sys.dm_os_sys_info;


--If the number of threads configured is being exceeded, the following query will provide information about the system tasks that have spawned the additional threads.
SELECT  s.session_id, r.command, r.status,  
   r.wait_type, r.scheduler_id, w.worker_address,  
   w.is_preemptive, w.state, t.task_state,  
   t.session_id, t.exec_context_id, t.request_id  
FROM sys.dm_exec_sessions AS s  
INNER JOIN sys.dm_exec_requests AS r  
   ON s.session_id = r.session_id  
INNER JOIN sys.dm_os_tasks AS t  
   ON r.task_address = t.task_address  
INNER JOIN sys.dm_os_workers AS w  
   ON t.worker_address = w.worker_address  
WHERE s.is_user_process = 0;


--3rd party modules loaded

SELECT base_address, description, name  FROM sys.dm_os_loaded_modules   WHERE company NOT LIKE N'Microsoft%';

--------------


SELECT (physical_memory_in_use_kb/1024)/1024 AS [PhysicalMemInUseGB] FROM sys.dm_os_process_memory;			-- 196 GB
GO

-- Page Life Expectancy (PLE) value for each NUMA node in current instance  (Query 43) (PLE by NUMA Node)
SELECT @@SERVERNAME AS [Server Name], RTRIM([object_name]) AS [Object Name], 
       instance_name, cntr_value AS [Page Life Expectancy]
FROM sys.dm_os_performance_counters WITH (NOLOCK)
WHERE [object_name] LIKE N'%Buffer Node%' -- Handles named instances
AND counter_name = N'Page life expectancy' OPTION (RECOMPILE);

------


WITH ResourceMonitorCte
AS (
          -- select & run this query for a list of records in the queue
    SELECT ROW_NUMBER() OVER (ORDER BY Buffer.Record.value( '@time', 'BIGINT' )
                                     , Buffer.Record.value( '@id', 'BIGINT' ) ) AS [RowNumber]
         , Data.ring_buffer_type AS [Type]
         , Buffer.Record.value( '(ResourceMonitor/Notification)[1]', 'NVARCHAR(128)' ) AS [ResourceNotification]
         , Buffer.Record.value( '@time', 'BIGINT' ) AS [time]
         , Buffer.Record.value( '@id', 'BIGINT' ) AS [Id]
         , Data.EventXML
    FROM (SELECT CAST(Record AS XML) AS EventXML
               , ring_buffer_type
          FROM sys.dm_os_ring_buffers
          WHERE ring_buffer_type = 'RING_BUFFER_RESOURCE_MONITOR') AS Data
    CROSS APPLY EventXML.nodes('//Record') AS Buffer(Record)
   )
SELECT first.[Type]
     , summary.[ResourceNotification]
            , summary.[count]
     , DATEADD( second
               , first.[Time] -- info.ms_ticks / 1000
               , CURRENT_TIMESTAMP ) AS [FirstTime]
     , DATEADD( second
               , last.[Time]  -- info.ms_ticks / 1000
               , CURRENT_TIMESTAMP ) AS [LastTime]
     , first.EventXML AS [FirstRecord]
     , last.EventXML AS [LastRecord]
FROM (SELECT [ResourceNotification]
           , COUNT(*) AS [count]
           , MIN(RowNumber) AS [FirstRow]
           , MAX(RowNumber) AS [LastRow]
      FROM ResourceMonitorCte
      GROUP BY [ResourceNotification] ) AS summary
JOIN ResourceMonitorCte AS first
ON first.RowNumber = summary.[FirstRow]
JOIN ResourceMonitorCte AS last
ON last.RowNumber = summary.[LastRow]
CROSS JOIN sys.dm_os_sys_info AS info
ORDER BY [ResourceNotification]; 


---------------------
--Find all queries waiting in the memory queue:
select top 100 a.text as 'Query', * from sys.dm_exec_query_memory_grants gr
	CROSS APPLY sys.dm_exec_sql_text(gr.sql_handle) a 
	WHERE grant_time is null -- Still waiting for memory grant

SELECT * FROM sys.dm_exec_query_memory_grants where grant_time is null


--Find who uses the most query memory grant:
SELECT convert(numeric(10,2), mg.granted_memory_kb/1024.0) as 'granted_memory_Mb', mg.session_id, mg.dop, t.text, qp.query_plan
FROM sys.dm_exec_query_memory_grants AS mg
CROSS APPLY sys.dm_exec_sql_text(mg.sql_handle) AS t
CROSS APPLY sys.dm_exec_query_plan(mg.plan_handle) AS qp
where mg.session_id <> @@SPID
ORDER BY 1 DESC OPTION (MAXDOP 1)

--sp_who 81

--Search cache for queries with memory grants:
SELECT t.text, cp.objtype,qp.query_plan
FROM sys.dm_exec_cached_plans AS cp
JOIN sys.dm_exec_query_stats AS qs ON cp.plan_handle = qs.plan_handle
CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) AS qp
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS t
WHERE qp.query_plan.exist('declare namespace n=" http://schemas.microsoft.com/sqlserver/2004/07/showplan "; //n:MemoryFractions') = 1

select top 100 * from sys.dm_exec_query_resource_semaphores -- resource_semaphore_id = 0 - Regular, 1 - Small queries
select top 100 * from sys.dm_exec_query_memory_grants gr


select * from sys.dm_os_wait_stats 
--where wait_type = 'RESOURCE_SEMAHORE' 
order by wait_time_ms desc

-- List Windows loaded modules
select * from sys.dm_os_loaded_modules

select top 100 * from sys.dm_exec_requests

-- Memory used by database
SELECT
(CASE WHEN ([is_modified] = 1) THEN 'Dirty' ELSE 'Clean' END) AS 'Page State',
(CASE WHEN ([database_id] = 32767) THEN 'Resource Database' ELSE DB_NAME (database_id) END) AS 'Database Name',
COUNT (*) AS 'Page Count'
FROM sys.dm_os_buffer_descriptors
GROUP BY [database_id], [is_modified]
ORDER BY [database_id], [is_modified];
GO

-- https://www.johnsansom.com/sql-server-memory-configuration-determining-memtoleave-settings/
-- MemToLeave is virtual address space (VAS) that’s left un-used when SQL Server starts so that external components called by SQL Server are saved some address space. So in order for these technologies, .NET CLR, Linked Servers and extended stored procedures, to operate efficiently you must ensure that they too have access to sufficient memory.
WITH VAS_Summary AS
(
    SELECT Size = VAS_Dump.Size,
    Reserved = SUM(CASE(CONVERT(INT, VAS_Dump.Base) ^ 0) WHEN 0 THEN 0 ELSE 1 END),
    Free = SUM(CASE(CONVERT(INT, VAS_Dump.Base) ^ 0) WHEN 0 THEN 1 ELSE 0 END)
    FROM
    (
        SELECT CONVERT(VARBINARY, SUM(region_size_in_bytes)) [Size],
            region_allocation_base_address [Base]
            FROM sys.dm_os_virtual_address_dump
        WHERE region_allocation_base_address <> 0
        GROUP BY region_allocation_base_address
        UNION
        SELECT
            CONVERT(VARBINARY, region_size_in_bytes) [Size],
            region_allocation_base_address [Base]
        FROM sys.dm_os_virtual_address_dump
        WHERE region_allocation_base_address = 0x0 ) AS VAS_Dump
        GROUP BY Size
    )
SELECT
    SUM(CONVERT(BIGINT, Size) * Free) / 1024 AS [Total avail mem, KB],
    CAST(MAX(Size) AS BIGINT) / 1024 AS [Max free size, KB]
FROM VAS_Summary WHERE FREE <> 0
--Total avail mem, KB	Max free size, KB
--137 010 092 648			136 975 531 536

--- Huge cached plans (plans >8KB are stored in MemToLeave
select top 10 convert(numeric(10,2), size_in_bytes/1024.0/1024) as 'size_in_Mbytes', db_name(EQP.dbid) as 'DB', object_name(EQP.objectid, EQP.dbid) as 'Object', EQP.query_plan, * 
	from  sys.dm_exec_cached_plans ECP
	CROSS APPLY sys.dm_exec_query_plan(ECP.plan_handle) EQP order by 1 desc


SELECT COUNT(*) AS [NumCachedObjects],
       CONVERT(numeric(10,2), SUM(CONVERT(BIGINT, size_in_bytes)) / 1024.0/1024) AS [CachedMBytes],
       ISNULL(cacheobjtype, '<-- Totally Total') AS [CacheObjType],
       ISNULL(objtype, '<-- TOTAL') AS [objtype]
FROM   sys.dm_exec_cached_plans
GROUP BY cacheobjtype, objtype WITH ROLLUP;

-------------- Plan
SELECT EQP.query_plan, ER.*
FROM sys.dm_exec_requests AS ER
   CROSS APPLY sys.dm_exec_query_plan(ER.plan_handle) AS EQP
WHERE plan_handle = 0x05000700F8CC0A4C50BF1FD10000000001000000000000000000000000000000000000000000000000000000
--ER.session_id = 1201

-- 
select * from sys.dm_exec_connections where net_packet_size > 8192


SELECT counter_name, instance_name, mb = cntr_value/1024.0
  FROM sys.dm_os_performance_counters 
  WHERE (counter_name = N'Cursor memory usage' and instance_name <> N'_Total')
  OR (instance_name = N'' AND counter_name IN 
       (N'Connection Memory (KB)', N'Granted Workspace Memory (KB)', 
        N'Lock Memory (KB)', N'Optimizer Memory (KB)', N'Stolen Server Memory (KB)', 
        N'Log Pool Memory (KB)', N'Free Memory (KB)')
  ) ORDER BY mb DESC;

--Now						StolenMemory_GB	StolenMemoryPercent
--2021-07-14 16:38:36.233	11.571975708007	5.642814439091754
SELECT Now = GETDATE()
    ,StolenMemory_GB = (
        SELECT cntr_value/1024.0/1024.0
        FROM sys.dm_os_performance_counters
        WHERE [counter_name] IN ('Stolen Server Memory (KB)')
        )
    ,StolenMemoryPercent = 100.0 * (
        SELECT cntr_value
        FROM sys.dm_os_performance_counters
        WHERE [counter_name] IN ('Stolen Server Memory (KB)')
        ) / (
        SELECT cntr_value
        FROM sys.dm_os_performance_counters
        WHERE [counter_name] IN ('Total Server Memory (KB)')
        )

SELECT * FROM sys.dm_clr_appdomains;
