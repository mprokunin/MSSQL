use master
go
if OBJECT_ID('dbo.sp__highcpuusage') is not null drop procedure dbo.sp__highcpuusage
go
create procedure dbo.sp__highcpuusage
as 
BEGIN
declare @MailProfile nvarchar(30) = 'openrelay';
declare @Recip nvarchar(30)  = 'prokunin@ffin.ru';
declare @CopyRecip nvarchar(30) = 'prokunin@ffin.ru';
declare @Subject nvarchar(60) = 'High CPU utilisation at ' + @@SERVERNAME;
declare @version nvarchar(20) = 'ver 1.0 2021-07-08'

/*
declare @thr_idle int = 50
declare @thr_sql int = 1

declare @cpu_idle int, @cpu_sql int

SELECT
         @cpu_idle = record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int'),
         @cpu_sql = record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int')
FROM (
         SELECT TOP 1 CONVERT(XML, record) AS record
         FROM sys.dm_os_ring_buffers
         WHERE ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR'
         AND record LIKE '% %'
		 ORDER BY TIMESTAMP DESC
) as cpu_usage

if ((@cpu_sql > @thr_sql) or (@cpu_idle < @thr_idle))
begin
*/

declare @html varchar(max);
select @html = ' 
<html>    
<head>    
<title>High CPU using processes</title>    
</head>    
<body>    
<h3>Processes list </h3>
<table border="1">
<tr><th> session_id </th> <th> status </th> <th> blocking_session_id </th> <th> wait_type </th>
<th> wait_resource </th>
<th> wait_time(Min) </th> <th> cpu_time </th> <th> logical_reads </th> <th> reads </th> <th> writes </th> 
<th> total_elapsed_time(Min) </th> <th> statement_text </th> <th> command_text </th> <th> command </th> <th> login_name </th> <th> host_name </th> <th> program_name </th> <th> last_request_end_time </th> <th> login_time </th>

<th> open_tran </th></tr>'    


SELECT  @html = @html + '<tr><td>' + convert(nvarchar(10),s.session_id) + '</td><td>' +
convert(nvarchar(60), r.status) + '</td><td>' +
convert(nvarchar(60), r.blocking_session_id) + '</td><td>' +
convert(nvarchar(60), coalesce(r.wait_type, 'NULL')) + '</td><td>' +
convert(nvarchar(60), coalesce(r.wait_resource,'NULL')) + ' </td><td>' +
convert(nvarchar(60), r.wait_time / (1000 * 60)) + '</td><td>' +
convert(nvarchar(60), r.cpu_time) + '</td><td>' +
convert(nvarchar(60), r.logical_reads) + '</td><td>' +
convert(nvarchar(60), r.reads) + '</td><td>' +
convert(nvarchar(60), r.writes) + '</td><td>' +

convert(nvarchar(60), r.total_elapsed_time / (1000 * 60)) + '</td><td>' +
Substring(st.TEXT,(r.statement_start_offset / 2) + 1, 
((CASE r.statement_end_offset
	WHEN -1
	THEN Datalength(st.TEXT)
	ELSE r.statement_end_offset
	END - r.statement_start_offset) / 2) + 1) + '</td><td>' +
Coalesce(Quotename(Db_name(st.dbid)) + N'.' + Quotename(Object_schema_name(st.objectid, st.dbid)) + N'.' + Quotename(Object_name(st.objectid, st.dbid)), ' ') + '</td><td>' +
convert(nvarchar(60), r.command) + '</td><td>' +
convert(nvarchar(60), s.login_name) + '</td><td>' +
convert(nvarchar(60), s.host_name) + '</td><td>' +
convert(nvarchar(60), s.program_name) + '</td><td>' +
convert(nvarchar(60), s.last_request_end_time) + '</td><td>' +
convert(nvarchar(60), s.login_time) + '</td><td>' +

convert(nvarchar(60), r.open_transaction_count) + '</td></tr>' 
FROM sys.dm_exec_sessions AS s
JOIN sys.dm_exec_requests AS r
ON r.session_id = s.session_id
CROSS APPLY sys.Dm_exec_sql_text(r.sql_handle) AS st
WHERE r.session_id != @@SPID
ORDER BY r.cpu_time desc

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


exec sp__highcpuusage   


