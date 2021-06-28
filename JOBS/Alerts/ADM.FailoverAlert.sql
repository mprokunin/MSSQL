USE [msdb]
GO

/****** Object:  Alert [ADM.FailoverAlert]    Script Date: 6/4/2020 3:42:01 PM ******/
EXEC msdb.dbo.sp_add_alert @name=N'ADM.FailoverAlert', 
		@message_id=1480, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=0, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO


