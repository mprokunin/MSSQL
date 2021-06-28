select @@SERVERNAME, @@VERSION
go
USE [master]
GO

/****** Object:  StoredProcedure [dbo].[sp_Traceon_1204_1222]    Script Date: 01.08.2018 14:29:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[sp_Traceon_1204_1222] as 
begin
dbcc traceon(1204, -1)
dbcc traceon(1222, -1)
end
GO

EXEC sp_procoption N'[dbo].[sp_Traceon_1204_1222]', 'startup', '1'
GO

exec [master].[dbo].[sp_Traceon_1204_1222]
go

dbcc traceon(3604)
dbcc tracestatus(-1)
----------------------------------------------

USE [msdb]
GO

/****** Object:  Job [ADM.DeadlockJob]    Script Date: 28.09.2018 13:13:37 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 28.09.2018 13:13:37 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'ADM.DeadlockJob', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Notify operetor when deadlock occured', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [_ReadSendDeadlockInfo]    Script Date: 28.09.2018 13:13:37 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'_ReadSendDeadlockInfo', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
if object_id(''tempdb..##error'') is not null drop table ##error
go

create table ##error
(
id int identity(1, 1),
logDate datetime,
processInfo varchar(20),
errorText nvarchar(max)
)

insert into ##error
exec master.dbo.sp_readErrorLog

select logDate, processInfo, errorText
from ##error
where id >=
(
   select max(id)
   from ##error
   where errorText like ''%deadlock encountered%''
)

declare @subject varchar(250), @file varchar(100)
select @subject = ''Deadlock reported on '' + @@servername
select @file = ''DeadlockReport_'' + @@servicename + ''.txt''

EXEC msdb.dbo.sp_send_dbmail
      @profile_name = ''DBMailProfile'',
       @recipients=''mprokunin@renins.com'',
--       @recipients=''SQLAdmin@aton.ru'',
--       @copy_recipients=''_finsupport@aton.ru'',
       @subject = @subject,
       @body = ''A deadlock occured. Further information can be found in the attached file.'',
       @query = ''select logDate, processInfo, errorText
from ##error
where id >=
(
select max(id)
from ##error
where errorText like ''''%deadlock encountered%''''
)'',
       @query_result_width = 600,
      @attach_query_result_as_file = 1, 
     @query_attachment_filename = @file

drop table ##error', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


----------------
USE [msdb]
GO

/****** Object:  Alert [ADM.DeadlockAlert]    Script Date: 28.09.2018 13:13:52 ******/
EXEC msdb.dbo.sp_add_alert @name=N'ADM.DeadlockAlert', 
		@message_id=0, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=0, 
		@category_name=N'[Uncategorized]', 
		@performance_condition=N'Locks|Number of Deadlocks/sec|_Total|>|0'
--		, 		@job_id=N'bc0ed141-0efc-4c34-b715-06bd6c5f4fa6'
GO

