USE [msdb]
GO

/****** Object:  Alert [Переполнен журнал транзакций]    Script Date: 12.02.2021 11:43:40 ******/
EXEC msdb.dbo.sp_add_alert @name=N'ADM.LogFull', 
		@message_id=9002, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=90, 
		@include_event_description_in=1, 
		@notification_message=N'Сервер MSK-CASPRODB01', 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO


select @@SERVERNAME
