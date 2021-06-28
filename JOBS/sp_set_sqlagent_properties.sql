EXEC msdb.dbo.sp_set_sqlagent_properties @jobhistory_max_rows=10000,@jobhistory_max_rows_per_job=500
EXEC msdb.dbo.sp_get_sqlagent_properties 