use AtonBase
go

exec sp_addarticle @publication = N'AtonBase_Pub', @article = N'Asset', @source_owner = N'dbo', @source_object = N'Asset', @type = N'logbased', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'Asset', @destination_owner = N'dbo', @status = 24, @vertical_partition = N'true', @ins_cmd = N'CALL [sp_MSins_dboAsset]', @del_cmd = N'CALL [sp_MSdel_dboAsset]', @upd_cmd = N'SCALL [sp_MSupd_dboAsset]'

-- Adding the article's partition column(s)
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'AssetID', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'XLAssetID', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'AssetTemplID', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'AssetName', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'ReportRName', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'ReportEName', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'AssetCode', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'AssetKind', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'AssetType', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'Rating', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'Nominal', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'NominalCurr', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'ADRBaseID', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'ADRNumerator', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'ADRDenominator', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'IssueBaseID', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'BegDate', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'EndDate', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'ISIN', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'CUSIP', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'RegCode', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'IssueVolume', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'CorrectVolDate', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'IsFullCalc', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'IsClosed', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'StartDate', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'IsHasCoupon', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'NominalAct', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'BaseModeID', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'IsTrade', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'IsCreditFKCB', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'ADREmitent', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'Comment', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'IssuerID', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'StockStatusID', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'rev_ins', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'AssetLiquidID', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'CustodianBank', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'SubjectID', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'CountryCode', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'IsListRTS', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'IsListMICEXSS', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'IssueFormID', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'AuditName', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'IsForeign', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'IsAuditPrice', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'PaymentCurr', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'FOBaseID', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'FOBaseVolume', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'CustodyAccName', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'CustodyAgreement', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'DepoMergingDate', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'DepoEndDate', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'CalcMethod', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'BondType', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'SEDOL', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'IsListingA1', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'IssueType', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'SecCodeDCC', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'ClassID', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'USSymbol', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'AssetLimit', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'FStamp', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'PriceInstr', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'CurrSortOrder', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'DateRepReg', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'LSEList', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'IsRecDateNkd', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'IntDayLimit', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'IntDayLimitCurr', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'VaultID', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'FO_ExecDate', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'FO_MinStep', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'FO_MinStepPrice', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'FO_DeliverableType', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'FO_OptionType', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'FO_Strike', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'FO_OptionStyle', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'RiskGroup', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'Discount', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'IsDAX30', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'FO_InitMarginCode', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'FO_MaintMarginCode', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'TRS_PaymentCurr', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'TRS_ExecDate', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'SecCodeNDC', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'FutBaseType', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'DateReg', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'Creator', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'CreateDate', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'CorrectRegDate', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'IsNominalCut', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'IsMost', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'FO_IsMarginOption', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'IsExchangeOnly', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'CFI', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'IsING', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'FortsSpotCode', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'CurrencyCode', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'IsQualifiedOnlyDepo', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'IsQualifiedOnlyBrok', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'AssetEName', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'DefaultExchange', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'DefaultExchangeID', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'NIN', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'IsCySec', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'BillTerm', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'DefaultDate', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'IsExgCommodity', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'NotInSaldo', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'DefaultClearingSystemID', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'DefaultOperPlaceID', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'CalendarTypeID', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'StampDutyRate', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'IsDeleted', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'QuotingID', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'QuotingMOEX_ID', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'IsCalcNominal', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'FractBaseID', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'FractNumerator', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'FractDenominator', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'MoexTicker', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'BloombergTicker', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'IsTradeRepoCK', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'IsEquity', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'PlacementStartDate', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'PlacePrice', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'Corrector', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1

exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'Asset', @column = N'rev_stamp', @operation = N'drop', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1

-- Adding the article synchronization object
exec sp_articleview @publication = N'AtonBase_Pub', @article = N'Asset', @view_name = N'SYNC_Asset_1__188', @filter_clause = N'', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
GO
exec sp_refreshsubscriptions @publication = N'AtonBase_Pub'
go

---------------

exec sp_addarticle @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @source_owner = N'dbo', @source_object = N'AssetOnOperPlace', @type = N'logbased', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'none', @destination_table = N'AssetOnOperPlace', @destination_owner = N'dbo', @status = 24, @vertical_partition = N'true', @ins_cmd = N'CALL [sp_MSins_dboAssetOnOperPlace]', @del_cmd = N'CALL [sp_MSdel_dboAssetOnOperPlace]', @upd_cmd = N'SCALL [sp_MSupd_dboAssetOnOperPlace]'

-- Adding the article's partition column(s)
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'AssetID', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'OperPlaceID', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'DepoCom', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'PriceCurr', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'Lot', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'PriceType', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'LAST', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'WAPRICE', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'NKD', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'IsActive', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'IsCredited', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'OperPlaceCom', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'OperPlaceCode', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'DaysReg', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'REV_INS', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'REV_UPD', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'REV_DEL', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'PriceMin', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'PriceMax', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'IsOperPlaceComScalped', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'ClearingCom', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'IsClearingComScalped', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'IsLimited', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'LimitUp', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'LimitDown', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'PriceOld', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'DepositBuy', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'DepositSell', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'PriceStepMin', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'PriceStepCost', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'NonExgCom', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'FutExecCom', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'REV_STAMP_INS', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'MarketPrice', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'IsStopShort', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'ShortLimit', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'FStamp', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'ITSCom', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'Priority', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'IsIntradayShort', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'CustomCostDenom', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'IsListSPB', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'MarketPriceToday', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'CalendarTypeID', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'ClearingSystemID', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'DaysPayRegDVP', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'DaysPayPrePayment', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'DaysRegPrePayment', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'DaysPayPreDelivery', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'DaysRegPreDelivery', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'DaysPay', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'ProductCode', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'LastInPoints', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'Bid', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'Offer', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'AdmQuote', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'MarketPrice2', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'Volat', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'Indicative', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'IndicativeBid', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'IndicativeOffer', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'IndicativeSourceID', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'TradeDate', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'SecCode', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'VolumeToday', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'PriceChangeTime', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1

exec sp_articlecolumn @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @column = N'Rev_stamp', @operation = N'drop', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1

-- Adding the article synchronization object
exec sp_articleview @publication = N'AtonBase_Pub', @article = N'AssetOnOperPlace', @view_name = N'SYNC_AssetOnOperPlace_1__431', @filter_clause = N'', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
GO
exec sp_refreshsubscriptions @publication = N'AtonBase_Pub'
go


select object_id('AssetOnOperPlace') -- 430662815