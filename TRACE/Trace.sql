-- Check if default trace is enabled
SELECT * FROM sys.configurations WHERE   name like 'default trace enabled'

-- Enable default trace
USE   master;
GO
EXEC   sp_configure 'show advanced option',   '1';
reconfigure
go
exec   sp_configure 'default trace enabled',   1
reconfigure
GO


-- Traces Info
SELECT   * FROM sys.traces 
	WHERE id = 1;

SELECT * FROM sys.fn_trace_getinfo(0)
SELECT * FROM sys.fn_trace_getinfo(default); --property 5 = Current trace status. 0 = stopped. 1 = running.
SELECT * FROM sys.fn_trace_getinfo(2); --property 5 = Current trace status. 0 = stopped. 1 = running.

exec sp_trace_setstatus @traceid = 0, @property = 1 -- start trace #3
exec sp_trace_setstatus @traceid = 3, @status = 1 -- start trace #3

-- Get events
drop table tempdb..TRACETAB
DECLARE @PROC varchar(100), @EXESTR varchar(max), @TRACETAB sysname = 'TRACETAB'
select @EXESTR= 'select * into TEMPDB..' + @TRACETAB + ' from fn_trace_gettable(''C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Log\log_138.trc'',default)'
select @EXESTR
exec (@EXESTR)
--select top 1000 DatabaseName, ObjectName, * from tempdb..TRACETAB where EventClass in (46, 47, 164) and DatabaseID = 5 -- and ObjectName like '%NT_Import_ExchangeFiles%'
select top 1000 DatabaseName, ObjectName, * from tempdb..TRACETAB where DatabaseID = db_id('Quik_Export') -- and ObjectName like '%NT_Import_ExchangeFiles%'




select * from sys.trace_events -- type of events
where name like '%alter%'
-- log_2849.trc 2021-07-16 13:19:39.770  2021-07-17 09:58:57.063
-- log_2850.trc 2021-07-16 16:00:04.72  2021-07-17 09:57:15.390
-- log_2851.trc 2021-07-16 19:28:32.950 2021-07-17 09:57:54.860
select min(Starttime) from tempdb..TRACETAB -- log_2851.trc 7 | log_2851.trc 2021-07-16 19:28:32.950
select max(Starttime) from tempdb..TRACETAB -- log_2851.trc 2021-07-17 09:53:42.250


--select top 100 * from tempdb..TRACETAB where ObjectName <> 'telemetry_xevents'
select top 1000 * from tempdb..TRACETAB where EventClass in (46, 47, 164) and DatabaseID <> 2 -- drop, create, alter
select top 1000 * from tempdb..TRACETAB where EventClass in (46, 47, 164) and DatabaseID = 5 and ObjectName like '%NT_Import_ExchangeFiles%'
select top 1000 ObjectName from tempdb..TRACETAB where EventClass in (46, 47, 164) and DatabaseID = 5 and StartTime > '2021-07-27' group by ObjectName

------------
-- Schema Changes
DECLARE   @filename nvarchar(1000);
 
-- Get the name of the current default trace
SELECT   @filename = cast(value as nvarchar(1000))
FROM   ::fn_trace_getinfo(default)
WHERE   traceid = 1 and   property = 2;
 
-- view current trace file
SELECT  top 100  *
FROM   ::fn_trace_gettable(@filename, default) AS ftg 
INNER   JOIN sys.trace_events AS te ON ftg.EventClass = te.trace_event_id  
WHERE (ftg.EventClass = 46 or ftg.EventClass = 47)
and   DatabaseName <> 'tempdb' 
and   EventSubClass = 0
ORDER   BY ftg.StartTime;

--------------
-- Autogrowth Events
DECLARE   @filename nvarchar(1000);
 
-- Get the name of the current default trace
SELECT   @filename = cast(value as nvarchar(1000))
FROM   ::fn_trace_getinfo(default)
WHERE   traceid = 1 and   property = 2;
 
-- Find auto growth events in the current trace file
SELECT
    ftg.StartTime
 ,te.name as EventName
 ,DB_NAME(ftg.databaseid) AS DatabaseName  
 ,ftg.Filename
 ,(ftg.IntegerData*8)/1024.0 AS GrowthMB 
 ,(ftg.duration/1000)as DurMS
FROM   ::fn_trace_gettable(@filename, default) AS ftg 
INNER   JOIN sys.trace_events AS te ON ftg.EventClass = te.trace_event_id  
WHERE (ftg.EventClass = 92  -- Date File Auto-grow
      OR ftg.EventClass   = 93) -- Log File Auto-grow
ORDER BY   ftg.StartTime

------------
-- Security Changes
DECLARE   @filename nvarchar(1000);
 
-- Get the name of the current default trace
SELECT   @filename = cast(value as nvarchar(1000))
FROM   ::fn_trace_getinfo(default)
WHERE   traceid = 1 and   property = 2;
 
-- process all trace files
SELECT   *  
FROM   ::fn_trace_gettable(@filename, default) AS ftg 
INNER   JOIN sys.trace_events AS te ON ftg.EventClass = te.trace_event_id  
WHERE   ftg.EventClass 
      in (102,103,104,105,106,108,109,110,111)
  ORDER BY   ftg.StartTime



-------- Grant permissions
grant view server state to [abc]
grant alter trace to [abc]
