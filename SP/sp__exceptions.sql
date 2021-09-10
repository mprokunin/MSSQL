use master
go
if OBJECT_ID('dbo.sp__exceptions') is not null drop procedure dbo.sp__exceptions
go
create procedure dbo.sp__exceptions (
	@severity int = 0,
	@MailProfile nvarchar(30) = 'openrelay',
	@Recip nvarchar(30)  = 'prokunin@ffin.ru',
	@CopyRecip nvarchar(30) = 'prokunin@ffin.ru'
)
as 
BEGIN
declare @Subject nvarchar(60) = 'Last exception';
declare @version nvarchar(20) = 'ver 1.0 2021-09-06'

if (@severity = 0)
begin
	select top 1 when_, severity, username, hostname, appname, errno, errmsg, DB, SPname, linenum, batch_text, statement from dbo.view_exceptions order by when_ desc OPTION (RECOMPILE);
end
else
begin
	select top 1 when_, severity, username, hostname, appname, errno, errmsg, DB, SPname, linenum, batch_text, statement from dbo.view_exceptions where severity = @severity order by when_ desc OPTION (RECOMPILE);
end

select @Subject = @Subject + ' at ' + @@SERVERNAME

--declare @severity int = 14
declare @html nvarchar(max), @cmd nvarchar(1000), @ParamDef nvarchar(100)
set @ParamDef = N'@severity int, @OutRow nvarchar(max) output'

select @cmd = N'select top 1 @OutRow = ''<tr><td>'' + convert(nvarchar(19), when_) 
+ ''</td><td>'' +  convert(nvarchar(20),coalesce(severity, 0))
+ ''</td><td>'' +  coalesce(username, '' '')
+ ''</td><td>'' +  coalesce(hostname, '' '')
+ ''</td><td>'' +  coalesce(appname, '' '')
+ ''</td><td>'' +  convert(nvarchar(20),coalesce(errno, 0))
+ ''</td><td>'' +  coalesce(errmsg, '' '')
+ ''</td><td>'' +  coalesce(DB, '' '')
+ ''</td><td>'' +  coalesce(SPname, '' '')
+ ''</td><td>'' +  convert(nvarchar(20),coalesce(linenum, 0))
+ ''</td><td>'' +  coalesce(batch_text, '' '')
+ ''</td><td>'' +  coalesce(statement, '' '')
+ ''</td></tr>'' from dbo.view_exceptions' 
+ case @severity 
when 0 then ''
else ' where severity = @severity'
end
+ ' order by when_ desc'
select @cmd

exec sp_executesql @stmt = @cmd, @params = @ParamDef, @severity = @severity, @OutRow = @html OUTPUT
select @html

select @html = ' 
<html>    
<head>    
<title>Last exception</title>    
</head>    
<body>
<table border="1">
<tr><th> When </th> <th> Severity </th> <th> UserName </th> <th> HostName </th> <th> AppName </th> <th> Errno </th> <th> ErrMsg </th> <th> DB </th> <th> SPname </th> <th> Line </th> <th> Batch </th> <th> Statement </th></tr>'
+ @html + '</table>
<br><div style="color:white">' + @version +  '</div>
</body>
</html>'


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

--exec dbo.sp__exceptions 14


