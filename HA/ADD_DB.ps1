# Backup my database and its log on the primary  
Backup-SqlDatabase `  
    -Database "SSISDB" `  
    -BackupFile "\\share\backups\SSISDB.bak" `  
    -ServerInstance "PrimaryComputer\Instance"  

Backup-SqlDatabase `  
    -Database "SSISDB" `  
    -BackupFile "\\share\backups\SSISDB.log" `  
    -ServerInstance "PrimaryComputer\Instance" `  
    -BackupAction Log   

# Restore the database and log on the secondary (using NO RECOVERY)  
Restore-SqlDatabase `  
    -Database "SSISDB" `  
    -BackupFile "\\share\backups\SSISDB.bak" `  
    -ServerInstance "SecondaryComputer\Instance" `  
    -NoRecovery  

Restore-SqlDatabase `  
    -Database "SSISDB" `  
    -BackupFile "\\share\backups\SSISDB.log" `  
    -ServerInstance "SecondaryComputer\Instance" `  
    -RestoreAction Log `  
    -NoRecovery  

# Create an in-memory representation of the primary replica.  
$primaryReplica = New-SqlAvailabilityReplica `  
    -Name "PrimaryComputer\Instance" `  
    -EndpointURL "TCP://PrimaryComputer.domain.com:5022" `  
    -AvailabilityMode "SynchronousCommit" `  
    -FailoverMode "Automatic" `  
    -Version 12 `  
    -AsTemplate  

# Create an in-memory representation of the secondary replica.  
$secondaryReplica = New-SqlAvailabilityReplica `  
    -Name "SecondaryComputer\Instance" `  
    -EndpointURL "TCP://SecondaryComputer.domain.com:5022" `  
    -AvailabilityMode "SynchronousCommit" `  
    -FailoverMode "Automatic" `  
    -Version 12 `  
    -AsTemplate  

# Create the availability group  
New-SqlAvailabilityGroup `  
    -Name "MyAG" `  
    -Path "SQLSERVER:\SQL\PrimaryComputer\Instance" `  
    -AvailabilityReplica @($primaryReplica,$secondaryReplica) `  
    -Database "SSISDB"  

# Join the secondary replica to the availability group.  
Join-SqlAvailabilityGroup -Path "SQLSERVER:\SQL\SecondaryComputer\Instance" -Name "MyAG"  

# Join the secondary database to the availability group.  
Add-SqlAvailabilityDatabase -Path "SQLSERVER:\SQL\SecondaryComputer\Instance\AvailabilityGroups\MyAG" -Database "SSISDB"
