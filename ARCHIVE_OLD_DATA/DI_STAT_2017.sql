USE [master]
GO

/****** Object:  Database [DI_STAT_2017]    Script Date: 5/22/2020 8:47:57 PM ******/
CREATE DATABASE [DI_STAT_2017]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'DI_STAT_2017', FILENAME = N'U:\DATA\DI_STAT_2017.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'DI_STAT_2017_log', FILENAME = N'U:\LOG\DI_STAT_2017_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
GO

IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [DI_STAT_2017].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO

ALTER DATABASE [DI_STAT_2017] SET ANSI_NULL_DEFAULT OFF 
GO

ALTER DATABASE [DI_STAT_2017] SET ANSI_NULLS OFF 
GO

ALTER DATABASE [DI_STAT_2017] SET ANSI_PADDING OFF 
GO

ALTER DATABASE [DI_STAT_2017] SET ANSI_WARNINGS OFF 
GO

ALTER DATABASE [DI_STAT_2017] SET ARITHABORT OFF 
GO

ALTER DATABASE [DI_STAT_2017] SET AUTO_CLOSE OFF 
GO

ALTER DATABASE [DI_STAT_2017] SET AUTO_SHRINK OFF 
GO

ALTER DATABASE [DI_STAT_2017] SET AUTO_UPDATE_STATISTICS ON 
GO

ALTER DATABASE [DI_STAT_2017] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO

ALTER DATABASE [DI_STAT_2017] SET CURSOR_DEFAULT  GLOBAL 
GO

ALTER DATABASE [DI_STAT_2017] SET CONCAT_NULL_YIELDS_NULL OFF 
GO

ALTER DATABASE [DI_STAT_2017] SET NUMERIC_ROUNDABORT OFF 
GO

ALTER DATABASE [DI_STAT_2017] SET QUOTED_IDENTIFIER OFF 
GO

ALTER DATABASE [DI_STAT_2017] SET RECURSIVE_TRIGGERS OFF 
GO

ALTER DATABASE [DI_STAT_2017] SET  DISABLE_BROKER 
GO

ALTER DATABASE [DI_STAT_2017] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO

ALTER DATABASE [DI_STAT_2017] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO

ALTER DATABASE [DI_STAT_2017] SET TRUSTWORTHY OFF 
GO

ALTER DATABASE [DI_STAT_2017] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO

ALTER DATABASE [DI_STAT_2017] SET PARAMETERIZATION SIMPLE 
GO

ALTER DATABASE [DI_STAT_2017] SET READ_COMMITTED_SNAPSHOT OFF 
GO

ALTER DATABASE [DI_STAT_2017] SET HONOR_BROKER_PRIORITY OFF 
GO

ALTER DATABASE [DI_STAT_2017] SET RECOVERY SIMPLE 
GO

ALTER DATABASE [DI_STAT_2017] SET  MULTI_USER 
GO

ALTER DATABASE [DI_STAT_2017] SET PAGE_VERIFY CHECKSUM  
GO

ALTER DATABASE [DI_STAT_2017] SET DB_CHAINING OFF 
GO

ALTER DATABASE [DI_STAT_2017] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO

ALTER DATABASE [DI_STAT_2017] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO

ALTER DATABASE [DI_STAT_2017] SET DELAYED_DURABILITY = DISABLED 
GO

ALTER DATABASE [DI_STAT_2017] SET QUERY_STORE = OFF
GO

USE [DI_STAT_2017]
GO

ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = OFF;
GO

ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 0;
GO

ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = ON;
GO

ALTER DATABASE SCOPED CONFIGURATION SET QUERY_OPTIMIZER_HOTFIXES = OFF;
GO

ALTER DATABASE [DI_STAT_2017] SET  READ_WRITE 
GO


USE [DI_STAT_2017]
GO

select max(policyID) from [DI_STAT].[dbo].[policies] with (nolock) where [CreationDate] < '2018-01-01'  -- 51350081
select min(policyID) from [DI_STAT].[dbo].[policies] with (nolock) where [CreationDate] < '2018-01-01'  -- 42823768

CREATE PARTITION FUNCTION policy_PF (int) 
AS RANGE LEFT FOR VALUES (
42000000, 43000000, 44000000, 45000000, 46000000, 47000000, 48000000, 49000000, 50000000, 51000000, 52000000); 
GO

CREATE PARTITION SCHEME policy_PS
AS PARTITION policy_PF 
TO ([PRIMARY],[PRIMARY],[PRIMARY],[PRIMARY],[PRIMARY],[PRIMARY],[PRIMARY],[PRIMARY],[PRIMARY],[PRIMARY],[PRIMARY],[PRIMARY]);
go

/****** Object:  Table [dbo].[policies]    Script Date: 5/22/2020 8:37:42 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
--drop table [DI_STAT_2017].[dbo].[policies]
CREATE TABLE [dbo].[policies](
	[policyID] [int] NOT NULL,
	[creationDate] [datetime] NOT NULL,
	[InsuredSum] [bigint] NULL,
	[Bonus] [float] NULL,
	[StartDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[LastEditDate] [datetime] NOT NULL,
	[programID] [int] NOT NULL,
	[content] [xml] NOT NULL,
	[status] [nvarchar](50) NULL,
	[Number] [varchar](255) NULL,
	[creatorID] [int] NULL,
	[lastUser] [int] NULL,
	[integrationStatus] [varchar](50) NULL,
	[printStatus] [tinyint] NOT NULL,
	[currency] [char](3) NULL,
	[exchangeRate] [float] NULL,
	[signDate] [datetime] NULL,
	[prevNumber] [varchar](50) NULL,
	[InsuranceObject] [varchar](500) NULL,
	[results] [xml] NULL,
	[insurant] [varchar](500) NULL,
	[rescissionResult] [xml] NULL,
	[rescissionInterview] [xml] NULL,
	[BackOfficeSystemID] [int] NULL,
	[notificationID] [int] NULL,
	[SiebelID] [varchar](15) NULL,
	[AccountNumber] [varchar](50) NULL,
	[SyncDate] [datetime] NULL,
	[TSTAMP] [datetime] NOT NULL,
	[DWH_DELETED_FLG] [char](1) NULL,
 CONSTRAINT [PK_policies] PRIMARY KEY CLUSTERED 
(
	[policyID] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, data_compression = PAGE) ON [policy_PS] ([policyID])
) ON [policy_PS] ([policyID]) 
GO

--drop table [dbo].[plc]
CREATE TABLE [dbo].[plc](
	[policyID] [int] NOT NULL,
	[creationDate] [datetime] NOT NULL,
	[InsuredSum] [bigint] NULL,
	[Bonus] [float] NULL,
	[StartDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[LastEditDate] [datetime] NOT NULL,
	[programID] [int] NOT NULL,
	[content] [xml] NOT NULL,
	[status] [nvarchar](50) NULL,
	[Number] [varchar](255) NULL,
	[creatorID] [int] NULL,
	[lastUser] [int] NULL,
	[integrationStatus] [varchar](50) NULL,
	[printStatus] [tinyint] NOT NULL,
	[currency] [char](3) NULL,
	[exchangeRate] [float] NULL,
	[signDate] [datetime] NULL,
	[prevNumber] [varchar](50) NULL,
	[InsuranceObject] [varchar](500) NULL,
	[results] [xml] NULL,
	[insurant] [varchar](500) NULL,
	[rescissionResult] [xml] NULL,
	[rescissionInterview] [xml] NULL,
	[BackOfficeSystemID] [int] NULL,
	[notificationID] [int] NULL,
	[SiebelID] [varchar](15) NULL,
	[AccountNumber] [varchar](50) NULL,
	[SyncDate] [datetime] NULL,
	[TSTAMP] [datetime] NOT NULL,
	[DWH_DELETED_FLG] [char](1) NULL,
 CONSTRAINT [PK_plc] PRIMARY KEY CLUSTERED 
(
	[policyID] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [policy_PS] ([policyID])
) ON [policy_PS] ([policyID]) 
GO
-- sp_help policies


--- PREPARE to MOVE
create table [policies_ID] (
	[policyID] [int] NOT NULL,
 CONSTRAINT [PK_policies_ID] PRIMARY KEY CLUSTERED 
 (
	[policyID] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] 

--- MOVE DATA to DI_STAT_2017
SET ROWCOUNT 1000
declare @RC int = 1, @CNT int = 0, @BEFORE datetime = '2018-01-01 00:00:00.000'
WHILE (@RC > 0 and @CNT < 5000) 
begin 
  begin tran move_2017
  -- Save IDs 
  truncate table [policies_ID]
  insert into [policies_ID] select [policyID] from [DI_STAT].[dbo].[policies] where [CreationDate] < @BEFORE -- 4337122 total
  -- Move rows with saved IDs
  insert into [DI_STAT_2017].[dbo].[policies]
	select [old].* from [DI_STAT].[dbo].[policies] [old] join [policies_ID] [new] on [new].[policyID] = [old].[policyID]
  select @RC = @@ROWCOUNT
  PRINT @RC
  delete [old] from [DI_STAT].[dbo].[policies] [old] inner join [policies_ID] [new] on [new].[policyID] = [old].[policyID]
  select @CNT += 1
  commit 
end


set rowcount 10000
insert into plc select * from [DI_STAT].[dbo].[policies] 
select * from plc

sp_partitioninfo

declare @RC int = 1, @CNT int = 0, @BEFORE datetime = '2018-01-01 00:00:00.000'
select count([policyID]) from [DI_STAT].[dbo].[policies] where [CreationDate] < @BEFORE -- 4337122 total
select count([policyID]) from [DI_STAT].[dbo].[policies] where policyID > 45000000 and policyID <= 46000000 -- 56769

exec sp_spaceused plc --no compression = 8710128 KB -- page compressed 8707616 KB -- row compressed 8709408 KB
exec sp_spaceused policies
truncate table [DI_STAT_2017].[dbo].[policies]
truncate table [DI_STAT_2017].[dbo].[plc]

exec [DI_STAT]..sp_helpindex '[dbo].[policies]'

GO
select * from [dbo].[PartitionRanges]
sp_partitioninfo
select top 100 * from [DI_STAT_2017].[dbo].[policies] where policyID > 52000000
select count(policyID) from [DI_STAT_2017].[dbo].[policies] where policyID > 46000000
select count(policyID) from [DI_STAT_2017].[dbo].[policies] where policyID > 45000000 and policyID <= 46000000
select count(policyID) from [DI_STAT_2017].[dbo].[policies] where policyID <= 45000000 
select count(policyID) from [DI_STAT_2017].[dbo].[policies] 

select policyID from [DI_STAT_2017].[dbo].[policies] where policyID <= 45000000 
select top 100 * from [DI_STAT].[dbo].[policies] where policyID in (select policyID from [DI_STAT_2017].[dbo].[policies] )where policyID <= 45000000 )
sp_who [rimos_nt_01\mprokunin]
