SELECT SES.Session_id
	,CASE 
		WHEN TDT.database_id = 32767
			THEN 'MSSQLSystemResource'
		ELSE DB.NAME
		END AS DatabaseName
	,SES.login_name AS LoginName
	,SUBSTRING(EST.TEXT, 1 + REQ.statement_start_offset / 2, (
			CASE 
				WHEN REQ.statement_end_offset = - 1
					THEN LEN(convert(NVARCHAR(max), EST.TEXT)) * 2
				ELSE REQ.statement_end_offset
				END - REQ.statement_start_offset
			) / 2) AS SqlStatement
	,object_name(EST.objectid, EST.dbid) AS ObjectName
	,REQ.start_time AS ReqStart
	,TAT.transaction_begin_time AS TransBegin
	,convert(VARCHAR(8), getdate() - TAT.transaction_begin_time, 108) AS TranDuration
	,TAT.NAME AS TransName
	,CASE TDT.database_transaction_type
		WHEN 1
			THEN N'Read/Write'
		WHEN 2
			THEN N'Read-only'
		WHEN 3
			THEN N'System'
		ELSE N'Unkown'
		END AS TransType
	,CASE TAT.transaction_state
		WHEN 0
			THEN N'Not initialized'
		WHEN 1
			THEN N'Not started'
		WHEN 2
			THEN N'Active'
		WHEN 3
			THEN N'Ended'
		WHEN 4
			THEN N'DTC active'
		WHEN 5
			THEN N'Preparing'
		WHEN 6
			THEN N'Committing'
		WHEN 7
			THEN N'Being rolled back'
		WHEN 8
			THEN N'Rolled back'
		ELSE N'Unkown'
		END AS TransState
	,REQ.[status] AS ReqStatus
	,TDT.database_transaction_log_record_count AS LogRec
	,TDT.database_transaction_log_bytes_used AS LogBytes
	,REQ.wait_type AS ReqWaitType
	,REQ.percent_complete AS [ReqCompl%]
	,REQ.command AS ReqCommand
FROM sys.dm_tran_active_transactions AS TAT
INNER JOIN sys.dm_tran_database_transactions AS TDT ON TAT.transaction_id = TDT.transaction_id
INNER JOIN sys.databases AS DB ON TDT.database_id = DB.database_id
LEFT JOIN sys.dm_tran_session_transactions AS TST ON TAT.transaction_id = TST.transaction_id
LEFT JOIN sys.dm_exec_requests AS REQ ON TAT.transaction_id = REQ.transaction_id
LEFT JOIN sys.dm_exec_sessions AS SES ON REQ.session_id = SES.session_id
CROSS APPLY sys.dm_exec_sql_text(REQ.sql_handle) AS EST
WHERE TAT.transaction_id > 255 
	AND ISNULL(REQ.session_id, - 1) <> @@SPID
	AND TDT.database_id <> DB_ID(N'tempdb')
ORDER BY DatabaseName
	,TransBegin
	,TransName;