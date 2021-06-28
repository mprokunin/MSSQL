SET NOCOUNT ON
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

--/*
IF OBJECT_ID('[TestMoney].[Operations]') IS NOT NULL
  DROP TABLE [TestMoney].[Operations]

IF OBJECT_ID('[TestMoney].[Currencies Rates]') IS NOT NULL
  DROP TABLE [TestMoney].[Currencies Rates]

IF OBJECT_ID('[TestMoney].[Currencies]') IS NOT NULL
  DROP TABLE [TestMoney].[Currencies]

IF OBJECT_ID('[TestMoney].[Clients]') IS NOT NULL
  DROP TABLE [TestMoney].[Clients]
--*/
--------------------------------------------------------------------------------------
-- ��������� ������                                                                 --
-- (*) ������������� ��� ������������, �� ���������� �� ���������� � ������������   --
--------------------------------------------------------------------------------------
IF SCHEMA_ID('TestMoney') IS NULL
  EXEC('
    CREATE SCHEMA [TestMoney]
  ')
GO

IF OBJECT_ID('[TestMoney].[Clients]') IS NULL
  CREATE TABLE [TestMoney].[Clients]
  (
    [Id]        Int                                   NOT NULL  IDENTITY(1,1),
    [Name]      NVarChar(128)                         NOT NULL,
    -- ... � ��� �����-�� ����
    PRIMARY KEY CLUSTERED([Id])
  )
GO
IF OBJECT_ID('[TestMoney].[Currencies]') IS NULL
  CREATE TABLE [TestMoney].[Currencies]
  (
    [Id]        Int                                   NOT NULL,
    [CodeLat3]  Char(3) COLLATE Cyrillic_General_BIN  NOT NULL,
    [Name]      NVarChar(128)                         NOT NULL,
    PRIMARY KEY CLUSTERED([Id])
  )
GO
IF OBJECT_ID('[TestMoney].[Currencies Rates]') IS NULL
  CREATE TABLE [TestMoney].[Currencies Rates]
  (
    [Currency_Id]       Int           NOT NULL, -- ������, ���� ������� ������
    [BaseCurrency_Id]   Int           NOT NULL, -- ������� ������; ��� ���� USD/RUB � ���� �aseCurrency_Id ����� ������ �� RUB; � ���� Currency_Id - ������ �� USD; � ���� Rate = ���� = 60; �.�. 60 RUB = 1 USD
    [Date]              Date          NOT NULL, -- ���� �����
    [Rate]              Numeric(32,8) NOT NULL, -- ���������� ���� 
    [Volume]            Numeric(18,8) NOT NULL, -- �� ����������; ��������, �� 10 000 ����������� ������ ���� 39.4419 ������; Rate = 39.4419; Volume = 10 000;
    PRIMARY KEY CLUSTERED([Currency_Id], [BaseCurrency_Id], [Date]),
    FOREIGN KEY ([Currency_Id]) REFERENCES [TestMoney].[Currencies] ([Id]),
    FOREIGN KEY ([BaseCurrency_Id]) REFERENCES [TestMoney].[Currencies] ([Id])
  )
-- ����� �������� ����� Sb � @BaseCurrency_Id, ���� � ��� ���� ����� Sc � ������ Currency_Id,
-- �� ���� ����� �� ������������ ���� ����� ��������� �� ���� ������ (���� ���� �� �� ������ ����),
-- ��� [BaseCurrency_Id] = @BaseCurrency_Id � [Currency_Id] = @Currency_Id � [Date] <= @Date,
-- �������� �� Rate � ��������� �� Volume
-- �.�. Sb = Sc * Rate / Volume �� ��������� ����
GO

IF OBJECT_ID('[TestMoney].[Operations]') IS NULL
  CREATE TABLE [TestMoney].[Operations]
  (
    [Id]                Int           NOT NULL IDENTITY(1,1),
    [Date]              Date          NOT NULL,               -- ���� ��������
    [Client_Id]         Int           NOT NULL,               -- ������, �� �������� �������� ������
    [Value]             Numeric(32,8) NOT NULL,               -- �����, �� ������� �������� ������
    [Currency_Id]       Int           NOT NULL,               -- ������ ��������
    [DocNo]             NVarChar(32)      NULL,
    -- ... � ��� �����-�� ����
    PRIMARY KEY CLUSTERED([Id]),
    FOREIGN KEY ([Currency_Id]) REFERENCES [TestMoney].[Currencies] ([Id]),
    FOREIGN KEY ([Client_Id]) REFERENCES [TestMoney].[Clients] ([Id])
  )
GO

----------------------------------------------------
-- ��������� ������
-----------------------------------------------------
/*
TRUNCATE TABLE [TestMoney].[Operations]
TRUNCATE TABLE [TestMoney].[Currencies Rates]

DELETE FROM [TestMoney].[Currencies]
DELETE FROM [TestMoney].[Clients]
--*/
GO
--/*
INSERT INTO [TestMoney].[Clients] ([Name])
SELECT
  [Name]    = CAST(O1.[object_id] AS NVarChar(128)) + ' - ' + CAST(O2.[object_id] AS NVarChar(128))
FROM
(
  SELECT TOP (100)
    O.[object_id]
  FROM sys.all_objects O
) O1
CROSS APPLY
(
  SELECT TOP (20)
    O.[object_id]
  FROM sys.all_objects O
) O2
GO

INSERT INTO [TestMoney].[Currencies]
VALUES
  (1, 'RUB', '�����'),
  (2, 'USD', '������ ���'),
  (3, 'EUR', '����'),
  (4, 'JPY', '����'),
  (5, 'BYR', '����������� �����')
GO

DECLARE @DateStart Date = '20130101'
INSERT INTO [TestMoney].[Currencies Rates]
SELECT
  [Currency_Id]     = C.[Id],
  [BaseCurrency_Id] = 1,
  [Date]            = DATEADD(Day, I.[RowNumber], @DateStart),
  [Rate]            = CASE C.[CodeLat3]
                        WHEN 'USD' THEN 40 - 10 + RAND( CAST(CAST(RIGHT(NewId(), 4) AS Binary(4)) AS Int) ) * 20
                        WHEN 'EUR' THEN 50 - 10 + RAND( CAST(CAST(RIGHT(NewId(), 4) AS Binary(4)) AS Int) ) * 20
                        WHEN 'JPY' THEN 40 - 10 + RAND( CAST(CAST(RIGHT(NewId(), 4) AS Binary(4)) AS Int) ) * 20
                        WHEN 'BYR' THEN 35 - 7 + RAND( CAST(CAST(RIGHT(NewId(), 4) AS Binary(4)) AS Int) ) * 15
                      END,
  [Volume]          = CASE
                        WHEN C.[CodeLat3] = 'BYR' THEN 10000
                        WHEN C.[CodeLat3] = 'JPY' THEN 100
                        ELSE 1
                      END
FROM [TestMoney].[Currencies] C
CROSS APPLY
(
  SELECT TOP (365*3)
    [RowNumber]     = ROW_NUMBER() OVER (ORDER BY O1.[object_id], O2.[object_id])
  FROM
  (
    SELECT TOP (100)
      O.[object_id]
    FROM sys.all_objects O
  ) O1
  CROSS APPLY
  (
    SELECT TOP (50)
      O.[object_id]
    FROM sys.all_objects O
  ) O2
) I
WHERE C.[Id] > 1 -- ����� �����
  AND I.[RowNumber] % 10 > 2 -- ����� ���� ������� � ������
GO

-- �� 3 ���� 2013, 2014, 2015
-- ������, ��� ����� ���������� ����� ����� �� 1 ����!
DECLARE
  @DateStart  Date        = '20130101',
  @N          Int         = 12 * 3,
  @DebugTime  DateTime    = GETDATE()

WHILE @N > 0 BEGIN

  INSERT INTO [TestMoney].[Operations] ([Date], [Client_Id], [Value], [Currency_Id], [DocNo])
  SELECT
    [Date]        = DATEADD(Day, I.[RowNumber], @DateStart),
    [Client_Id]   = C.[Id],
    [Value]       = RAND( CAST(CAST(RIGHT(NewId(), 4) AS Binary(4)) AS Int) ) * 1000 - 500,
    [Currency_Id] = CR.[Id],
    [DocNo]       = CAST(C.[Id] AS NVarChar(20)) + N'/' + CAST(CR.[Id] AS NVarChar(20)) + N'/' + CAST(I.[RowNumber] AS NVarChar(20)) + N'-' + CAST(I2.[RowIndex] AS NVarChar(20))
  FROM [TestMoney].[Clients]          C
  CROSS JOIN [TestMoney].[Currencies] CR
  CROSS APPLY
  (
    SELECT TOP (30)
      [RowNumber]     = ROW_NUMBER() OVER (ORDER BY O.[object_id])
    FROM sys.all_objects O
  ) I
  CROSS APPLY
  (
    SELECT TOP (20)
      [RowIndex]      = ROW_NUMBER() OVER (ORDER BY O.[object_id])
    FROM sys.all_objects O
  ) I2

  SET @DateStart = DATEADD(Month, 1, @DateStart)
  SET @N -= 1

END

SELECT [RUN_TIME] = CONVERT(VarChar(20), GETDATE() - @DebugTime, 114)
--*/
GO

/*
�������� ������, ������� ������ ������� �� �������� � ��������� ����:
-- Client_Id        -- ������
-- Currency_Id      -- ������
-- BaseBalance      -- ��������� ������� ������� � ������� ������ = ����� ���� ��������, � ������� Date >= @DateFrom � Date < @DateTo
������� ������ ������:
--ORDER BY
--  Client_Id, Currency_Id

��� ���� �������� ���������:
  @BaseCurrency_Id        - ������������� ������� ������, � ������� ���� �������� ����� Balance;
  @DateFrom, @DateTo      - ������ �� ������� ���� ��������� ������ �������

��� ��������� ������� ������������, ��� � ������� [TestMoney].[Currencies Rates] ���� ����� ��� [BaseCurrency_Id] = @BaseCurrency_Id
(�.�. �� ���� ��������� ������ �� �����-������)

�������: � ������� Operations ����� ����� ������. @DateFrom � @DateTo, ��� �������, ��������� ������ (�� ����� 1 ������ ��� ����� ������� ������ � Operations �� ����� 3-� ���)
���������� ������� ������(�) ��� ������� �������(��).

����������������/��������� ��� �����. ����� ���� ��������. ������ "��"/"���"?
--*/
GO

-----------------------------------------------------
-- ������ �������� ����������:
-----------------------------------------------------
DECLARE
  @DateFrom         Date    = '20150101'
DECLARE
  @DateTo           Date    = DATEADD(Day, 7, @DateFrom),
  @BaseCurrency_Id  Int     = 1

