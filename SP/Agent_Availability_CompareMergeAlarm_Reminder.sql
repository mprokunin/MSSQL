USE [monitoring]
GO
/****** Object:  StoredProcedure [dbo].[Agent_Availability_CompareMergeAlarm_Reminder]    Script Date: 11.01.2019 11:32:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER proc [dbo].[Agent_Availability_CompareMergeAlarm_Reminder]  
as  
begin  
-------- v 1.1. 2018-07-24 Prokunin removed c.rowid 177 = AL-SQL04\QUIK  
-------- v 1.2. 2018-08-16 Prokunin removed c.rowid 89  = AL-SQL03\WEBMIRROR  
-------- v 1.3. 2019-01-11 Prokunin removed c.rowid 143  = AL-SQL03\IT  
  
declare @html varchar(max),  @t varchar(max),  @sms varchar(200)  
  
 set @html = '      
 <html>      
 <head>      
  <title>Untitled Page</title>      
 </head>      
 <body>      
 <h3> SQL Server Agent not working <h3>      
 <br></br>      
  <table border="1">      
 <tr><td> Server </td> <td> Agent </td> <td> State </td>  </tr>'      
  
if exists (  
 select distinct c.*  
from AvailAgent_Current c  
inner join AvailDB1 a on (SUBSTRING(a.server,0,PATINDEX('%\%',a.server)) = c.server)  
where State  = 'Stopped' and    
c.rowid not in (22,33,29,31,54,86,90,91,110,25,27,39,57,69,89,111,114,141,143,146,147,148,149,150,159,167,171,176,177, 178) and DATEDIFF(MINUTE,date,getdate()) > 10  
 )  
begin  
  
  
     
 select distinct @html = @html +  '<tr><td>' +   c.server + '</td><td>' + c.name + '</td><td>' + c.State + '</td></tr>'  
from AvailAgent_Current c  
inner join AvailDB1 a on (SUBSTRING(a.server,0,PATINDEX('%\%',a.server)) = c.server)  
where State  = 'Stopped' and    
c.rowid not in (22,33,29,31,54,86,90,91,110,25,27,39,57,69,89,111,114,141,143,146,147,148,149,150,159,167,171,176,177, 178) and DATEDIFF(MINUTE,date,getdate()) > 10       
          
    
  set @html = @html + '</table>    
 </body>    
 </html>  '  
  
  EXEC msdb.dbo.sp_send_dbmail    
   @profile_name = 'monitoring',    
--   @recipients = 'SQLAdmin@aton.ru;Valentin.Anisimov@aton.ru',    
   @recipients = 'SQLAdmin@aton.ru',    
   @body = @html,    
   @body_format = 'html',    
   @subject = 'SQL Server Agent OFF'      
     
   set @sms = 'Agent OFF: '  
     
   select distinct @sms = @sms + c.server + ' ' + c.name + ', '  
 from AvailAgent_Current c  
inner join AvailDB1 a on (SUBSTRING(a.server,0,PATINDEX('%\%',a.server)) = c.server)  
where State  = 'Stopped' and    
c.rowid not in (22,33,29,31,54,86,90,91,110,25,27,39,57,69,89,111,114,141,143,146,147,148,149,150,159,167,171,176,177, 178) and DATEDIFF(MINUTE,date,getdate()) > 10       
  
  
  
  exec monitoring.dbo.[SendSMS2Admin] @sms  
     
  end     
end


