USE [master]
GO
drop procedure [dbo].[sp_Traceon_1204_1222]
go

/****** Object:  StoredProcedure [dbo].[sp_Traceon_1204_1222]    Script Date: 01.08.2018 14:29:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[sp_Traceon_1204_1222] as 
begin
dbcc traceon(1204, -1)--  Comment for REN-MSKSQL21\LOGS
dbcc traceon(1222, -1) 
end
GO

EXEC sp_procoption N'[dbo].[sp_Traceon_1204_1222]', 'startup', '1'
GO


--dbcc tracestatus()
--exec [master].[dbo].[sp_Traceon_1204_1222]
dbcc traceoff(1222, -1)
dbcc traceoff(1204, -1)

sp_cycle_errorlog