declare @sql nvarchar (max)

declare @Database table (
		DbName nvarchar (128)
	)
;



insert into @Database (DbName)
values
	    ('AtonBase')
	  , ('NotificationBase')
;

set @sql = 'declare @sql nvarchar (max);' + char (13)

set @sql += (
		select
			  'use ' + DbName + ';' + char (13)
			+ 'set @sql = (
						select
							  ''ALTER QUEUE '' + quotename (name) + '' WITH STATUS = OFF;''
							+ ''ALTER QUEUE '' + quotename (name) + '' WITH STATUS = ON;''	
							+ char (13)
							+ ''print ''''' + DbName + '.'' + name + '''''''' 
							+ char (13)
						from sys.service_queues
						where
								is_receive_enabled = 1
							and is_ms_shipped = 0
						for xml path (''''), root (''root''), type
					).value (''root[1]'', ''nvarchar (max)'')
				;

				exec (@sql);'
		from @Database
		for xml path (''), root ('root'), type
	).value ('root[1]', 'nvarchar (max)')



exec (@sql);

;

--declare @sql nvarchar (max)

--set @sql = (
--		select
--			  'ALTER QUEUE ' + quotename (name) + ' WITH STATUS = OFF;'
--			+ 'ALTER QUEUE ' + quotename (name) + ' WITH STATUS = ON;'
--			+ char (13)
--		from sys.service_queues
--		where
--				is_receive_enabled = 1
--			and is_ms_shipped = 0
--		for xml path (''), root ('root'), type
--	).value ('root[1]', 'nvarchar (max)')
--;

--exec (@sql);

--go



 