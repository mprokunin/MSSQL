SET NOCOUNT ON

CREATE Table master.dbo.ASD
(DBName sysname,
-- DiskName char(1),
 AvaliableSpaceInMb int)

EXECUTE master.sys.sp_MSForEachDB  '
IF ''?'' IN (''dwh_archive'',''actuary_fix'',''DWH_ACT_PREP'')
BEGIN
    USE [?];
    SELECT SUBSTRING(physical_name,1,1) As  DiskName,cast(sum(size/128.0 - CAST(FILEPROPERTY(name, ''SpaceUsed'') AS int)/128.0) as int) AS AvailableSpaceInMB
	INTO #AvaliableSpaceINDB
	FROM sys.database_files
	GROUP BY SUBSTRING(physical_name,1,1),type_desc
	HAVING type_desc=''ROWS''

	CREATE Table #DiskFreeSpace
	(DiskName char(1), Size int)

	--select * from #AvaliableSpaceINDB
	insert into #DiskFreeSpace
	  exec xp_fixeddrives
	  
	--select * from #DiskFreeSpace

	Update #AvaliableSpaceINDB
	SET AvailableSpaceInMB=asp.AvailableSpaceInMB+ds.Size
	from #AvaliableSpaceINDB asp join #DiskFreeSpace ds
	ON asp.DiskName=ds.DiskName COLLATE Cyrillic_General_CI_AS

	insert into master.dbo.ASD (DBName, AvaliableSpaceInMb)
	select DB_Name(),sum(AvailableSpaceInMB) from  #AvaliableSpaceINDB
    
END
'

--select * from master.dbo.ASD

if exists (select 1 from  master..ASD 
where 
--(DBName='actuary' and AvaliableSpaceInMb<5000000)
   (DBName='actuary_fix' and AvaliableSpaceInMb<102400)
OR (DBName='dwh_archive' and AvaliableSpaceInMb<512000)
OR (DBName='DWH_ACT_PREP' and AvaliableSpaceInMb<102400))
--OR (DBName='MIS' and AvaliableSpaceInMb<51200))
BEGIN
	Declare @Body varchar(max)
	SET @Body='Для следующих БД недостаточно места:'+CHAR(10)+CHAR(13)
	select distinct @Body=@Body+
	  case 
		--when DBName='actuary' and AvaliableSpaceInMb< then 'actuary'+CHAR(10)+CHAR(13) 
		when DBName='actuary_fix' and AvaliableSpaceInMb<102400 then 'actuary_fix'+CHAR(10)+CHAR(13)
		when DBName='dwh_archive' and AvaliableSpaceInMb<512000 then 'dwh_archive'+CHAR(10)+CHAR(13)
		--when DBName='MIS' and AvaliableSpaceInMb<51200 then 'MIS'+CHAR(10)+CHAR(13)
		when DBName='DWH_ACT_PREP' and AvaliableSpaceInMb<102400 then 'DWH_ACT_PREP'+CHAR(10)+CHAR(13)
		else ''
	  end
	from master.dbo.ASD

	select @Body

	EXEC msdb.dbo.sp_send_dbmail
		@profile_name = 'DBMailProfile',
--		@recipients = 'MVorobev@renins.com;INaumova@renins.com;OSukhanov@renins.com;VMilahin@renins.com;AKutsenko@renins.com;APapoyan@renins.com;akropatchev@renins.com;mrumyantsev@renins.com;anyrov@renins.com',
		@recipients = 'MProkunin@renins.com;OSukhanov@renins.com;VMilahin@renins.com;AKutsenko@renins.com;APapoyan@renins.com;akropatchev@renins.com;mrumyantsev@renins.com;anyrov@renins.com',
		@body = @Body,
		@subject = 'Disk low space on REN-MSKFA03';

END

drop table master.dbo.ASD
