set nocount on
set ansi_nulls on
set quoted_identifier on
go

--/*
------------------------------------------------------------------
-- �������� ���������
------------------------------------------------------------------
if schema_id('Test') is null
  exec('create schema [Test]')
go

if object_id('[Test].[Contracts]') is null
  create table [Test].[Contracts]
  (
    [Id]          int   not null identity(1,1),
    [Type_Id]     int   not null,
    [Client_Id]   int   not null,
    [DateFrom]    date  not null,
    [DateTo]      date      null,
    primary key clustered ([Id])
  )
go

/*
�������� ������, ������� ������ ������ ���� ��������������� � ��������� ��������
(�.�., ����� ����� ��������� ������ ���� ������� ���� ������� ����) �����
@DateBegin � @DateEnd ������������, ����� � ������� ��� ���� �� ���� �������� ������� ���� @Type_Id.
������, ��� � ������� ����� ���� ��������� ����������� ���������.

��������� ������ ���� ����������� � ��������� ����:
-- Client_Id        -- ������
-- First_Date       -- ���� ������ ������������ ������� �������� ��������(-��) ��������� ����
-- Last_Date        -- ���� ��������� ������������ ������� �������� ��������(-��) ��������� ����

--*/

------------------------------------------------------------------
-- ���������
------------------------------------------------------------------
declare
  @Type_Id    int   = 1,
  @DateBegin  date  = '20000601',
  @DateEnd    date  = '20010131'

------------------------------------------------------------------
-- ���������
------------------------------------------------------------------
select 
	[Client_Id]        -- ������
	, [First_Date]       -- ���� ������ ������������ ������� �������� ��������(-��) ��������� ����
	, [Last_Date]        -- ���� ��������� ������������ ������� �������� ��������(-��) ��������� ����

insert into [Test].[Contracts] values(1,1,'20210103','20210110');
insert into [Test].[Contracts] values(1,1,'20210203','20210310');
insert into [Test].[Contracts] values(1,1,'20210403','20210510');
insert into [Test].[Contracts] values(1,1,'20210511','20210520');
insert into [Test].[Contracts] values(1,1,'20210603','20210610');

insert into [Test].[Contracts] values(1,2,'20210403','20210510');
insert into [Test].[Contracts] values(1,2,'20210511','20210520');


insert into [Test].[Contracts] values(2,1,'20210103','20210110');
insert into [Test].[Contracts] values(2,1,'20210203','20210310');
insert into [Test].[Contracts] values(2,1,'20210403','20210510');
insert into [Test].[Contracts] values(2,1,'20210511','20210520');
insert into [Test].[Contracts] values(2,1,'20210603','20210610');

insert into [Test].[Contracts] values(2,2,'20210403','20210510');
insert into [Test].[Contracts] values(2,2,'20210511','20210520');

select * from [Test].[Contracts]

create procedure cl_test(@typ int)
as
begin
declare @FS int, @cl int, @cl_old int, @fr date,@fr_old date, @to date,@to_old date
DECLARE cl_cursor CURSOR FOR   
    select [Client_Id],[DateFrom]
	,[DateTo] from [Test].[Contracts]
	where [Type_Id] = @typ order by  [Client_Id],[DateFrom],[DateTo]
	for read only

OPEN cl_cursor  
FETCH NEXT FROM cl_cursor INTO @cl_old, @fr_old, @to_old
set @FS = @@FETCH_STATUS
WHILE @FS = 0  
BEGIN  
    FETCH NEXT FROM cl_cursor INTO @cl, @fr, @to
	set @FS = @@FETCH_STATUS
	if @FS = 0
	begin
		if @cl_old <> @cl
		begin
			select @cl_old as 'Client_Id', @fr_old as 'First_Date', @to_old as 'Last_Date'
			select @cl_old = @cl, @fr_old = @fr, @to_old = @to
		end
		else
		begin
			if DATEDIFF(dd, @to_old, @fr) > 1
			begin
				select @cl_old as 'Client_Id', @fr_old as 'First_Date', @to_old as 'Last_Date'
				select @fr_old = @fr, @to_old = @to		
			end
			else
				set @to_old = @to
		end
	end
	else
		select @cl_old as 'Client_Id', @fr_old as 'First_Date', @to_old as 'Last_Date'
END   
CLOSE cl_cursor; 
deallocate cl_cursor
end
go
exec cl_test 2
go