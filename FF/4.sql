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
-- Структура данных                                                                 --
-- (*) исключительно для тестирования, не претендует на реальность и адекватность   --
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
    -- ... И еще какие-то поля
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
    [Currency_Id]       Int           NOT NULL, -- Валюту, курс которой указан
    [BaseCurrency_Id]   Int           NOT NULL, -- Базовая валюта; для пары USD/RUB в поле ВaseCurrency_Id будет ссылка на RUB; в поле Currency_Id - ссылка на USD; в поле Rate = курс = 60; т.е. 60 RUB = 1 USD
    [Date]              Date          NOT NULL, -- Дата курса
    [Rate]              Numeric(32,8) NOT NULL, -- Собственно курс 
    [Volume]            Numeric(18,8) NOT NULL, -- За количество; Например, за 10 000 Белорусских рублей дают 39.4419 Рублей; Rate = 39.4419; Volume = 10 000;
    PRIMARY KEY CLUSTERED([Currency_Id], [BaseCurrency_Id], [Date]),
    FOREIGN KEY ([Currency_Id]) REFERENCES [TestMoney].[Currencies] ([Id]),
    FOREIGN KEY ([BaseCurrency_Id]) REFERENCES [TestMoney].[Currencies] ([Id])
  )
-- Чтобы получить сумму Sb в @BaseCurrency_Id, если у Вас есть сумма Sc в валюте Currency_Id,
-- то надо найти на интересующую дату такую ближайшую по дате запись (курс есть не на каждый день),
-- где [BaseCurrency_Id] = @BaseCurrency_Id и [Currency_Id] = @Currency_Id и [Date] <= @Date,
-- умножить на Rate и разделить на Volume
-- т.е. Sb = Sc * Rate / Volume на требуемую дату
GO

IF OBJECT_ID('[TestMoney].[Operations]') IS NULL
  CREATE TABLE [TestMoney].[Operations]
  (
    [Id]                Int           NOT NULL IDENTITY(1,1),
    [Date]              Date          NOT NULL,               -- Дата операции
    [Client_Id]         Int           NOT NULL,               -- Клиент, по которому меняется баланс
    [Value]             Numeric(32,8) NOT NULL,               -- Сумма, на которую меняется баланс
    [Currency_Id]       Int           NOT NULL,               -- Валюта операции
    [DocNo]             NVarChar(32)      NULL,
    -- ... И еще какие-то поля
    PRIMARY KEY CLUSTERED([Id]),
    FOREIGN KEY ([Currency_Id]) REFERENCES [TestMoney].[Currencies] ([Id]),
    FOREIGN KEY ([Client_Id]) REFERENCES [TestMoney].[Clients] ([Id])
  )
GO

----------------------------------------------------
-- Генерация данных
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
  (1, 'RUB', 'Рубль'),
  (2, 'USD', 'Доллар США'),
  (3, 'EUR', 'Евро'),
  (4, 'JPY', 'Йена'),
  (5, 'BYR', 'Белорусский рубль')
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
WHERE C.[Id] > 1 -- кроме рубля
  AND I.[RowNumber] % 10 > 2 -- чтобы были пробелы в курсах
GO

-- За 3 года 2013, 2014, 2015
-- Учтите, что время заполнения может дойти до 1 часа!
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
Напишите скрипт, который вернет обороты по клиентам в следующем виде:
-- Client_Id        -- Клиент
-- Currency_Id      -- Валюта
-- BaseBalance      -- Изменение баланса клиента в базовой валюте = сумма всех операций, у которых Date >= @DateFrom и Date < @DateTo
Порядок вывода данных:
--ORDER BY
--  Client_Id, Currency_Id

При этом входящие параметры:
  @BaseCurrency_Id        - идентификатор базовой валюты, к которой надо привести сумму Balance;
  @DateFrom, @DateTo      - период за который надо расчитать баланс клиента

При написании скрипта предположите, что в таблице [TestMoney].[Currencies Rates] есть курсы для [BaseCurrency_Id] = @BaseCurrency_Id
(т.е. не надо усложнять задачу до кросс-курсов)

Условие: в таблице Operations очень много данных. @DateFrom и @DateTo, как правило, небольшой период (не более 1 недели при общей истории данных в Operations не менее 3-х лет)
Предложите хороший индекс(ы) для данного запроса(ов).

Прокомментируйте/обоснуйте Ваш выбор. Какие были варианты. Почему "да"/"нет"?
--*/
GO

-----------------------------------------------------
-- Пример тестовых параметров:
-----------------------------------------------------
DECLARE
  @DateFrom         Date    = '20150101'
DECLARE
  @DateTo           Date    = DATEADD(Day, 7, @DateFrom),
  @BaseCurrency_Id  Int     = 1

