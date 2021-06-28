USE [msdb]
GO

/****** Object:  Alert [ADM.LongLockAlert]    Script Date: 12/6/2019 6:44:58 PM ******/
EXEC msdb.dbo.sp_add_alert @name=N'ADM.LongLockAlert', 
		@message_id=0, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=300, 
		@include_event_description_in=0, 
		@category_name=N'[Uncategorized]', 
		@performance_condition=N'General Statistics|Processes blocked||>|0', 
		@job_id=N'bc951766-3b79-4e9c-abf5-ff0f73ef5520'
GO


