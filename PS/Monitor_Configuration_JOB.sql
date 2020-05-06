USE [msdb]
GO

/****** Object:  Job [Monitor_Configuration]    Script Date: 06.11.2018 17:36:05 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 06.11.2018 17:36:05 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Monitor_Configuration', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [1]    Script Date: 06.11.2018 17:36:05 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'1', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'PowerShell', 
		@command=N'
#Import-Module SQLServer


#add-pssnapin SqlServerProviderSnapin100


#add-pssnapin SqlServerCmdletSnapin100

function SaveConfig($server, $name, $run_value)
{
    
     
    $con = New-Object System.Data.SqlClient.SqlConnection
    $con.ConnectionString = "Server=. ;Database= monitoring; integrated security = true"

        $con.Open()
    
    $cmd = New-Object System.Data.SQlClient.SqlCommand
    $cmd.CommandText = "[ConfigInsert_new]"
    $cmd.CommandType = [System.Data.CommandType]::StoredProcedure
    $cmd.Parameters.Add("@server", [system.data.sqldbtype]::Varchar)
    $cmd.Parameters[''@server''].value = $server.ToString()
        $cmd.Parameters.Add("@name", [system.data.sqldbtype]::Varchar)
    $cmd.Parameters[''@name''].value = $name.ToString()
    $cmd.Parameters.Add("@run_value", [system.data.sqldbtype]::int)
    $cmd.Parameters[''@run_value''].value = $run_value
    
    $cmd.Connection = $con
   
    $cmd.ExecuteNonQuery()
    
    $con.Close

}


function Deleteold
{
    
     
    $con = New-Object System.Data.SqlClient.SqlConnection
    $con.ConnectionString = "Server=. ;Database= monitoring; integrated security = true"

        $con.Open()
    
    $cmd = New-Object System.Data.SQlClient.SqlCommand
    $cmd.CommandText = "delete from Configuration_new"
    #$cmd.CommandType = [System.Data.CommandType]::StoredProcedure
    
    $cmd.Connection = $con
   
    $cmd.ExecuteNonQuery()
    
    $con.Close

}

function SendAlarm
{
    
     
    $con = New-Object System.Data.SqlClient.SqlConnection
    $con.ConnectionString = "Server=. ;Database= monitoring; integrated security = true"

        $con.Open()
    
    $cmd = New-Object System.Data.SQlClient.SqlCommand
    $cmd.CommandText = "[Config_CompareMergeAlarm]"
    $cmd.CommandType = [System.Data.CommandType]::StoredProcedure
    
    $cmd.Connection = $con
   
    $cmd.ExecuteNonQuery()
    
    $con.Close

}

#$error.clear()
#$erroractionpreference = "SilentlyContinue"

$con = New-Object System.Data.SqlClient.SqlConnection
$con.ConnectionString = "Server=. ;Database= monitoring; integrated security = true"

$cmd = New-Object System.Data.SQlClient.SqlCommand
$cmd.CommandText = "select server from ConfigurationServer"
$cmd.Connection = $con

$da = new-object System.Data.SqlClient.SqlDataAdapter
$da.SelectCommand = $cmd

$ds = new-object System.Data.DataSet
$da.Fill($ds, "servers")

$con.Close



    #drop old values
    DeleteOld


#save config
foreach($row in $ds.tables["servers"].rows)
{

    $query = "exec [" + $row.server + "].master.sys.sp_executesql N''sp_configure'';"
    
    $val = $null
    
     try
	{
    $val = invoke-sqlcmd  -query $query -database "master" -serverinstance $row.server -ErrorAction silentlycontinue
 	  
}
catch
{
	continue;
}

    if($val)
    {
        #add each config value
        foreach($conf in $val)
        {
             SaveConfig $row.server $conf.name $conf.run_value
        }
    }    
    #Write-Host $query

 
}

    #compare values and alarm
SendAlarm', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'1', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=10, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20110126, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'e1a13fd1-b34d-4bd8-9d1e-1be9b0d5889b'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


