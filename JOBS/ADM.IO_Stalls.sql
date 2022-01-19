USE [master]
GO

/****** Object:  Table [dbo].[io_stalls]    Script Date: 22.02.2019 11:31:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[io_stalls](
	[DT] [datetime] NULL,
	[Database Name] [nvarchar](128) NULL,
	[avg_read_stall_ms] [numeric](10, 1) NULL,
	[avg_write_stall_ms] [numeric](10, 1) NULL,
	[avg_io_stall_ms] [numeric](10, 1) NULL,
	[File Size (MB)] [decimal](18, 2) NULL,
	[physical_name] [nvarchar](260) NOT NULL,
	[type_desc] [nvarchar](60) NULL,
	[io_stall_read_ms] [bigint] NOT NULL,
	[num_of_reads] [bigint] NOT NULL,
	[io_stall_write_ms] [bigint] NOT NULL,
	[num_of_writes] [bigint] NOT NULL,
	[io_stalls] [bigint] NULL,
	[total_io] [bigint] NULL,
	[Resource Governor Total Read IO Latency (ms)] [bigint] NOT NULL,
	[Resource Governor Total Write IO Latency (ms)] [bigint] NOT NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[io_stalls] ADD  DEFAULT (getdate()) FOR [DT]
GO

--alter table [dbo].[io_stalls] add [num_of_bytes_read] [numeric](19, 0) NULL
--alter table [dbo].[io_stalls] add [num_of_bytes_written] [numeric](19, 0) NULL

USE [msdb]
GO

/****** Object:  Job [ADM.io_stalls]    Script Date: 19.01.2022 11:39:44 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Notifies]]    Script Date: 19.01.2022 11:39:44 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Notifies]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Notifies]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'ADM.io_stalls', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Fix io stalls per whole server', 
		@category_name=N'[Notifies]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'prokunin@abc.ru', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [io_stalls]    Script Date: 19.01.2022 11:39:44 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'io_stalls', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'----- Sender & Recipients
declare 	@MailProfile sysname =  ''MyProfile''
	, @Recip varchar(max) = ''prokunin@abc.ru'' 
	, @CopyRecip varchar(max) = ''prokunin@abc.ru''

insert into master.dbo.io_stalls ([Database Name], [avg_read_stall_ms] ,[avg_write_stall_ms] ,[avg_io_stall_ms], [File Size (MB)],
[physical_name], [type_desc], [io_stall_read_ms], [num_of_reads], [num_of_bytes_read], [io_stall_write_ms], [num_of_writes], [num_of_bytes_written], [io_stalls], 
[total_io], [Resource Governor Total Read IO Latency (ms)], [Resource Governor Total Write IO Latency (ms)])
SELECT DB_NAME(fs.database_id) AS [Database Name], CAST(fs.io_stall_read_ms/(1.0 + fs.num_of_reads) AS NUMERIC(10,1)) AS [avg_read_stall_ms],
CAST(fs.io_stall_write_ms/(1.0 + fs.num_of_writes) AS NUMERIC(10,1)) AS [avg_write_stall_ms],
CAST((fs.io_stall_read_ms + fs.io_stall_write_ms)/(1.0 + fs.num_of_reads + fs.num_of_writes) AS NUMERIC(10,1)) AS [avg_io_stall_ms],
CONVERT(DECIMAL(18,2), mf.size/128.0) AS [File Size (MB)], mf.physical_name, mf.type_desc, fs.io_stall_read_ms, fs.num_of_reads, fs.num_of_bytes_read,
fs.io_stall_write_ms, fs.num_of_writes, fs.num_of_bytes_written, fs.io_stall_read_ms + fs.io_stall_write_ms AS [io_stalls], fs.num_of_reads + fs.num_of_writes AS [total_io],
io_stall_queued_read_ms AS [Resource Governor Total Read IO Latency (ms)], io_stall_queued_write_ms AS [Resource Governor Total Write IO Latency (ms)] 

FROM sys.dm_io_virtual_file_stats(null,null) AS fs
INNER JOIN sys.master_files AS mf WITH (NOLOCK)
ON fs.database_id = mf.database_id
AND fs.[file_id] = mf.[file_id]

delete  from master.dbo.io_stalls  where DT < dateadd(dd, -30, getdate())

declare @DT1 datetime,  @DT2 datetime
select @DT2 = max(DT) from master..io_stalls 
select @DT1 = max(DT) from master..io_stalls where DT < @DT2
--drop table #Results 

select [DT], [Database Name], [physical_name], [io_stall_read_ms], [num_of_reads], [num_of_bytes_read], [io_stall_write_ms], [num_of_writes], [num_of_bytes_written]
into #Results
from master..io_stalls 
where DT = @DT1 -- and [Database Name] in (''tempdb'', ''p_ner'', ''P_AST'')

--select * from #Results

declare 
@Database_Name nvarchar(256), 
@physical_name nvarchar(250), 
@io_stall_read_ms numeric(19,0), 
@num_of_reads bigint,
@num_of_bytes_read numeric(19,0),
@io_stall_write_ms numeric(19,0),
@num_of_writes bigint,
@num_of_bytes_written numeric(19,0),
@EXESTR varchar(max)

declare stalls_cur cursor for 
select [Database Name], [physical_name], [io_stall_read_ms], [num_of_reads], [num_of_bytes_read], [io_stall_write_ms], [num_of_writes], [num_of_bytes_written]
from master..io_stalls 
where DT = @DT2 -- and [Database Name] in (''tempdb'', ''p_ner'', ''P_AST'')

OPEN stalls_cur  

FETCH NEXT FROM stalls_cur INTO @Database_Name, @physical_name, @io_stall_read_ms, @num_of_reads, @num_of_bytes_read,
	@io_stall_write_ms, @num_of_writes, @num_of_bytes_written

WHILE @@FETCH_STATUS = 0  
BEGIN  
	select @EXESTR = ''update #Results set [io_stall_read_ms] = ('' + convert(nvarchar(21), + @io_stall_read_ms) 	+ '' - [io_stall_read_ms]) ,''
	+ ''[io_stall_write_ms] = ('' + convert(nvarchar(21), + @io_stall_write_ms) 	+ '' - [io_stall_write_ms]), ''
	+ ''[num_of_reads] = ('' + convert(nvarchar(21), + @num_of_reads) 	+ '' - [num_of_reads]), ''
	+ ''[num_of_bytes_read] = ('' + convert(nvarchar(21), + @num_of_bytes_read) 	+ '' - [num_of_bytes_read]), ''
	+ ''[num_of_writes] = ('' + convert(nvarchar(21), + @num_of_writes) 	+ '' - [num_of_writes]),''
	+ ''[num_of_bytes_written] = ('' + convert(nvarchar(21), + @num_of_bytes_written) + '' - [num_of_bytes_written]) ''
	+ '' where [Database Name] = '''''' + @Database_Name + '''''' and [physical_name] = '''''' + @physical_name + ''''''''
--	select @EXESTR
	exec (@EXESTR)
	FETCH NEXT FROM stalls_cur INTO @Database_Name, @physical_name, @io_stall_read_ms, @num_of_reads, @num_of_bytes_read,
		@io_stall_write_ms, @num_of_writes, @num_of_bytes_written
END   
CLOSE stalls_cur;  

DEALLOCATE stalls_cur;  

declare @html varchar(max)
select @html = ''<html><body><h3>IO Stalls on '' + @@servername + '' from '' + convert(varchar(19), @DT1) + '' to '' + convert(varchar(19), @DT2) +
''</h3><table border=1><tr><th>Database Name</th><th>Physical Name</th><th>Read stalls ms</th><th>Write Stalls ms</th><th>Num of Reads</th><th>Read MB</th><th>Num of Writes</th><th>Written MB</th></tr>''
select @html = @html + ''<tr><td>'' + [Database Name] +''</td><td>''+ [physical_name] +''</td><td>'' +
CASE 
		WHEN num_of_reads = 0 THEN ''0'' 
		ELSE convert(varchar(21),convert(numeric(10,2),(io_stall_read_ms/num_of_reads)))
END +''</td><td>''+
CASE 
		WHEN num_of_writes = 0 THEN ''0'' 
		ELSE convert(varchar(21),convert(numeric(10,2),(io_stall_write_ms/num_of_writes)))
END +''</td><td>'' 
	+ convert(varchar(21),[num_of_reads]) + ''</td><td>'' + convert(varchar(21),convert(numeric(19,0),[num_of_bytes_read]/(1024*1024))) + ''</td><td>'' +
	+ convert(varchar(21),[num_of_writes]) +''</td><td>'' + convert(varchar(21),convert(numeric(19,0),[num_of_bytes_written]/(1024*1024)))
	+ ''</td></tr>''
from #Results
order by [Database Name], [physical_name]

select @html=@html + ''</table></body></html>''

declare @subject varchar(250), @file varchar(100)
select @subject = ''IO stalls  on '' + @@servername + '' report''
EXEC msdb.dbo.sp_send_dbmail
      @profile_name = @MailProfile,
      @recipients= @Recip,
      @copy_recipients= @CopyRecip,
      @subject = @subject,
	  @body_format = ''html'',
      @body = @html
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'every hour', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=30, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20190218, 
		@active_end_date=99991231, 
		@active_start_time=600, 
		@active_end_time=235959, 
		@schedule_uid=N'7b6824fd-2345-4e99-b237-e2b65a73c7ed'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
