-- Get Read-Only Routing
SELECT   AVGSrc.replica_server_name AS SourceReplica
 , AVGRepl.replica_server_name AS ReadOnlyReplica
 , AVGRepl.read_only_routing_url AS RoutingURL
 , AVGRL.routing_priority AS RoutingPriority
 FROM sys.availability_read_only_routing_lists AVGRL
 INNER JOIN sys.availability_replicas AVGSrc ON AVGRL.replica_id = AVGSrc.replica_id
 INNER JOIN sys.availability_replicas AVGRepl ON AVGRL.read_only_replica_id = AVGRepl.replica_id
 INNER JOIN sys.availability_groups AV ON AV.group_id = AVGSrc.group_id
 ORDER BY SourceReplica


USE [master]
GO
ALTER AVAILABILITY GROUP [Webhadr1]
MODIFY REPLICA ON N'SQL202\WEB' WITH (SECONDARY_ROLE(READ_ONLY_ROUTING_URL = N'TCP://SQL202.aton.global:52711'))
GO

ALTER AVAILABILITY GROUP [Webhadr1]
MODIFY REPLICA ON N'AL-SQL04\WEB' WITH (SECONDARY_ROLE(READ_ONLY_ROUTING_URL = N'TCP://AL-SQL04.aton.global:51804'))
GO
