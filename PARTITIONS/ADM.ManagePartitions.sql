USE [msdb]
GO

/****** Object:  Job [ADM.ManagePartitions]    Script Date: 6/22/2020 1:43:24 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Notifies]]    Script Date: 6/22/2020 1:43:24 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Notifies]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Notifies]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'ADM.ManagePartitions', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=3, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Notifies]', 
		@owner_login_name=N'RIMOS_NT_01\MProkunin', 
		@notify_email_operator_name=N'SQLAdmin', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Add New Partition]    Script Date: 6/22/2020 1:43:24 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Add New Partition', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'use [REN_LOG]
go
declare @path varchar(100) = ''J:\renlog.data\REN_LOG_'', @partname1 char(8), @partname2 char(8), @exestr varchar(max) = '''', @i int =1;
select @partname1 = convert(char(8), dateadd(dd, @i, getdate()), 112)
select @partname2 = convert(char(8), dateadd(dd, @i+1, getdate()), 112)
select @exestr = ''ALTER DATABASE [REN_LOG] ADD FILEGROUP [REN_LOG_FG_'' + @partname1 + '']''
--select @exestr
exec (@exestr)
select @exestr = ''ALTER DATABASE [REN_LOG] ADD FILE (NAME = [REN_LOG_'' + @partname1 + ''], FILENAME = '''''' + @path + @partname1 + ''.ndf'''', SIZE = 10240 KB, FILEGROWTH = 10240 KB) TO FILEGROUP [REN_LOG_FG_'' + @partname1 + '']''
--select @exestr
exec (@exestr)
select @exestr = ''Alter Partition Scheme Daily_PS NEXT USED [REN_LOG_FG_'' + @partname1 + '']''
--select @exestr
exec (@exestr)
select @exestr = ''Alter Partition function Daily_PF() split range ('''''' + @partname2 + '''''')''
--select @exestr
exec (@exestr)
go', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Drop Partition 1]    Script Date: 6/22/2020 1:43:24 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Drop Partition 1', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'---- Swith Partition
ALTER TABLE [Message] SWITCH PARTITION 1 TO [Message_TMP] PARTITION 1
go
truncate table [Message_TMP]
go
ALTER TABLE [MessageParamCompressed] SWITCH PARTITION 1 TO [MessageParamCompressed_TMP] PARTITION 1 
go
truncate table [MessageParamCompressed_TMP]
go
ALTER TABLE [MessageParamText] SWITCH PARTITION 1 TO [MessageParamText_TMP] PARTITION 1 
go
truncate table [MessageParamText_TMP]
go

declare @MIN_RANGE sql_variant, @OLD_FG sysname, @EXESTR varchar(max)
set @MIN_RANGE=(select top 1 boundary_value from PartitionRanges where partition_function=''Daily_PF'' and boundary_value is not null order by boundary_value)
select convert(char(8), dateadd(dd, -1, convert(datetime, @MIN_RANGE)), 112)
select @EXESTR = ''Alter Partition function Daily_PF() merge range ('''''' + convert(varchar(23), @MIN_RANGE) + '''''')'' 
exec (@EXESTR)
--select  (@EXESTR)
select @EXESTR = ''alter database REN_LOG remove file REN_LOG_'' + convert(char(8), dateadd(dd, -1, convert(datetime, @MIN_RANGE)), 112)
--select  (@EXESTR)
exec (@EXESTR)
go', 
		@database_name=N'REN_LOG', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Daily', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20200319, 
		@active_end_date=99991231, 
		@active_start_time=300, 
		@active_end_time=235959, 
		@schedule_uid=N'8d8e1f2b-f48f-44c9-b3c0-f8fad8ed21b3'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


