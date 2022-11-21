CREATE EVENT SESSION [CatchDropTable] ON SERVER 
ADD EVENT sqlserver.metadata_ddl_add_column(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.nt_username,sqlserver.sql_text,sqlserver.username)
    WHERE ([sqlserver].[database_name]=N'PBI')),
ADD EVENT sqlserver.metadata_ddl_drop_column(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.nt_username,sqlserver.sql_text,sqlserver.username)
    WHERE ([sqlserver].[database_name]=N'PBI')),
ADD EVENT sqlserver.object_altered(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.nt_username,sqlserver.sql_text,sqlserver.username)
    WHERE ([sqlserver].[database_name]=N'PBI')),
ADD EVENT sqlserver.object_created(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.nt_username,sqlserver.sql_text,sqlserver.username)
    WHERE ([sqlserver].[equal_i_sql_unicode_string]([sqlserver].[database_name],N'PBI') AND [database_id]=(7))),
ADD EVENT sqlserver.object_deleted(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.nt_username,sqlserver.sql_text,sqlserver.username)
    WHERE ([sqlserver].[equal_i_sql_unicode_string]([sqlserver].[database_name],N'PBI') AND [database_id]=(7)))
ADD TARGET package0.event_file(SET filename=N'D:\DOC\CatchDropTable.xel',max_file_size=(100))
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
GO



select xdata.value(N'(event/@timestamp)[1]', N'datetime') AT TIME ZONE 'UTC' AT TIME ZONE 'Russian Standard Time' [DateTime]
,xdata.value(N'(event/action[@name="database_name"]/value)[1]', N'sysname') [Database_name]
,xdata.value(N'(event/action[@name="client_hostname"]/value)[1]', N'nvarchar(100)') [Client_hostname]
,xdata.value(N'(event/action[@name="client_app_name"]/value)[1]', N'nvarchar(100)') [Client_app_name]
,xdata.value(N'(event/action[@name="username"]/value)[1]', N'nvarchar(100)') [Username]
,xdata.value(N'(event/data[@name="ddl_phase"]/text)[1]', N'nvarchar(20)') [Ddl_phase]
,xdata.value(N'(event/action[@name="sql_text"]/value)[1]', N'nvarchar(max)') [Sql_text]
FROM    ( SELECT    CAST(event_data AS XML)
          FROM      sys.fn_xe_file_target_read_file('D:\DOC\CatchDropTable*.xel',
                                                    NULL, NULL, NULL)
        ) AS xmlr ( xdata )
ORDER BY xdata.value(N'(event/@timestamp)[1]', N'datetime') DESC;





SELECT
 event_xml.value('(./@name)', 'varchar(1000)') as event_name,
 event_xml.value('(./data[@name="database_id"]/value)[1]', 'int') as database_id,
 event_xml.value('(./data[@name="nt_username"]/value)[1]', 'sysname') as nt_username,
 event_xml.value('(./data[@name="sqlserver.username"]/value)[1]', 'sysname') as username,
event_xml.value('(./data[@name="collect_system_time"]/value)[1]', 'datetime2') as collect_system_time,
 --event_xml.value('(./data[@name="object_type"]/value)[1]', 'varchar(25)') as object_type,
 --event_xml.value('(./data[@name="duration"]/value)[1]', 'bigint') as duration,
 --event_xml.value('(./data[@name="cpu"]/value)[1]', 'bigint') as cpu,
 --event_xml.value('(./data[@name="row_count"]/value)[1]', 'int') as row_count,
 --event_xml.value('(./data[@name="reads"]/value)[1]', 'bigint') as reads,
 --event_xml.value('(./data[@name="writes"]/value)[1]', 'bigint') as writes,
 event_xml.value('(./action[@name="sql_text"]/value)[1]', 'varchar(4000)') as sql_text
FROM (SELECT CAST(event_data AS XML) xml_event_data 
  FROM sys.fn_xe_file_target_read_file('D:\DOC\CatchDropTable*.xel', NULL, NULL, NULL)) AS event_table
 CROSS APPLY xml_event_data.nodes('//event') n (event_xml);

SELECT * FROM sys.fn_xe_file_target_read_file('D:\DOC\CatchDropTable*.xel', null, null, null)
WHERE cast(timestamp_utc as datetime2(7)) > dateadd(day, -1, GETUTCDATE())

 
