dbcc opentran(tempdb)
sp_who 96
dbcc inputbuffer(195)

SELECT session_id,(user_objects_alloc_page_count*8/1024) AS SpaceUsedByTheSessionMB,*
FROM	sys.dm_db_session_space_usage 
WHERE	database_id=DB_ID('tempdb')
AND	user_objects_alloc_page_count > 0
order by user_objects_alloc_page_count desc

SELECT sum((user_objects_alloc_page_count*8/1024)) AS TotalSpaceUsedMB
FROM	sys.dm_db_session_space_usage 
WHERE	database_id=DB_ID('tempdb')
AND	user_objects_alloc_page_count > 0

sp_help 'sys.dm_os_performance_counters'
--- read internal free space for data files and log files
declare 
SELECT
   @mdf_internal_free_mb = [Free Space in tempdb (KB)] /1024 ,
   @mdf_internal_free_perc = ((([Free Space in tempdb (KB)] / 1024)*100)/([Data File(s) Size (KB)]/1024)),
   @ldf_internal_free_mb = (([Log File(s) Size (KB)]/1024)-([Log File(s) Used Size (KB)]/1024)),
   @ldf_internal_free_perc = ( 100- [Percent Log Used])
FROM (SELECT counter_name, cntr_value,cntr_type 
      FROM sys.dm_os_performance_counters
      WHERE counter_name IN
        ('Data File(s) Size (KB)',
         'Free Space in tempdb (KB)',
         'Log File(s) Size (KB)',
         'Log File(s) Used Size (KB)',
         'Percent Log Used'
        )
        AND (instance_name = 'tempdb' or counter_name like '%tempdb%')
     ) AS A
PIVOT
     ( MAX(cntr_value)FOR counter_name IN
      ([Data File(s) Size (KB)],
       [Free Space in tempdb (KB)],
       [LOG File(s) Size (KB)],
       [Log File(s) Used Size (KB)],
       [Percent Log Used])
      )AS B
