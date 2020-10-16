-- Copy data throught linked server (tables exacltly the same)
--
DECLARE @ID int, @TAB sysname, @COL sysname, @COLS varchar(1000), @EXESTR varchar(max)
DECLARE TAB_cursor CURSOR FOR 
	SELECT id, name FROM sysobjects where type = 'U' order by name
	for read only
OPEN TAB_cursor  

FETCH NEXT FROM TAB_cursor INTO @ID, @TAB

WHILE @@FETCH_STATUS = 0  
BEGIN  
	select @EXESTR = 'insert into openquery(MAA01, ''select ', @COLS = ''
	DECLARE COL_cursor CURSOR FOR
		select name from syscolumns where id = @ID
	for read only
	open COL_cursor
	fetch next from COL_cursor into @COL
	while @@FETCH_STATUS = 0
	begin 
		select @COLS = @COLS + '"' + @COL + '",'
		fetch next from COL_cursor into @COL
	end
	close COL_cursor
	DEALLOCATE COL_cursor;  
	set @COLS = LEFT(@COLS, LEN(@COLS) - 1) 
	select @EXESTR = 'insert into openquery(MAA01, ''select ' +  @COLS + ' from rmw."' + @TAB + '"'') select ' + @COLS + ' from ' + @TAB
	select @EXESTR
--	exec (@EXESTR)
	FETCH NEXT FROM TAB_cursor INTO @ID, @TAB
END   
CLOSE TAB_cursor;  
DEALLOCATE TAB_cursor;  
