------------ Get list of Server Triggers

select top 100 * from sys.server_triggers


------------ Get Server Triggers Definitions
SELECT
    SSM.definition
FROM
    sys.server_triggers AS ST JOIN
    sys.server_sql_modules AS SSM
        ON ST.object_id = SSM.object_id


SELECT name, OBJECT_DEFINITION ([object_id]) 
FROM sys.server_triggers
WHERE name = N'trg_Logon_ConnectionFilter'
;
SELECT name, OBJECT_DEFINITION ([object_id]) 
FROM sys.server_triggers
WHERE name = N'ServerAuditTrigger'
;

CREATE TRIGGER [trg_Logon_ConnectionFilter]  ON ALL SERVER WITH EXECUTE AS 'sa'  
FOR LOGON  AS  BEGIN     
BEGIN TRY    SET XACT_ABORT OFF      
IF ORIGINAL_LOGIN() = 'python_conn'     
BEGIN     
DECLARE @IPAddress nvarchar(30) = ''     
SELECT @IPAddress = ISNULL(client_net_address, '')      
	FROM sys.dm_exec_connections      
	WHERE session_id = @@SPID       
IF (@IPAddress NOT IN       (       '172.17.56.42',       '172.17.57.28',       '172.17.56.23',       '172.17.11.185',       '172.17.7.183',       '172.17.11.128',       '172.17.57.19',       '172.17.56.28',       '172.17.57.90',       '172.17.57.89'))     
	BEGIN      DECLARE @Now datetime = GETDATE();      
	DECLARE @Message nvarchar(100)= 'Access denied for [python_conn] from ' + @IPAddress;      
	ROLLBACK;      
	EXEC RMTelemetry.dbo.LogEvent 0, 121, 0, @Now, 'AL-COD3-SQL-03', 3, @Message, NULL     
	END    
END      
SET XACT_ABORT ON   
END TRY   
BEGIN CATCH    
-- Log to do : 	log SQL Server error somehow    
	SET XACT_ABORT ON   
END CATCH    END;  
-------
CREATE TRIGGER [ServerAuditTrigger] ON ALL SERVER  FOR DDL_SERVER_LEVEL_EVENTS  
AS  
DECLARE @data XML;  
DECLARE @eventtype sysname;  
DECLARE @PostTime sysname;  
DECLARE @LoginName sysname;  
DECLARE @UserName sysname;  
DECLARE @object sysname;  
DECLARE @tsql sysname;  
DECLARE @message varchar(max);  
DECLARE @path varchar(200);  

SET @data = EVENTDATA();  
SET @eventType = @data.value('(/EVENT_INSTANCE/EventType)[1]', 'sysname')  
SET @PostTime = @data.value('(/EVENT_INSTANCE/PostTime)[1]','sysname')  
SET @LoginName = @data.value('(/EVENT_INSTANCE/LoginName)[1]','sysname')  
SET @UserName = @data.value('(/EVENT_INSTANCE/UserName)[1]','sysname')  
SET @object = @data.value('(/EVENT_INSTANCE/DatabaseName)[1]','sysname')  
SET @tsql=EVENTDATA().value('(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]','nvarchar(max)')  
SET @message=' On server '+ @@servername+ ' login name '+ isnull(@LoginName,'UNKNOWN')+',user '  +ISNULL(@UserName,'UNKNOWN')+' run the command '+ isnull(@eventType, 'Unknown Database Operation')  + ' on database '+ISNULL(@object,'UNKNOWN')+' at '+ISNULL(@PostTime,'UNKNOWN') + '. '  
SET @message=@message + 'SQL Command is:'  
SET @message=@message + isnull(@tsql,'')    
--select @message
insert into ServerAudit values (getdate(), @message,0)    

select top 100 * from ServerAudit

CREATE TRIGGER [trg_Logon_ConnectionFilter]  ON ALL SERVER 
WITH EXECUTE AS 'sa'  
FOR LOGON  AS  
BEGIN     
IF ORIGINAL_LOGIN() = 'python_conn'    
	BEGIN    
	DECLARE @IPAddress nvarchar(30) = ''    
	SELECT @IPAddress = ISNULL(client_net_address, '')     
	FROM sys.dm_exec_connections     WHERE session_id = @@SPID      
	
	IF (@IPAddress NOT IN      (      '172.17.56.42',      '172.17.57.28',      '172.17.56.23',      '172.17.11.185',      '172.17.7.183',      '172.17.11.128',      '172.17.57.19',      '172.17.56.28'))    
		BEGIN     
		DECLARE @Now datetime = GETDATE();     
		DECLARE @Message nvarchar(100)= 'Access denied for [python_conn] from ' + @IPAddress;     ROLLBACK;     
		EXEC RMTelemetry.dbo.LogEvent 0, 121, 0, @Now, 'AL-COD3-SQL-03', 3, @Message, NULL    
		END   
	END  
END;  

select top 100 * from RMTelemetry.dbo.Events

CREATE TRIGGER [trg_Logon_Prioritisation]  ON ALL SERVER WITH EXECUTE AS 'sa'  FOR LOGON  AS  
BEGIN   if IS_SRVROLEMEMBER('LowPriorityReaders') = 1    
	BEGIN    SET DEADLOCK_PRIORITY -10;    
	SET LOCK_TIMEOUT 2000; -- 2 second   
	END;  
END;  

-- AOLFRONT03\SQL2008
CREATE TRIGGER [ServerAuditTrigger] ON ALL SERVER  FOR DDL_SERVER_LEVEL_EVENTS  
AS  
DECLARE @data XML;  DECLARE @eventtype sysname;  DECLARE @PostTime sysname;  DECLARE @LoginName sysname;  DECLARE @UserName sysname;  
DECLARE @object sysname;  DECLARE @tsql sysname;  DECLARE @message varchar(max);  DECLARE @path varchar(200);  

SET @data = EVENTDATA();  
SET @eventType = @data.value('(/EVENT_INSTANCE/EventType)[1]', 'sysname')  
SET @PostTime = @data.value('(/EVENT_INSTANCE/PostTime)[1]','sysname')  
SET @LoginName = @data.value('(/EVENT_INSTANCE/LoginName)[1]','sysname')  
SET @UserName = @data.value('(/EVENT_INSTANCE/UserName)[1]','sysname')  
SET @object = @data.value('(/EVENT_INSTANCE/DatabaseName)[1]','sysname')  
SET @tsql=EVENTDATA().value('(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]','nvarchar(max)')  
SET @message=' On server '+ @@servername+ ' login name '+ isnull(@LoginName,'UNKNOWN')+',user '  +ISNULL(@UserName,'UNKNOWN')
	+ ' run the command '+ isnull(@eventType, 'Unknown Database Operation')  
	+ ' on database '+ISNULL(@object,'UNKNOWN')+' at '+ISNULL(@PostTime,'UNKNOWN') 
	+ '. '  SET @message=@message + 'SQL Command is:'  SET @message=@message + isnull(@tsql,'')    
insert into ServerAudit values (getdate(), @message,0)    

SELECT TOP 100 * from ServerAudit order by d desc
 On server AOLFRONT03\SQL2008 login name ICATON\Prokunin,user UNKNOWN run the command CREATE_LOGIN on database UNKNOWN at 2018-08-03T16:02:06.677. SQL Command is:CREATE LOGIN [ICATON\SqlDocGenerator] FROM WINDOWS WITH DEFAULT_DATABASE=[master]



 CREATE TRIGGER [ServerAuditTrigger] ON ALL SERVER  FOR DDL_SERVER_LEVEL_EVENTS  
 AS  
 DECLARE @data XML;  
 DECLARE @eventtype sysname;  
 DECLARE @PostTime sysname;  
 DECLARE @LoginName sysname;  
 DECLARE @UserName sysname;  
 DECLARE @object sysname;  
 DECLARE @tsql sysname;  
 DECLARE @message varchar(max);  
 DECLARE @path varchar(200);  SET @data = EVENTDATA();  SET @eventType = @data.value('(/EVENT_INSTANCE/EventType)[1]', 'sysname')  SET @PostTime = @data.value('(/EVENT_INSTANCE/PostTime)[1]','sysname')  SET @LoginName = @data.value('(/EVENT_INSTANCE/LoginName)[1]','sysname')  SET @UserName = @data.value('(/EVENT_INSTANCE/UserName)[1]','sysname')  SET @object = @data.value('(/EVENT_INSTANCE/DatabaseName)[1]','sysname')  SET @tsql=EVENTDATA().value('(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]','nvarchar(max)')  SET @message=' On server '+ @@servername+ ' login name '+ isnull(@LoginName,'UNKNOWN')+',user '  +ISNULL(@UserName,'UNKNOWN')+' run the command '+ isnull(@eventType, 'Unknown Database Operation')  + ' on database '+ISNULL(@object,'UNKNOWN')+' at '+ISNULL(@PostTime,'UNKNOWN') + '. '  SET @message=@message + 'SQL Command is:'  SET @message=@message + isnull(@tsql,'')    insert into ServerAudit values (getdate(), @message,0)    


 select top 100 * from RMTelemetry.dbo.Events where TimeStamp > '2019-03-10'


 exec RMTelemetry..sp_helptext LogEvent 


   
  
CREATE PROCEDURE [dbo].[LogEvent]  
 @SessionId int = NULL,  
 @SourceId smallint = NULL,  
 @ComponentId int = 0,  
 @TimeStamp datetime,  
 @MachineName nvarchar(50) = NULL,  
 @EventTypeId smallint,  
 @Message nvarchar(MAX),  
 @Metadata nvarchar(MAX) = NULL  
AS  
BEGIN  
  
 IF @SourceId IS NULL  
 BEGIN  
  SELECT @SourceId = ISNULL(SourceId, 0)  
  FROM [EventTypes]  
  WHERE Id = @EventTypeId  
 END  
  
 IF DATALENGTH(@Message) > 100  
  BEGIN  
   INSERT INTO [dbo].[Events] (SessionId, SourceId, ComponentId, TimeStamp, MachineName, EventTypeId, Message)  
   VALUES (@SessionId, @SourceId, @ComponentId, @TimeStamp, @MachineName, @EventTypeId, SUBSTRING(@Message, 1, 96) + '...')  
  END  
 ELSE  
  BEGIN  
   INSERT INTO [dbo].[Events] (SessionId, SourceId, ComponentId, TimeStamp, MachineName, EventTypeId, Message)  
   VALUES (@SessionId, @SourceId, @ComponentId, @TimeStamp, @MachineName, @EventTypeId, @Message)  
  END  
  
 IF @Metadata IS NOT NULL  
  BEGIN  
   IF (DATALENGTH(@Message) > 100)  
    BEGIN  
     INSERT INTO [dbo].[EventMetadata] (EventId, Metadata)  
     VALUES (@@IDENTITY,  'Message: ' + @Message + char(13) + char(10) + 'Metadata: ' + @Metadata)  
    END  
   ELSE  
    BEGIN  
     INSERT INTO [dbo].[EventMetadata] (EventId, Metadata)  
     VALUES (@@IDENTITY, @Metadata)  
    END  
  END  
 ELSE  
  IF (DATALENGTH(@Message) > 100)  
   BEGIN  
    INSERT INTO [dbo].[EventMetadata] (EventId, Metadata)  
    VALUES (@@IDENTITY,  'Message: ' + @Message)  
   END  
END  

exec RMTelemetry..sp_help [Events]

