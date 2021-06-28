DECLARE 
	@SessionName SysName 
	, @TopCount Int = 10000
	
--SELECT @SessionName = 'PlanCacheRemoval'
SELECT @SessionName = 'Recompiles'

--SELECT @SessionName = 'system_health'
/* 
SELECT * FROM sys.traces

SELECT  Session_Name = s.name, s.blocked_event_fire_time, s.dropped_buffer_count, s.dropped_event_count, s.pending_buffers
FROM sys.dm_xe_session_targets t
	INNER JOIN sys.dm_xe_sessions s ON s.address = t.event_session_address
WHERE target_name = 'event_file'
--*/

IF OBJECT_ID('tempdb..#Events') IS NOT NULL BEGIN
	DROP TABLE #Events
END

IF OBJECT_ID('tempdb..#Queries') IS NOT NULL BEGIN
	DROP TABLE #Queries 
END

DECLARE @Target_File NVarChar(1000)
	, @Target_Dir NVarChar(1000)
	, @Target_File_WildCard NVarChar(1000)

SELECT @Target_File = CAST(t.target_data as XML).value('EventFileTarget[1]/File[1]/@name', 'NVARCHAR(256)')
FROM sys.dm_xe_session_targets t
	INNER JOIN sys.dm_xe_sessions s ON s.address = t.event_session_address
WHERE s.name = @SessionName
	AND t.target_name = 'event_file'

SELECT @Target_Dir = LEFT(@Target_File, Len(@Target_File) - CHARINDEX('\', REVERSE(@Target_File))) 

SELECT @Target_File_WildCard = @Target_Dir + '\'  + @SessionName + '_*.xel'

--SELECT @Target_File_WildCard
CREATE TABLE #Events 
(
	event_data_XML XML
)

INSERT INTO #Events 
SELECT TOP (@TopCount) CAST(event_data AS XML) AS event_data_XML
FROM sys.fn_xe_file_target_read_file(@Target_File_WildCard, null, null, null) AS F
ORDER BY File_name DESC
	, file_offset DESC 

SELECT  EventType = event_data_XML.value('(event/@name)[1]', 'varchar(50)')
	, ObjectName = event_data_XML.value ('(/event/data  [@name=''object_name'']/value)[1]', 'sysname')
	, ObjectType = event_data_XML.value ('(/event/data  [@name=''object_type'']/text)[1]', 'sysname')
	, UserName = event_data_XML.value ('(/event/action  [@name=''username'']/value)[1]', 'sysname')
	, Statement_Text = ISNULL(ISNULL(event_data_XML.value ('(/event/data  [@name=''statement'']/value)[1]', 'NVARCHAR(4000)'), event_data_XML.value ('(/event/data  [@name=''batch_text''     ]/value)[1]', 'NVARCHAR(4000)')), event_data_XML.value ('(/event/data[@name=''wait_type'']/text)[1]', 'NVARCHAR(60)'))
	, Recompile_Cause = event_data_XML.value ('(/event/data  [@name=''recompile_cause'']/text)[1]', 'sysname')
	, TimeStamp = DateAdd(Hour, DateDiff(Hour, GetUTCDate(), GetDate()) , CAST(event_data_XML.value('(event/@timestamp)[1]', 'varchar(50)') as DateTime2))
	, SPID = event_data_XML.value ('(/event/action  [@name=''session_id'']/value)[1]', 'BIGINT')
	, Database_Name = DB_Name(event_data_XML.value ('(/event/action  [@name=''database_id'']/value)[1]', 'BIGINT'))
	, EventDetails = event_data_XML 
INTO #Queries
FROM #Events

SELECT q.EventType
	, q.ObjectType
	, q.ObjectName
	, q.Statement_Text
	, q.Recompile_Cause
	, q.TimeStamp
	, q.SPID
	, q.UserName
	, q.Database_Name
	, q.EventDetails
FROM #Queries q
--where q.EventType like '%recom%'
--where q.Statement_Text like '%AgrLoadById_TravelInsuranceProcessBasket%'
ORDER BY TimeStamp DESC 
