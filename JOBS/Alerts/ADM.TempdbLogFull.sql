USE [msdb]
GO

/****** Object:  Alert [ADM.TempdbLogFull]    Script Date: 06.07.2021 12:46:58 ******/
EXEC msdb.dbo.sp_add_alert @name=N'ADM.TempdbLogFull', 
		@message_id=0, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@performance_condition=N'Databases|Percent Log Used|tempdb|>|98', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO


