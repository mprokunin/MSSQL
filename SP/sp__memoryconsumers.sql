use master
go
if OBJECT_ID('dbo.sp__memoryconsumers') is not null drop procedure dbo.sp__memoryconsumers
go
create procedure dbo.sp__memoryconsumers (
	@PLE int = 0,
	@MailProfile nvarchar(30) = 'openrelay',
	@Recip nvarchar(30)  = 'prokunin@ffin.ru',
	@CopyRecip nvarchar(30) = 'prokunin@ffin.ru'
)
as 
BEGIN
declare @Subject nvarchar(60) = 'Low PLE ';
declare @version nvarchar(20) = 'ver 1.0 2021-07-19'

if (@PLE = 0)
begin
	SELECT @PLE = AVG(cntr_value) FROM sys.dm_os_performance_counters WITH (NOLOCK)
	WHERE [object_name] LIKE N'%Buffer Node%' -- Handles named instances
		AND counter_name = N'Page life expectancy' OPTION (RECOMPILE);
end

select @Subject = @Subject + convert(nvarchar(10), @PLE) + ' at ' + @@SERVERNAME

declare @html varchar(max);
select @html = ' 
<html>    
<head>    
<title>Top memory consuming processes</title>    
</head>    
<body>    
<h3>Processes list </h3>
<table border="1">
<tr><th> session_id </th> <th> granted_memory_Mb </th> <th> logical_reads </th>
<th> login_name </th> <th> nt_user_name </th> <th> host_name </th> <th> program_name </th> <th> DB </th> <th> dop </th> 
<th> sqltext </th></tr>'    


SELECT top 10 @html = @html + '<tr><td>' + convert(nvarchar(10),ss.session_id) + '</td><td>' +
convert(nvarchar(60), convert(numeric(10,2), mg.granted_memory_kb/1024.0)) + '</td><td>' +
convert(nvarchar(60), ss.logical_reads) + '</td><td>' +
convert(nvarchar(60), coalesce(ss.login_name, ' ')) + '</td><td>' +
convert(nvarchar(60), coalesce(ss.nt_user_name, ' ')) + '</td><td>' +
convert(nvarchar(60), coalesce(ss.host_name, ' ')) + '</td><td>' +
convert(nvarchar(60), coalesce(ss.program_name, ' ')) + '</td><td>' +
db_name(ss.database_id) + '</td><td>' +
convert(nvarchar(60), coalesce(mg.dop, ' ')) + '</td><td>' +
convert(nvarchar(250), coalesce(t.text, ' ')) + '</td></tr>' 

--SELECT mg.session_id, convert(numeric(10,2), mg.granted_memory_kb/1024.0) as 'granted_memory_Mb', ss.logical_reads, ss.login_name, ss.nt_user_name, ss.host_name, ss.program_name, db_name(ss.database_id) as 'DB', mg.dop, convert(varchar(250), t.text) as text -- , qp.query_plan
FROM sys.dm_exec_query_memory_grants AS mg
join sys.dm_exec_sessions ss on mg.session_id = ss.session_id
CROSS APPLY sys.dm_exec_sql_text(mg.sql_handle) AS t
--CROSS APPLY sys.dm_exec_query_plan(mg.plan_handle) AS qp
where mg.session_id <> @@SPID
ORDER BY granted_memory_kb DESC OPTION (MAXDOP 1)


select @html = @html + '</table>
<br><div style="color:white">' + @version +  '</div>
</body>
</html>'

select @html
-------------------- Send

EXEC msdb.dbo.sp_send_dbmail
      @profile_name = @MailProfile 
      , @recipients= @Recip
      , @copy_recipients= @CopyRecip
      , @subject = @subject
      , @body_format = 'html'
--      , @body = 'Long locks occured. Further information can be found in the attached file.'
      , @body = @html
--      , @query = 'select [server],[date] ,[spid] ,[BlockedBySpid] ,[SqlUser] ,[NTUser] ,[Type] ,[Resource]  ,[status] ,	[WaitTimeMS]  ,[Program]  ,[Command]  ,[CPU],[PhysicalIO],[HostName],[DBName] ,[sql_text],[blocking_sql_text]from #res'
--      , @query_result_header = 1
--      , @query_result_width = 600
--      , @attach_query_result_as_file = 1
--      , @query_attachment_filename = @file

END

--exec sp__memoryconsumers


