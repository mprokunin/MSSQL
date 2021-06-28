use master
go
create procedure [ADM_DeadlockTraceOn]
as
BEGIN
	DBCC TRACEON (1204,-1)
	DBCC TRACEON (1222,-1)
END
go
exec sp_procoption @ProcName = [ADM_DeadlockTraceOn], @OptionName = 'STARTUP', @OptionValue = [on]
go
--drop procedure ADM_DeadlockTraceOn 
--exec ADM_DeadlockTraceOn 
--dbcc tracestatus(-1)
--SELECT ROUTINE_NAME FROM MASTER.INFORMATION_SCHEMA.ROUTINES WHERE OBJECTPROPERTY(OBJECT_ID(ROUTINE_NAME),'ExecIsStartup') = 1
