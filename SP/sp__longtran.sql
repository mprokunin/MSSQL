USE [master]
GO
/****** Object:  StoredProcedure [dbo].[sp__longtran]    Script Date: 16.06.2022 23:30:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
alter procedure [dbo].[sp__longtran] (
	@MailProfile nvarchar(30) = 'openrelay',
	@Recip nvarchar(30)  = 'prokunin@abc.ru',
	@CopyRecip nvarchar(30) = 'dba_admins@abc.ru'
)
as 
BEGIN
declare @Subject nvarchar(60) = 'Long transactions at ' + @@SERVERNAME;
declare @version nvarchar(20) = 'ver 1.5 2023-01-27'

declare @html varchar(max);
select @html = ' 
<html>    
<head>    
<title>Top Long Running Transactions</title>    
</head>    
<body>'  

select @html = @html + '<h3>Top Long Running Transactions</h3>
<table border="1">
<tr><th> Now </th> <th> Elapsed Time, sec </th> <th> DB </th> <th> Spid </th> <th> Blocked By </th> 
	<th> Sql </th> 
	<th> Transaction </th> <th> Started </th> <th> Program </th> <th> Login </th> <th> Host </th> <th> Host Process </th> <th> Connected </th></tr>'  

-- Get list of active transactions
SELECT top 10 @html = @html + '<tr><td>' + convert(varchar(19), GETDATE())  + '</td><td>' + convert(varchar(19),DATEDIFF(SECOND, at.transaction_begin_time, GETDATE()))  + '</td><td>' 
  + DB_NAME(sess.database_id) + '</td><td>' + convert(varchar(10),coalesce(st.session_id, 0)) + '</td><td>' + convert(varchar(10),coalesce(er.blocking_session_id, 0)) 
  + '</td><td>' + convert(varchar(250),coalesce(txt.text, ' ')) + '</td><td>'
  + coalesce(at.name, ' ') + '</td><td>' + convert(varchar(19), at.transaction_begin_time) + '</td><td>' + sess.program_name + '</td><td>' + coalesce(sess.login_name, ' ') + '</td><td>'
  + coalesce(sess.host_name, ' ') + '</td><td>' +  convert(varchar(10), coalesce(sess.host_process_id, 0)) + '</td><td>' +  convert(varchar(19),conn.connect_time) + '</td></tr>'
FROM
  sys.dm_tran_active_transactions at
  INNER JOIN sys.dm_tran_session_transactions st ON st.transaction_id = at.transaction_id
  left outer JOIN sys.dm_exec_requests er ON st.session_id = er.session_id
  LEFT OUTER JOIN sys.dm_exec_sessions sess ON st.session_id = sess.session_id
  LEFT OUTER JOIN sys.dm_exec_connections conn ON conn.session_id = sess.session_id
    OUTER APPLY sys.dm_exec_sql_text(conn.most_recent_sql_handle)  AS txt
ORDER BY
  at.transaction_begin_time;
--select @@rowcount

if (@@rowcount > 0) 
	begin 
	select @html = @html + '</table>
	<br><div style="color:white">' + @version +  '</div>
	</body>
	</html>'

--	select @html
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
	end

END
