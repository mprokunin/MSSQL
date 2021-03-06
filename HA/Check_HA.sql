-- List Replicas
SELECT replica_server_name, availability_mode, availability_mode_desc, failover_mode, failover_mode_desc -- , *
FROM sys.availability_replicas


SELECT
AG.name AS [Name],ISNULL(agstates.primary_replica, '') AS [PrimaryReplicaServerName],ISNULL(arstates.role, 3) AS [LocalReplicaRole]
FROM master.sys.availability_groups AS AG
LEFT OUTER JOIN master.sys.dm_hadr_availability_group_states as agstates
    ON AG.group_id = agstates.group_id
INNER JOIN master.sys.availability_replicas AS AR
    ON AG.group_id = AR.group_id
INNER JOIN master.sys.dm_hadr_availability_replica_states AS arstates
    ON AR.replica_id = arstates.replica_id --AND arstates.is_local = 1
ORDER BY [Name] ASC

-- List database in AlwaysOn 
SELECT
AG.name AS [AvailabilityGroupName],
ISNULL(agstates.primary_replica, '') AS [PrimaryReplicaServerName],
ISNULL(arstates.role, 3) AS [LocalReplicaRole],
dbcs.database_name AS [DatabaseName],
ISNULL(dbrs.synchronization_state, 0) AS [SynchronizationState],
ISNULL(dbrs.is_suspended, 0) AS [IsSuspended],
ISNULL(dbcs.is_database_joined, 0) AS [IsJoined]
FROM master.sys.availability_groups AS AG
LEFT OUTER JOIN master.sys.dm_hadr_availability_group_states as agstates
   ON AG.group_id = agstates.group_id
INNER JOIN master.sys.availability_replicas AS AR
   ON AG.group_id = AR.group_id
INNER JOIN master.sys.dm_hadr_availability_replica_states AS arstates
   ON AR.replica_id = arstates.replica_id AND arstates.is_local = 1
INNER JOIN master.sys.dm_hadr_database_replica_cluster_states AS dbcs
   ON arstates.replica_id = dbcs.replica_id
LEFT OUTER JOIN master.sys.dm_hadr_database_replica_states AS dbrs
   ON dbcs.replica_id = dbrs.replica_id AND dbcs.group_database_id = dbrs.group_database_id
ORDER BY AG.name ASC, dbcs.database_name

-- Good overview of AG health and status (Query 17) (AlwaysOn AG Status)
SELECT ag.name AS [AG Name], ar.replica_server_name, ar.availability_mode_desc, adc.[database_name], 
	   drs.last_hardened_time, drs.last_redone_time, 
	   drs.log_send_rate, drs.redo_queue_size, drs.redo_rate, drs.filestream_send_rate, 
	   drs.end_of_log_lsn, drs.last_commit_lsn, drs.database_state_desc,
       drs.is_local, drs.is_primary_replica, drs.synchronization_state_desc, drs.is_commit_participant, 
	   drs.synchronization_health_desc, drs.recovery_lsn, drs.truncation_lsn, drs.last_sent_lsn, 
	   drs.last_sent_time, drs.last_received_lsn, drs.last_received_time, drs.last_hardened_lsn, 
	   drs.last_redone_lsn, drs.log_send_queue_size, drs.last_commit_time
FROM sys.dm_hadr_database_replica_states AS drs WITH (NOLOCK)
INNER JOIN sys.availability_databases_cluster AS adc WITH (NOLOCK)
ON drs.group_id = adc.group_id 
AND drs.group_database_id = adc.group_database_id
INNER JOIN sys.availability_groups AS ag WITH (NOLOCK)
ON ag.group_id = drs.group_id
INNER JOIN sys.availability_replicas AS ar WITH (NOLOCK)
ON drs.group_id = ar.group_id 
AND drs.replica_id = ar.replica_id
where adc.[database_name] = 'AtonBase'
ORDER BY adc.[database_name], ag.name, ar.replica_server_name OPTION (RECOMPILE);


SELECT db_name(DRS.database_id) as 'DB', AGS.NAME AS AGGroupName
    ,AR.replica_server_name AS InstanceName
    ,HARS.role_desc
    ,DRS.synchronization_state_desc AS SyncState
    ,DRS.last_hardened_time
    ,DRS.last_redone_time
    ,((DRS.log_send_queue_size)/8)/1024 QueueSize_MB
	,datediff(MINUTE, last_redone_time, last_hardened_time) as Latency_Minutes
FROM sys.dm_hadr_database_replica_states DRS
LEFT JOIN sys.availability_replicas AR ON DRS.replica_id = AR.replica_id
LEFT JOIN sys.availability_groups AGS ON AR.group_id = AGS.group_id
LEFT JOIN sys.dm_hadr_availability_replica_states HARS ON AR.group_id = HARS.group_id
    AND AR.replica_id = HARS.replica_id
order by DB


