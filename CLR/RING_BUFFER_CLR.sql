SELECT CONVERT (varchar(30), GETDATE(), 121) as [RunTime],
dateadd (ms, (rbf.[timestamp] - tme.ms_ticks), GETDATE()) as [Notification_Time], 
cast(record as xml).value('(//Record/ResourceMonitor/Notification)[1]', 'varchar(30)') AS [Notification_type], 
cast(record as xml).value('(//Record/MemoryRecord/MemoryUtilization)[1]', 'bigint') AS [MemoryUtilization %], 
cast(record as xml).value('(//Record/MemoryNode/@id)[1]', 'bigint') AS [Node Id], 
cast(record as xml).value('(//Record/ResourceMonitor/IndicatorsProcess)[1]', 'int') AS [Process_Indicator],
cast(record as xml).value('(//Record/ResourceMonitor/IndicatorsSystem)[1]', 'int') AS [System_Indicator],
cast(record as xml).value('(//Record/MemoryNode/ReservedMemory)[1]', 'bigint')/1024 AS [SQL_ReservedMemory_MB], 
cast(record as xml).value('(//Record/MemoryNode/CommittedMemory)[1]', 'bigint')/1024 AS [SQL_CommittedMemory_MB], 
cast(record as xml).value('(//Record/MemoryNode/AWEMemory)[1]', 'bigint')/1024 AS [SQL_AWEMemory_MB], 
cast(record as xml).value('(//Record/MemoryNode/PagesMemory)[1]', 'bigint') AS [PagesMemory_MB], 
cast(record as xml).value('(//Record/MemoryRecord/TotalPhysicalMemory)[1]', 'bigint')/1024 AS [TotalPhysicalMemory_MB], 
cast(record as xml).value('(//Record/MemoryRecord/AvailablePhysicalMemory)[1]', 'bigint')/1024 AS [AvailablePhysicalMemory_MB], 
cast(record as xml).value('(//Record/MemoryRecord/TotalPageFile)[1]', 'bigint')/1024 AS [TotalPageFile_MB], 
cast(record as xml).value('(//Record/MemoryRecord/AvailablePageFile)[1]', 'bigint')/1024 AS [AvailablePageFile_MB], 
cast(record as xml).value('(//Record/MemoryRecord/TotalVirtualAddressSpace)[1]', 'bigint')/1024 AS [TotalVirtualAddressSpace_MB], 
cast(record as xml).value('(//Record/MemoryRecord/AvailableVirtualAddressSpace)[1]', 'bigint')/1024 AS [AvailableVirtualAddressSpace_MB], 
cast(record as xml).value('(//Record/@id)[1]', 'bigint') AS [Record Id], 
cast(record as xml).value('(//Record/@type)[1]', 'varchar(30)') AS [Type],
cast(record as xml).value('(//Record/@time)[1]', 'bigint') AS [Record Time],
tme.ms_ticks as [Current Time],
cast(record as xml) as [Record]
from sys.dm_os_ring_buffers rbf
cross join sys.dm_os_sys_info tme
where rbf.ring_buffer_type = 'RING_BUFFER_CLRAPPDOMAIN' 
--and dateadd (ms, (rbf.[timestamp] - tme.ms_ticks), GETDATE()) < '2018-11-13 20:10:00'
order by rbf.timestamp ASC


--select top 100 * from mssqlsystemresource.sys.loaded_modules

select * from msdb..syspolicy_management_facets 
  where 1 = execution_mode & 1 
  order by name

select @@version

sp_configure 'Memory'
sp_configure 'show advanced'

sp_configure 'clr'