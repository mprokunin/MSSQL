sp_helpdb [AtonBase171202]
USE [AtonBase171202]
GO
sp_help Operation
select min(OperID) from Operation with (index (XPKOperation)) -- -4039
select max(OperID) from Operation with (index (XPKOperation)) -- 187251223
select 187251223 + 4093 -- 187 255 316


/****** Object:  PartitionFunction [MPortfolio_BankID]    Script Date: 29.06.2018 18:06:35 ******/
CREATE PARTITION FUNCTION [Operation_OperID] (OperID)(int) AS RANGE LEFT FOR VALUES (10000000,20000000,30000000,40000000,50000000,60000000,70000000,80000000,90000000,100000000,110000000,120000000,130000000,140000000,150000000,160000000,170000000,180000000,190000000,200000000)
GO

CREATE PARTITION SCHEME [Operation_OperID] AS PARTITION [Operation_OperID] (OperID) TO ([OPER],[OPER],[OPER],[OPER],[OPER],[OPER],[OPER],[OPER],[OPER],[OPER],[OPER],[OPER],[OPER],[OPER],[OPER],[OPER],[OPER],[OPER],[OPER],[OPER],[OPER],[OPER])
GO
--Partition scheme 'Operation_OperID' has been created successfully. 'OPER' is marked as the next used filegroup in partition scheme 'Operation_OperID'.
--drop PARTITION SCHEME [Operation_OperID] 
--drop PARTITION FUNCTION [Operation_OperID] (OperID) 

select @@servername, db_name()
/****** Object:  Index [idx_operation_FrontOperID]    Script Date: 29.06.2018 18:39:02 ******/
DROP INDEX [idx_operation_FrontOperID] ON [dbo].[Operation]
GO
DROP INDEX [IX_Operation_AdjustmentMonth] ON [dbo].[Operation]
GO
DROP INDEX [IX_OPER_SD1] ON [dbo].[Operation]
GO
DROP INDEX [IX_Oper_SD] ON [dbo].[Operation]
GO
DROP INDEX [IX_OPER_RD2] ON [dbo].[Operation]
GO
DROP INDEX [IX_OPER_RD1] ON [dbo].[Operation]
GO
DROP INDEX [IX_OPER_RD] ON [dbo].[Operation]
GO
DROP INDEX [IX_OIDCD] ON [dbo].[Operation]
GO
DROP INDEX [IX_ODSI] ON [dbo].[Operation]
GO
DROP INDEX [IX_InstructionID] ON [dbo].[Operation]
GO
DROP INDEX [IX_CorrectDate] ON [dbo].[Operation]
GO
DROP INDEX [IX_AssetID] ON [dbo].[Operation]
GO
DROP INDEX [idx_operation_REV_STAMP] ON [dbo].[Operation]
GO
DROP INDEX [idx_operation_FrontOperID] ON [dbo].[Operation]
GO
DROP INDEX [IX_Operation_BCOM] ON [dbo].[Operation]
GO
DROP INDEX [IX_Operation_BSOperID] ON [dbo].[Operation]
go
DROP INDEX [IX_Operation_ClosedDate] ON [dbo].[Operation]
GO
drop index [IX_Operation_ContragentID] ON [dbo].[Operation]
go
DROP INDEX [IX_Operation_ExtOperNUm] ON [dbo].[Operation]
GO
DROP INDEX [IX_Operation_ExtOrderID] ON [dbo].[Operation]
GO
DROP INDEX [IX_Operation_IntOperNum] ON [dbo].[Operation]
GO
DROP INDEX [IX_Operation_IONOD] ON [dbo].[Operation]
go
DROP INDEX [IX_Operation_LinkAssetID] ON [dbo].[Operation]
GO
DROP INDEX [IX_Operation_LinkOperID_Incl] ON [dbo].[Operation]
GO
DROP INDEX [IX_Operation_OTAU] ON [dbo].[Operation]
GO
DROP INDEX [IX_Operation_OTIDOD] ON [dbo].[Operation]
GO
DROP INDEX [IX_Operation_PaymentDate] ON [dbo].[Operation]
GO
DROP INDEX [IX_Operation_rbtOperID] ON [dbo].[Operation]
GO
DROP INDEX [IX_Operation_ReflectionType] ON [dbo].[Operation]
GO
DROP INDEX [IX_Operation_SchemeID] ON [dbo].[Operation]
GO
DROP INDEX [IX_Operation_SettlementDate] ON [dbo].[Operation]
GO
DROP INDEX [IX_Operation_StockDate] ON [dbo].[Operation]
GO
DROP INDEX [IX_Operation_trd_no] ON [dbo].[Operation]
GO
DROP INDEX [IX_OperDate_TradeOperPlaceID] ON [dbo].[Operation]
GO
DROP INDEX [IX_OPIDION] ON [dbo].[Operation]
GO
DROP INDEX [IX_OrderID] ON [dbo].[Operation]
GO
DROP INDEX [IX_OTIDSC] ON [dbo].[Operation]
GO
DROP INDEX [IX_RCVIDODOTID] ON [dbo].[Operation]
GO
DROP INDEX [IX_RcvODSDPD] ON [dbo].[Operation]
go
DROP INDEX [IX_RD] ON [dbo].[Operation]
GO
DROP INDEX [IX_SIDOTIDPD] ON [dbo].[Operation]
GO
DROP INDEX [IX_SNDIDODOTID] ON [dbo].[Operation]
GO
DROP INDEX [IX_SndODSDPD] ON [dbo].[Operation]
GO
DROP INDEX [IX_TicketID] ON [dbo].[Operation]
GO
DROP INDEX [IX_TypeCode] ON [dbo].[Operation]
GO
DROP INDEX [NDX_Operation_StockInstrID] ON [dbo].[Operation]
GO


--(1 row affected)

--(1 row affected)
--Msg 1908, Level 16, State 1, Line 226
--Column 'OperID' is partitioning column of the index 'idx_operation_REV_STAMP'. Partition columns for a unique index must be a subset of the index key.
--Msg 1908, Level 16, State 1, Line 336
--Column 'OperID' is partitioning column of the index 'IX_Operation_IntOperNum'. Partition columns for a unique index must be a subset of the index key.

--(1 row affected)

--(1 row affected)

--(1 row affected)
sp_help Operation











SET ANSI_PADDING ON
GO
----------------- DROP Foreign keys


EXEC sp_fkeys 'Operation'
go
ALTER TABLE [dbo].[DividendPayClient] drop CONSTRAINT [FK__DividendP__OperI__6509867B] 
go
ALTER TABLE [dbo].[Operation]  drop CONSTRAINT [Ref_BSOperID_2_OperID] 
go
ALTER TABLE [dbo].[tblOperMoneyTransSum] DROP CONSTRAINT [FK_tblOperMoneyTransSum_OperID]
GO
ALTER TABLE [dbo].[OperLink] DROP CONSTRAINT [FK__OperLink__Slave]
GO
ALTER TABLE [dbo].[MoneyTrans] DROP CONSTRAINT [FK__MoneyTran__OperI__727DEDC9]
GO
ALTER TABLE [dbo].[ComHistory] DROP CONSTRAINT [FK__ComHistor__OperI__0B7EA5BD]
GO
ALTER TABLE [dbo].[OperLink] DROP CONSTRAINT [FK__OperLink__Master]
GO
ALTER TABLE [dbo].[CommOper] DROP CONSTRAINT [FK__CommOper__OperID__16F05869]
GO
ALTER TABLE [dbo].[SPortfolio] DROP CONSTRAINT [FK__SPortfoli__OperI__4B2F167E]
GO
ALTER TABLE [dbo].[StockTrans] DROP CONSTRAINT [FK__StockTran__OperI__4EFFA762]
GO
ALTER TABLE [dbo].[Trade] DROP CONSTRAINT [FK__Trade__OperID__009702F6]
GO
ALTER TABLE [dbo].[MPortfolio] DROP CONSTRAINT [FK__MPortfoli__OperI__7FD7E8E7]
GO
ALTER TABLE [dbo].[tblRequireOperLink] DROP CONSTRAINT [FK_tblRequireOperLink_OperID]
GO
ALTER TABLE [dbo].[tblCommCalcOperationLink] DROP CONSTRAINT [FK_tblCommCalcOperationLink_OperID]
GO
ALTER TABLE [dbo].[DividendRegulationPayment] DROP CONSTRAINT [FK__DividendR__OperI__67E5F326]
GO
ALTER TABLE [dbo].[Ex_Operation] DROP CONSTRAINT [FK_Ex_Operation_Operation]
GO
ALTER TABLE [dbo].[InstrLink] DROP CONSTRAINT [FK__InstrLink__Operation]
GO
ALTER TABLE [dbo].[OperParamSet] DROP CONSTRAINT [FK__OperParam__OperI__3CCE7C5D]
GO
ALTER TABLE [dbo].[OperReq] DROP CONSTRAINT [FK__OperReq__OperID__327D9EEB]
GO
ALTER TABLE [dbo].[tblDealFieldUpdate] DROP CONSTRAINT [FK_tblDealFieldUpdate_Operation_OperID]
GO
ALTER TABLE [dbo].[tblDividendAllocationOperationLog] DROP CONSTRAINT [FK_tblDividendAllocationOperationLog_OperID]
GO
ALTER TABLE [dbo].[tblNettingLink] DROP CONSTRAINT [FK_tblNettingLink_OperID_OperID_OperID]
GO
ALTER TABLE [dbo].[tblOperationDatePlnUpdate] DROP CONSTRAINT [FK_tblOperationDatePlnUpdate_OperID]
GO
ALTER TABLE [dbo].[tblOperationSign] DROP CONSTRAINT [FK_tblOperationSign_Operation]
GO
ALTER TABLE [dbo].[DepoAccount] DROP CONSTRAINT [FK__DepoAccou__LinkO__39EBB4FA]
GO
ALTER TABLE [dbo].[Operation] DROP CONSTRAINT [FK_Operation_Operation_Brock]
GO






--SELECT OBJECT_NAME(REFERENCED_OBJECT_ID) AS MASTERTABLE 
--	FROM SYS.FOREIGN_KEY_COLUMNS A JOIN SYS.COLUMNS B ON A.PARENT_COLUMN_ID =B.COLUMN_ID AND A.PARENT_OBJECT_ID=B.OBJECT_ID 
--		JOIN SYS.COLUMNS C ON A.CONSTRAINT_COLUMN_ID=C.COLUMN_ID AND A.REFERENCED_OBJECT_ID=C.OBJECT_ID 
--WHERE OBJECT_NAME(PARENT_OBJECT_ID)='Operation'


------------ CREATE CLUSTERED INDEX
/****** Object:  Index [XPKOperation]    Script Date: 29.06.2018 18:30:38 ******/
ALTER TABLE [dbo].[Operation] DROP  CONSTRAINT [XPKOperation] 
go
--DROP INDEX [XPKOperation] ON [dbo].[Operation]
GO

sp_helpindex [Operation]
go
select getdate() as 'Start' -- 2018-06-29 20:07:01.227
go
ALTER TABLE [dbo].[Operation] ADD  CONSTRAINT [XPKOperation] PRIMARY KEY CLUSTERED 
(
	[OperID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) 
ON [Operation_OperID] (OperID)
GO

select getdate() as 'Finished CLUSTERED KEY' -- 2018-06-29 23:28:34.770
go

------------------- CREATE Nonclustered indices
/****** Object:  Index [idx_operation_FrontOperID]    Script Date: 29.06.2018 18:31:49 ******/
CREATE NONCLUSTERED INDEX [idx_operation_FrontOperID] ON [dbo].[Operation]
(
	[FrontOperID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Operation_OperID] (OperID)
GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_operation_REV_STAMP] ON [dbo].[Operation]
(
	[rev_stamp] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Operation_OperID] (OperID)
GO
CREATE NONCLUSTERED INDEX [IX_AssetID] ON [dbo].[Operation]
(
	[AssetID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Operation_OperID] (OperID)
GO
CREATE NONCLUSTERED INDEX [IX_CorrectDate] ON [dbo].[Operation]
(
	[CorrectDate] ASC
)
INCLUDE ( 	[RcvID],
	[SndID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Operation_OperID] (OperID)
GO
CREATE NONCLUSTERED INDEX [IX_InstructionID] ON [dbo].[Operation]
(
	[InstructionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Operation_OperID] (OperID)
GO
CREATE NONCLUSTERED INDEX [IX_ODSI] ON [dbo].[Operation]
(
	[OperDate] ASC,
	[ServiceInf] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Operation_OperID] (OperID)
GO
CREATE NONCLUSTERED INDEX [IX_OIDCD] ON [dbo].[Operation]
(
	[OperID] ASC,
	[CreateDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Operation_OperID] (OperID)
GO
CREATE NONCLUSTERED INDEX [IX_Oper_RD] ON [dbo].[Operation]
(
	[OperDate] ASC,
	[RcvID] ASC,
	[RcvOperPlaceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Operation_OperID] (OperID)
GO
CREATE NONCLUSTERED INDEX [IX_OPER_RD1] ON [dbo].[Operation]
(
	[RcvID] ASC,
	[RcvOperPlaceID] ASC
)
INCLUDE ( 	[SettlementDate],
	[PaymentDate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Operation_OperID] (OperID)
GO
CREATE NONCLUSTERED INDEX [IX_OPER_RD2] ON [dbo].[Operation]
(
	[RcvID] ASC,
	[PaymentDate] ASC,
	[RcvOperPlaceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Operation_OperID] (OperID)
GO
CREATE NONCLUSTERED INDEX [IX_Oper_SD] ON [dbo].[Operation]
(
	[SndID] ASC,
	[SndOperPlaceID] ASC
)
INCLUDE ( 	[OperDate],
	[PaymentDate],
	[SettlementDate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Operation_OperID] (OperID)
GO
CREATE NONCLUSTERED INDEX [IX_OPER_SD1] ON [dbo].[Operation]
(
	[SndID] ASC,
	[SettlementDate] ASC,
	[SndOperPlaceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Operation_OperID] (OperID)
GO
CREATE NONCLUSTERED INDEX [IX_Operation_AdjustmentMonth] ON [dbo].[Operation]
(
	[AdjustmentMonth] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Operation_OperID] (OperID)
GO

------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX [IX_Operation_BCOM] ON [dbo].[Operation]
(
	[BrokComOperID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Operation_OperID] (OperID)
GO
CREATE NONCLUSTERED INDEX [IX_Operation_BSOperID] ON [dbo].[Operation]
(
	[BSOperID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [Operation_OperID] (OperID)
GO
CREATE NONCLUSTERED INDEX [IX_Operation_ClosedDate] ON [dbo].[Operation]
(
	[ClosedDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Operation_OperID] (OperID)
GO
CREATE NONCLUSTERED INDEX [IX_Operation_ContragentID] ON [dbo].[Operation]
(
	[ContragentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Operation_OperID] (OperID)
GO
CREATE NONCLUSTERED INDEX [IX_Operation_ExtOperNUm] ON [dbo].[Operation]
(
	[ExtOperNum] ASC,
	[OperTemplID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Operation_OperID] (OperID)
GO
CREATE NONCLUSTERED INDEX [IX_Operation_ExtOrderID] ON [dbo].[Operation]
(
	[ExtOrderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Operation_OperID] (OperID)
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Operation_IntOperNum] ON [dbo].[Operation]
(
	[IntOperNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Operation_OperID] (OperID)
GO
select getdate() as 'Finished IX_Operation_IntOperNum' -- 2018-06-30 02:57:59.210
go

CREATE NONCLUSTERED INDEX [IX_Operation_IONOD] ON [dbo].[Operation]
(
	[IntOperNum] ASC,
	[OperDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Operation_OperID] (OperID)
GO
CREATE NONCLUSTERED INDEX [IX_Operation_LinkAssetID] ON [dbo].[Operation]
(
	[LinkAssetID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Operation_OperID] (OperID)
GO
CREATE NONCLUSTERED INDEX [IX_Operation_LinkOperID_Incl] ON [dbo].[Operation]
(
	[LinkOperID] ASC
)
INCLUDE ( 	[OperID],
	[PaymentDate],
	[ServiceInf],
	[Quantity]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Operation_OperID] (OperID)
GO
CREATE NONCLUSTERED INDEX [IX_Operation_OTAU] ON [dbo].[Operation]
(
	[OperTemplID] ASC,
	[AssignUser] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Operation_OperID] (OperID)
GO
CREATE NONCLUSTERED INDEX [IX_Operation_OTIDOD] ON [dbo].[Operation]
(
	[OperTemplID] ASC,
	[OperDate] ASC
)
INCLUDE ( 	[ClosedDate],
	[PaymentCurr],
	[PaymentDate],
	[PriceCurr],
	[SettlementDate],
	[TypeCode]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Operation_OperID] (OperID)
GO
CREATE NONCLUSTERED INDEX [IX_Operation_PaymentDate] ON [dbo].[Operation]
(
	[PaymentDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Operation_OperID] (OperID)
GO
CREATE NONCLUSTERED INDEX [IX_Operation_rbtOperID] ON [dbo].[Operation]
(
	[rbtOperID] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [Operation_OperID] (OperID)
GO
CREATE NONCLUSTERED INDEX [IX_Operation_ReflectionType] ON [dbo].[Operation]
(
	[ReflectionType] ASC
)
INCLUDE ( 	[OperID],
	[OperTemplID],
	[IntOperNum],
	[RcvID],
	[SndID],
	[AssetID],
	[Quantity],
	[TotalPayment],
	[Comment],
	[Creator],
	[TradeOperPlaceID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Operation_OperID] (OperID)
GO
CREATE NONCLUSTERED INDEX [IX_Operation_SchemeID] ON [dbo].[Operation]
(
	[SchemeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Operation_OperID] (OperID)
GO
CREATE NONCLUSTERED INDEX [IX_Operation_SettlementDate] ON [dbo].[Operation]
(
	[SettlementDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Operation_OperID] (OperID)
GO
CREATE NONCLUSTERED INDEX [IX_Operation_StockDate] ON [dbo].[Operation]
(
	[StockDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Operation_OperID] (OperID)
GO
CREATE NONCLUSTERED INDEX [IX_Operation_trd_no] ON [dbo].[Operation]
(
	[mif_trd_no] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Operation_OperID] (OperID)
GO
CREATE NONCLUSTERED INDEX [IX_OperDate_TradeOperPlaceID] ON [dbo].[Operation]
(
	[OperDate] ASC,
	[TradeOperPlaceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Operation_OperID] (OperID)
GO
CREATE NONCLUSTERED INDEX [IX_OPIDION] ON [dbo].[Operation]
(
	[OperTemplID] ASC,
	[IntOperNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Operation_OperID] (OperID)
GO
CREATE NONCLUSTERED INDEX [IX_OrderID] ON [dbo].[Operation]
(
	[OrderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Operation_OperID] (OperID)
GO
CREATE NONCLUSTERED INDEX [IX_OTIDSC] ON [dbo].[Operation]
(
	[OperTemplID] ASC,
	[SettleCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Operation_OperID] (OperID)
GO
CREATE NONCLUSTERED INDEX [IX_RCVIDODOTID] ON [dbo].[Operation]
(
	[RcvID] ASC,
	[OperDate] ASC,
	[OperTemplID] ASC
)
INCLUDE ( 	[ServiceInf]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Operation_OperID] (OperID)
GO
CREATE NONCLUSTERED INDEX [IX_RcvODSDPD] ON [dbo].[Operation]
(
	[RcvID] ASC,
	[PaymentDate] ASC
)
INCLUDE ( 	[OperDate],
	[SettlementDate],
	[OperTemplID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Operation_OperID] (OperID)
GO
CREATE NONCLUSTERED INDEX [IX_RD] ON [dbo].[Operation]
(
	[ReportDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Operation_OperID] (OperID)
GO
CREATE NONCLUSTERED INDEX [IX_SIDOTIDPD] ON [dbo].[Operation]
(
	[SndID] ASC,
	[OperTemplID] ASC,
	[PaymentDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Operation_OperID] (OperID)
GO
CREATE NONCLUSTERED INDEX [IX_SNDIDODOTID] ON [dbo].[Operation]
(
	[SndID] ASC,
	[OperDate] ASC,
	[OperTemplID] ASC
)
INCLUDE ( 	[ServiceInf]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Operation_OperID] (OperID)
GO
CREATE NONCLUSTERED INDEX [IX_SndODSDPD] ON [dbo].[Operation]
(
	[SndID] ASC,
	[OperDate] ASC,
	[SettlementDate] ASC,
	[PaymentDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Operation_OperID] (OperID)
GO
CREATE NONCLUSTERED INDEX [IX_TicketID] ON [dbo].[Operation]
(
	[TicketID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Operation_OperID] (OperID)
GO
CREATE NONCLUSTERED INDEX [IX_TypeCode] ON [dbo].[Operation]
(
	[TypeCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Operation_OperID] (OperID)
GO
CREATE NONCLUSTERED INDEX [NDX_Operation_StockInstrID] ON [dbo].[Operation]
(
	[StockInstrID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Operation_OperID] (OperID)
GO
select getdate() as 'Finished other keys' -- 2018-06-30 08:17:27.593
go


---------------- FOREIGN KEYS
ALTER TABLE [dbo].[Operation]  WITH CHECK ADD  CONSTRAINT [Ref_BSOperID_2_OperID] FOREIGN KEY([BSOperID])
REFERENCES [dbo].[Operation] ([OperID])
GO
ALTER TABLE [dbo].[Operation] CHECK CONSTRAINT [Ref_BSOperID_2_OperID]
GO
ALTER TABLE [dbo].[DividendPayClient]  WITH NOCHECK ADD  CONSTRAINT [FK__DividendP__OperI__6509867B] FOREIGN KEY([OperID])
REFERENCES [dbo].[Operation] ([OperID])
GO
ALTER TABLE [dbo].[DividendPayClient] CHECK CONSTRAINT [FK__DividendP__OperI__6509867B]
GO
ALTER TABLE [dbo].[tblOperMoneyTransSum]  WITH CHECK ADD  CONSTRAINT [FK_tblOperMoneyTransSum_OperID] FOREIGN KEY([OperID])
REFERENCES [dbo].[Operation] ([OperID])
GO
ALTER TABLE [dbo].[tblOperMoneyTransSum] CHECK CONSTRAINT [FK_tblOperMoneyTransSum_OperID]
GO
ALTER TABLE [dbo].[OperLink]  WITH CHECK ADD  CONSTRAINT [FK__OperLink__Slave] FOREIGN KEY([SlaveOperID])
REFERENCES [dbo].[Operation] ([OperID])
GO
ALTER TABLE [dbo].[OperLink] CHECK CONSTRAINT [FK__OperLink__Slave]
GO
ALTER TABLE [dbo].[MoneyTrans]  WITH NOCHECK ADD  CONSTRAINT [FK__MoneyTran__OperI__727DEDC9] FOREIGN KEY([OperID])
REFERENCES [dbo].[Operation] ([OperID])
GO
ALTER TABLE [dbo].[MoneyTrans] CHECK CONSTRAINT [FK__MoneyTran__OperI__727DEDC9]
GO
ALTER TABLE [dbo].[ComHistory]  WITH NOCHECK ADD  CONSTRAINT [FK__ComHistor__OperI__0B7EA5BD] FOREIGN KEY([OperID])
REFERENCES [dbo].[Operation] ([OperID])
GO
ALTER TABLE [dbo].[ComHistory] CHECK CONSTRAINT [FK__ComHistor__OperI__0B7EA5BD]
GO
ALTER TABLE [dbo].[OperLink]  WITH CHECK ADD  CONSTRAINT [FK__OperLink__Master] FOREIGN KEY([MasterOperID])
REFERENCES [dbo].[Operation] ([OperID])
GO
ALTER TABLE [dbo].[OperLink] CHECK CONSTRAINT [FK__OperLink__Master]
GO
ALTER TABLE [dbo].[CommOper]  WITH NOCHECK ADD  CONSTRAINT [FK__CommOper__OperID__16F05869] FOREIGN KEY([OperID])
REFERENCES [dbo].[Operation] ([OperID])
GO
ALTER TABLE [dbo].[CommOper] CHECK CONSTRAINT [FK__CommOper__OperID__16F05869]
GO
ALTER TABLE [dbo].[SPortfolio]  WITH NOCHECK ADD  CONSTRAINT [FK__SPortfoli__OperI__4B2F167E] FOREIGN KEY([OperID])
REFERENCES [dbo].[Operation] ([OperID])
GO
ALTER TABLE [dbo].[SPortfolio] CHECK CONSTRAINT [FK__SPortfoli__OperI__4B2F167E]
GO
ALTER TABLE [dbo].[StockTrans]  WITH NOCHECK ADD  CONSTRAINT [FK__StockTran__OperI__4EFFA762] FOREIGN KEY([OperID])
REFERENCES [dbo].[Operation] ([OperID])
GO
ALTER TABLE [dbo].[StockTrans] CHECK CONSTRAINT [FK__StockTran__OperI__4EFFA762]
GO
ALTER TABLE [dbo].[Trade]  WITH NOCHECK ADD  CONSTRAINT [FK__Trade__OperID__009702F6] FOREIGN KEY([OperID])
REFERENCES [dbo].[Operation] ([OperID])
GO
ALTER TABLE [dbo].[Trade] CHECK CONSTRAINT [FK__Trade__OperID__009702F6]
GO
ALTER TABLE [dbo].[MPortfolio]  WITH NOCHECK ADD  CONSTRAINT [FK__MPortfoli__OperI__7FD7E8E7] FOREIGN KEY([OperID])
REFERENCES [dbo].[Operation] ([OperID])
GO
ALTER TABLE [dbo].[MPortfolio] CHECK CONSTRAINT [FK__MPortfoli__OperI__7FD7E8E7]
GO
ALTER TABLE [dbo].[tblRequireOperLink]  WITH CHECK ADD  CONSTRAINT [FK_tblRequireOperLink_OperID] FOREIGN KEY([OperID])
REFERENCES [dbo].[Operation] ([OperID])
GO
ALTER TABLE [dbo].[tblRequireOperLink] CHECK CONSTRAINT [FK_tblRequireOperLink_OperID]
GO
ALTER TABLE [dbo].[tblCommCalcOperationLink]  WITH CHECK ADD  CONSTRAINT [FK_tblCommCalcOperationLink_OperID] FOREIGN KEY([OperID])
REFERENCES [dbo].[Operation] ([OperID])
GO
ALTER TABLE [dbo].[tblCommCalcOperationLink] CHECK CONSTRAINT [FK_tblCommCalcOperationLink_OperID]
GO
ALTER TABLE [dbo].[DividendRegulationPayment]  WITH NOCHECK ADD  CONSTRAINT [FK__DividendR__OperI__67E5F326] FOREIGN KEY([OperID])
REFERENCES [dbo].[Operation] ([OperID])
GO
ALTER TABLE [dbo].[DividendRegulationPayment] CHECK CONSTRAINT [FK__DividendR__OperI__67E5F326]
GO
ALTER TABLE [dbo].[tblOperationSign]  WITH CHECK ADD  CONSTRAINT [FK_tblOperationSign_Operation] FOREIGN KEY([OperID])
REFERENCES [dbo].[Operation] ([OperID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblOperationSign] CHECK CONSTRAINT [FK_tblOperationSign_Operation]
GO
ALTER TABLE [dbo].[tblOperationDatePlnUpdate]  WITH CHECK ADD  CONSTRAINT [FK_tblOperationDatePlnUpdate_OperID] FOREIGN KEY([OperID])
REFERENCES [dbo].[Operation] ([OperID])
GO
ALTER TABLE [dbo].[tblOperationDatePlnUpdate] CHECK CONSTRAINT [FK_tblOperationDatePlnUpdate_OperID]
GO
ALTER TABLE [dbo].[tblNettingLink]  WITH CHECK ADD  CONSTRAINT [FK_tblNettingLink_OperID_OperID_OperID] FOREIGN KEY([OperID])
REFERENCES [dbo].[Operation] ([OperID])
GO
ALTER TABLE [dbo].[tblNettingLink] CHECK CONSTRAINT [FK_tblNettingLink_OperID_OperID_OperID]
GO
ALTER TABLE [dbo].[tblDividendAllocationOperationLog]  WITH CHECK ADD  CONSTRAINT [FK_tblDividendAllocationOperationLog_OperID] FOREIGN KEY([OperID])
REFERENCES [dbo].[Operation] ([OperID])
GO
ALTER TABLE [dbo].[tblDividendAllocationOperationLog] CHECK CONSTRAINT [FK_tblDividendAllocationOperationLog_OperID]
GO
ALTER TABLE [dbo].[tblDealFieldUpdate]  WITH CHECK ADD  CONSTRAINT [FK_tblDealFieldUpdate_Operation_OperID] FOREIGN KEY([OperID])
REFERENCES [dbo].[Operation] ([OperID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblDealFieldUpdate] CHECK CONSTRAINT [FK_tblDealFieldUpdate_Operation_OperID]
GO
ALTER TABLE [dbo].[OperReq]  WITH CHECK ADD FOREIGN KEY([OperID])
REFERENCES [dbo].[Operation] ([OperID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[OperParamSet]  WITH CHECK ADD FOREIGN KEY([OperID])
REFERENCES [dbo].[Operation] ([OperID])
GO
ALTER TABLE [dbo].[InstrLink]  WITH NOCHECK ADD  CONSTRAINT [FK__InstrLink__Operation] FOREIGN KEY([OperID])
REFERENCES [dbo].[Operation] ([OperID])
GO
ALTER TABLE [dbo].[InstrLink] CHECK CONSTRAINT [FK__InstrLink__Operation]
GO
ALTER TABLE [dbo].[Ex_Operation]  WITH CHECK ADD  CONSTRAINT [FK_Ex_Operation_Operation] FOREIGN KEY([OperID])
REFERENCES [dbo].[Operation] ([OperID])
GO
ALTER TABLE [dbo].[Ex_Operation] CHECK CONSTRAINT [FK_Ex_Operation_Operation]
GO
ALTER TABLE [dbo].[DepoAccount]  WITH CHECK ADD FOREIGN KEY([LinkOperID])
REFERENCES [dbo].[Operation] ([OperID])
GO
ALTER TABLE [dbo].[Operation]  WITH CHECK ADD  CONSTRAINT [FK_Operation_Operation_Brock] FOREIGN KEY([BrokComOperID])
REFERENCES [dbo].[Operation] ([OperID])
GO
ALTER TABLE [dbo].[Operation] CHECK CONSTRAINT [FK_Operation_Operation_Brock]
GO
select getdate() as 'Finished FK' -- 2018-06-30 08:26:26.080
go


------------------- Is table partitioned

SELECT *   
FROM sys.tables AS t   
JOIN sys.indexes AS i   
    ON t.[object_id] = i.[object_id]   
    AND i.[type] IN (0,1)   
JOIN sys.partition_schemes ps   
    ON i.data_space_id = ps.data_space_id   
WHERE t.name = 'Operation';   
GO  
-----boundary values for each partition
SELECT t.name AS TableName, i.name AS IndexName, p.partition_number, p.partition_id, i.data_space_id, f.function_id, f.type_desc, r.boundary_id, r.value AS BoundaryValue   
FROM sys.tables AS t  
JOIN sys.indexes AS i  
    ON t.object_id = i.object_id  
JOIN sys.partitions AS p  
    ON i.object_id = p.object_id AND i.index_id = p.index_id   
JOIN  sys.partition_schemes AS s   
    ON i.data_space_id = s.data_space_id  
JOIN sys.partition_functions AS f   
    ON s.function_id = f.function_id  
LEFT JOIN sys.partition_range_values AS r   
    ON f.function_id = r.function_id and r.boundary_id = p.partition_number  
WHERE t.name = 'Operation' AND i.type <= 1  
ORDER BY p.partition_number;  


----------- name of the partitioning column for table
SELECT   
    t.[object_id] AS ObjectID   
    , t.name AS TableName   
    , ic.column_id AS PartitioningColumnID   
    , c.name AS PartitioningColumnName   
FROM sys.tables AS t   
JOIN sys.indexes AS i   
    ON t.[object_id] = i.[object_id]   
    AND i.[type] <= 1 -- clustered index or a heap   
JOIN sys.partition_schemes AS ps   
    ON ps.data_space_id = i.data_space_id   
JOIN sys.index_columns AS ic   
    ON ic.[object_id] = i.[object_id]   
    AND ic.index_id = i.index_id   
    AND ic.partition_ordinal >= 1 -- because 0 = non-partitioning column   
JOIN sys.columns AS c   
    ON t.[object_id] = c.[object_id]   
    AND ic.column_id = c.column_id   
WHERE t.name = 'Operation' ;   
GO  

select * from sys.dm_db_partition_stats where object_id=object_id('Operation')
select sum(reserved_page_count)*8 as 'RESERVED, KB' from sys.dm_db_partition_stats where object_id=object_id('Operation') and index_id=1
select sum(used_page_count)*8 from sys.dm_db_partition_stats where object_id=object_id('Operation') and index_id=1

sp_spaceused Operation -- 118 506 872 KB









------------------

/****** Object:  Table [dbo].[Operation]    Script Date: 29.06.2018 18:02:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Operation](
	[OperID] [int] IDENTITY(1,1) NOT NULL,
	[LinkOperID] [int] NULL,
	[OperTemplID] [int] NOT NULL,
	[OperDate] [dbo].[ShortDate] NOT NULL,
	[OperTime] [dbo].[FullDate] NOT NULL,
	[IntOperNum] [dbo].[LongString] NOT NULL,
	[ExtOperNum] [dbo].[LongString] NULL,
	[OrderID] [dbo].[UID] NULL,
	[RcvOperPlaceID] [int] NOT NULL,
	[RcvID] [int] NOT NULL,
	[RcvVaultID] [int] NULL,
	[RcvBankID] [int] NULL,
	[SndID] [int] NOT NULL,
	[SndOperPlaceID] [int] NOT NULL,
	[SndVaultID] [int] NULL,
	[SndBankID] [int] NULL,
	[AssetID] [int] NOT NULL,
	[Quantity] [dbo].[Currency] NOT NULL,
	[Price] [dbo].[Currency] NOT NULL,
	[PriceCurr] [int] NOT NULL,
	[TotalPayment] [dbo].[Currency] NOT NULL,
	[TotalPayed] [dbo].[Currency] NOT NULL,
	[PaymentCurr] [int] NULL,
	[SettlementDate] [dbo].[ShortDate] NULL,
	[PaymentDate] [dbo].[ShortDate] NULL,
	[ClosedDate] [dbo].[ShortDate] NULL,
	[StockUser] [dbo].[ShortString] NULL,
	[StockDate] [dbo].[ShortDate] NULL,
	[MoneyUser] [dbo].[ShortString] NULL,
	[MoneyDate] [dbo].[ShortDate] NULL,
	[RcvDepoInstr] [varchar](255) NULL,
	[RcvDepoInstrDate] [dbo].[ShortDate] NULL,
	[SndDepoInstr] [varchar](255) NULL,
	[SndDepoInstrDate] [dbo].[ShortDate] NULL,
	[Comment] [dbo].[LargeString] NULL,
	[Creator] [dbo].[ShortString] NOT NULL,
	[CreateDate] [dbo].[FullDate] NOT NULL,
	[Corrector] [dbo].[ShortString] NULL,
	[CorrectDate] [dbo].[FullDate] NULL,
	[TypeCode] [dbo].[LITERA] NULL,
	[ServiceInf] [dbo].[LongString] NULL,
	[ExtOrderID] [dbo].[LongString] NULL,
	[rev_stamp] [timestamp] NOT NULL,
	[AssignGroup] [dbo].[ShortString] NULL,
	[AssignUser] [dbo].[ShortString] NULL,
	[RateTypeID] [tinyint] NULL,
	[RateNum] [dbo].[Currency] NULL,
	[RateDenom] [dbo].[Currency] NULL,
	[RateDate] [dbo].[ShortDate] NULL,
	[TaxFreeQtty] [dbo].[Currency] NOT NULL,
	[SettleCode] [varchar](3) NULL,
	[FrontOperID] [bigint] NULL,
	[ContragentID] [int] NULL,
	[rev_ins] [tinyint] NULL,
	[SchemeID] [int] NULL,
	[FStamp] [bigint] NOT NULL,
	[TicketID] [int] NULL,
	[CommentEng] [dbo].[LargeString] NULL,
	[LinkAssetID] [int] NULL,
	[IsNotInTax] [tinyint] NOT NULL,
	[InstructionID] [int] NULL,
	[PaymentDateBlocked] [dbo].[ShortDate] NULL,
	[IsNotForClientReport] [tinyint] NOT NULL,
	[RepoTerm] [int] NULL,
	[ExpirationType] [tinyint] NULL,
	[RepoPrice2] [dbo].[Currency] NULL,
	[OtherYear] [int] NULL,
	[ContragentPrice] [dbo].[Currency] NULL,
	[JournalTime] [datetime] NULL,
	[IsNotForDepoReport] [dbo].[BYTE] NULL,
	[IsNoCom] [tinyint] NULL,
	[BrokComOperID] [int] NULL,
	[IsInTaxRemainUsed] [dbo].[BYTE] NULL,
	[StockInstrID] [int] NULL,
	[ReportDate] [datetime] NULL,
	[BSOperID] [int] NULL,
	[RateDIT] [dbo].[Currency] NULL,
	[ProfitRelationType] [dbo].[BYTE] NULL,
	[TicketSetID] [int] NULL,
	[TicketOrderInSet] [int] NULL,
	[ExchangeID] [int] NULL,
	[MarketPlaceID] [int] NULL,
	[Trader] [dbo].[ShortString] NULL,
	[SalesManager] [dbo].[ShortString] NULL,
	[BackupSalesManager] [dbo].[ShortString] NULL,
	[SalesTraderManager] [dbo].[ShortString] NULL,
	[SalesManagerPercent] [numeric](11, 8) NULL,
	[BackupSalesManagerPercent] [numeric](11, 8) NULL,
	[SalesTraderManagerPercent] [numeric](11, 8) NULL,
	[SomebodyManagerPercent] [numeric](11, 8) NULL,
	[SomebodyManager] [dbo].[ShortString] NULL,
	[isFXSwap] [tinyint] NULL,
	[IsNotInRisk] [dbo].[BYTE] NULL,
	[PresentatorID] [int] NULL,
	[RcvExtAccount] [varchar](255) NULL,
	[SndExtAccount] [varchar](255) NULL,
	[IsOpenRepo] [tinyint] NULL,
	[ReflectionType] [int] NULL,
	[SystemID] [int] NULL,
	[IsRepo] [tinyint] NULL,
	[TradeOperPlaceID] [int] NULL,
	[ExtBrokerID] [int] NULL,
	[SourceTypeID] [int] NULL,
	[RcvCalcOperPlaceID] [int] NULL,
	[SndCalcOperPlaceID] [int] NULL,
	[DestCounterpartyID] [int] NULL,
	[IsNotReflect] [tinyint] NULL,
	[IsPostpone] [tinyint] NULL,
	[mif_trd_no] [int] NULL,
	[AdjustmentMonth] [dbo].[ShortDate] NULL,
	[rbtOperID] [int] NULL,
	[rbtPosID] [int] NULL,
	[PaymentDatePln] [datetime] NULL,
	[TreasureRateNum] [numeric](20, 9) NULL,
	[TreasureRateDenom] [numeric](20, 9) NULL,
 CONSTRAINT [XPKOperation] PRIMARY KEY CLUSTERED 
(
	[OperID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [OPER]
) ON [OPER]
GO

ALTER TABLE [dbo].[Operation] ADD  DEFAULT ((0)) FOR [isFXSwap]
GO

ALTER TABLE [dbo].[Operation] ADD  DEFAULT ((0)) FOR [IsOpenRepo]
GO

ALTER TABLE [dbo].[Operation] ADD  DEFAULT ((0)) FOR [IsRepo]
GO

ALTER TABLE [dbo].[Operation] ADD  DEFAULT ((0)) FOR [IsNotReflect]
GO

ALTER TABLE [dbo].[Operation]  WITH NOCHECK ADD  CONSTRAINT [FK__Operation__32E4EDA6] FOREIGN KEY([RcvID], [RcvOperPlaceID])
REFERENCES [dbo].[CpOnOperPlace] ([CounterPartyID], [OperPlaceID])
GO

ALTER TABLE [dbo].[Operation] CHECK CONSTRAINT [FK__Operation__32E4EDA6]
GO

ALTER TABLE [dbo].[Operation]  WITH NOCHECK ADD  CONSTRAINT [FK__Operation__33D911DF] FOREIGN KEY([SndID], [SndOperPlaceID])
REFERENCES [dbo].[CpOnOperPlace] ([CounterPartyID], [OperPlaceID])
GO

ALTER TABLE [dbo].[Operation] CHECK CONSTRAINT [FK__Operation__33D911DF]
GO

ALTER TABLE [dbo].[Operation]  WITH NOCHECK ADD  CONSTRAINT [FK__Operation__Assig__2D2C1450] FOREIGN KEY([AssignUser])
REFERENCES [dbo].[DBUser] ([Name])
GO

ALTER TABLE [dbo].[Operation] CHECK CONSTRAINT [FK__Operation__Assig__2D2C1450]
GO

ALTER TABLE [dbo].[Operation]  WITH NOCHECK ADD  CONSTRAINT [FK__Operation__Assig__2E203889] FOREIGN KEY([AssignGroup])
REFERENCES [dbo].[DBUser] ([Name])
GO

ALTER TABLE [dbo].[Operation] CHECK CONSTRAINT [FK__Operation__Assig__2E203889]
GO

ALTER TABLE [dbo].[Operation]  WITH CHECK ADD FOREIGN KEY([ContragentID])
REFERENCES [dbo].[Counterparty] ([CounterPartyID])
GO

ALTER TABLE [dbo].[Operation]  WITH CHECK ADD FOREIGN KEY([InstructionID])
REFERENCES [dbo].[Instruction] ([InstructionID])
GO

ALTER TABLE [dbo].[Operation]  WITH NOCHECK ADD  CONSTRAINT [FK__Operation__LinkA__3C8FEA1F] FOREIGN KEY([LinkAssetID])
REFERENCES [dbo].[Asset] ([AssetID])
GO

ALTER TABLE [dbo].[Operation] CHECK CONSTRAINT [FK__Operation__LinkA__3C8FEA1F]
GO

ALTER TABLE [dbo].[Operation]  WITH NOCHECK ADD  CONSTRAINT [FK__Operation__OperT__300880FB] FOREIGN KEY([OperTemplID])
REFERENCES [dbo].[OperTempl] ([OperTemplID])
GO

ALTER TABLE [dbo].[Operation] CHECK CONSTRAINT [FK__Operation__OperT__300880FB]
GO

ALTER TABLE [dbo].[Operation]  WITH NOCHECK ADD  CONSTRAINT [FK__Operation__RateT__2F145CC2] FOREIGN KEY([RateTypeID])
REFERENCES [dbo].[RateType] ([RateTypeID])
GO

ALTER TABLE [dbo].[Operation] CHECK CONSTRAINT [FK__Operation__RateT__2F145CC2]
GO

ALTER TABLE [dbo].[Operation]  WITH NOCHECK ADD  CONSTRAINT [FK__Operation__RcvBa__389DC6FC] FOREIGN KEY([RcvBankID])
REFERENCES [dbo].[Vault] ([VaultID])
GO

ALTER TABLE [dbo].[Operation] CHECK CONSTRAINT [FK__Operation__RcvBa__389DC6FC]
GO

ALTER TABLE [dbo].[Operation]  WITH NOCHECK ADD  CONSTRAINT [FK__Operation__RcvVa__37A9A2C3] FOREIGN KEY([RcvVaultID])
REFERENCES [dbo].[Vault] ([VaultID])
GO

ALTER TABLE [dbo].[Operation] CHECK CONSTRAINT [FK__Operation__RcvVa__37A9A2C3]
GO

ALTER TABLE [dbo].[Operation]  WITH NOCHECK ADD  CONSTRAINT [FK__Operation__Schem__31F0C96D] FOREIGN KEY([SchemeID])
REFERENCES [dbo].[Scheme] ([SchemeID])
GO

ALTER TABLE [dbo].[Operation] CHECK CONSTRAINT [FK__Operation__Schem__31F0C96D]
GO

ALTER TABLE [dbo].[Operation]  WITH NOCHECK ADD  CONSTRAINT [FK__Operation__SndBa__3A860F6E] FOREIGN KEY([SndBankID])
REFERENCES [dbo].[Vault] ([VaultID])
GO

ALTER TABLE [dbo].[Operation] CHECK CONSTRAINT [FK__Operation__SndBa__3A860F6E]
GO

ALTER TABLE [dbo].[Operation]  WITH NOCHECK ADD  CONSTRAINT [FK__Operation__SndVa__3991EB35] FOREIGN KEY([SndVaultID])
REFERENCES [dbo].[Vault] ([VaultID])
GO

ALTER TABLE [dbo].[Operation] CHECK CONSTRAINT [FK__Operation__SndVa__3991EB35]
GO

ALTER TABLE [dbo].[Operation]  WITH CHECK ADD FOREIGN KEY([TicketID])
REFERENCES [dbo].[Ticket] ([TicketID])
GO

ALTER TABLE [dbo].[Operation]  WITH NOCHECK ADD  CONSTRAINT [FK__Operation__TypeC__36B57E8A] FOREIGN KEY([TypeCode])
REFERENCES [dbo].[TradeType] ([TypeCode])
GO

ALTER TABLE [dbo].[Operation] CHECK CONSTRAINT [FK__Operation__TypeC__36B57E8A]
GO

ALTER TABLE [dbo].[Operation]  WITH CHECK ADD  CONSTRAINT [FK_Operation_Company_ExtBrokerID_CompanyID] FOREIGN KEY([ExtBrokerID])
REFERENCES [dbo].[Company] ([CompanyID])
GO

ALTER TABLE [dbo].[Operation] CHECK CONSTRAINT [FK_Operation_Company_ExtBrokerID_CompanyID]
GO

ALTER TABLE [dbo].[Operation]  WITH CHECK ADD  CONSTRAINT [FK_Operation_Counterparty_DestCounterpartyID_CounterpartyID] FOREIGN KEY([DestCounterpartyID])
REFERENCES [dbo].[Counterparty] ([CounterPartyID])
GO

ALTER TABLE [dbo].[Operation] CHECK CONSTRAINT [FK_Operation_Counterparty_DestCounterpartyID_CounterpartyID]
GO

ALTER TABLE [dbo].[Operation]  WITH CHECK ADD  CONSTRAINT [FK_Operation_Operation_Brock] FOREIGN KEY([BrokComOperID])
REFERENCES [dbo].[Operation] ([OperID])
GO

ALTER TABLE [dbo].[Operation] CHECK CONSTRAINT [FK_Operation_Operation_Brock]
GO

ALTER TABLE [dbo].[Operation]  WITH CHECK ADD  CONSTRAINT [FK_Operation_OperPlace_TradeOperPlaceID] FOREIGN KEY([TradeOperPlaceID])
REFERENCES [dbo].[OperPlace] ([OperPlaceID])
GO

ALTER TABLE [dbo].[Operation] CHECK CONSTRAINT [FK_Operation_OperPlace_TradeOperPlaceID]
GO

ALTER TABLE [dbo].[Operation]  WITH CHECK ADD  CONSTRAINT [FK_Operation_RcvCalcOperPlaceID] FOREIGN KEY([RcvCalcOperPlaceID])
REFERENCES [dbo].[OperPlace] ([OperPlaceID])
GO

ALTER TABLE [dbo].[Operation] CHECK CONSTRAINT [FK_Operation_RcvCalcOperPlaceID]
GO

ALTER TABLE [dbo].[Operation]  WITH CHECK ADD  CONSTRAINT [FK_Operation_SndCalcOperPlaceID] FOREIGN KEY([SndCalcOperPlaceID])
REFERENCES [dbo].[OperPlace] ([OperPlaceID])
GO

ALTER TABLE [dbo].[Operation] CHECK CONSTRAINT [FK_Operation_SndCalcOperPlaceID]
GO

ALTER TABLE [dbo].[Operation]  WITH CHECK ADD  CONSTRAINT [FK_OperationExchange] FOREIGN KEY([ExchangeID])
REFERENCES [dbo].[Exchange] ([ExchangeID])
GO

ALTER TABLE [dbo].[Operation] CHECK CONSTRAINT [FK_OperationExchange]
GO

ALTER TABLE [dbo].[Operation]  WITH CHECK ADD  CONSTRAINT [Ref_BSOperID_2_OperID] FOREIGN KEY([BSOperID])
REFERENCES [dbo].[Operation] ([OperID])
GO

ALTER TABLE [dbo].[Operation] CHECK CONSTRAINT [Ref_BSOperID_2_OperID]
GO

ALTER TABLE [dbo].[Operation]  WITH NOCHECK ADD  CONSTRAINT [LargerOrEqualZero7] CHECK  (([Price] >= 0))
GO

ALTER TABLE [dbo].[Operation] CHECK CONSTRAINT [LargerOrEqualZero7]
GO

ALTER TABLE [dbo].[Operation]  WITH NOCHECK ADD  CONSTRAINT [LargerZero19] CHECK  (([Quantity] > 0))
GO

ALTER TABLE [dbo].[Operation] CHECK CONSTRAINT [LargerZero19]
GO

ALTER TABLE [dbo].[Operation]  WITH NOCHECK ADD  CONSTRAINT [MoreThen20081999] CHECK  (([OperDate] >= '08.20.1999'))
GO

ALTER TABLE [dbo].[Operation] CHECK CONSTRAINT [MoreThen20081999]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Уникальный идентификатор операции' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'OperID'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Признак объединения операций в группу' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'LinkOperID'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Идентификатор шаблона операции' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'OperTemplID'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Дата совершения операции (без времени)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'OperDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Время совершения операции' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'OperTime'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Внутренний номер операции в системе' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'IntOperNum'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Внешний номер операции в системе' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'ExtOperNum'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Идентификатор заявки' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'OrderID'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Идентификатор Площадки - получателя' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'RcvOperPlaceID'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Идентификатор счета владения - получателя' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'RcvID'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Идентификатор бумажного счета получателя' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'RcvVaultID'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Идентификатор денежного счета получателя' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'RcvBankID'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Идентификатор счета владения отправителя' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'SndID'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Идентификатор Площадки отправителя' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'SndOperPlaceID'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Идентификатор бумажного счета отправителя' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'SndVaultID'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Идентификатор денежного счета отправителя' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'SndBankID'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Идентификатор актива' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'AssetID'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Количество Актива' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'Quantity'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Цена единицы актива' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'Price'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Валюта цены' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'PriceCurr'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Сумма к оплате' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'TotalPayment'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Оплачено' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'TotalPayed'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Валюта платежа' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'PaymentCurr'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Дата поставки актива' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'SettlementDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Дата оплаты актива или поставки денег' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'PaymentDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Это поле ничего не говорит о том, закрыта ли сделка по поставке и оплате. Имеет значение только для OTC-сделок. Проставленная ClosedDate блокирует дальнейшие изменения в сделках' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'ClosedDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Пользователь, утвердивший сделку (бумаги)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'StockUser'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Дата утверждения сделки (бумаги)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'StockDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Пользователь, утвердивший сделку (деньги)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'MoneyUser'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Дата утверждения сделки (деньги)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'MoneyDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Номер депозитарного поручения' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'RcvDepoInstr'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Дата депозитарного поручения' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'RcvDepoInstrDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Номер депозитарного поручения' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'SndDepoInstr'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Дата депозитарного поручения' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'SndDepoInstrDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Коментарий к операции' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'Comment'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Пользователь, который создал запись' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'Creator'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Дата создания записи' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'CreateDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Пользователь изменивший запись' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'Corrector'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Дата последнего изменения' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'CorrectDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Тип сделки' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'TypeCode'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Служебное поле:
   погашение купона-COUP=[ID Купона]' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'ServiceInf'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Внешний идентификатор заявки,
   приходящий с биржи' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'ExtOrderID'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Имя пользователя/группы' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'AssignGroup'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Имя пользователя/группы' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'AssignUser'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Идентификатор типа курса' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'RateTypeID'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Курс-числитель (в случае фиксированного курса)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'RateNum'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Курс-числитель (в случае фиксированного курса)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'RateDenom'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Дата на которую фиксируется курс (в случае фиксированного курса на дату)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'RateDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Количество актива не облагаемого налогом' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'TaxFreeQtty'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Используется при формировании биржевой сделки.
   Вохможные значения:
   T0 - обыкновенная сделка, которая закрывается в тотже день
   B## - левая сделка. Проводки закрываются на дату OperDate+## по хитрому алгоритму (см. процеду' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'SettleCode'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Разнос баз. Идентификатор соответствующей операции в базе AtonBase_Front. Заполняется только для пришедших из соски сделок.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'FrontOperID'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Идентификатор счета владения' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'ContragentID'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Поле используется при переносе операций из AtonBase_Main в AtonBase_front. Кроме того 
   для переноса необходимо, чтобы FrontOperID был NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'rev_ins'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Идентификатор спец схемы' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'SchemeID'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Версия записи Фокуса' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'FStamp'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Идентификатор билета' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'TicketID'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Комментарий к операции, английский' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'CommentEng'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Идентификатор Актива привязанного к данной операции' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'LinkAssetID'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Признак того, что данная операция не учитывается в расчете налога' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'IsNotInTax'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Идентификатор поручения' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'InstructionID'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Дата закрытия последней денежной проводки на банк Clients(BLOCKED)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'PaymentDateBlocked'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Не отображать в клиентском отчете' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'IsNotForClientReport'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Количество дней, через которое будет заключена вторая часть сделки РЕПО' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'RepoTerm'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Тип экспирации, используется для обозначения экспирации опционов,
   1 -  экспирация
   2 - истечение
   NULL - обычная операция' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'ExpirationType'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Цена второй репо-сделки. Прописываем в первой, т.к. из сервисинфа долго доставать' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'RepoPrice2'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Цена второй стороны клиентской сделки' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'ContragentPrice'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Галка, отвечающая за то, чтобы данная операция не попала в депозитарный отчет.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Operation', @level2type=N'COLUMN',@level2name=N'IsNotForDepoReport'
GO




