-- Create XEvent session for recompile
IF EXISTS (SELECT 1 FROM sys.server_event_sessions WHERE name = 'Recompiles')
	DROP EVENT SESSION [Recompiles] ON SERVER;
GO

CREATE EVENT SESSION [Recompiles] ON SERVER 
ADD EVENT sqlserver.sql_statement_recompile
(	SET collect_object_name=(1)
		, collect_statement=(1)
	ACTION
		(sqlserver.database_id
			, sqlserver.database_name
			, sqlserver.session_id
			, sqlserver.sql_text
			, sqlserver.username))
	ADD TARGET package0.event_file
		(SET filename=N'Recompiles'
			, max_file_size=(10)
)
WITH 
	(MAX_MEMORY=4096 KB
		, EVENT_RETENTION_MODE=ALLOW_MULTIPLE_EVENT_LOSS
		, MAX_DISPATCH_LATENCY=30 SECONDS
		, MAX_EVENT_SIZE=0 KB
		, MEMORY_PARTITION_MODE=NONE
		, TRACK_CAUSALITY=OFF
		, STARTUP_STATE=OFF)
GO

ALTER EVENT SESSION Recompiles
ON SERVER
STATE = START;