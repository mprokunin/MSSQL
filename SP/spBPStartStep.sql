USE [BP]
GO
/****** Object:  StoredProcedure [dbo].[spBPStartStep]    Script Date: 19.07.2018 12:25:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER proc [dbo].[spBPStartStep] (                   
    @pOperDate    datetime      
  , @pBPID        int      
  , @pStepID      int      
  , @pStartType   int      
  , @SysUserInfo  varchar(255)  = null                  
  , @pRetCode     int           = null out      
  , @pRetMsg      nvarchar(max) = null out      
)                    
as begin              
                  
set nocount on                  
set transaction isolation level read uncommitted      
                  
/*                  
  CREATED: 19.02.2008/akravchenko - запускает работу шага @pStepID                  
  UPDATED: 12.10.2009/akravchenko - двухфазность                
           17.10.2011/akravchenko - новый механизм (IsNew) - m4779
	UPDATED: 30.11.2015/Dtarasov/Ticket#015013921 - попытка исправить параллельное выполнение одного и того же шага     
*/                  
                  
declare       
    @StepIndex        int      
  , @StepName         varchar(255)      
  , @StepShortName    varchar(255)      
  , @WorkID           int      
  , @DateFrom         int      
  , @WithoutDelete    int      
  , @IsTwoPhaseStep   int      
  , @StepPhase        int                
  , @Cmd              nvarchar(max)      
  , @Cmd1             nvarchar(max)      
  , @IsPrm            int                  
  , @Msg              varchar(max)                  
  , @RetCode          int              
  , @IsNotWorkDay     int              
  , @IsNew            int      
  , @rc               int      
  , @RetMsg           varchar(8000)      
  , @DebugMode        int
  , @return_status    int = 0
  , @CurState         int = null
  , @State            int    
      
declare       
    @Success          int         
  , @Working          int         
  , @Rollbacking      int         
  , @Rollbacked       int         
  , @Error            int         
  , @BPDayState       int      
      
select      
    @Success      = 2      
  , @Working      = 1                
  , @Rollbacking  = 6                   
  , @Rollbacked   = 5        
  , @Error        = 3            
  , @DebugMode    = null          
      
select       
    @StepIndex      = s.StepIndex      
  , @StepName       = s.StepName      
  , @WorkID         = s.WorkID      
  , @DateFrom       = s.DateFrom      
  , @WithoutDelete  = s.WithoutDelete      
  , @IsNotWorkDay   = isnull( s.IsNotWorkDay, 0 )                
  , @IsNew          = case when s.IsNew = 1 then 1 else 0 end      
  , @StepShortName  = s.StepShortName      
  , @BPDayState     = isnull( h.BPDayState, 0 )      
from       
  BPStep s with (nolock) inner join dbo.BPDayHistory h with (nolock) on h.OperDate = @pOperDate and h.BPID = s.BPID      
where       
  s.BPID = @pBPID       
  and s.StepID = @pStepID                  
        
if @BPDayState != @Working begin      
  -- весь бизнес-процесс приостановлен      
  set @pRetCode = -1      
  set @pRetMsg = 'Бизнес-процесс приостановлен. Для возобновления установить dbo.BPDayHistory.BPDayState = 1'      
  goto bye      
end 

set @WorkID = isnull( @WorkID, 0 )                  
                  
declare @WorkTypeID int, @ServerName varchar(255), @DbName varchar(255), @WorkName varchar(255), @d datetime                  
      
select @WorkTypeID = WorkTypeID, @ServerName = ServerName, @DbName = DbName, @WorkName = WorkName                   
from BPWork                   
where WorkID = @WorkID      
  
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ  
                    
select @IsTwoPhaseStep = isnull( IsTwoPhaseStep, 0 ), @StepPhase = isnull( StepPhase, -1 ), @CurState = [State]               
  from dbo.BPStepDayHistory WITH(READPAST)                
    where OperDate = @pOperDate and BPID = @pBPID and StepID = @pStepID                

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

if @CurState IS NULL
	goto bye                
                
-----------------------------------------------------------------------------------------------------------------                
if @IsNew = 1 begin                
-----------------------------------------------------------------------------------------------------------------                
      
if( @WorkTypeID = 3 ) begin  -- хранимая процедура                  
                    
  set @IsPrm = 0                  
  set @Cmd = 'exec @ret = ' + @ServerName + '.' + @DbName + '..' + @WorkName     
                    
  -- обработка @DateFrom                  
  set @DateFrom = isnull( @DateFrom, 0 )                    
  -- по-новому флаг @IsNotWorkDay определяет - с рабочими(0) или календарными(1) днями работаем          
  if @IsNotWorkDay = 0 begin              
    set @d = dbo.fnGetWorkDay( @pOperDate, @DateFrom, 1 )                        
  end else begin                  
    set @d = @pOperDate + @DateFrom                
  end           
      
  set @Cmd = @Cmd + case when @IsPrm > 0 then ',' else '' end + ' @pDate = ''' + convert( varchar(10), @d, 121 ) + ''''                  
  set @IsPrm = @IsPrm + 1                  
                    
  -- если откат сделанного ( @pIsOnlyDelete )                  
  if( @pStartType = -1 ) begin                      
    set @Cmd = @Cmd + case when @IsPrm > 0 then ',' else '' end + ' @pIsOnlyDelete = 1'                  
    set @IsPrm = @IsPrm + 1                  
  end                     
                    
  set @Cmd = @Cmd + case when @IsPrm > 0 then ',' else '' end + ' @pRetCode = @RetCode out, @pRetMsg = @RetMsg out, @SysUserInfo = ''' + isnull( @SysUserInfo, '' ) + ''''                  
  set @IsPrm = @IsPrm + 1                  
                      
  set @Msg = convert( varchar(max), 'Выполняем команду: ' + @Cmd )                  
  exec spBPLog                   
      @pOperDate  = @pOperDate                   
    , @pBPID      = @pBPID                
    , @pStepID    = @pStepID      
    , @pState     = null      
    , @pDbUser    = null      
    , @pHost      = null      
    , @pIsError   = 0      
    , @pIsWarning = 0      
    , @pIsDebug   = 1      
    , @pMsg       = @Msg                  
      
declare @RealTime datetime, @Initiator varchar(20), @Host varchar(20)      
set @State      = case when @pStartType = -1 then @Rollbacking else @Working end                
set @RealTime   = getdate()                
set @Initiator  = dbo.fnSysParseSysUserInfo( @SysUserInfo, 'UserName' )                
set @Host       = dbo.fnSysParseSysUserInfo( @SysUserInfo, 'ComputerName' )                

-- установить статус шага (выполняется)      
  exec @return_status = dbo.spBPSetStepParam                 
      @SysUserInfo    = @SysUserInfo      
    , @pOperDate      = @pOperDate      
    , @pBPID          = @pBPID      
    , @pStepShortName = @StepShortName      
    , @pState         = @State      
    , @pRealTime      = @RealTime      
    , @pSPID          = @@SPID      
    , @pInitiator     = @Initiator                
  
  IF @return_status <> 0
  BEGIN
	goto bye
  END  
                      
	-- пишем в лог, что запускаемся                
	set @Msg = 'Запускается шаг ''' + isnull( @StepName, '' ) + ''''                
	exec dbo.spBPLog                 
		@pOperDate  = @pOperDate      
	, @pBPID      = @pBPID      
	, @pStepID    = @pStepID      
	, @pState     = @State      
	, @pDbUser    = @Initiator      
	, @pHost      = @Host      
	, @pIsError   = 0      
	, @pIsWarning = 0      
	, @pMsg       = @Msg                
      
	-- выполняем      
	select @DebugMode = DebugMode from dbo.BP with (nolock) where BPID = @pBPID      
	set @DebugMode = coalesce( @DebugMode, 0 )      
	if @DebugMode > 0 begin      
	exec dbo.spBPTest @pBPID = @pBPID, @pStepShortName = @StepShortName, @pBPRetCode = @RetCode out, @pBPRetMsg = @RetMsg out      
	end else begin      
	exec sp_executesql @Cmd, N'@ret int out, @RetCode int out, @RetMsg varchar(8000) out', @ret = @rc out, @RetCode = @RetCode out, @RetMsg = @RetMsg out      
	end      
      
if @RetCode = 0 begin                
        
	set @State = case when @pStartType = -1 then @Rollbacked else @Success end      
                  
	-- успешно выполнен или успешно откачен                
	exec dbo.spBPSetStepParam                
	@SysUserInfo    = @SysUserInfo,                
	@pOperDate      = @pOperDate,                
	@pBPID          = @pBPID,                
	@pStepShortName = @StepShortName,                
	@pState         = @State,                
	@pComment       = @RetMsg                
                
	set @Msg = 'Шаг ''' + @StepName + ''' - успешно ' + case @State when @Success then 'выполнен' else 'откачен' end                
	exec dbo.spBPLog                 
	@pOperDate  = @pOperDate,                 
	@pBPID      = @pBPID,                 
	@pStepID    = @pStepID,                 
	@pState     = @State,                 
	@pDbUser    = @Initiator,                 
	@pHost      = @Host,                 
	@pIsError   = 0,                 
	@pIsWarning = 0,                 
	@pMsg       = @Msg                
            
end else begin                
      
	-- неуспех                
	exec dbo.spBPSetStepError                
	@SysUserInfo    = @SysUserInfo,                 
	@pOperDate      = @pOperDate,                @pBPID          = @pBPID,                
	@pStepShortName = @StepShortName,                
	@pErrorMessage  = @RetMsg                
                
	set @Msg = 'Шаг ''' + @StepName + ''' - ошибка: ' + convert( varchar(200), isnull( @RetMsg, '' ) )                
	exec dbo.spBPLog                 
	@pOperDate  = @pOperDate,                 
	@pBPID      = @pBPID,                 
	@pStepID    = @pStepID,                 
	@pState     = @Error,                 
	@pDbUser    = @Initiator,                 
	@pHost      = @Host,                 
	@pIsError   = 1,                 
	@pIsWarning = 0,                 
	@pMsg       = @Msg                
            
	--print 'epilog6'                                 
        
end
                   
end -- 3      
      
goto bye      
      
-----------------------------------------------------------------------------------------------------------------                
end -- @IsNew = 1      
-----------------------------------------------------------------------------------------------------------------                
      
-----------------------------------------------------------------------------------------------------------------                
if @IsTwoPhaseStep = 0 begin                
-----------------------------------------------------------------------------------------------------------------                
                
if( @WorkTypeID = 3 ) begin  -- хранимая процедура                  
                    
  set @IsPrm = 0                  
  set @Cmd = 'exec ' + @ServerName + '.' + @DbName + '..' + @WorkName                  
                    
  -- обработка @DateFrom                  
  set @DateFrom = isnull( @DateFrom, 0 )                    
  -- по-новому флаг @IsNotWorkDay определяет - с рабочими(0) или календарными(1) днями работаем          
  if @IsNotWorkDay = 0 begin              
    set @d = dbo.fnGetWorkDay( @pOperDate, @DateFrom, 1 )                        
  end else begin                  
    set @d = @pOperDate + @DateFrom                  
  end           
  -- старая затычка          
  if @pBPID = 8 begin                  
    set @d = @pOperDate + @DateFrom                  
  end                    
  set @Cmd = @Cmd + case when @IsPrm > 0 then ',' else '' end + ' @pDate = ''' + convert( varchar(10), @d, 121 ) + ''''                  
  set @IsPrm = @IsPrm + 1                  
                    
  -- если без отката уже сделанного ( @pWithoutDelete )                  
  if( @WithoutDelete != 0 and @pStartType != -1 ) begin                      
    set @Cmd = @Cmd + case when @IsPrm > 0 then ',' else '' end + ' @pWithoutDelete = 1'                  
    set @IsPrm = @IsPrm + 1                  
  end                    
                    
  -- если откат сделанного ( @pIsOnlyDelete )                  
  if( @pStartType = -1 ) begin                      
    set @Cmd = @Cmd + case when @IsPrm > 0 then ',' else '' end + ' @pIsOnlyDelete = 1'                  
    set @IsPrm = @IsPrm + 1                  
  end                     
                    
  set @Cmd = @Cmd + case when @IsPrm > 0 then ',' else '' end + ' @pIsBP = 1, @SysUserInfo = ''' + isnull( @SysUserInfo, '' ) + ''''                  
  set @IsPrm = @IsPrm + 1                  
   
  set @State = case when @pStartType = -1 then @Rollbacking else @Working end

  if @State <> @CurState
  begin
                      
	  set @Msg = convert( varchar(max), 'Выполняем команду: ' + @Cmd )                  
	  exec spBPLog                   
	  @pOperDate  = @pOperDate,                   
	  @pBPID      = @pBPID,                   
	  @pStepID    = @pStepID,                   
	  @pState     = null,                   
	  @pDbUser    = null,                  
	  @pHost      = null,                  
	  @pIsError   = 0,                   
	  @pIsWarning = 0,                   
	  @pIsDebug   = 1,                  
	  @pMsg       = @Msg                  
                    
	  exec( @Cmd )                  
                    
  end                  
end                  
                
-----------------------------------------------------------------------------------------------------------------                
end -- @IsTwoPhaseStep = 0                  
-----------------------------------------------------------------------------------------------------------------                
                
-----------------------------------------------------------------------------------------------------------------                
if @IsTwoPhaseStep = 1 begin                
-----------------------------------------------------------------------------------------------------------------                
                
if( @WorkTypeID = 3 ) begin  -- хранимая процедура                  
                    
  set @IsPrm = 0                  
  set @Cmd1 = 'exec @ret = ' + @ServerName + '.' + @DbName + '..' + @WorkName                  
                    
  -- обработка @DateFrom                  
  set @DateFrom = isnull( @DateFrom, 0 )                    
  if @IsNotWorkDay = 0 begin              
    set @d = dbo.fnGetWorkDay( @pOperDate, @DateFrom, 1 )                        
  end else begin                  
    set @d = @pOperDate + @DateFrom                  
  end           
  if @pBPID = 8 begin                  
    set @d = @pOperDate + @DateFrom                  
  end                    
  set @Cmd1 = @Cmd1 + case when @IsPrm > 0 then ',' else '' end + ' @pDate = ''' + convert( varchar(10), @d, 121 ) + ''''                  
  set @IsPrm = @IsPrm + 1                         
                
  set @Cmd = @Cmd1 + case when @IsPrm > 0 then ',' else '' end + ' @pIsOnlyDelete = 1' + ', @pIsBP = 1, @SysUserInfo = ''' + isnull( @SysUserInfo, '' ) + ''''                  
  set @IsPrm = @IsPrm + 1                        
                
  -- если не заказывали откат и фаза 1 уже пройдена, то сразу идем на фазу 2              
  if @pStartType != -1 if @StepPhase = 1 goto Phase2                
                  
  set @Msg = convert( varchar(max), 'Выполняем команду (фаза 1): ' + @Cmd )                  
  exec spBPLog                   
    @pOperDate  = @pOperDate,                   
    @pBPID      = @pBPID,                   
    @pStepID    = @pStepID,                   
    @pState     = null,                   
    @pDbUser    = null,                  
    @pHost      = null,                  
    @pIsError   = 0,                   
    @pIsWarning = 0,                   
    @pIsDebug   = 1,                  
    @pMsg       = @Msg                  
                
  -- выполняем сформированную команду, забираем из нее код возврата                      
  exec sp_executesql @Cmd, N'@ret int output', @ret = @retcode output                
  if @retcode != 0 goto bye              
                
  -- обновляем фазу шага - если не заказывали откат, то ставим 1 (т.е. первая фаза прошла), если заказывали откат, то ставим NULL (т.е. шаг вообще стал в исходном)              
  update BPStepDayHistory set StepPhase = case when @pStartType = -1 then null else 1 end              
    where BPID = @pBPID and StepID = @pStepID and OperDate = @pOperDate                    
                  
  -- если заказывали только откат, то уходим              
  if @pStartType = -1 goto bye              
       
  Phase2:                
                
  set @Cmd = @Cmd1 + case when @IsPrm > 0 then ',' else '' end + ' @pWithoutDelete = 1' + ', @pIsBP = 1, @SysUserInfo = ''' + isnull( @SysUserInfo, '' ) + ''''                  
  set @IsPrm = @IsPrm + 1                        
                  
  set @Msg = convert( varchar(max), 'Выполняем команду (фаза 2): ' + @Cmd )                  
  exec spBPLog                   
    @pOperDate  = @pOperDate,                   
    @pBPID      = @pBPID,                   
    @pStepID    = @pStepID,                   
    @pState     = null,                   
    @pDbUser    = null,                  
    @pHost      = null,                  
    @pIsError   = 0,                   
    @pIsWarning = 0,                   
    @pIsDebug   = 1,                  
    @pMsg       = @Msg                  
                    
  -- выполняем сформированную команду, забираем из нее код возврата                      
  exec sp_executesql @Cmd, N'@ret int output', @ret = @retcode output                
  if @retcode != 0 goto bye              
  update BPStepDayHistory set StepPhase = 2 where BPID = @pBPID and StepID = @pStepID and OperDate = @pOperDate                
                    
end                  
                
-----------------------------------------------------------------------------------------------------------------                
end -- @IsTwoPhaseStep = 1                
-----------------------------------------------------------------------------------------------------------------                
              
bye:        
      
set @pRetCode = coalesce( @pRetCode, 0 )      
set @pRetMsg = coalesce( @pRetMsg, N'' )      
      
return @pRetCode            
              
end -- proc
