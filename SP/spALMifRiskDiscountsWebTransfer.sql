--select @@servername

use mif
go

create or alter procedure dbo.spALMifRiskDiscountsWebTransfer
as
	create table #t
	(
		ID int identity primary key,
		AssetCode varchar(20) NOT NULL,
		AssetName varchar(255) NOT NULL,
		D1BeginLong decimal(23, 8) NULL,
		D2BeginLong decimal(23, 8) NULL,
		D1BeginShort decimal(23, 8) NULL,
		D2BeginShort decimal(23, 8) NULL
	)

	insert into #t 
	(
		AssetCode,
		AssetName,
		D1BeginLong,
		D2BeginLong,
		D1BeginShort,
		D2BeginShort
	)
	exec dbo.spALMifRiskDiscountsWeb
--	delete from [MYSQL42]...[risk_rates]
	delete openquery(MYSQL42, 'select * from site_shared.risk_rates')

--	insert into [MYSQL42]...[risk_rates]
	insert openquery(MYSQL42, 'select ID,AssetCode,AssetName,D1BeginLong,
		D2BeginLong,IsExcludeLong,D1BeginShort,D2BeginShort,IsExcludeShort from site_shared.risk_rates')
	
	select 
		ID,
		AssetCode,
		AssetName,
		D1BeginLong,
		D2BeginLong,
		0,
		D1BeginShort,
		D2BeginShort,
		0
	from #t

go
