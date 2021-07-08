USE [msdb]
GO

/****** Object:  Job [ADM.LongLockJob]    Script Date: 08.07.2021 12:11:12 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 08.07.2021 12:11:12 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'ADM.LongLockJob', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Notify operetor when long lock occured', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [_SendLongLockInfo]    Script Date: 08.07.2021 12:11:12 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'_SendLongLockInfo', 
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

declare 	@MailProfile sysname =  ''openrelay''
	, @Recip varchar(max) = ''prokunin@ffin.ru'' 
	, @CopyRecip varchar(max) = ''prokunin@ffin.ru''


----- Filter resultset

declare 	@BlockingProcessCount  [int] = 10
	, @TimeBlockedMS [int] = 10000	

----- Version 
declare @version varchar(100) = ''ver. 1.2 Aug 17,2018''
 
CREATE table #requests 
	(	session_id			smallint
	,	database_id			smallint
	,	status				nvarchar(60)
	,	blocking_session_id	smallint
	,	blocking_task_address varbinary(8)
	,	wait_type			nvarchar(64)
	,	wait_resource		nvarchar(512)
	,	command				nvarchar(32)
	,	wait_time			int
	)	
	
CREATE table #blocking (
	[server] [varchar](100) ,
	[date] [datetime] ,
	[spid] [int] ,
	[BlockedBySpid] [int] ,
	[SqlUser] [varchar](100) ,
	[NTUser] [varchar](100) ,
	[Type] [varchar](100) ,
	[Resource] [varchar](100) ,
	[status] [varchar](100) ,
	[WaitTimeMS] [bigint] ,
	[Program] [varchar](100) ,
	[Command] [varchar](100) ,
	[CPU] [bigint] ,
	[PhysicalIO] [int],
	[HostName] [varchar](100),
	[DBName] [varchar](100),
	[sql_text] [varchar](max),
	[blocking_sql_text] [varchar](max) 
)

CREATE table #out (
	[server] [varchar](100) ,
	[date] [datetime] ,
	[spid] [int] ,
	[BlockedBySpid] [int] ,
	[SqlUser] [varchar](100) ,
	[NTUser] [varchar](100) ,
	[Type] [varchar](100) ,
	[Resource] [varchar](100) ,
	[status] [varchar](100) ,
	[WaitTimeMS] [bigint] ,
	[Program] [varchar](100) ,
	[Command] [varchar](100) ,
	[CPU] [bigint] ,
	[PhysicalIO] [int],
	[HostName] [varchar](100),
	[DBName] [varchar](100),
	[sql_text] [varchar](max),
	[blocking_sql_text] [varchar](max), 
	n int
)

	
---------------------
--declare @count int
	
insert into #requests
	(	session_id			
	,	database_id			
	,	status				
	,	blocking_session_id	
	,   blocking_task_address
	,	wait_type			
	,	wait_resource		
	,	command				
	,	wait_time			
	)	
	select	wt.session_id			
		,	database_id			
		,	status				
		,	case when wt.blocking_session_id is NULL then 0 else wt.blocking_session_id end as blocking_session_id
		,   blocking_task_address
		,	wt.wait_type	
		,	case when wt.wait_type is NULL then '''' else wait_resource end as wait_resource
		,	command				
		,	wt.wait_duration_ms as wait_time	
	from sys.dm_exec_requests	es
	left join  sys.dm_os_waiting_tasks wt on es.session_id = wt.session_id
	where  wt.blocking_session_id is not null

insert into #blocking
	select	
	    @@servername as server,
	    getdate() as [date],
		s.session_id		spid
		,	isnull(r.blocking_session_id,0)	BlockedBySPID
		,	s.login_name				SQLUser
		,	coalesce(s.nt_user_name,'''')	NTUser
		,	convert(nvarchar(20),r.wait_type)		Type	
		,	convert(nvarchar(512),r.wait_resource)	Resource
		,	coalesce(r.status,s.status)
		+	case when r.blocking_task_address is not null then '', blocked'' else '''' end
		+	case when r.blocking_task_address is null or (s.session_id in (select blocking_session_id from #requests where blocking_task_address is not null)) then '', blocking'' else '''' end status	
		,	coalesce(r.wait_time,0)	WaitTimeMS
		,	s.program_name			Program
		,	isnull(r.command,''AWAITING COMMAND'')	Command
		,	s.cpu_time				CPU
		,	s.reads+s.writes		PhysicalIO
		,	s.host_name				HostName
		,	case when coalesce(r.database_id,0) = 0 then '''' else db_name(coalesce(r.database_id,0)) end	DBName	
		
		,	isnull((select top 1 left(text, 150) from sys.dm_exec_sql_text(c.most_recent_sql_handle)),N''/* SQL Text not available */'')	sql_text,
		(select top 1 left(t.text,150) from sys.dm_exec_sessions s1
		inner join sys.dm_exec_connections  c1  on ( c1.session_id = s1.session_id)
		cross apply sys.dm_exec_sql_text(c1.most_recent_sql_handle) t
		where s1.session_id = r.blocking_session_id) blocking_sql_text
	from	sys.dm_exec_sessions	s	with (readpast) 
	--inner join sys.dm_tran_locks L on (s.session_id = L.request_session_id) 
	--JOIN sys.partitions P ON P.hobt_id = L.resource_associated_entity_id
 --   JOIN sys.objects O ON O.object_id = P.object_id
	left join sys.dm_exec_connections c on c.most_recent_session_id = s.session_id
	left join #requests r on r.session_id = s.session_id	
	where 
		--r.blocking_session_id is null 
		--and 
		--s.session_id != r.blocking_session_id 
--and
(
		r.blocking_session_id > 0 or 
		s.session_id in (select blocking_session_id from #requests where blocking_session_id > 0)
		)
		--and coalesce(r.wait_time,0) >= 30000

declare @spid int, @maxn int

DECLARE server_cursor CURSOR FOR
	select spid from #blocking where BlockedBySpid  = 0

OPEN server_cursor

FETCH NEXT FROM server_cursor INTO @spid

WHILE @@FETCH_STATUS = 0
BEGIN

with x (   	[server] ,[date] ,[spid] ,[BlockedBySpid] ,[SqlUser] ,[NTUser] ,[Type] ,[Resource]  ,[status] ,[WaitTimeMS]  ,[Program]  ,[Command]  ,[CPU],[PhysicalIO],[HostName],[DBName] ,[sql_text],[blocking_sql_text], n)
as
(
select 
   	[server] ,
	[date] ,
	[spid] ,
	[BlockedBySpid] ,
	[SqlUser] ,
	[NTUser] ,
	[Type] ,
	[Resource]  ,
	[status] ,
	[WaitTimeMS]  ,
	[Program]  ,
	[Command]  ,
	[CPU],
	[PhysicalIO],
	[HostName],
	[DBName] ,
	[sql_text],
	[blocking_sql_text],
	0 as n 
   from #blocking r2 where BlockedBySpid =0 and spid = @spid
   
   union all
  
select 
   	r.[server],
	r.[date] ,
	r.[spid] ,
	r.[BlockedBySpid] ,
	r.[SqlUser] ,
	r.[NTUser] ,
	r.[Type] ,
	r.[Resource]  ,
	r.[status] ,
	r.[WaitTimeMS]  ,
	r.[Program]  ,
	r.[Command]  ,
	r.[CPU],
	r.[PhysicalIO],
	r.[HostName],
	r.[DBName] ,
	r.[sql_text],
	r.[blocking_sql_text]
	 , n+ 1
   from #blocking  r 
   inner join x r1 on (r1.spid = r.BlockedBySpid)
    
)
insert into #out
select * from x
option (maxrecursion 1000)



FETCH NEXT FROM server_cursor
INTO @spid

END			

CLOSE server_cursor
DEALLOCATE server_cursor

-------------------- Filter
select @maxn = MAX(n) from #out
if (@maxn >= @BlockingProcessCount  OR exists( select 1 from #out where WaitTimeMS > @TimeBlockedMS ))

begin 
declare @html varchar(max)
select @html = '' 
<html>    
<head>    
<title>Blocking and blocked processes</title>    
</head>    
<body>    
<h3>Processes list <h3>
<table border="1">    
<tr><td> DBName </td> <td> Spid </td> <td> Blocking spid </td>  <td> WaitTimeMS </td> <td> SQLUsername </td> <td> NTUserName </td> <td> HostName </td> <td> Type </td> <td> Resource </td> <td> Program </td> <td> sql_text </td> <td> blocking_sql_text </td></tr>''    
select @html =@html +  ''<tr><td>'' +  isnull([DBName],'''') + ''</td><td>'' 
	+ convert(varchar,isnull([spid],'''')) + ''</td><td>'' + convert(varchar, isnull(BlockedBySpid,'''')) + ''</td><td>'' 
	+ convert(varchar,isnull(WaitTimeMS,'''')) + ''</td><td>'' + isnull(SqlUser,'''') + ''</td><td>'' + isnull(NTUser,'''') + ''</td><td>'' 
	+ isnull([HostName],'''') +  ''</td><td>'' + isnull([TYPE],'''') +  ''</td><td>'' + isnull([Resource],'''') + ''</td><td>'' + isnull([Program],'''') + ''</td><td>'' 
	+ isnull([sql_text],'''') + ''</td><td>''+ isnull([blocking_sql_text],'''') +''</td>''+ ''</tr>'' 
	from #out

select @html =@html + ''</table>
<br><div style="color:white">'' + @version +  ''</div>
</body>
</html>''

-------------------- Send
declare @subject varchar(250), @file varchar(100)
select @subject = ''Blocked processes on '' + @@servername
select @file = ''LongLockReport_'' + @@servicename + ''.txt''

EXEC msdb.dbo.sp_send_dbmail
      @profile_name = @MailProfile 
      , @recipients= @Recip
      , @copy_recipients= @CopyRecip
      , @subject = @subject
      , @body_format = ''html''
--      , @body = ''Long locks occured. Further information can be found in the attached file.''
      , @body = @html
--      , @query = ''select [server],[date] ,[spid] ,[BlockedBySpid] ,[SqlUser] ,[NTUser] ,[Type] ,[Resource]  ,[status] ,	[WaitTimeMS]  ,[Program]  ,[Command]  ,[CPU],[PhysicalIO],[HostName],[DBName] ,[sql_text],[blocking_sql_text]from #res''
--      , @query_result_header = 1
--      , @query_result_width = 600
--      , @attach_query_result_as_file = 1
--      , @query_attachment_filename = @file
end', 
		@database_name=N'msdb', 
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


