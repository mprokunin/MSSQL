USE [REN_LOG]
GO
/****** Object:  StoredProcedure [dbo].[Delete_All_MessagesAndParameters_OlderThan]    Script Date: 3/5/2020 10:18:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Nikita Danilov (EPAM)
-- Create date: 2018-11-07
-- Update date: 2019-06-24 (см. преамбулу WD-31931)
-- Description:	WD-27125. Logbook. Настроить сбор статистики использования и сократить время хранения логов для которых не требуется полное время хранения.
-- Удаляем ВСЕ логи старше 6 месяцев.
-- =============================================
ALTER PROCEDURE [dbo].[Delete_All_MessagesAndParameters_OlderThan]
	@maxStoragePeriodDays INT = 180
AS
BEGIN
	IF @maxStoragePeriodDays IS NULL RETURN;

	PRINT 'Delete - All Messages and Parameters - Older than ' + CAST(@maxStoragePeriodDays AS NVARCHAR(10)) + ' days ... ';

	DECLARE @toDate DATETIME = DATEADD(DAY, -@maxStoragePeriodDays, GETDATE());
	DECLARE @totalCount INT = 0;
	DECLARE @lastCount INT = -1;

	DECLARE @targetMaxId INT;
	DECLARE @targetMinId INT;

	-- Старые таблицы.
	SELECT @targetMaxId = MAX(m.Id)
	FROM [dbo].[Old_Message] m with (nolock)
	WHERE m.CreationDate = (
		SELECT MAX(m.CreationDate)
		FROM [dbo].[Old_Message] m with (nolock)
		WHERE m.CreationDate < @toDate)

	SELECT @targetMinId = MIN(m.Id)
	FROM [dbo].[Old_Message] m with (nolock)
	WHERE m.CreationDate = (
		SELECT MIN(m.CreationDate)
		FROM [dbo].[Old_Message] m with (nolock)
		WHERE m.CreationDate < @toDate)

	-- Удаляем порциями, чтобы не сработал LOCK_ESCALATION:
	DECLARE @messages TABLE(ID INT PRIMARY KEY)

	WHILE (@lastCount != 0)
	BEGIN
		INSERT INTO @messages (ID)
		SELECT TOP (250) [ID]
		FROM [dbo].[Old_Message] WITH (NOLOCK)
		WHERE [ID] < @targetMaxId and [ID] >= @targetMinId
		ORDER BY [ID] ASC

		SELECT @lastCount = COUNT(ID) FROM @messages;
		SET @totalCount = @totalCount + @lastCount;

		DELETE mpt FROM [dbo].[Old_MessageParamText] mpt
			INNER JOIN @messages m ON m.[ID] = mpt.[MessageID]

		DELETE mpc FROM [dbo].[Old_MessageParamCompressed] mpc
			INNER JOIN @messages m ON m.[ID] = mpc.[MessageID]

		DELETE m FROM [dbo].[Old_Message] m
			INNER JOIN @messages m2 ON m2.[ID] = m.[ID]

		DELETE FROM @messages;
		WAITFOR DELAY '00:00:00.001';
	END

	-- Новые таблицы
	SELECT @targetMaxId = MAX(m.Id)
	FROM [dbo].[Message] m WITH (NOLOCK)
	WHERE m.CreationDate = (SELECT MAX(m.CreationDate)
							FROM [dbo].[Message] m  WITH (NOLOCK)
							WHERE m.CreationDate < @toDate)

	SELECT @targetMinId = MIN(m.Id)
	FROM [dbo].[Message] m WITH (NOLOCK)
	WHERE m.CreationDate = (SELECT MIN(m.CreationDate)
							FROM [dbo].[Message] m WITH (NOLOCK)
							WHERE m.CreationDate < @toDate)

	SET @lastCount = -1

	WHILE (@lastCount != 0)
	BEGIN
		INSERT INTO @messages (ID)
		SELECT TOP (250) [ID]
		FROM [dbo].[Message] WITH (NOLOCK)
		WHERE [ID] < @targetMaxId and [ID] >= @targetMinId
		ORDER BY [ID] ASC
	
		SELECT @lastCount = COUNT(ID) FROM @messages;
		SET @totalCount = @totalCount + @lastCount;

		DELETE mpt FROM [dbo].[MessageParamText] mpt
			INNER JOIN @messages m ON m.[ID] = mpt.[MessageID]

		DELETE mpc FROM [dbo].[MessageParamCompressed] mpc
			INNER JOIN @messages m ON m.[ID] = mpc.[MessageID]

		DELETE m FROM [dbo].[Message] m
			INNER JOIN @messages m2 ON m2.[ID] = m.[ID]

		DELETE FROM @messages;
		WAITFOR DELAY '00:00:00.001';
	END

	PRINT 'Deleted: ' + CAST(@totalCount AS NVARCHAR(50)) + '.';
END