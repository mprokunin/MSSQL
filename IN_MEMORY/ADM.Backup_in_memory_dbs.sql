USE [msdb]
GO

/****** Object:  Job [ADM.Backup_in_memory_dbs]    Script Date: 26.09.2019 15:20:48 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Notifies]]    Script Date: 26.09.2019 15:20:48 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Notifies]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Notifies]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'ADM.Backup_in_memory_dbs', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Notifies]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [get_availability_group_role]    Script Date: 26.09.2019 15:20:48 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'get_availability_group_role', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'-- Detect if this instance''s role is a Primary Replica.
-- If this instance''s role is NOT a Primary Replica stop the job so that it does not go on to the next job step
DECLARE @rc int; 
EXEC @rc = master.dbo.fn_hadr_group_is_primary N''MIFHADR'';

IF @rc = 0
BEGIN;
    DECLARE @name sysname;
    SELECT  @name = (SELECT name FROM msdb.dbo.sysjobs WHERE job_id = CONVERT(uniqueidentifier, $(ESCAPE_NONE(JOBID))));
    
    EXEC msdb.dbo.sp_stop_job @job_name = @name;
    PRINT ''Stopped the job since this is not a Primary Replica'';
END;', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup mif_qe_dma]    Script Date: 26.09.2019 15:20:48 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup mif_qe_dma', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'declare @exec_str nvarchar(max)
, @db nvarchar(250) = N''mif_qe_dma''
, @path nvarchar(250) = N''E:\BACKUP\MIF\''
, @options nvarchar(500) = '' WITH NOFORMAT, NOINIT,  SKIP, NOREWIND, NOUNLOAD, COMPRESSION, NAME = N''''''
, @hh int, @dw int

select @hh = datepart(hh, getdate())
select @dw = datepart(dw, getdate())

if (@hh > 4) 

begin 
--Log
select @exec_str = ''BACKUP LOG ['' + @db + ''] TO '' + ''disk='''''' + @path + @db +  ''_'' 
+ convert(varchar, convert(date,getdate(),112)) + ''_'' +
+ replace(convert(varchar(8), convert(time,getdate(),108)), '':'', '''') + ''.trn'''''' 
+ @options + @db + ''-LOG backup''''''
--FULL
end 

else if (@dw = 1) -- Sunday Night
begin
-- Full
select @exec_str = ''BACKUP DATABASE ['' + @db + ''] TO '' + ''disk='''''' + @path + @db +  ''_'' + convert(varchar, convert(date,getdate(),112)) + ''-1.bak'''''' 
+ '', disk='''''' + @path + @db +  ''_'' + convert(varchar, convert(date,getdate(),112)) + ''-2.bak'''''' 
+ '', disk='''''' + @path + @db +  ''_'' + convert(varchar, convert(date,getdate(),112)) + ''-3.bak''''''
+ @options + @db + ''-full database backup''''''
end

else 
begin
--Diff
select @exec_str = ''BACKUP DATABASE ['' + @db + ''] TO '' + ''disk='''''' + @path + @db +  ''_'' + convert(varchar, convert(date,getdate(),112)) + ''-1.diff'''''' 
+ '', disk='''''' + @path + @db +  ''_'' + convert(varchar, convert(date,getdate(),112)) + ''-2.diff'''''' 
+ '', disk='''''' + @path + @db +  ''_'' + convert(varchar, convert(date,getdate(),112)) + ''-3.diff''''''
+ @options + @db + ''-DIFFERENTIAL database backup'''', DIFFERENTIAL''
end

--select @exec_str
exec (@exec_str)
go
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 4 hours', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=4, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20190408, 
		@active_end_date=99991231, 
		@active_start_time=35000, 
		@active_end_time=235959, 
		@schedule_uid=N'2254394c-9d28-4182-b43d-1af1ae334537'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


