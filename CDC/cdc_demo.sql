use [TSTCDC]
go

-- enable cdc for the database
declare @rc int
exec @rc = sys.sp_cdc_enable_db
select @rc

/*
declare @rc int
exec @rc = sys.sp_cdc_disable_db
select @rc
*/


-- new column added to sys.databases: is_cdc_enabled
select name, is_cdc_enabled from sys.databases

-- create table to be used for cdc demo

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[MANAGEMENT$G_L Entry](
	[timestamp] [timestamp] NOT NULL,
	[Entry No_] [int] NOT NULL,
	[G_L Account No_] [varchar](20) NOT NULL,
	[Posting Date] [datetime] NOT NULL,
	[Document Type] [int] NOT NULL,
	[Document No_] [varchar](20) NOT NULL,
	[Description] [varchar](50) NOT NULL,
	[Bal_ Account No_] [varchar](20) NOT NULL,
	[Amount] [decimal](38, 20) NOT NULL,
	[Global Dimension 1 Code] [varchar](20) NOT NULL,
	[Global Dimension 2 Code] [varchar](20) NOT NULL,
	[User ID] [varchar](20) NOT NULL,
	[Source Code] [varchar](10) NOT NULL,
	[System-Created Entry] [tinyint] NOT NULL,
	[Prior-Year Entry] [tinyint] NOT NULL,
	[Job No_] [varchar](20) NOT NULL,
	[Quantity] [decimal](38, 20) NOT NULL,
	[VAT Amount] [decimal](38, 20) NOT NULL,
	[Business Unit Code] [varchar](10) NOT NULL,
	[Journal Batch Name] [varchar](10) NOT NULL,
	[Reason Code] [varchar](10) NOT NULL,
	[Gen_ Posting Type] [int] NOT NULL,
	[Gen_ Bus_ Posting Group] [varchar](10) NOT NULL,
	[Gen_ Prod_ Posting Group] [varchar](10) NOT NULL,
	[Bal_ Account Type] [int] NOT NULL,
	[Transaction No_] [int] NOT NULL,
	[Debit Amount] [decimal](38, 20) NOT NULL,
	[Credit Amount] [decimal](38, 20) NOT NULL,
	[Document Date] [datetime] NOT NULL,
	[External Document No_] [varchar](20) NOT NULL,
	[Source Type] [int] NOT NULL,
	[Source No_] [varchar](20) NOT NULL,
	[No_ Series] [varchar](10) NOT NULL,
	[Tax Area Code] [varchar](20) NOT NULL,
	[Tax Liable] [tinyint] NOT NULL,
	[Tax Group Code] [varchar](10) NOT NULL,
	[Use Tax] [tinyint] NOT NULL,
	[VAT Bus_ Posting Group] [varchar](10) NOT NULL,
	[VAT Prod_ Posting Group] [varchar](10) NOT NULL,
	[Additional-Currency Amount] [decimal](38, 20) NOT NULL,
	[Add_-Currency Debit Amount] [decimal](38, 20) NOT NULL,
	[Add_-Currency Credit Amount] [decimal](38, 20) NOT NULL,
	[Close Income Statement Dim_ ID] [int] NOT NULL,
	[IC Partner Code] [varchar](20) NOT NULL,
	[Reversed] [tinyint] NOT NULL,
	[Reversed by Entry No_] [int] NOT NULL,
	[Reversed Entry No_] [int] NOT NULL,
	[Prod_ Order No_] [varchar](20) NOT NULL,
	[FA Entry Type] [int] NOT NULL,
	[FA Entry No_] [int] NOT NULL,
	[Value Entry No_] [int] NOT NULL,
	[Used in Correspondence] [tinyint] NOT NULL,
	[Initial Entry No_] [int] NOT NULL,
	[Reverse] [tinyint] NOT NULL,
	[Reverse Entry No_] [int] NOT NULL,
	[Capital Facility Code] [varchar](20) NOT NULL,
	[Capital Facility Charge] [tinyint] NOT NULL,
	[Capital Facility Open] [tinyint] NOT NULL,
	[Source Company No_] [int] NOT NULL,
	[Source Entry No_] [int] NOT NULL,
	[Original Posting Date] [datetime] NOT NULL,
	[Translation Line No_] [int] NOT NULL,
	[Translation No_] [int] NOT NULL,
	[Base Mapp_ Rule No_] [int] NOT NULL,
	[Add_ Dim_ Mapp_ Rule No_] [int] NOT NULL,
	[Add_ Corr_ Mapp_ Rule No_] [int] NOT NULL,
	[Exclude Type] [int] NOT NULL,
	[Original Currency Code] [varchar](10) NOT NULL,
	[Original Amount] [decimal](38, 20) NOT NULL,
	[Original Debit Amount] [decimal](38, 20) NOT NULL,
	[Original Credit Amount] [decimal](38, 20) NOT NULL,
 CONSTRAINT [MANAGEMENT$G_L Entry$0] PRIMARY KEY CLUSTERED 
(
	[Entry No_] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/*
create table dbo.customer
(
id int identity not null
, name varchar(50) not null
, state varchar(2) not null
, constraint pk_customer primary key clustered (id)
)
*/
-- enable table for cdc
exec sys.sp_cdc_enable_table 
    @source_schema = 'dbo', 
    @source_name = 'MANAGEMENT$G_L Entry' ,
    @role_name = 'CDCRole',
    @supports_net_changes = 1
go
select name, type, type_desc, is_tracked_by_cdc from sys.tables

select o.name, o.type, o.type_desc from sys.objects o
join sys.schemas  s on s.schema_id = o.schema_id
where s.name = 'cdc'

-- disable table for cdc; disable database for cdc
/*
exec sys.sp_cdc_disable_table 
  @source_schema = 'dbo', 
  @source_name = 'customer',
  @capture_instance = 'dbo_customer' -- or 'all'
  
declare @rc int
exec @rc = sys.sp_cdc_disable_db
select @rc
 */

-- show databases and their CDC setting
select name, is_cdc_enabled from sys.databases

-- perform dml to see change tracking
--select '[' + name + '],' from sys.all_columns where object_id = OBJECT_ID('MANAGEMENT$G_L Entry')
insert into [TSTCDC].[dbo].[MANAGEMENT$G_L Entry] (
[Entry No_],
[G_L Account No_],
[Posting Date],
[Document Type],
[Document No_],
[Description],
[Bal_ Account No_],
[Amount],
[Global Dimension 1 Code],
[Global Dimension 2 Code],
[User ID],
[Source Code],
[System-Created Entry],
[Prior-Year Entry],
[Job No_],
[Quantity],
[VAT Amount],
[Business Unit Code],
[Journal Batch Name],
[Reason Code],
[Gen_ Posting Type],
[Gen_ Bus_ Posting Group],
[Gen_ Prod_ Posting Group],
[Bal_ Account Type],
[Transaction No_],
[Debit Amount],
[Credit Amount],
[Document Date],
[External Document No_],
[Source Type],
[Source No_],
[No_ Series],
[Tax Area Code],
[Tax Liable],
[Tax Group Code],
[Use Tax],
[VAT Bus_ Posting Group],
[VAT Prod_ Posting Group],
[Additional-Currency Amount],
[Add_-Currency Debit Amount],
[Add_-Currency Credit Amount],
[Close Income Statement Dim_ ID],
[IC Partner Code],
[Reversed],
[Reversed by Entry No_],
[Reversed Entry No_],
[Prod_ Order No_],
[FA Entry Type],
[FA Entry No_],
[Value Entry No_],
[Used in Correspondence],
[Initial Entry No_],
[Reverse],
[Reverse Entry No_],
[Capital Facility Code],
[Capital Facility Charge],
[Capital Facility Open],
[Source Company No_],
[Source Entry No_],
[Original Posting Date],
[Translation Line No_],
[Translation No_],
[Base Mapp_ Rule No_],
[Add_ Dim_ Mapp_ Rule No_],
[Add_ Corr_ Mapp_ Rule No_],
[Exclude Type],
[Original Currency Code],
[Original Amount],
[Original Debit Amount],
[Original Credit Amount]
)
select top 10 
[Entry No_],
[G_L Account No_],
[Posting Date],
[Document Type],
[Document No_],
[Description],
[Bal_ Account No_],
[Amount],
[Global Dimension 1 Code],
[Global Dimension 2 Code],
[User ID],
[Source Code],
[System-Created Entry],
[Prior-Year Entry],
[Job No_],
[Quantity],
[VAT Amount],
[Business Unit Code],
[Journal Batch Name],
[Reason Code],
[Gen_ Posting Type],
[Gen_ Bus_ Posting Group],
[Gen_ Prod_ Posting Group],
[Bal_ Account Type],
[Transaction No_],
[Debit Amount],
[Credit Amount],
[Document Date],
[External Document No_],
[Source Type],
[Source No_],
[No_ Series],
[Tax Area Code],
[Tax Liable],
[Tax Group Code],
[Use Tax],
[VAT Bus_ Posting Group],
[VAT Prod_ Posting Group],
[Additional-Currency Amount],
[Add_-Currency Debit Amount],
[Add_-Currency Credit Amount],
[Close Income Statement Dim_ ID],
[IC Partner Code],
[Reversed],
[Reversed by Entry No_],
[Reversed Entry No_],
[Prod_ Order No_],
[FA Entry Type],
[FA Entry No_],
[Value Entry No_],
[Used in Correspondence],
[Initial Entry No_],
[Reverse],
[Reverse Entry No_],
[Capital Facility Code],
[Capital Facility Charge],
[Capital Facility Open],
[Source Company No_],
[Source Entry No_],
[Original Posting Date],
[Translation Line No_],
[Translation No_],
[Base Mapp_ Rule No_],
[Add_ Dim_ Mapp_ Rule No_],
[Add_ Corr_ Mapp_ Rule No_],
[Exclude Type],
[Original Currency Code],
[Original Amount],
[Original Debit Amount],
[Original Credit Amount]
from [RENINS_REV].[dbo].[MANAGEMENT$G_L Entry]

set rowcount 7
delete from [TSTCDC].[dbo].[MANAGEMENT$G_L Entry]
set rowcount 0

-- query changes
declare @begin_lsn binary(10), @end_lsn binary(10)

-- get the first LSN for customer changes
select @begin_lsn = sys.fn_cdc_get_min_lsn('dbo_MANAGEMENT$G_L Entry')
-- get the last LSN for customer changes
select @end_lsn = sys.fn_cdc_get_max_lsn()
select @begin_lsn, @end_lsn
--select [TSTCDC].[sys].fn_cdc_get_min_lsn('dbo_MANAGEMENT$G_L Entry') as begin_lsn, [TSTCDC].[sys].fn_cdc_get_max_lsn() as end_lsn

-- get net changes; group changes in the range by the pk
select * from [cdc].[fn_cdc_get_net_changes_dbo_MANAGEMENT$G_L Entry](
	@begin_lsn, @end_lsn, 'all'); 

-- get individual changes in the range
select * from cdc.[fn_cdc_get_all_changes_dbo_MANAGEMENT$G_L Entry](
	@begin_lsn, @end_lsn, 'all');

select * from cdc.[fn_cdc_get_all_changes_dbo_MANAGEMENT$G_L Entry_lsn](
	@begin_lsn, @end_lsn, 'all');
go
select * from 
--0x00000055000008FB0001
--0x00000050000044D30004

-- create table to hold ending_lsn	
create table dbo.[MANAGEMENT$G_L Entry_lsn] (
last_lsn binary(10)
)
go
-- create function to retrieve ending_lsn
create function dbo.[get_last_MANAGEMENT$G_L Entry_lsn]() 
returns binary(10)
as
begin
 declare @last_lsn binary(10)
 select @last_lsn = last_lsn from dbo.[MANAGEMENT$G_L Entry_lsn]
 select @last_lsn = isnull(@last_lsn, sys.fn_cdc_get_min_lsn('dbo_MANAGEMENT$G_L Entry'))
 return @last_lsn
end	
go


-- modify earlier query to use function to retrieve ending_lsn of last run
-- and store ending_lsn of this run
declare @begin_lsn binary(10), @end_lsn binary(10)

-- get the next LSN for customer changes
select @begin_lsn = dbo.[get_last_MANAGEMENT$G_L Entry_lsn]()
-- get the last LSN for customer changes
select @end_lsn = sys.fn_cdc_get_max_lsn()
select @begin_lsn as 'begin_lsn', sys.fn_cdc_map_lsn_to_time(@begin_lsn) as 'begin_time', @end_lsn as 'end_lsn', sys.fn_cdc_map_lsn_to_time(@end_lsn) as 'end_time'

-- get the net changes; group all changes in the range by the pk
select * from [cdc].[fn_cdc_get_net_changes_dbo_MANAGEMENT$G_L Entry](
	@begin_lsn, @end_lsn, 'all'); 

-- get individual changes in the range
select * from cdc.[fn_cdc_get_all_changes_dbo_MANAGEMENT$G_L Entry](
	@begin_lsn, @end_lsn, 'all');

-- save the end_lsn in the customer_lsn table
update dbo.[MANAGEMENT$G_L Entry_lsn]
set last_lsn = @end_lsn

if @@ROWCOUNT = 0
insert into dbo.[MANAGEMENT$G_L Entry_lsn] values(@end_lsn)



sys.sp_cdc_help_change_data_capture  'dbo', 'MANAGEMENT$G_L Entry'


-- query changes
declare @begin_lsn binary(10), @end_lsn binary(10)
select convert(binary(10), '0001345')

select top 100 * from cdc.lsn_time_mapping where tran_id > 0x0

DECLARE @max_lsn binary(10), @from_lsn binary(10) = 0x00000050000044D30004, @to_lsn binary(10) = 0x00000055000008FB0001;  
SELECT @max_lsn = MAX(__$start_lsn)
FROM cdc.[fn_cdc_get_all_changes_dbo_MANAGEMENT$G_L Entry](@from_lsn, @to_lsn, 'all');  
SELECT sys.fn_cdc_map_lsn_to_time(@max_lsn);  
GO   

DECLARE @from_lsn binary(10) = 0x00000050000044D30004, @to_lsn binary(10) = 0x00000055000008FB0001;  
select __$start_lsn, * FROM cdc.[fn_cdc_get_all_changes_dbo_MANAGEMENT$G_L Entry](@from_lsn, @to_lsn, 'all');  


SELECT sys.fn_cdc_map_lsn_to_time(0x00000050000044D30004),sys.fn_cdc_map_lsn_to_time(0x00000055000008FB0001);  

select [TSTCDC].[sys].fn_cdc_get_min_lsn('dbo_MANAGEMENT$G_L Entry') as begin_lsn, sys.fn_cdc_map_lsn_to_time([TSTCDC].[sys].fn_cdc_get_min_lsn('dbo_MANAGEMENT$G_L Entry')) as 'begin_time', 
[TSTCDC].[sys].fn_cdc_get_max_lsn() as end_lsn, sys.fn_cdc_map_lsn_to_time([TSTCDC].[sys].fn_cdc_get_max_lsn()) as 'end_time'
select @begin_lsn as 'begin_lsn', sys.fn_cdc_map_lsn_to_time(@begin_lsn) as 'begin_time', @end_lsn as 'end_lsn', sys.fn_cdc_map_lsn_to_time(@end_lsn) as 'end_time'
