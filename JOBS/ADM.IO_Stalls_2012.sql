USE [master]
GO

-- MSSQL Version 2012
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
-- drop table [dbo].[io_stalls]
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
	[total_io] [bigint] NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[io_stalls] ADD  DEFAULT (getdate()) FOR [DT]
GO


---------------------------
USE [msdb]
GO

/****** Object:  Job [ADM.io_stalls]    Script Date: 14.03.2019 10:54:59 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Notifies]]    Script Date: 14.03.2019 10:54:59 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Notifies]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Notifies]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'ADM.io_stalls', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Fix io stalls per whole server', 
		@category_name=N'[Notifies]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [io_stalls]    Script Date: 14.03.2019 10:54:59 ******/
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

declare 	@MailProfile sysname =  ''AL-SQL04\CRM''
	, @Recip varchar(max) = ''SQLAdmin@aton.ru'' 
--	, @Recip varchar(max) = ''mikhail.prokunin@aton.ru'' 
--	, @CopyRecip varchar(max) = ''_finsupport@aton.ru;Nikolay.Mezhenskiy@aton.ru''
--	, @CopyRecip varchar(max) = ''_finsupport@aton.ru''
	, @CopyRecip varchar(max) = ''mikhail.prokunin@aton.ru''

insert into master.dbo.io_stalls ([Database Name], [avg_read_stall_ms] ,[avg_write_stall_ms] ,[avg_io_stall_ms], [File Size (MB)],
[physical_name], [type_desc], [io_stall_read_ms], [num_of_reads], [io_stall_write_ms], [num_of_writes], [io_stalls], 
[total_io])
SELECT DB_NAME(fs.database_id) AS [Database Name], CAST(fs.io_stall_read_ms/(1.0 + fs.num_of_reads) AS NUMERIC(10,1)) AS [avg_read_stall_ms],
CAST(fs.io_stall_write_ms/(1.0 + fs.num_of_writes) AS NUMERIC(10,1)) AS [avg_write_stall_ms],
CAST((fs.io_stall_read_ms + fs.io_stall_write_ms)/(1.0 + fs.num_of_reads + fs.num_of_writes) AS NUMERIC(10,1)) AS [avg_io_stall_ms],
CONVERT(DECIMAL(18,2), mf.size/128.0) AS [File Size (MB)], mf.physical_name, mf.type_desc, fs.io_stall_read_ms, fs.num_of_reads, 
fs.io_stall_write_ms, fs.num_of_writes, fs.io_stall_read_ms + fs.io_stall_write_ms AS [io_stalls], fs.num_of_reads + fs.num_of_writes AS [total_io]


FROM sys.dm_io_virtual_file_stats(null,null) AS fs
INNER JOIN sys.master_files AS mf WITH (NOLOCK)
ON fs.database_id = mf.database_id
AND fs.[file_id] = mf.[file_id]

delete  from master.dbo.io_stalls  where DT < dateadd(dd, -30, getdate())

declare @DT1 datetime,  @DT2 datetime
select @DT2 = max(DT) from master..io_stalls 
select @DT1 = max(DT) from master..io_stalls where DT < @DT2
--drop table #Results 

select [DT], [Database Name], [physical_name], [io_stall_read_ms], [num_of_reads], [io_stall_write_ms], [num_of_writes] 
into #Results
from master..io_stalls 
where DT = @DT1 -- and [Database Name] in (''tempdb'', ''p_ner'', ''P_AST'')

--select * from #Results

declare 
@Database_Name nvarchar(256), 
@physical_name nvarchar(250), 
@io_stall_read_ms numeric(19,0), 
@num_of_reads bigint,
@io_stall_write_ms numeric(19,0),
@num_of_writes bigint,
@EXESTR varchar(max)

declare stalls_cur cursor for 
select [Database Name], [physical_name], [io_stall_read_ms], [num_of_reads], [io_stall_write_ms], [num_of_writes] 
from master..io_stalls 
where DT = @DT2 -- and [Database Name] in (''tempdb'', ''p_ner'', ''P_AST'')

OPEN stalls_cur  

FETCH NEXT FROM stalls_cur INTO @Database_Name, @physical_name, @io_stall_read_ms, @num_of_reads, 
	@io_stall_write_ms, @num_of_writes 

WHILE @@FETCH_STATUS = 0  
BEGIN  
	select @EXESTR = ''update #Results set [io_stall_read_ms] = ('' + convert(nvarchar(21), + @io_stall_read_ms) 	+ '' - [io_stall_read_ms]) ,''
	+ ''[io_stall_write_ms] = ('' + convert(nvarchar(21), + @io_stall_write_ms) 	+ '' - [io_stall_write_ms]), ''
	+ ''[num_of_reads] = ('' + convert(nvarchar(21), + @num_of_reads) 	+ '' - [num_of_reads]), ''
	+ ''[num_of_writes] = ('' + convert(nvarchar(21), + @num_of_writes) 	+ '' - [num_of_writes])''
	+ '' where [Database Name] = '''''' + @Database_Name + '''''' and [physical_name] = '''''' + @physical_name + ''''''''
--	select @EXESTR
	exec (@EXESTR)
	FETCH NEXT FROM stalls_cur INTO @Database_Name, @physical_name, @io_stall_read_ms, @num_of_reads, 
		@io_stall_write_ms, @num_of_writes 
END   
CLOSE stalls_cur;  

DEALLOCATE stalls_cur;  

declare @html varchar(max)
select @html = ''<html><body><h3>IO Stalls on '' + @@servername + '' from '' + convert(varchar(19), @DT1) + '' to '' + convert(varchar(19), @DT2) +
''</h3><table border=1><tr><td>Database Name</td><td>Physical Name</td><td>Read stalls ms</td><td>Write Stalls ms</td><td>Num of Reads</td><td>Num of Writes</td></tr>''
select @html = @html + ''<tr><td>'' + [Database Name] +''</td><td>''+ [physical_name] +''</td><td>'' +
CASE 
		WHEN num_of_reads = 0 THEN ''0'' 
		ELSE convert(varchar(21),convert(numeric(10,2),(io_stall_read_ms/num_of_reads)))
END +''</td><td>''+
CASE 
		WHEN num_of_writes = 0 THEN ''0'' 
		ELSE convert(varchar(21),convert(numeric(10,2),(io_stall_write_ms/num_of_writes)))
END +''</td><td>'' +
	convert(varchar(21),[num_of_reads]) +''</td><td>'' + convert(varchar(21),[num_of_writes]) + ''</td></tr>''
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
		@freq_subday_type=8, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20190218, 
		@active_end_date=99991231, 
		@active_start_time=100, 
		@active_end_time=235959, 
		@schedule_uid=N'bab76e78-a618-4108-8300-34e6887687d6'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

