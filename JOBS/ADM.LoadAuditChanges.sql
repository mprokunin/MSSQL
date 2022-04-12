USE [msdb]
GO

/****** Object:  Job [ADM.LoadAuditChanges_ABHADR]    Script Date: 28.08.2019 20:38:30 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 28.08.2019 20:38:31 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'ADM.LoadAuditChanges_ABHADR', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'ICABC\Prokunin', 
		@notify_email_operator_name=N'SQLAdmin@ABC.ru', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Load Audit files SQL105\AB]    Script Date: 28.08.2019 20:38:31 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Load Audit files SQL105\AB', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'use monitoring
go
-- Read all audit file names into #AF
create table #AF (ID int IDENTITY, FileName nvarchar(260))
insert into #AF execute xp_cmdshell ''dir \\sql105\ChangesAudit$\*.sqlaudit /b/s''
delete from #AF where FileName is NULL
--delete from #AF where FileName= ''\\sql105\ChangesAudit$\Changes_790D190A-A781-431A-B435-ABBE90B0BC74_0_131894041965190000.sqlaudit'' -- corrupted

if exists (select file_name from [dbo].[audit_changes_ABCBASE_2019])
	begin
	delete from #AF where FileName in (select file_name from [dbo].[audit_changes_ABCBASE_2019])
	insert into #AF (FileName) select top 1 file_name from [dbo].[audit_changes_ABCBASE_2019] order by event_time desc
	end
--select * from #AF
---------------
declare @FN nvarchar(260), @MAXEVENTTIME datetime, @cnt int = 0
select @MAXEVENTTIME = coalesce(max(event_time), ''1970-01-01 00:00:00'') from [dbo].[audit_changes_ABCBASE_2019]
select @MAXEVENTTIME 
DECLARE AUD_File CURSOR FOR 
	SELECT FileName FROM #AF
OPEN AUD_File  

FETCH NEXT FROM AUD_File INTO @FN

WHILE @@FETCH_STATUS = 0 and @cnt < 1000 
BEGIN  
	select @FN
	insert into [dbo].[audit_changes_ABCBASE_2019] select event_time, sequence_number, action_id, session_id, object_id, session_server_principal_name, database_principal_name, server_instance_name, database_name,schema_name, object_name, statement, file_name  
		FROM sys.fn_get_audit_file (@FN,default,default) where event_time >= @MAXEVENTTIME and action_id <> ''VW'';  
	select @cnt = @cnt + 1
	FETCH NEXT FROM Aud_File INTO @FN
END   
CLOSE AUD_File;  
DEALLOCATE AUD_File;  
drop table #AF;
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Daily at 07', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20181227, 
		@active_end_date=99991231, 
		@active_start_time=70100, 
		@active_end_time=235959, 
		@schedule_uid=N'e9027bf4-cba1-42c9-af08-e189d4f28158'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Daily at 18', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20181227, 
		@active_end_date=99991231, 
		@active_start_time=180100, 
		@active_end_time=235959, 
		@schedule_uid=N'01fdfd7c-6cc1-48da-8208-4a344ed00dfd'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Daily at 23', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20181227, 
		@active_end_date=99991231, 
		@active_start_time=230100, 
		@active_end_time=235959, 
		@schedule_uid=N'fa92df64-9c83-41c1-ac7e-30e6ac223c8c'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

