USE [TestDB]
GO

/****** Object:  Table [dbo].[header]    Script Date: 27.03.2024 2:41:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[header](
	[ns2:SendingCompanyIN] [nvarchar](255) NULL,
	[ns2:TransmittingCountry] [nvarchar](255) NULL,
	[ns2:ReceivingCountry] [nvarchar](255) NULL,
	[ns2:MessageType] [nvarchar](255) NULL,
	[ns2:MessageRefId] [nvarchar](255) NULL,
	[ns2:ReportingPeriod] [nvarchar](255) NULL,
	[ns2:Timestamp] [datetime] NULL,
	[ns2:ResCountryCode] [nvarchar](255) NULL,
	[ns2:TIN] [nvarchar](255) NULL,
	[ns2:FirstName] [nvarchar](255) NULL,
	[ns2:MiddleName] [nvarchar](255) NULL,
	[ns2:LastName] [nvarchar](255) NULL,
	[ns2:CountryCode] [nvarchar](255) NULL,
	[ns2:Street] [nvarchar](255) NULL,
	[ns2:BuildingIdentifier] [nvarchar](255) NULL,
	[ns2:SuiteIdentifier] [nvarchar](255) NULL,
	[ns2:DistrictName] [nvarchar](255) NULL,
	[ns2:PostCode] [float] NULL,
	[ns2:City] [nvarchar](255) NULL,
	[ns2:CountrySubentity] [nvarchar](255) NULL,
	[ns2:AddressFree] [nvarchar](255) NULL,
	[ns1:DocTypeIndic] [nvarchar](255) NULL,
	[ns1:DocRefId] [nvarchar](255) NULL
) ON [PRIMARY]
GO


/****** Object:  Table [dbo].[clients]    Script Date: 27.03.2024 2:41:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[clients](
	[ns1:DocTypeIndic2] [nvarchar](255) NULL,
	[ns1:DocRefId3] [nvarchar](255) NULL,
	[ns1:AccountNumber] [nvarchar](255) NULL,
	[ns1:AccountClosed] [nvarchar](255) NULL,
	[ns2:ResCountryCode4] [nvarchar](255) NULL,
	[ns2:TIN5] [nvarchar](255) NULL,
	[ns2:FirstName6] [nvarchar](255) NULL,
	[ns2:MiddleName7] [nvarchar](255) NULL,
	[ns2:LastName8] [nvarchar](255) NULL,
	[ns2:CountryCode9] [nvarchar](255) NULL,
	[ns2:Street10] [nvarchar](255) NULL,
	[ns2:BuildingIdentifier11] [float] NULL,
	[ns2:SuiteIdentifier12] [float] NULL,
	[ns2:DistrictName13] [nvarchar](255) NULL,
	[ns2:PostCode14] [float] NULL,
	[ns2:City15] [nvarchar](255) NULL,
	[ns2:CountrySubentity16] [nvarchar](255) NULL,
	[ns2:AddressFree17] [nvarchar](255) NULL,
	[ns2:BirthDate] [datetime] NULL,
	[ns2:City18] [nvarchar](255) NULL,
	[ns1:AccountBalance] [float] NULL,
	[currCode] [nvarchar](255) NULL,
	[ns1:Type] [nvarchar](255) NULL,
	[ns1:PaymentAmnt] [float] NULL,
	[currCode19] [nvarchar](255) NULL,
	[ns1:Type1] [nvarchar](255) NULL,
	[ns1:PaymentAmnt1] [float] NULL,
	[currCode191] [nvarchar](255) NULL
) ON [PRIMARY]
GO


