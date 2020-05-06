USE [master]
GO

/****** Object:  UserDefinedFunction [dbo].[fn_hadr_group_is_primary]    Script Date: 23.05.2019 15:20:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[fn_hadr_group_is_primary] (@AGName sysname)
RETURNS bit
AS
BEGIN;
  DECLARE @PrimaryReplica sysname; 

  SELECT
    @PrimaryReplica = hags.primary_replica
  FROM sys.dm_hadr_availability_group_states hags
  INNER JOIN sys.availability_groups ag ON ag.group_id = hags.group_id
  WHERE ag.name = @AGName;

  IF UPPER(@PrimaryReplica) =  UPPER(@@SERVERNAME)
    RETURN 1; -- primary

    RETURN 0; -- not primary
END; 

-----
GO


