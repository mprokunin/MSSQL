----- Sender & Recipients
declare 	@MailProfile sysname =  'myprofile'
	, @Recip varchar(max) = 'Group@abc.ru' 
	, @CopyRecip varchar(max) = 'user@abc.ru'
	, @txt nvarchar(max)


create table ##filecont ([Job Report] nvarchar(max))
BULK INSERT ##filecont
   FROM 'C:\DOC\JOB_LOG\Лог_работы.txt'
   WITH 
      (
	  DATAFILETYPE = 'widechar',
      ROWTERMINATOR =N'\n'
      )
declare @query nvarchar(100) = 'set nocount on;select null where 1<>1 union all select * from ##filecont'

declare @subject varchar(250), @file varchar(100)

select @subject = 'Job "Qwerty" on ' + @@servername + ' report'
EXEC msdb.dbo.sp_send_dbmail
      @profile_name = @MailProfile,
      @recipients= @Recip,
      @copy_recipients= @CopyRecip,
      @subject = @subject,
	  @body = '',
	  @body_format = 'text',
      @query = N'select * from ##filecont', 
	  @execute_query_database = N'master'

drop table ##filecont
go
