USE [msdb]
GO

/****** Object:  Job [ADM.TopLogicalReads]    Script Date: 03.12.2019 9:03:34 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Notifies]]    Script Date: 03.12.2019 9:03:34 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Notifies]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Notifies]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'ADM.TopLogicalReads', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Get top 10 IO reads from Query Store', 
		@category_name=N'[Notifies]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'SQLAdmin', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Get Top 10 Total IO Reads from Query Store]    Script Date: 03.12.2019 9:03:34 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Get Top 10 Total IO Reads from Query Store', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'declare 	@MailProfile sysname =  ''DBMailProfile''
	, @Recip varchar(max) = ''mprokunin@renins.com'' 
--	, @CopyRecip varchar(max) = ''mprokunin@renins.com'' 
	, @CopyRecip varchar(max) = ''WebDev_Integration@renins.com''
----- Version 
declare @version varchar(100) = ''ver. 1.2 Dec 3,2019''

declare @html varchar(max), @rowstr varchar(1000), @cnt int = 0

select @html = '' 
<html>    
<head>    
<title>Yesterday Top 10 Total Logical IO Reads</title>    
</head>    
<body>    
<h3>Yesterday Top 10 Total Logical IO Reads in '' + db_name() + ''</h3>
<table border="1">    
<tr><td> Million io_reads </td> <td> query_id </td> <td> plan_id </td> <td> procedure </td> <td> query_sql_text </td> </tr>''    


DECLARE QS_cursor CURSOR FOR 
SELECT ''<tr valign="top"><td>''
	+convert(varchar(10),convert(numeric(10,0),max(Stat.avg_logical_io_reads/1000000*Stat.count_executions)))+''</td><td>'' 
	+convert(varchar,Pl.query_id)+''</td><td>'' 
	+convert(varchar,Pl.plan_id)+''</td><td>'' 
	+isnull(object_name(Qry.object_id),'''')+''</td><td>'' 
	+isnull(convert(varchar(255),Txt.query_sql_text),'''')
	+''</td></tr>'' 
FROM sys.query_store_plan AS Pl  
INNER JOIN sys.query_store_query AS Qry  
    ON Pl.query_id = Qry.query_id  
INNER JOIN sys.query_store_query_text AS Txt  
    ON Qry.query_text_id = Txt.query_text_id 
INNER JOIN sys.query_store_runtime_stats Stat on Stat.plan_id = Pl.plan_id
and Stat.last_execution_time > dateadd(hh, -4, getdate())
group by Pl.query_id, Txt.query_sql_text, Qry.object_id, Pl.plan_id
order by max(Stat.avg_logical_io_reads/1000000*Stat.count_executions) desc

OPEN QS_cursor  

FETCH NEXT FROM QS_cursor INTO @rowstr

WHILE @@FETCH_STATUS = 0 and @cnt < 10
BEGIN  
	select @html = @html + @rowstr
	select @cnt = @cnt + 1
	FETCH NEXT FROM QS_cursor INTO @rowstr
END   
CLOSE QS_cursor;  
DEALLOCATE QS_cursor;  


select @html =@html + ''</table>
<br><div style="color:white">'' + @version +  ''</div>
</body>
</html>''

-------------------- Send
declare @subject varchar(250)
select @subject = ''Query Store Top 10 IO Reads in '' + @@servername + ''.'' + db_name()

EXEC msdb.dbo.sp_send_dbmail
      @profile_name = @MailProfile 
      , @recipients= @Recip
      , @copy_recipients= @CopyRecip
      , @subject = @subject
      , @body_format = ''html''
      , @body = @html

', 
		@database_name=N'DI_STAT', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Dayly', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=127, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20191202, 
		@active_end_date=99991231, 
		@active_start_time=100, 
		@active_end_time=235959, 
		@schedule_uid=N'dc353578-6d15-4eae-9847-78cb06e438c5'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


