---- Sender & Recipients
declare 	@MailProfile sysname =  'MyProfile'
	, @Recip varchar(max) = 'prokunin@domain.ru' 
	, @CopyRecip varchar(max) = 'prokunin@domain.ru'


----- Filter resultset
declare 	@BlockingProcessCount  [int] = 10
	, @TimeBlockedMS [int] = 10000	

----- Version 
declare @version varchar(100) = 'ver. 2.0 Jul 9,2021'

CREATE table #requests 
	(	session_id			smallint
	,	database_id			smallint
	,	blocking_session_id	smallint
	,	wait_type			nvarchar(64)
	,	wait_resource		nvarchar(512)
	,	command				nvarchar(32)
	,	wait_time			int
	)	
	
CREATE table #blocking (
	[date] [datetime] ,
	[spid] [int] ,
	[BlockedBySpid] [int] ,
	[SqlUser] [varchar](100) ,
	[NTUser] [varchar](100) ,
	[Type] [varchar](100) ,
	[Resource] [varchar](100) ,
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
	
insert into #requests
	(	session_id			
	,	database_id			
	,	blocking_session_id	
	,	wait_type			
	,	wait_resource		
	,	command				
	,	wait_time			
	)	
	select	wt.session_id			
		,	es.database_id			
		,	case when wt.blocking_session_id is NULL then 0 else wt.blocking_session_id end as blocking_session_id
		,	wt.wait_type	
		,	case when wt.wait_type is NULL then '' else wait_resource end as wait_resource
		,	es.command				
		,	wt.wait_duration_ms as wait_time	
	from sys.dm_exec_requests	es
	left join  sys.dm_os_waiting_tasks wt on es.session_id = wt.session_id
	where  wt.blocking_session_id is not null

insert into #blocking
	select	
	    getdate() as [date],
		s.session_id		spid
		,	isnull(r.blocking_session_id,0)	BlockedBySPID
		,	s.login_name				SQLUser
		,	coalesce(s.nt_user_name,'')	NTUser
		,	convert(nvarchar(20),r.wait_type)		Type	
		,	convert(nvarchar(512),r.wait_resource)	Resource
		,	coalesce(r.wait_time,0)	WaitTimeMS
		,	s.program_name			Program
		,	isnull(r.command,'AWAITING COMMAND')	Command
		,	s.cpu_time				CPU
		,	s.reads+s.writes		PhysicalIO
		,	s.host_name				HostName
		,	case when coalesce(r.database_id,0) = 0 then '' else db_name(coalesce(r.database_id,0)) end	DBName	
		
		,	isnull((select top 1 left(text, 150) from sys.dm_exec_sql_text(c.most_recent_sql_handle)),N'/* SQL Text not available */')	sql_text,
		(select top 1 left(t.text,150) from sys.dm_exec_sessions s1
		inner join sys.dm_exec_connections  c1  on ( c1.session_id = s1.session_id)
		cross apply sys.dm_exec_sql_text(c1.most_recent_sql_handle) t
		where s1.session_id = r.blocking_session_id) blocking_sql_text
	from	sys.dm_exec_sessions	s	with (readpast) 
	left join sys.dm_exec_connections c on c.most_recent_session_id = s.session_id
	left join #requests r on r.session_id = s.session_id	
	where 
		(
		r.blocking_session_id > 0 or 
		s.session_id in (select blocking_session_id from #requests where blocking_session_id > 0)
		)


-------------------- Filter
declare @maxn int
select @maxn = count(BlockedBySpid) from #blocking where BlockedBySpid > 0
if (coalesce(@maxn, 0) >= @BlockingProcessCount  OR exists( select 1 from #blocking where WaitTimeMS > @TimeBlockedMS ))

begin 
declare @html varchar(max)
select @html = ' 
<html>    
<head>    
<title>Blocking and blocked processes</title>    
</head>    
<body>    
<h3>Processes list </h3>
<table border="1">    
<tr><td> DBName </td> <td> Spid </td> <td> Blocking spid </td>  <td> WaitTimeMS </td> <td> SQLUsername </td> <td> NTUserName </td> <td> HostName </td> <td> Type </td> <td> Resource </td> <td> Program </td> <td> sql_text </td> <td> blocking_sql_text </td></tr>'    
select @html =@html +  '<tr><td>' +  isnull([DBName],'') + '</td><td>' 
	+ convert(varchar,isnull([spid],'')) + '</td><td>' + convert(varchar, isnull(BlockedBySpid,'')) + '</td><td>' 
	+ convert(varchar,isnull(WaitTimeMS,'')) + '</td><td>' + isnull(SqlUser,'') + '</td><td>' + isnull(NTUser,'') + '</td><td>' 
	+ isnull([HostName],'') +  '</td><td>' + isnull([TYPE],'') +  '</td><td>' + isnull([Resource],'') + '</td><td>' + isnull([Program],'') + '</td><td>' 
	+ isnull([sql_text],'') + '</td><td>'+ isnull([blocking_sql_text],'') +'</td>'+ '</tr>' 
	from #blocking order by BlockedBySpid, spid

select @html =@html + '</table>
<br><div style="color:white">' + @version +  '</div>
</body>
</html>'


-------------------- Send
declare @subject varchar(250), @file varchar(100)
select @subject = 'Blocked processes on ' + @@servername
select @file = 'LongLockReport_' + @@servicename + '.txt'

EXEC msdb.dbo.sp_send_dbmail
      @profile_name = @MailProfile 
      , @recipients= @Recip
      , @copy_recipients= @CopyRecip
      , @subject = @subject
      , @body_format = 'html'
      , @body = @html
end
