USE [master]
GO

/****** Object:  Table [dbo].[io_stalls]    Script Date: 16.04.2019 21:16:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[io_stalls](
	[DT] [datetime] NULL,
	[Database Name] [nvarchar](128) NULL,
	[avg_read_stall_ms] [numeric](10, 1) NULL,
	[avg_write_stall_ms] [numeric](10, 1) NULL,
	[avg_io_stall_ms] [numeric](10, 1) NULL,
	[File Size (MB)] [decimal](18, 2) NULL,
	[physical_name] [nvarchar](260) NOT NULL,
	[type_desc] [nvarchar](60) NULL,
	[io_stall_read_ms] [bigint] NOT NULL,
	[num_of_reads] [bigint] NOT NULL,
	[io_stall_write_ms] [bigint] NOT NULL,
	[num_of_writes] [bigint] NOT NULL,
	[io_stalls] [bigint] NULL,
	[total_io] [bigint] NULL,
	[Resource Governor Total Read IO Latency (ms)] [bigint] NOT NULL,
	[Resource Governor Total Write IO Latency (ms)] [bigint] NOT NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[io_stalls] ADD  DEFAULT (getdate()) FOR [DT]
GO




 
 
-- Login: svu_job
CREATE LOGIN [svu_job] WITH PASSWORD = 0x0200A90F3B87C09A5F023FFB43635290D6491E67EAA16C266DEADE68E42E2A31673F62426EF12FFC9FC2CD5429F1522DDBC7523B06210479D05019E2A9E589E218245F46E0C3 HASHED, SID = 0x030ACF47D7F7C0478431AE6C560572FA, DEFAULT_DATABASE = [master], CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF
use master
go
grant exec on dbo.CommandExecute to [svu_job] 
go
grant exec on dbo.IndexOptimize to [svu_job] 
go
grant select, insert, update, delete on CommandLog to [svu_job] 
go
