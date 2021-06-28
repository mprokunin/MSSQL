;WITH task_space_usage AS (
    -- SUM alloc/delloc pages
    SELECT session_id,
           request_id,
           SUM(internal_objects_alloc_page_count) AS alloc_pages,
           SUM(internal_objects_dealloc_page_count) AS dealloc_pages
    FROM sys.dm_db_task_space_usage WITH (NOLOCK)
    WHERE session_id <> @@SPID
    GROUP BY session_id, request_id
)
SELECT TSU.session_id,
       TSU.alloc_pages * 1.0 / 128 AS [internal object MB space],
       TSU.dealloc_pages * 1.0 / 128 AS [internal object dealloc MB space],
       EST.text,
       -- Extract statement from sql text
       ISNULL(
           NULLIF(
               SUBSTRING(
                 EST.text, 
                 ERQ.statement_start_offset / 2, 
                 CASE WHEN ERQ.statement_end_offset < ERQ.statement_start_offset 
                  THEN 0 
                 ELSE( ERQ.statement_end_offset - ERQ.statement_start_offset ) / 2 END
               ), ''
           ), EST.text
       ) AS [statement text],
       EQP.query_plan
FROM task_space_usage AS TSU
INNER JOIN sys.dm_exec_requests ERQ WITH (NOLOCK)
    ON  TSU.session_id = ERQ.session_id
    AND TSU.request_id = ERQ.request_id
OUTER APPLY sys.dm_exec_sql_text(ERQ.sql_handle) AS EST
OUTER APPLY sys.dm_exec_query_plan(ERQ.plan_handle) AS EQP
WHERE EST.text IS NOT NULL OR EQP.query_plan IS NOT NULL
ORDER BY 3 DESC;


------------------
;WITH s AS
(
    SELECT 
        s.session_id,
        [pages] = SUM(s.user_objects_alloc_page_count 
          + s.internal_objects_alloc_page_count) 
    FROM sys.dm_db_session_space_usage AS s
    GROUP BY s.session_id
    HAVING SUM(s.user_objects_alloc_page_count 
      + s.internal_objects_alloc_page_count) > 0
)
SELECT s.session_id, s.[pages], t.[text], 
  [statement] = COALESCE(NULLIF(
    SUBSTRING(
        t.[text], 
        r.statement_start_offset / 2, 
        CASE WHEN r.statement_end_offset < r.statement_start_offset 
        THEN 0 
        ELSE( r.statement_end_offset - r.statement_start_offset ) / 2 END
      ), ''
    ), t.[text])
FROM s
LEFT OUTER JOIN 
sys.dm_exec_requests AS r
ON s.session_id = r.session_id
OUTER APPLY sys.dm_exec_sql_text(r.plan_handle) AS t
ORDER BY s.[pages] DESC;
------------------
SELECT tdt.database_transaction_log_bytes_reserved,tst.session_id,
       t.[text], [statement] = COALESCE(NULLIF(
         SUBSTRING(
           t.[text],
           r.statement_start_offset / 2,
           CASE WHEN r.statement_end_offset < r.statement_start_offset
             THEN 0
             ELSE( r.statement_end_offset - r.statement_start_offset ) / 2 END
         ), ''
       ), t.[text])
     FROM sys.dm_tran_database_transactions AS tdt
     INNER JOIN sys.dm_tran_session_transactions AS tst
     ON tdt.transaction_id = tst.transaction_id
         LEFT OUTER JOIN sys.dm_exec_requests AS r
         ON tst.session_id = r.session_id
         OUTER APPLY sys.dm_exec_sql_text(r.plan_handle) AS t
     WHERE tdt.database_id = 2;

------------------
SELECT
st.dbid AS QueryExecutionContextDBID,
DB_NAME(st.dbid) AS QueryExecContextDBNAME,
st.objectid AS ModuleObjectId,
SUBSTRING(st.TEXT,
dmv_er.statement_start_offset/2 + 1,
(CASE WHEN dmv_er.statement_end_offset = -1
THEN LEN(CONVERT(NVARCHAR(MAX),st.TEXT)) * 2
ELSE dmv_er.statement_end_offset
END - dmv_er.statement_start_offset)/2) AS Query_Text,
dmv_tsu.session_id ,
dmv_tsu.request_id,
dmv_tsu.exec_context_id,
(dmv_tsu.user_objects_alloc_page_count - dmv_tsu.user_objects_dealloc_page_count) AS OutStanding_user_objects_page_counts,
(dmv_tsu.internal_objects_alloc_page_count - dmv_tsu.internal_objects_dealloc_page_count) AS OutStanding_internal_objects_page_counts,
dmv_er.start_time,
dmv_er.command,
dmv_er.open_transaction_count,
dmv_er.percent_complete,
dmv_er.estimated_completion_time,
dmv_er.cpu_time,
dmv_er.total_elapsed_time,
dmv_er.reads,dmv_er.writes,
dmv_er.logical_reads,
dmv_er.granted_query_memory,
dmv_es.HOST_NAME,
dmv_es.login_name,
dmv_es.program_name
FROM sys.dm_db_task_space_usage dmv_tsu
INNER JOIN sys.dm_exec_requests dmv_er
ON (dmv_tsu.session_id = dmv_er.session_id AND dmv_tsu.request_id = dmv_er.request_id)
INNER JOIN sys.dm_exec_sessions dmv_es
ON (dmv_tsu.session_id = dmv_es.session_id)
CROSS APPLY sys.dm_exec_sql_text(dmv_er.sql_handle) st
WHERE (dmv_tsu.internal_objects_alloc_page_count + dmv_tsu.user_objects_alloc_page_count) > 0
ORDER BY (dmv_tsu.user_objects_alloc_page_count - dmv_tsu.user_objects_dealloc_page_count) + (dmv_tsu.internal_objects_alloc_page_count - dmv_tsu.internal_objects_dealloc_page_count) DESC

------------------
-- Object Sizes
SELECT 
(SUM(unallocated_extent_page_count)/128) AS [Free space (MB)],
SUM(internal_object_reserved_page_count)*8 AS [Internal objects (KB)],
SUM(user_object_reserved_page_count)*8 AS [User objects (KB)],
SUM(version_store_reserved_page_count)*8 AS [Version store (KB)]
FROM sys.dm_db_file_space_usage
--database_id '2' represents tempdb
WHERE database_id = 2


USE [tempdb]
go
SELECT tb.name AS [Temporary table name],
stt.row_count AS [Number of rows], 
stt.used_page_count * 8 AS [Used space (KB)], 
stt.reserved_page_count * 8 AS [Reserved space (KB)] FROM tempdb.sys.partitions AS prt 
INNER JOIN tempdb.sys.dm_db_partition_stats AS stt 
ON prt.partition_id = stt.partition_id 
AND prt.partition_number = stt.partition_number 
INNER JOIN tempdb.sys.tables AS tb 
ON stt.object_id = tb.object_id 
ORDER BY tb.name