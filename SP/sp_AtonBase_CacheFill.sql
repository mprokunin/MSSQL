USE [master]
GO
/****** Object:  StoredProcedure [dbo].[sp_AtonBase_CacheFill]    Script Date: 25.03.2019 17:58:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER  procedure [dbo].[sp_AtonBase_CacheFill] as 
-- v1.2 Mar 24, 2019
begin
if exists (select 1 from [AtonBase].[sys].[tables] where schema_name(schema_id)='dbo' and name='tblRepresentativeCompany') select checksum_agg(checksum (*)) from [AtonBase].[dbo].[tblRepresentativeCompany] with (nolock);
if exists (select 1 from [AtonBase].[sys].[tables] where schema_name(schema_id)='dbo' and name='Login') select checksum_agg(checksum (*)) from [AtonBase].[dbo].[Login] with (nolock);
if exists (select 1 from [AtonBase].[sys].[tables] where schema_name(schema_id)='dbo' and name='CpTree') select checksum_agg(checksum (*)) from [AtonBase].[dbo].[CpTree] with (nolock);
if exists (select 1 from [AtonBase].[sys].[tables] where schema_name(schema_id)='dbo' and name='Filial') select checksum_agg(checksum (*)) from [AtonBase].[dbo].[Filial] with (nolock);
if exists (select 1 from [AtonBase].[sys].[tables] where schema_name(schema_id)='dbo' and name='AddOffice') select checksum_agg(checksum (*)) from [AtonBase].[dbo].[AddOffice] with (nolock);
if exists (select 1 from [AtonBase].[sys].[tables] where schema_name(schema_id)='dbo' and name='Country') select checksum_agg(checksum (*)) from [AtonBase].[dbo].[Country] with (nolock);
if exists (select 1 from [AtonBase].[sys].[tables] where schema_name(schema_id)='dbo' and name='Constant') select checksum_agg(checksum (*)) from [AtonBase].[dbo].[Constant] with (nolock);
if exists (select 1 from [AtonBase].[sys].[tables] where schema_name(schema_id)='dbo' and name='tblRepresentativeCompanyExcludeList') select checksum_agg(checksum (*)) from [AtonBase].[dbo].[tblRepresentativeCompanyExcludeList] with (nolock);
if exists (select 1 from [AtonBase].[sys].[tables] where schema_name(schema_id)='dbo' and name='CpOnOperPlace') select checksum_agg(checksum (*)) from [AtonBase].[dbo].[CpOnOperPlace] with (nolock);
if exists (select 1 from [AtonBase].[sys].[tables] where schema_name(schema_id)='dbo' and name='tblRuCompanyCitizenship') select checksum_agg(checksum (*)) from [AtonBase].[dbo].[tblRuCompanyCitizenship] with (nolock);
if exists (select 1 from [AtonBase].[sys].[tables] where schema_name(schema_id)='dbo' and name='tblCpLinkType') select checksum_agg(checksum (*)) from [AtonBase].[dbo].[tblCpLinkType] with (nolock);
if exists (select 1 from [AtonBase].[sys].[tables] where schema_name(schema_id)='dbo' and name='tblCpLink') select checksum_agg(checksum (*)) from [AtonBase].[dbo].[tblCpLink] with (nolock);
if exists (select 1 from [AtonBase].[sys].[tables] where schema_name(schema_id)='dbo' and name='tblRuCompany') select checksum_agg(checksum (*)) from [AtonBase].[dbo].[tblRuCompany] with (nolock);
if exists (select 1 from [AtonBase].[sys].[tables] where schema_name(schema_id)='dbo' and name='CounterpartyCompany') select checksum_agg(checksum (*)) from [AtonBase].[dbo].[CounterpartyCompany] with (nolock);
if exists (select 1 from [AtonBase].[sys].[tables] where schema_name(schema_id)='dbo' and name='ClientProfileGroup') select checksum_agg(checksum (*)) from [AtonBase].[dbo].[ClientProfileGroup] with (nolock);
if exists (select 1 from [AtonBase].[sys].[tables] where schema_name(schema_id)='dbo' and name='CounterpartySBSType') select checksum_agg(checksum (*)) from [AtonBase].[dbo].[CounterpartySBSType] with (nolock);
if exists (select 1 from [AtonBase].[sys].[tables] where schema_name(schema_id)='dbo' and name='ClientProfileService') select checksum_agg(checksum (*)) from [AtonBase].[dbo].[ClientProfileService] with (nolock);
if exists (select 1 from [AtonBase].[sys].[tables] where schema_name(schema_id)='dbo' and name='Signature') select checksum_agg(checksum (*)) from [AtonBase].[dbo].[Signature] with (nolock);
if exists (select 1 from [AtonBase].[sys].[tables] where schema_name(schema_id)='dbo' and name='CounterpartyService') select checksum_agg(checksum (*)) from [AtonBase].[dbo].[CounterpartyService] with (nolock);
if exists (select 1 from [AtonBase].[sys].[tables] where schema_name(schema_id)='dbo' and name='OperPlace') select checksum_agg(checksum (*)) from [AtonBase].[dbo].[OperPlace] with (nolock);
if exists (select 1 from [AtonBase].[sys].[tables] where schema_name(schema_id)='dbo' and name='Representative') select checksum_agg(checksum (*)) from [AtonBase].[dbo].[Representative] with (nolock);
if exists (select 1 from [AtonBase].[sys].[tables] where schema_name(schema_id)='dbo' and name='Counterparty') select checksum_agg(checksum (*)) from [AtonBase].[dbo].[Counterparty] with (nolock);
if exists (select 1 from [AtonBase].[sys].[tables] where schema_name(schema_id)='dbo' and name='Client') select checksum_agg(checksum (*)) from [AtonBase].[dbo].[Client] with (nolock);
if exists (select 1 from [AtonBase].[sys].[tables] where schema_name(schema_id)='dbo' and name='tblBankrupt') select checksum_agg(checksum (*)) from [AtonBase].[dbo].[tblBankrupt] with (nolock);
if exists (select 1 from [AtonBase].[sys].[tables] where schema_name(schema_id)='dbo' and name='CpDocument') select checksum_agg(checksum (*)) from [AtonBase].[dbo].[CpDocument] with (nolock);
if exists (select 1 from [AtonBase].[sys].[tables] where schema_name(schema_id)='dbo' and name='Operation') select top 1000000 checksum_agg(checksum (*)) from [AtonBase].[dbo].[Operation] with (nolock, index(XPKOperation)) where OperDate > dateadd(dd, -20, getdate());
if exists (select 1 from [AtonBase].[sys].[tables] where schema_name(schema_id)='dbo' and name='Operation') select top 1000000 checksum_agg(checksum (*)) from [AtonBase].[dbo].[Operation] with (nolock, index(IX_RCVIDODOTID)) where OperDate > dateadd(dd, -20, getdate());
if exists (select 1 from [AtonBase].[sys].[tables] where schema_name(schema_id)='dbo' and name='Operation') select top 1000000 checksum_agg(checksum (*)) from [AtonBase].[dbo].[Operation] with (nolock, index(IX_Operation_OTIDOD)) where OperDate > dateadd(dd, -20, getdate());
if exists (select 1 from [AtonBase].[sys].[tables] where schema_name(schema_id)='dbo' and name='Operation') select top 1000000 checksum_agg(checksum (*)) from [AtonBase].[dbo].[Operation] with (nolock, index(IX_ODSI)) where OperDate > dateadd(dd, -20, getdate());
if exists (select 1 from [AtonBase].[sys].[tables] where schema_name(schema_id)='dbo' and name='Price') select checksum_agg(checksum (*)) from [AtonBase].[dbo].[Price] with (nolock, index(IX_Asset));
if exists (select 1 from [AtonBase].[sys].[tables] where schema_name(schema_id)='dbo' and name='SPortfolio') select checksum_agg(checksum (*)) from [AtonBase].[dbo].[SPortfolio] with (nolock, index(XPKSPortfolio)) where TransId > 100000000;
if exists (select 1 from [AtonBase].[sys].[tables] where schema_name(schema_id)='dbo' and name='MPortfolio') select checksum_agg(checksum (*)) from [AtonBase].[dbo].[MPortfolio] with (nolock, index(XPKMPortfolio)) where TransId > 700000000;
-- By Peter Chebadukhin
if exists (select 1 from [AtonBase].[sys].[tables] where schema_name(schema_id)='dbo' and name='Asset') select checksum_agg(checksum (*)) from [AtonBase].[dbo].[Asset] with (nolock);
if exists (select 1 from [AtonBase].[sys].[tables] where schema_name(schema_id)='dbo' and name='AssetOnOperPlace') select checksum_agg(checksum (*)) from [AtonBase].[dbo].[AssetOnOperPlace] with (nolock);
if exists (select 1 from [AtonBase].[sys].[tables] where schema_name(schema_id)='dbo' and name='MoneyTrans') select checksum_agg(checksum (*)) from [AtonBase].[dbo].[MoneyTrans] with (nolock) where TransId > 700000000;
if exists (select 1 from [AtonBase].[sys].[tables] where schema_name(schema_id)='dbo' and name='StockTrans') select checksum_agg(checksum (*)) from [AtonBase].[dbo].[StockTrans] with (nolock) where TransId > 100000000;
if exists (select 1 from [AtonBase].[sys].[tables] where schema_name(schema_id)='dbo' and name='MoneyTrans') select checksum_agg(checksum (*)) from [AtonBase].[dbo].[MoneyTrans] with (nolock, index(IX_MoneyTrans_OIDCD)) where TransId > 700000000;
if exists (select 1 from [AtonBase].[sys].[tables] where schema_name(schema_id)='dbo' and name='StockTrans') select checksum_agg(checksum (*)) from [AtonBase].[dbo].[StockTrans] with (nolock, index(IX_StockTrans_OperID)) where TransId > 100000000;
if exists (select 1 from [AtonBase].[sys].[tables] where schema_name(schema_id)='dbo' and name='ReplDelta') select checksum_agg(checksum (*)) from [AtonBase].[dbo].[ReplDelta] with (nolock);
if exists (select 1 from [AtonBase].[sys].[tables] where schema_name(schema_id)='dbo' and name='rbtOperation') select checksum_agg(checksum (*)) from [AtonBase].[dbo].[rbtOperation] with (nolock);

end
go
grant exec on [dbo].[sp_AtonBase_CacheFill] to public
go

--exec [dbo].[sp_AtonBase_CacheFill] 