USE [msdb]
GO

/****** Object:  Job [ADM.CheckFreeSpace]    Script Date: 07.07.2021 17:19:50 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 07.07.2021 17:19:50 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'ADM.CheckFreeSpace', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Check free space on MSSQL drives', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'prokunin@ffin.ru', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check Free Space on Drives]    Script Date: 07.07.2021 17:19:50 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check Free Space on Drives', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'declare @profile nvarchar (255) = N''openrelay''
declare @recipients nvarchar (255) = N''prokunin@ffin.ru''
declare @copy_recipients nvarchar (255) = N''prokunin@ffin.ru''
declare @threshold int = 50 -- Percent free

declare @subject varchar(250)
select @subject = @@servername  + '': free space at drive(s)''


DECLARE @Drive nvarchar(512), @Tot decimal(18,2), @Ava decimal(18,2), @Per decimal(18,2), @Flag int = 0, @PerFree nvarchar(100);
declare @Body nvarchar(max) = ''<html><body><table><tr><th>Drive</th><th>Total_GB</th><th>Free_GB</th><th>Percent_Free</th></tr>''

DECLARE FS_cursor CURSOR FOR 
	
-- Glenn Berry Volume info for all LUNS that have database files on the current instance (Query 26) (Volume Info)
SELECT DISTINCT vs.volume_mount_point as ''Drive'',
CONVERT(DECIMAL(18,2), vs.total_bytes/1073741824.0) AS [Total Size (GB)],
CONVERT(DECIMAL(18,2), vs.available_bytes/1073741824.0) AS [Available Size (GB)],  
CONVERT(DECIMAL(18,2), vs.available_bytes * 1. / vs.total_bytes * 100.) AS [Space Free %]
FROM sys.master_files AS f WITH (NOLOCK)
CROSS APPLY sys.dm_os_volume_stats(f.database_id, f.[file_id]) AS vs 
ORDER BY vs.volume_mount_point OPTION (RECOMPILE) for read only

OPEN FS_cursor  

FETCH NEXT FROM FS_cursor INTO @Drive, @Tot, @Ava, @Per

WHILE @@FETCH_STATUS = 0  
BEGIN  
	if @Per < @threshold
		begin
		select @subject = @subject + case when @flag = 1 then '', '' else '' '' end + @Drive 
		select @Flag = 1, @PerFree = ''<b>'' + convert(nvarchar(19), @Per) + ''</b>''
		end
	else
		set @PerFree = convert(nvarchar(19), @Per)
    select @body = @body + ''<tr><td>'' + convert(nvarchar(19), @Drive) + ''</td><td>'' + convert(nvarchar(19), @Tot) + ''</td><td>'' +  convert(nvarchar(19), @Ava) + ''</td><td>'' +  @PerFree + ''</td></tr>''
	FETCH NEXT FROM FS_cursor INTO @Drive, @Tot, @Ava, @Per
END   
CLOSE FS_cursor;  
DEALLOCATE FS_cursor;  

if (@flag  > 0)
begin 
	select @subject = @subject + '' < '' + CONVERT(nvarchar(2), @threshold) + ''%''
--	select @Body + ''</table></body></html>''
	EXEC msdb.dbo.sp_send_dbmail
		@profile_name = @profile,
		@recipients = @recipients,
		@copy_recipients = @copy_recipients,
		@subject = @subject,
		@body = @Body,
		@body_format = ''HTML''
end

', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'CollectorSchedule_Every_60min', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=60, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20140220, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'be34828d-6b68-446e-9d9c-a66873058e04'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


