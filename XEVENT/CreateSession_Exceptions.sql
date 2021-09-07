IF EXISTS (SELECT * FROM sys.server_event_sessions WHERE name = 'Exceptions')
   DROP EVENT SESSION Exceptions ON SERVER
go
CREATE EVENT SESSION Exceptions ON SERVER 
ADD EVENT sqlserver.error_reported(
    ACTION(sqlserver.session_server_principal_name,
           sqlserver.client_hostname,
           sqlserver.client_app_name,
           sqlserver.session_id,
           sqlserver.database_name,
           sqlserver.sql_text,
           sqlserver.tsql_frame,
           sqlserver.tsql_stack)
    WHERE  severity >= 11
       AND NOT sqlserver.like_i_sql_unicode_string(sqlserver.client_app_name, 
                                    '%SQL Server Management Studio%')
    --  AND sqlserver.equal_i_sql_unicode_string 
    --      (sqlserver.database_name, N'Northwind') 
)
ADD TARGET package0.event_file (SET FILENAME = N'Exceptions.xel',
                                    MAX_FILE_SIZE = 1, 
                                    MAX_ROLLOVER_FILES = 5)
WITH (MAX_MEMORY             = 512 KB,
      EVENT_RETENTION_MODE   = ALLOW_SINGLE_EVENT_LOSS,
      MAX_DISPATCH_LATENCY   = 30 SECONDS,
      MAX_EVENT_SIZE         = 0 KB,
      MEMORY_PARTITION_MODE  = NONE,
      TRACK_CAUSALITY        = OFF,
      STARTUP_STATE          = ON)
GO
ALTER EVENT SESSION Exceptions ON SERVER STATE = START