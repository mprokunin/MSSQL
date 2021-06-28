--check to see if  the database is broker enabled
select name , is_broker_enabled from sys.databases
 alter database Ssisdb set enable_broker with rollback immediate
--Check Service Broker activated stored procedures
SELECT t.*, s.last_wait_type,* FROM sys.dm_broker_activated_tasks t
INNER JOIN sys.dm_exec_requests s ON s.session_id = t.spid

--check if queues are enabled
select name,is_receive_enabled,is_enqueue_enabled from sys.service_queues
 
--check tcp endpoints for SERVICE BROKER
select * from sys.tcp_endpoints
 

--Check Service Broker network connections
select * from sys.dm_broker_connections
 
--List Queue Monitors
select db_name(database_id),* from sys.dm_broker_queue_monitors


-----------

--list out SCCM sites
Select * from Sites
 
--Object Lock States for “Serialized Editing of Data Objects”
select * from SEDO_LockState where LockStateID = 1 
--ConfigMgr 2012 and DRS Initialization troubleshooting
select * from vLogs where LogTime > GETDATE()-1 and ProcedureName <> 'spDRSSendChangesForGroup' order by LogTime DESC