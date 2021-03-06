USE [monitoring]
GO
/****** Object:  StoredProcedure [dbo].[Config_CompareMergeAlarm]    Script Date: 06.11.2018 15:21:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER proc [dbo].[Config_CompareMergeAlarm]
as
begin
--- M.Prokunin removed 79652074427 by Valery Zolotarev request Nov 6, 2018

declare @html varchar(max),  @t varchar(max)



if exists (select 1
from Configuration c
inner join Configuration_new cn on (c.serv = cn.serv and c.name = cn.name
 and c.run_value ! = cn.run_value))
begin

	set @html = '    
	<html>    
	<head>    
		<title>Untitled Page</title>    
	</head>    
	<body>    
	<h3> Были изменены следующие конфигурации <h3>    
	<br></br>    
		<table border="1">    
	<tr><td> Сервер </td> <td> Конфигурация </td> <td> Старое значение </td> <td> Новое значение </td>  </tr>'    
	       
	       
	select 
	@html =@html +  '<tr><td>' +  c.serv + '</td><td>' + c.name + '</td><td>' +  convert(varchar,c.run_value) + '</td><td>' + convert(varchar,cn.run_value) + '</td></tr>' 
	from Configuration c
	inner join Configuration_new cn on (c.serv = cn.serv and c.name = cn.name
	 and c.run_value ! = cn.run_value)
	 
	 
	 
	 set @html = @html + '</table>  
	</body>  
	</html>  '

	 EXEC msdb.dbo.sp_send_dbmail  
	  @profile_name = 'monitoring',  
	  @recipients = '_FastSolutionSectProg@aton.ru;SQLAdmin@aton.ru',  
	  @body = @html,  
	  @body_format = 'html',  
	  @subject = 'sp_configure change'    
	  
	 -- продублировать смской
	 
	 if exists(
	 select 1
	from Configuration c
	inner join Configuration_new cn on (c.serv = cn.serv and c.name = cn.name
	 and c.run_value ! = cn.run_value)
	 where c.name ! = 'max degree of parallelism'
	 )
	 
	 begin
	 
	 set @t = ''    
	       
	       
	select 
	@t =@t + 'server ' + c.serv + ' conf ' + c.name + ' changed from ' +  convert(varchar,c.run_value) + ' to ' + convert(varchar,cn.run_value) + '.' 
	from Configuration c
	inner join Configuration_new cn on (c.serv = cn.serv and c.name = cn.name
	 and c.run_value ! = cn.run_value)
	  where c.name ! = 'max degree of parallelism'
	 
	 
		 EXEC msdb.dbo.sp_send_dbmail
		@profile_name = 'sms',
--		@recipients = '79099660927.aton1@corp.smsmail.ru;79652074427.aton1@corp.smsmail.ru;79165824981.aton1@corp.smsmail.ru;79267683261.aton1@corp.smsmail.ru;',
		@recipients = '79099660927.aton1@corp.smsmail.ru;79165824981.aton1@corp.smsmail.ru;79267683261.aton1@corp.smsmail.ru;',
		@body = @t,
		@body_format = 'text',
		@subject = 'Configuration changed'
		
      end
  
end	  

-- merge two tables

MERGE Configuration AS TARGET
USING Configuration_new AS SOURCE 
ON (TARGET.serv = SOURCE.serv and TARGET.name = SOURCE.name) 

WHEN MATCHED AND TARGET.run_value ! = SOURCE.run_value
THEN 
UPDATE SET TARGET.run_value = SOURCE.run_value

WHEN NOT MATCHED BY TARGET THEN 
INSERT (name, minimum, maximum, config_value,run_value, d, serv) 
VALUES (SOURCE.name, null, null, null, SOURCE.run_value, SOURCE.d, SOURCE.serv);



end

