USE [msdb]
GO

/****** Object:  Job [Топ 10 тяжелых запросов]    Script Date: 12/4/2019 5:37:23 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/4/2019 5:37:23 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Топ 10 тяжелых запросов', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Производится рассылка списка наиболее "тяжелых" запросов для их дальнейшей оптимизации.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'SQLAdmin', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [1]    Script Date: 12/4/2019 5:37:23 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'1', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'declare @s varchar(max)

set @s = ''''

select @s = ''<H1>Top 10 наиболее "тяжелых" запросов. Учитывается общее время выполнения и частота исполнения.</H1><table cellpadding=3 cellspacing=0 border=1><tr style="color:White;background-color:SteelBlue;font-weight:bold;">''+
''<td>Avg CPU Time</td><td>Query text</td></tr>'' +
cast ((
select top 10 [Tag] = 1, [Parent] = 0, 
[tr!1!td!element] = qs.total_worker_time/qs.execution_count, 
[tr!1!td!element] = SUBSTRING(st.text, (qs.statement_start_offset/2)+1, 
					((CASE qs.statement_end_offset
					  WHEN -1 THEN DATALENGTH(st.text)
					 ELSE qs.statement_end_offset
					 END - qs.statement_start_offset)/2) + 1) 
			from sys.dm_exec_query_stats AS qs
			CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
			where st.text not like ''%''''DO_NOT_INCLUDE_IN_TOP_HEAVY_STAT'''' = ''''DO_NOT_INCLUDE_IN_TOP_HEAVY_STAT''''%''
			ORDER BY 3 DESC
for xml explicit
) as varchar(max) )+ ''</table>''

EXEC msdb.dbo.sp_send_dbmail @recipients=''mprokunin@renins.com;IDTEAM@renins.com'',
	@profile_name=''DBMailProfile'',
    @subject =''Top 10  REN-MSKSQL19'',
    @Body =@s,
    @body_format = ''HTML'';


', 
		@database_name=N'IrisCoefficientDB', 
		@flags=4
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'По понедельникам', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=2, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20140403, 
		@active_end_date=99991231, 
		@active_start_time=100000, 
		@active_end_time=235959, 
		@schedule_uid=N'dd237170-9f35-4f9b-9afd-f52ff4162228'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


