USE [msdb]
GO

/****** Object:  Alert [ADM.LowPLE]    Script Date: 19.07.2021 13:21:44 ******/
EXEC msdb.dbo.sp_add_alert @name=N'ADM.LowPLE', 
		@message_id=0, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=0, 
		@category_name=N'[Uncategorized]', 
		@performance_condition=N'Buffer Manager|Page life expectancy||<|2000'--, 
--		@job_id=N'053ea346-c4c6-4b05-8c5b-70f26bb7b544'
GO


