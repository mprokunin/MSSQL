USE [master]
GO

/****** Object:  ResourcePool [PerfPool]    Script Date: 11/25/2020 4:16:38 PM ******/
CREATE RESOURCE POOL [PerfPool_MEM10] WITH(min_cpu_percent=0, 
		max_cpu_percent=100, 
		min_memory_percent=10, 
		max_memory_percent=100, 
		cap_cpu_percent=100, 
		AFFINITY SCHEDULER = AUTO
, 
		min_iops_per_volume=0, 
		max_iops_per_volume=0)
GO

USE [master]
GO

/****** Object:  WorkloadGroup [PerfGroup]    Script Date: 11/25/2020 4:16:53 PM ******/
CREATE WORKLOAD GROUP [PerfGroup_MEM10] WITH(group_max_requests=0, 
		importance=High, 
		request_max_cpu_time_sec=0, 
		request_max_memory_grant_percent=25, 
		request_memory_grant_timeout_sec=0, 
		max_dop=0) USING [PerfPool_MEM10], EXTERNAL [default]
GO
-------------------------
/****** Object:  UserDefinedFunction [dbo].[rgClassifier]    Script Date: 11/25/2020 4:33:17 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[rgClassifier]() 
RETURNS sysname 
WITH SCHEMABINDING
AS
BEGIN
     -- Define the return sysname variable for the function
     DECLARE @grp_name AS sysname;
     SET @grp_name = 'default';

     -- Specify the T-SQL statements for mapping session information
     -- with Workload Groups defined for the Resource Governor.
     IF (IS_SRVROLEMEMBER('PerfRole_MEM10') = 1)
          SET @grp_name = 'PerfGroup_MEM10';

	-- TODO
	-- Put additional classification logic here
     RETURN @grp_name;
END
GO

-------------------------S

USE [master]
GO

ALTER RESOURCE GOVERNOR WITH (CLASSIFIER_FUNCTION = [dbo].[rgClassifier]);
GO

ALTER RESOURCE GOVERNOR WITH (MAX_OUTSTANDING_IO_PER_VOLUME = DEFAULT);
GO

ALTER RESOURCE GOVERNOR RECONFIGURE;
GO

USE [master]
GO


---------------------------
USE master;  
SELECT * FROM sys.resource_governor_resource_pools;  
SELECT * FROM sys.resource_governor_workload_groups;  
GO  

SELECT    SDES.[session_id] as 'Session ID',
              db_name(SDES.[database_id]) as 'DB',
              [host_name] as 'Host Name',
              [program_name] as 'Program Name',
              SDES.[login_name], 
              SDRGWG.[Name] as 'Group Assigned',
              DRGRP.[name] as 'Pool Assigned'
FROM sys.dm_exec_sessions SDES
        INNER JOIN sys.dm_resource_governor_workload_groups SDRGWG
                ON SDES.[group_id] = SDRGWG.[group_id]
        INNER JOIN sys.dm_resource_governor_resource_pools DRGRP
                ON SDRGWG.[pool_id] = DRGRP.[pool_id]
             where DRGRP.[name] = 'PerfRole_MEM10'

--------------------------------


SELECT osn.memory_node_id AS [numa_node_id], sc.cpu_id, sc.scheduler_id  
FROM sys.dm_os_nodes AS osn  
INNER JOIN sys.dm_os_schedulers AS sc   
    ON osn.node_id = sc.parent_node_id   
    AND sc.scheduler_id < 1048576; 
