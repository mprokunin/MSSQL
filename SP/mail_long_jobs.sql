USE [msdb]
GO
/****** Object:  StoredProcedure [dbo].[mail_long_jobs]    Script Date: 17.08.2018 11:42:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER procedure [dbo].[mail_long_jobs]
  @long_seconds  int          = null,
  @mail_to       varchar(max) = null
as
/*
  отправляет по почте список долго исполняющихся заданий
  
*/
  set nocount, ansi_padding, ansi_warnings, concat_null_yields_null on
  set numeric_roundabort off
  set transaction isolation level read uncommitted 

  -- обявления
  declare
    @error_number    int,
    @error_message   varchar(8000),
    @error_severity  int,
    @error_state     int,
    @proc_name       varchar(128),
    @rowcount        int,
    @trancount       int
  select
    @error_number    = 0,
    @error_message   = null,
    @error_severity  = 0,
    @error_state     = 1,
    @proc_name       = object_name(@@procid),
    @rowcount        = 0,
    @trancount       = @@trancount
  declare
    @subject         nvarchar(255),
    @body            nvarchar(max),
    @session_id      int,
    @jobs            cursor,
    @n               int,
    @s               nvarchar(255)
  select
    @long_seconds    = coalesce(@long_seconds,300),
    @subject         = 'Следующие задания исполняются более '+cast(@long_seconds as varchar)+' сек.',
    @body            = 'start                elapsed    job
-------------------- ---------- --------------------------------------------------'
  --declare @xp_results table
  -- (
  --  job_id                uniqueidentifier not null,
  --  last_run_date         int              not null,
  --  last_run_time         int              not null,
  --  next_run_date         int              not null,
  --  next_run_time         int              not null,
  --  next_run_schedule_id  int              not null,
  --  requested_to_run      int              not null,
  --  request_source        int              not null,
  --  request_source_id     sysname collate database_default null,
  --  running               int              not null,
  --  current_step          int              not null,
  --  current_retry_attempt int              not null,
  --  job_state             int              not null
  -- )

  begin try

  select top(1) @session_id = session_id from msdb.dbo.syssessions order by agent_start_date desc
  --insert into @xp_results execute master.dbo.xp_sqlagent_enum_jobs 1,''

  --set @jobs = cursor local static read_only for select
  --  convert(char(21),a.run_requested_date,120)+
  --  convert(char(11),dateadd(s,datediff(s,a.run_requested_date,getdate()),''),108)+
  --  convert(char(50),j.name)
  --from
  --       @xp_results             r
  --  join msdb.dbo.sysjobactivity a on a.job_id = r.job_id
  --  join msdb.dbo.sysjobs        j on j.job_id = a.job_id
  --where 1=1
  --  and r.job_state            = 1
  --  and a.session_id = @session_id
  --  and a.run_requested_date  is not null
  --  and a.stop_execution_date is     null
  --  and datediff(s,a.run_requested_date,getdate()) > @long_seconds

  set @jobs = cursor local static read_only for select
    convert(char(21),a.run_requested_date,120)+
    convert(char(11),dateadd(s,datediff(s,a.run_requested_date,getdate()),''),108)+
    convert(char(50),j.name)
  from
         msdb.dbo.sysjobactivity a
    join msdb.dbo.sysjobs        j on j.job_id = a.job_id and j.name not like '/10s%' and j.category_id <> 8
  where 1=1
    and a.session_id = @session_id
    and a.run_requested_date  is not null
    and a.stop_execution_date is     null
    and datediff(s,a.run_requested_date,getdate()) > @long_seconds

  open @jobs; set @n = @@cursor_rows
  while 1=1
    begin
    fetch next from @jobs into @s
    if @@fetch_status = -1 break
    if @@fetch_status = -2 continue
    set @body = @body  + char(13) + char(10) + @s
    end
  close @jobs
  deallocate @jobs

  proc_exit:
  end try

  begin catch
  if @@trancount > 0 rollback transaction
  select
    @error_number   = error_number(),
    @error_message  = error_message(),
    @error_severity = error_severity(),
    @error_state    = error_state(),
    @error_message  = @proc_name+': ' + @error_message + coalesce(' ('+cast(nullif(@error_number,50000) as varchar)+')',''),
    @body           = 'Ошибка при выполнении процедуры ' + @error_message
  raiserror(@error_message,@error_severity,@error_state) with nowait,seterror
  end catch

  while @@trancount > @trancount commit transaction

  if coalesce(@n,0) > 0
     if @mail_to is null
        print @body
     else
        execute msdb.dbo.sp_send_dbmail
--        @profile_name = 'SQLTESTER_MAIN',
          @recipients   = @mail_to,
          @subject      = @subject,
          @body         = @body,
          @body_format  = 'TEXT'

  return @error_number


