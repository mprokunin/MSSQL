
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
    $cmd.Parameters['@server'].value = $server.ToString()
        $cmd.Parameters.Add("@name", [system.data.sqldbtype]::Varchar)
    $cmd.Parameters['@name'].value = $name.ToString()
    $cmd.Parameters.Add("@run_value", [system.data.sqldbtype]::int)
    $cmd.Parameters['@run_value'].value = $run_value
    
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

    $query = "exec [" + $row.server + "].master.sys.sp_executesql N'sp_configure';"
    
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
SendAlarm