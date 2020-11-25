/*
    This query shows sessions that are blocking other sessions, including sessions that are 
    not currently processing requests (for instance, they have an open, uncommitted transaction).

    By:  Max Vernon, 2017-03-20
*/
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; --reduce possible blocking by this query.

USE tempdb;

IF OBJECT_ID('tempdb..#dm_tran_session_transactions') IS NOT NULL
DROP TABLE #dm_tran_session_transactions;
SELECT *
INTO #dm_tran_session_transactions
FROM sys.dm_tran_session_transactions;

IF OBJECT_ID('tempdb..#dm_exec_connections') IS NOT NULL
DROP TABLE #dm_exec_connections;
SELECT *
INTO #dm_exec_connections
FROM sys.dm_exec_connections;

IF OBJECT_ID('tempdb..#dm_os_waiting_tasks') IS NOT NULL
DROP TABLE #dm_os_waiting_tasks;
SELECT *
INTO #dm_os_waiting_tasks
FROM sys.dm_os_waiting_tasks;

IF OBJECT_ID('tempdb..#dm_exec_sessions') IS NOT NULL
DROP TABLE #dm_exec_sessions;
SELECT *
INTO #dm_exec_sessions
FROM sys.dm_exec_sessions;

IF OBJECT_ID('tempdb..#dm_exec_requests') IS NOT NULL
DROP TABLE #dm_exec_requests;
SELECT *
INTO #dm_exec_requests
FROM sys.dm_exec_requests;

;WITH IsolationLevels AS 
(
    SELECT v.*
    FROM (VALUES 
              (0, 'Unspecified')
            , (1, 'Read Uncomitted')
            , (2, 'Read Committed')
            , (3, 'Repeatable')
            , (4, 'Serializable')
            , (5, 'Snapshot')
        ) v(Level, Description)
)
, trans AS 
(
    SELECT dtst.session_id
        , blocking_sesion_id = 0
        , Type = 'Transaction'
        , QueryText = dest.text
    FROM #dm_tran_session_transactions dtst 
        LEFT JOIN #dm_exec_connections dec ON dtst.session_id = dec.session_id
    OUTER APPLY sys.dm_exec_sql_text(dec.most_recent_sql_handle) dest
)
, tasks AS 
(
    SELECT dowt.session_id
        , dowt.blocking_session_id
        , Type = 'Waiting Task'
        , QueryText = dest.text
    FROM #dm_os_waiting_tasks dowt
        LEFT JOIN #dm_exec_connections dec ON dowt.session_id = dec.session_id
    OUTER APPLY sys.dm_exec_sql_text(dec.most_recent_sql_handle) dest
    WHERE dowt.blocking_session_id IS NOT NULL
)
, requests AS 
(
SELECT des.session_id
    , der.blocking_session_id
    , Type = 'Session Request'
    , QueryText = dest.text
FROM #dm_exec_sessions des
    INNER JOIN #dm_exec_requests der ON des.session_id = der.session_id
OUTER APPLY sys.dm_exec_sql_text(der.sql_handle) dest
WHERE der.blocking_session_id IS NOT NULL
    AND der.blocking_session_id > 0 
)
, Agg AS (
    SELECT SessionID = tr.session_id
        , ItemType = tr.Type
        , CountOfBlockedSessions = (SELECT COUNT(*) FROM requests r WHERE r.blocking_session_id = tr.session_id)
        , BlockedBySessionID = tr.blocking_sesion_id
        , QueryText = tr.QueryText
    FROM trans tr
    WHERE EXISTS (
        SELECT 1
        FROM requests r
        WHERE r.blocking_session_id = tr.session_id
        )
    UNION ALL
    SELECT ta.session_id
        , ta.Type
        , CountOfBlockedSessions = (SELECT COUNT(*) FROM requests r WHERE r.blocking_session_id = ta.session_id)
        , BlockedBySessionID = ta.blocking_session_id
        , ta.QueryText
    FROM tasks ta
    UNION ALL
    SELECT rq.session_id
        , rq.Type
        , CountOfBlockedSessions =  (SELECT COUNT(*) FROM requests r WHERE r.blocking_session_id = rq.session_id)
        , BlockedBySessionID = rq.blocking_session_id
        , rq.QueryText
    FROM requests rq
)
SELECT agg.SessionID
    , ItemType = STUFF((SELECT ', ' + COALESCE(a.ItemType, '') FROM agg a WHERE a.SessionID = agg.SessionID ORDER BY a.ItemType FOR XML PATH ('')), 1, 2, '')
    , agg.BlockedBySessionID
    , agg.QueryText
    , agg.CountOfBlockedSessions
    , des.host_name
    , des.login_name
    , des.is_user_process
    , des.program_name
    , des.status
    , TransactionIsolationLevel = il.Description
FROM agg 
    LEFT JOIN #dm_exec_sessions des ON agg.SessionID = des.session_id
    LEFT JOIN IsolationLevels il ON des.transaction_isolation_level = il.Level
GROUP BY agg.SessionID
    , agg.BlockedBySessionID
    , agg.CountOfBlockedSessions
    , agg.QueryText
    , des.host_name
    , des.login_name
    , des.is_user_process
    , des.program_name
    , des.status
    , il.Description
ORDER BY 
    agg.BlockedBySessionID
    , agg.CountOfBlockedSessions
    , agg.SessionID;
