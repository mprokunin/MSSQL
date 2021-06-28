-- Where are Service Broker Enabled
select top 100 db_name(database_id) as 'DB',* from sys.dm_broker_queue_monitors order by DB
go
-- Queue status
select @@SERVERNAME, db_name()
use mif;

SELECT t1.name AS [Service_Name],  t3.name AS [Schema_Name],  t2.name AS [Queue_Name],    
CASE WHEN t4.state IS NULL THEN 'Not available'   
ELSE t4.state   
END AS [Queue_State],    
CASE WHEN t4.tasks_waiting IS NULL THEN '--'   
ELSE CONVERT(VARCHAR, t4.tasks_waiting)   
END AS tasks_waiting,   
CASE WHEN t4.last_activated_time IS NULL THEN '--'   
ELSE CONVERT(varchar, t4.last_activated_time)   
END AS last_activated_time ,    
CASE WHEN t4.last_empty_rowset_time IS NULL THEN '--'   
ELSE CONVERT(varchar,t4.last_empty_rowset_time)   
END AS last_empty_rowset_time,   
(   
SELECT COUNT(*)   
FROM sys.transmission_queue t6   
WHERE (t6.from_service_name = t1.name) ) AS [Tran_Message_Count]   
FROM sys.services t1    INNER JOIN sys.service_queues t2   
ON ( t1.service_queue_id = t2.object_id )     
INNER JOIN sys.schemas t3 ON ( t2.schema_id = t3.schema_id )    
LEFT OUTER JOIN sys.dm_broker_queue_monitors t4   
ON ( t2.object_id = t4.queue_id  AND t4.database_id = DB_ID() )    
INNER JOIN sys.databases t5 ON ( t5.database_id = DB_ID() )
order by 1,3;


SELECT q.name, t.*
FROM sys.dm_broker_activated_tasks t ,
sys.service_queues q
WHERE t.queue_id = q.object_id
go


-- Get Errors
select *, cast(message_body as xml)
from DI_STAT.sys.transmission_queue with (nolock) ---The session keys for this conversation could not be created or accessed. The database master key is required for this operation. 
--where enqueue_time < '2018-01-01'

select *, cast(message_body as xml) from Candles.sys.transmission_queue with (nolock) ---The session keys for this conversation could not be created or accessed. The database master key is required for this operation. 
select *, cast(message_body as xml) from mif.sys.transmission_queue with (nolock) ---The session keys for this conversation could not be created or accessed. The database master key is required for this operation. 
select *, cast(message_body as xml) from Signal.sys.transmission_queue with (nolock) ---The session keys for this conversation could not be created or accessed. The database master key is required for this operation. 

declare @c uniqueidentifier,
select GET_TRANSMISSION_STATUS('F76014E5-4A44-E511-9F91-78E3B50038C4')


SELECT q.name, m.tasks_waiting, DB_NAME(database_id), m.*
FROM sys.dm_broker_queue_monitors m
JOIN sys.service_queues q
ON m.queue_id = q.object_id
--WHERE q.name = 'queue_LETI_Import_Starter'
go

select db_name(database_id),* FROM sys.dm_broker_queue_monitors -- 462336782
select * from sys.service_queues


select top 10 * from [dbo].[MifMessageQueue]
select top 10 * from [dbo].[ExternalMessageQueue]
-------------- Clear the Queue

declare @c uniqueidentifier
while(1=1)
begin
--    select top 1 @c = conversation_handle from [dbo].[CandlesMessageQueue]
    select top 1 @c = conversation_handle from Candles.sys.transmission_queue where enqueue_time < '2018-01-01'
	if (@@ROWCOUNT = 0)
    break
    end conversation @c with cleanup
end

-- check conversations
Select top 2000 * From sys.conversation_endpoints ce Where ce.state <> 'CD'  order by state


-- Clear DISCONNECTED_INBOUND conversations
DECLARE @handle UNIQUEIDENTIFIER;
WHILE (SELECT COUNT(*) from sys.conversation_endpoints (nolock) where state_desc = 'DISCONNECTED_INBOUND') > 0
BEGIN
	SELECT TOP 1 @handle = conversation_handle from sys.conversation_endpoints (nolock) where state_desc = 'DISCONNECTED_INBOUND';
	END CONVERSATION @handle WITH CLEANUP
END

-------------EndPointPorts
SELECT tcpe.port, *
FROM sys.tcp_endpoints AS tcpe  
INNER JOIN sys.service_broker_endpoints AS ssbe  
   ON ssbe.endpoint_id = tcpe.endpoint_id  
WHERE ssbe.name = N'ATDPNotificationEndpoint'; 


/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) *, casted_message_body = 
CASE message_type_name WHEN 'X' 
  THEN CAST(message_body AS NVARCHAR(MAX)) 
  ELSE message_body 
END 
FROM [DI_STAT].[dbo].[ProcQueue1] WITH(NOLOCK)


alter QUEUE DI_STAT.dbo.ProcQueue1 with status = OFF
alter QUEUE DI_STAT.dbo.ProcQueue1 with status = ON

