select @@SERVERNAME, @@VERSION 
go


SELECT
         DATEADD (ss, (-1 * ((cpu_ticks / CONVERT (float, ( cpu_ticks / ms_ticks ))) - [timestamp])/1000), GETDATE()) AS EventTime,
         CONVERT (xml, record) AS record
     FROM sys.dm_os_ring_buffers
     CROSS JOIN sys.dm_os_sys_info
     WHERE ring_buffer_type = 'RING_BUFFER_OOM'