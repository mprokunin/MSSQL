select object_name(object_id) TableName,i.name IndexName, ps.Name PartitionScheme, pf.name PartitionFunction
 from sys.indexes i
 join sys.partition_schemes ps on ps.data_space_id = i.data_space_id
 join sys.partition_functions pf on pf.function_id = ps.function_id 

 sp_whoisactive
 sp_spaceused StockTrans
 sp_who 53
 dbcc inputbuffer(53)

name		rows		reserved	data		index_size	unused
StockTrans	159113666   34659184 KB	20317128 KB	14245504 KB	96552 KB

sp_helpindex StockTrans

USE [ABCBase]
GO
----
ALTER TABLE [dbo].[StockTrans] DROP  CONSTRAINT [XPKStockTrans] 
go
ALTER TABLE [dbo].[StockTrans] ADD  CONSTRAINT [XPKStockTrans] PRIMARY KEY CLUSTERED 
(
	[TransID] ASC, [TransDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON StockTrans_PS([TransDate])
GO
----
drop index [AssetID_Index] ON [dbo].[StockTrans]
go
CREATE NONCLUSTERED INDEX [AssetID_Index] ON [dbo].[StockTrans]
(
	[AssetID] ASC, [TransDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON StockTrans_PS([TransDate])
GO
----
drop index [IX_StockTrans_OperID]  ON [dbo].[StockTrans]
go
CREATE NONCLUSTERED INDEX [IX_StockTrans_OperID] ON [dbo].[StockTrans]
(
	[OperID] ASC, [TransDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON StockTrans_PS([TransDate])
GO
----
drop index [IX_StockTrans_RecStamp] ON [dbo].[StockTrans]
go
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_StockTrans_RecStamp] ON [dbo].[StockTrans]
(
	[RecStamp] ASC, [TransDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON StockTrans_PS([TransDate])
GO
----
drop index [RcvIdSndId_Index] ON [dbo].[StockTrans]
go
CREATE NONCLUSTERED INDEX [RcvIdSndId_Index] ON [dbo].[StockTrans]
(
	[RcvID] ASC, [SndID] ASC, [TransDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON StockTrans_PS([TransDate])
GO
----
drop index [TransDate_Index] ON [dbo].[StockTrans]
go
