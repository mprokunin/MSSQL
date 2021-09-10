USE [master]
GO
/****** Object:  StoredProcedure [dbo].[sp__memoryconsumers]    Script Date: 10.09.2021 9:03:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp__memoryconsumers]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[sp__memoryconsumers] AS'
END
go
ALTER procedure [dbo].[sp__memoryconsumers] (
	@PLE int = 0,
	@MailProfile nvarchar(30) = 'openrelay',
	@Recip nvarchar(30)  = 'prokunin@ffin.ru',
	@CopyRecip nvarchar(30) = 'prokunin@ffin.ru',
	@BeginTime time = '00:00:00',
	@EndTime time = '00:00:00'
)
as 
BEGIN
declare @Subject nvarchar(60) = 'Low PLE: (<=';
declare @version nvarchar(20) = 'ver 1.1 2021-09-09'
declare @now time = convert(time, convert(char(8), getdate(), 8))
declare @proclist varchar(max)

if ((@EndTime > @BeginTime) and ((@now < @BeginTime) or (@now > @EndTime)))
		return 1

SELECT top 10 @proclist = '<tr><td>' + convert(nvarchar(10),ss.session_id) + '</td><td>' +
convert(nvarchar(60), convert(numeric(10,2), mg.granted_memory_kb/1024.0)) + '</td><td>' +
convert(nvarchar(60), ss.logical_reads) + '</td><td>' +
convert(nvarchar(60), coalesce(ss.login_name, ' ')) + '</td><td>' +
convert(nvarchar(60), coalesce(ss.nt_user_name, ' ')) + '</td><td>' +
convert(nvarchar(60), coalesce(ss.host_name, ' ')) + '</td><td>' +
convert(nvarchar(60), coalesce(ss.program_name, ' ')) + '</td><td>' +
db_name(ss.database_id) + '</td><td>' +
convert(nvarchar(60), coalesce(mg.dop, ' ')) + '</td><td>' +
convert(nvarchar(512), coalesce(t.text, ' ')) + '</td></tr>' 
FROM sys.dm_exec_query_memory_grants AS mg
join sys.dm_exec_sessions ss on mg.session_id = ss.session_id
CROSS APPLY sys.dm_exec_sql_text(mg.sql_handle) AS t
--CROSS APPLY sys.dm_exec_query_plan(mg.plan_handle) AS qp
where mg.session_id <> @@SPID
ORDER BY granted_memory_kb DESC OPTION (MAXDOP 1)

if @@ROWCOUNT > 0
begin 
	if (@PLE = 0)
	begin
		SELECT @PLE = AVG(cntr_value) FROM sys.dm_os_performance_counters WITH (NOLOCK)
		WHERE [object_name] LIKE N'%Buffer Node%' -- Handles named instances
			AND counter_name = N'Page life expectancy' OPTION (RECOMPILE);
	end

	select @Subject = @Subject + convert(nvarchar(10), @PLE) + ') at ' + @@SERVERNAME

	declare @html varchar(max)
	select @html = ' 
<html>    
<head>    
<title>Top memory consuming processes</title>    
</head>    
<body>'    

	select @html = @html + '<h3>Page Life Expectancy</h3>
<table border="1">
<tr><th> ServerName </th> <th> ObjectName </th> <th> InstanceName </th> <th> PLE, sec </th></tr>'    

-- Page Life Expectancy (PLE) value for each NUMA node in current instance  (Query 43) (PLE by NUMA Node)
	SELECT @html = @html + '<tr><td>' + @@SERVERNAME + '</td><td>' +
	RTRIM([object_name]) + '</td><td>' +
	instance_name +  '</td><td>' +
	convert(nvarchar(10), cntr_value)
	FROM sys.dm_os_performance_counters WITH (NOLOCK)
	WHERE [object_name] LIKE N'%Buffer Node%' -- Handles named instances
	AND counter_name = N'Page life expectancy' OPTION (RECOMPILE);

	select @html = @html + '</table>
<h3>Processes list </h3>
<table border="1">
<tr><th> session_id </th> <th> granted_memory_Mb </th> <th> logical_reads </th>
<th> login_name </th> <th> nt_user_name </th> <th> host_name </th> <th> program_name </th> <th> DB </th> <th> dop </th> 
<th> sqltext </th></tr>'    

	select @html = @html + @proclist

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
		, @body = @html
end
END
go
--exec sp__memoryconsumers 100000,  'NoReplyProfile', 'prokunin@ffin.ru', 'prokunin@ffin.ru', '07:00:00', '23:59:59'