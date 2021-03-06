SELECT
  cs.replica_server_name 
 ,rs.role_desc, cs.join_state_desc, rs.synchronization_health_desc
FROM sys.availability_groups_cluster AS ag 
INNER JOIN sys.dm_hadr_availability_replica_cluster_states AS cs ON cs.group_id = ag.group_id
INNER JOIN sys.dm_hadr_availability_replica_states AS rs ON rs.replica_id = cs.replica_id
