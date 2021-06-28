USE [master]
GO

/****** Object:  Table [dbo].[SysHealth_SpWhoResults]    Script Date: 21.01.2021 20:29:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SysHealth_SpWhoResults](
	[spid] [int] NULL,
	[ecid] [int] NULL,
	[status] [varchar](50) NULL,
	[loginame] [varchar](50) NULL,
	[hostname] [varchar](50) NULL,
	[blk] [int] NULL,
	[dbname] [varchar](50) NULL,
	[cmd] [varchar](100) NULL,
	[request_id] [int] NULL,
	[EventType] [varchar](100) NULL,
	[Parameters] [varchar](100) NULL,
	[EventInfo] [varchar](4000) NULL,
	[TimeStamp] [datetime] NULL
) ON [PRIMARY]
GO

/****** Object:  StoredProcedure [dbo].[SysHealth_Save_SpWho_Results]    Script Date: 21.01.2021 20:12:54 ******/
DROP PROCEDURE [dbo].[SysHealth_Save_SpWho_Results]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		Nesyutin A., Renins
-- Create date: 03.07.2014
-- Description:	сохраняет результаты запросов к базе для последующего анализа зависаний и проблем
-- Mprokunin: send alert if too many locked processes
-- =============================================

CREATE PROCEDURE [dbo].[SysHealth_Save_SpWho_Results]
	
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @SleepHourStart INT
	DECLARE @SleepHourEnd INT
	
	SET @SleepHourStart = 23
	SET @SleepHourEnd = 3
	
	DECLARE @t TABLE (
		spid INT
		, ecid INT
		, STATUS VARCHAR(50)
		, loginame VARCHAR(50)
		, hostname VARCHAR(50)
		, blk INT
		, dbname VARCHAR(50)
		, cmd VARCHAR(100)
		, request_id INT
		, eventtype VARCHAR(100)
		, parameters VARCHAR(100)
		, eventinfo VARCHAR(4000)
		, [TIMESTAMP] DATETIME
	)

	declare @timeStamp DATETIME
	declare @numOfEntries int

	SET @timeStamp = GETDATE();

	INSERT INTO @t (spid, ecid, [STATUS], loginame, hostname, blk, dbname, cmd, request_id)
	exec sp_who ACTIVE
	
	DELETE FROM @t WHERE dbname IN ('distribution') /* Базы, за которым нам следить не надо */

	UPDATE @t SET [TIMESTAMP] = @timeStamp -- set timestamp
	 
	SELECT @numOfEntries = COUNT(*) FROM @t


	-- loop for getting spid info 
	DECLARE @cnt INT 
	declare @curSpid VARCHAR(10)
	SET @cnt = 0;

	CREATE TABLE #spidInfo(  -- use temp tables, other types of table don't work
	EventType NVARCHAR(30) NULL,
	Parameters INT NULL,
	EventInfo NVARCHAR(4000) NULL
	)

	WHILE(@cnt < @numOfEntries)
	BEGIN
		DELETE FROM #spidInfo
		
		SELECT TOP 1 @curSpid = cast(spid as varchar(10)) FROM @t WHERE eventtype IS NULL -- get first free spid
		begin try
		INSERT #spidInfo -- get current spid info via dbcc command 
		EXEC('DBCC INPUTBUFFER(' + @curSpid + ')')
		end try
		
		begin catch
		--SELECT ERROR_NUMBER(), ERROR_SEVERITY(), ERROR_STATE(), ERROR_LINE(), ERROR_MESSAGE()
		  insert into #spidInfo values('n/a',NULL,NULL)
		end catch

		UPDATE @t 
		SET EVENttype = (SELECT TOP 1 eventtype FROM #spidInfo),
			Parameters = (SELECT TOP 1 Parameters FROM #spidInfo),
			EventInfo = (SELECT TOP 1 EventInfo FROM #spidInfo)
		WHERE spid = @curSpid

		SET @cnt = @cnt + 1 
	END

	INSERT INTO dbo.SysHealth_SpWhoResults (
		spid, ecid, [STATUS], loginame, hostname, blk, dbname, cmd, request_id, eventtype, parameters, eventinfo, [TIMESTAMP])
	SELECT 
		spid, ecid, [STATUS], loginame, hostname, blk, dbname, cmd, request_id, eventtype, parameters, eventinfo, [TIMESTAMP]
	FROM @t

	DROP TABLE #spidInfo

	-- **************
	-- * Monitoring * 
	-- **************

	-- посмотрим не накопилось ли плохих запросов
	DECLARE @msgBody VARCHAR(max)

	SET @msgBody = '<html><body><style type="text/css">
	   #guilty tr td, #guilty tr th, #poors tr td, #poors tr th {border:solid 1px #c0c0c0;padding: 5px;}
	   #guilty, #poors {border:solid 1px #c0c0c0; border-collapse:collapse;}
	  </style>'

	-- Если сейчас есть блокировки, то начать дело!
	IF EXISTS (SELECT * FROM SysHealth_SpWhoResults shswr WITH(NOLOCK) WHERE shswr.[TimeStamp] = @timeStamp AND blk <> 0) 
	BEGIN
		
		PRINT 'blocks'
		
		-- *** Проверим, а не длятся ли блокировки уже несколько слепков? ***

		DECLARE @TimestampOfPreviosRun DATETIME; 
		DECLARE @TimestampOfPreviosRun2 DATETIME;

		SELECT @TimestampOfPreviosRun = shswr.[TimeStamp]
		  FROM SysHealth_SpWhoResults shswr WITH(NOLOCK)
		WHERE 1=1
		AND shswr.blk <> 0
		AND shswr.[TimeStamp] = (
			SELECT TOP 1 [timestamp]  -- previous timestamp
			FROM SysHealth_SpWhoResults shswr2 WITH(NOLOCK)
			WHERE shswr2.[TimeStamp] < @timeStamp
			ORDER BY shswr2.[TimeStamp] desc
			) 	
		IF @TimestampOfPreviosRun IS NOT NULL 
		BEGIN                    
			SET @msgBody = @msgBody + '<h3>В базе висят:</h3>'		
			
			SELECT @TimestampOfPreviosRun2 = shswr.[TimeStamp]
			  FROM SysHealth_SpWhoResults shswr WITH(NOLOCK)
			WHERE 1=1
			AND shswr.blk <> 0
			AND shswr.[TimeStamp] = (
				SELECT TOP 1 [timestamp]  -- previous timestamp
				FROM SysHealth_SpWhoResults shswr2 WITH(NOLOCK)
				WHERE shswr2.[TimeStamp] < @TimestampOfPreviosRun
				ORDER BY shswr2.[TimeStamp] desc
				) 	
		END
		ELSE RETURN; -- выйти если запросы не висят несколько слепков. 

			
		-- *** возможные виновники - те, которых никто не блокирует, но которые блокируют кого-то другого ***
		SET @msgBody = @msgBody + '<h3>Вероятный злоумышленик:</h3>'
		SET @msgBody = @msgBody + '
			<table id="guilty" border="1">
			<tr>
				<th>ID процесса</th>
				<th>Логин</th>
				<th>Сервер</th>
				<th>ID блокирующего</th>
				<th>База</th>
				<th>Команда</th>
				<th>Подробности</th>
				<th>Тип события</th>
				<th>Статус</th>
			</tr>'
			
		SELECT @msgBody = @msgBody 
			+ '<tr><td>' + cast(shswr.spid AS VARCHAR(10)) 
			+ '</td><td>' + shswr.loginame 
			+ '</td><td>' + shswr.hostname
			+ '</td><td>' + cast(shswr.blk AS VARCHAR(10))
			+ '</td><td>' + shswr.dbname
			+ '</td><td>' + shswr.cmd
			+ '</td><td>' + isnull(shswr.EventInfo, '')
			+ '</td><td>' + isnull(shswr.EventType,'')
			+ '</td><td>' + shswr.status
			+ '</td></tr>' 
		FROM SysHealth_SpWhoResults shswr WITH(NOLOCK)
		WHERE shswr.[TimeStamp] = @timeStamp
		AND shswr.blk = 0 AND exists (
			SELECT * FROM SysHealth_SpWhoResults shswr2 WITH(NOLOCK)
			WHERE shswr2.blk = shswr.spid AND shswr2.[TimeStamp] = @timeStamp
		)
		
		SET @msgBody = @msgBody + '</table>'

		-- *** Пострадавшие - те, кого блокируют другие запросы ***
		SET @msgBody = @msgBody + '<h3>Пострадавшие:</h3>'
		SET @msgBody = @msgBody + '<table id="poors" border="1"><tr>
				<th>ID процесса</th>
				<th>Логин</th>
				<th>Сервер</th>
				<th>ID блокирующего</th>
				<th>База</th>
				<th>Команда</th>
				<th>Подробности</th>
				<th>Тип события</th>
				<th>Статус</th>
			</tr>'

		-- пострадавшие
		SELECT
		 @msgBody = @msgBody 
		+ '<tr><td>' + cast(shswr.spid AS VARCHAR(10)) 
			+ '</td><td>' + shswr.loginame 
			+ '</td><td>' + shswr.hostname
			+ '</td><td>' + cast(shswr.blk AS VARCHAR(10))
			+ '</td><td>' + shswr.dbname
			+ '</td><td>' + shswr.cmd
			+ '</td><td>' + isnull(shswr.EventInfo, '')
			+ '</td><td>' + isnull(shswr.EventType,'')
			+ '</td><td>' + shswr.status
			+ '</td></tr>' 


		FROM SysHealth_SpWhoResults shswr WITH(NOLOCK)
		WHERE shswr.[TimeStamp] = @timeStamp
		AND shswr.blk <> 0
		AND not upper(shswr.cmd) = 'RESTORE HEADERON' /* решено, что некоторые системные процессы мониторить не надо  */ 
		AND not upper(shswr.cmd) = 'BACKUP DATABASE'
		AND shswr.dbname <> 'master'
		ORDER BY shswr.spid

		IF(@@ROWCOUNT <= 10) RETURN; /*пострадавших мало - ничего и не делать.*/

		SET @msgBody = @msgBody + '</table></body></html>'

		PRINT @msgBody
		
		DECLARE @hourNow INT; SET @hourNow = DATEPART(hour, GETDATE());
		
		/* заточились на полуночь */
		IF (@hourNow >= 0 AND @hourNow >= @SleepHourEnd) OR (@hourNow < 0 AND @hourNow < @SleepHourStart)
		BEGIN /* если попали в тихий час, не шлем письмо */
		/* закомментировал 6 июня 2014 в 13:23 Несютин, Ирина удаляет ненужные файлы, будет много блокировок
		выполняем отправку почты */
		declare @subject varchar(255);
		select @subject = concat('Блокировки на ',  @@servername)
		EXEC msdb.dbo.sp_send_dbmail 
			@profile_name='DBMailProfile', 
			@recipients ='IBekhterev@renins.com;AZvyagintsev2@renins.com;IKoreschikov@renins.com;asafonov@renins.com',
			@copy_recipients ='mprokunin@renins.com',
			@body_format = 'HTML',
			@subject = @subject,
			@body = @msgBody
		END
	END	
END
GO


/*

exec sp_spaceused '[dbo].[SysHealth_SpWhoResults]'
exec sp_help '[dbo].[SysHealth_SpWhoResults]'
select top 1000 * from [dbo].[SysHealth_SpWhoResults] order by [TimeStamp] desc
select top 1000 * from [dbo].[SysHealth_SpWhoResults] where EventType = 'n/a' order by [TimeStamp] desc

select concat('Блокировки на ',  @@servername)
*/