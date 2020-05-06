. C:\psscripts\Invoke-SqlCmd2.ps1



function SendAlarm($dep)
{
    
     
    $con = New-Object System.Data.SqlClient.SqlConnection
    $con.ConnectionString = "Server=. ;Database= monitoring; integrated security = true"

        $con.Open()
    
    $cmd = New-Object System.Data.SQlClient.SqlCommand
    $cmd.CommandText = "[FailedJobsAlarm]"
    $cmd.CommandType = [System.Data.CommandType]::StoredProcedure

       
    
    $cmd.Connection = $con
   
    $cmd.ExecuteNonQuery()
    
    $con.Close

}

function GetPassword($server)
{
    $server = 'c:\passwords\' +$server + '.txt'
    $credential = New-Object System.Management.Automation.PsCredential( 'sa', ( Get-Content $server | ConvertTo-SecureString ) ) 
    $credential.GetNetworkCredential().Password
}



$servs = invoke-sqlcmd -query "select distinct  server, IsDomain from AvailDB1 where IsFailedJobs = 1" -database monitoring -serverinstance sqlit01



#invoke-sqlcmd -query "delete from FailedJobsInfo_all" -database monitoring -serverinstance sqlit01

foreach ($serv in $servs)
{

    try 
    {

                
    if ($serv.IsDomain)
    {
    
        #$serv.server

        $dt=invoke-sqlcmd2 -InputFile  "C:\psscripts\FailedJobs.sql" -ServerInstance  $serv.server -Database master 
    
        Write-DataTable -ServerInstance sqlit01 -Database monitoring -TableName FailedJobsInfo_all -Data $dt
     }
     else
     {
        
         $pass = GetPassword $serv.server
           #$val = invoke-sqlcmd  -query $query -database $serv.dbname -serverinstance $serv.server -username 'sa' -password $pass -ErrorAction 'Stop'
        
          $dt=invoke-sqlcmd2 -InputFile  "C:\psscripts\FailedJobs.sql" -ServerInstance  $serv.server -Database master  -username 'sa' -password $pass
    
          Write-DataTable -ServerInstance sqlit01 -Database monitoring -TableName FailedJobsInfo_all -Data $dt
        
     }   
       
     }
     catch
     {
     
     }   
}


SendAlarm