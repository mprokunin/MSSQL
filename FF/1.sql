--Структура данных
SET NOCOUNT ON
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

--/*
IF OBJECT_ID('[TestDoc].[Accounts]') IS NOT NULL
  DROP TABLE [TestDoc].[Accounts]

IF OBJECT_ID('[TestDoc].[Contracts]') IS NOT NULL
  DROP TABLE [TestDoc].[Contracts]
--*/
--------------------------------------------------------------------------------------
-- Структура данных                                                                 --
--------------------------------------------------------------------------------------
IF SCHEMA_ID('TestDoc') IS NULL
  EXEC('
    CREATE SCHEMA [TestDoc]
  ')
GO

IF OBJECT_ID('[TestDoc].[Contracts]') IS NULL
  -- Договора
  CREATE TABLE [TestDoc].[Contracts]
  (
    [Id]        Int           NOT NULL  IDENTITY(1,1),
    [DocNo]     NVarChar(50)  NOT NULL,
    [DateFrom]  Date          NOT NULL, --  Дата, когда договор начал действовать
    [DateTo]    Date              NULL, --  Дата, когда договор прекращает действовать (последний день действия договора); NULL = бесконечность
    -- ... И еще какие-то поля
    PRIMARY KEY CLUSTERED([Id])
  )
GO

IF OBJECT_ID('[TestDoc].[Accounts]') IS NULL
  -- Счета
  CREATE TABLE [TestDoc].[Accounts]
  (
    [Id]            Int           NOT NULL  IDENTITY(1,1),
    [Contract_Id]   Int           NOT NULL, -- Договор, в рамках которого счет заключен
    [Number]        NVarChar(50)  NOT NULL, -- Номер счета
    [DateTimeFrom]  DateTime      NOT NULL, -- Момент времени (дата+время!), когда счет начал действовать
    [DateTimeTo]    DateTime          NULL, -- Момент времени (дата+время!), когда счет прекратил действовать
    -- ... И еще какие-то поля
    PRIMARY KEY CLUSTERED([Id]),
    FOREIGN KEY ([Contract_Id]) REFERENCES [TestDoc].[Contracts] ([Id])
  )
GO
/*
Есть таблица контрактов [TestDoc].[Contracts]. У контракта есть период действия. Поле [DateFrom] – дата начала действия договора. Поле [DateTo] – последний день действия договора. NULL в поле [DateTo] значит «договор с неуказанной датой закрытия», т.е. договор действует с даты открытия неопределенно долго.
Есть таблица счетов. Счета открываются в рамках договора. Поле [DateTimeFrom] – момент времени, когда счет открыли. [DateTimeTo] – момент времени, когда счета закрыли. NULL в поле [DateTimeTo] значит «счет с неуказанной датой закрытия», т.е. счет действует с даты открытия неопределенно долго.
Задание
Напишите скрипт, который вернет список «ошибок» в системе. Под «ошибкой» подразумевается ситуация, когда счет действует (действовал), а договор, в рамках которого заключен счет, не действует (не действовал).
*/
select a.* from [TestDoc].[Accounts] a
left outer join [TestDoc].[Contracts] c
on a.[Contract_id] = c.[Id]
where ( a.[DateTimeFrom] < c.[DateFrom] )
or ( a.[DateTimeTo] is null and c.[DateTo] is not null and c.[DateTo] > getdate()	)
or ( a.[DateTimeTo] is not null and c.[DateTo] is not null and a.[DateTimeTo] > c.[DateTo] )

insert into [TestDoc].[Contracts] values ('CONT1','20210501',null);
insert into [TestDoc].[Contracts] values ('CONT2','20210401','20210518')

select * from [TestDoc].[Contracts]
select * from [TestDoc].[Accounts]

insert into [TestDoc].[Accounts] values (1,'ACC1', '20210401', null);
insert into [TestDoc].[Accounts] values (1,'ACC1', '20210511', null);
insert into [TestDoc].[Accounts] values (1,'ACC1', '20210511', '20210525');
insert into [TestDoc].[Accounts] values (2,'ACC4', '20210511', '20210525');
insert into [TestDoc].[Accounts] values (2,'ACC5', '20210511', '20210525');
