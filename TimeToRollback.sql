sp_helpdb [progress]

exec msdb..sp__Dbinfo 1
exec xp_fixeddrives
dbcc opentran(progress)
dbcc inputbuffer(112) -- (@P1 nvarchar(4000),@P2 numeric(38,0),@P3 datetimeoffset,@P4 datetimeoffset,@P5 nvarchar(4000),@P6 nvarchar(4000),@P7 nvarchar(4000),@P8 numeric(38,0),@P9 datetimeoffset,@P10 numeric(38,0),@P11 nvarchar(4000),@P12 numeric(38,0),@P13 numeric(38,0),@P14 float,@P15 numeric(38,0),@P16 float,@P17 numeric(38,0),@P18 float,@P19 nvarchar(4000),@P20 numeric(38,0),@P21 datetimeoffset,@P22 datetimeoffset,@P23 numeric(38,0),@P24 numeric(38,0),@P25 numeric(38,0),@P26 float,@P27 numeric(38,0),@P28 nvarchar(4000),@P29 numeric(38,0),@P30 numeric(38,0),@P31 numeric(38,0),@P32 numeric(38,0),@P33 nvarchar(4000),@P34 float,@P35 float,@P36 numeric(38,0),@P37 numeric(38,0),@P38 nvarchar(4000),@P39 nvarchar(4000),@P40 nvarchar(4000),@P41 datetimeoffset,@P42 datetimeoffset,@P43 numeric(38,0),@P44 datetimeoffset,@P45 numeric(38,0),@P46 nvarchar(4000),@P47 float,@P48 numeric(38,0),@P49 nvarchar(4000),@P50 numeric(38,0),@P51 float,@P52 numeric(38,0),@P53 datetimeoffset,@P54 numeric(38,0),@P55 numeric(38,0),@P56 numeric(38,0),@P57 numeric(38,0),@P58 numeric(38,0),@P59 nvarchar(4000),@P60 datetimeoffset,@P61 nvarchar(4000),@P62 nvarchar(4000),@P63 nvarchar(4000),@P64 numeric(38,0),@P65 float,@P66 float,@P67 nvarchar(4000),@P68 float,@P69 numeric(38,0),@P70 float,@P71 float,@P72 numeric(38,0),@P73 numeric(38,0),@P74 numeric(38,0),@P75 nvarchar(4000),@P76 numeric(38,0),@P77 numeric(38,0),@P78 numeric(38,0),@P79 datetimeoffset,@P80 nvarchar(4000),@P81 float,@P82 datetimeoffset,@P83 numeric(38,0),@P84 numeric(38,0),@P85 nvarchar(4000),@P86 nvarchar(4000),@P87 datetimeoffset,@P88 nvarchar(4000),@P89 float,@P90 float,@P91 numeric(38,0),@P92 nvarchar(4000),@P93 nvarchar(4000),@P94 numeric(38,0),@P95 float,@P96 numeric(38,0),@P97 float,@P98 nvarchar(4000),@P99 nvarchar(4000),@P100 numeric(38,0),@P101 numeric(38,0),@P102 nvarchar(4000),@P103 datetimeoffset,@P104 datetimeoffset,@P105 datetimeoffset,@P106 numeric(38,0),@P107 nvarchar(4000),@P108 nvarchar(4000),@P109 nvarchar(4000),@P110 numeric(38,0),@P111 numeric(38,0),@P112 numeric(38,0),@P113 float,@P114 nvarchar(4000),@P115 nvarchar(4000),@P116 nvarchar(4000),@P117 numeric(38,0),@P118 numeric(38,0),@P119 float,@P120 numeric(38,0),@P121 numeric(38,0),@P122 numeric(38,0),@P123 float,@P124 numeric(38,0),@P125 nvarchar(4000),@P126 numeric(38,0),@P127 nvarchar(4000),@P128 nvarchar(4000),@P129 numeric(38,0),@P130 nvarchar(4000),@P131 nvarchar(4000),@P132 nvarchar(4000),@P133 float,@P134 float,@P135 numeric(38,0),@P136 float,@P137 float,@P138 nvarchar(4000),
	--@P139 nvarchar(4000),@P140 float,@P141 numeric(38,0),@P142 numeric(38,0),@P143 nvarchar(4000),@P144 numeric(38,0),@P145 numeric(38,0),@P146 nvarchar(4000),@P147 float,@P148 float,@P149 nvarchar(4000),@P150 float,@P151 float,@P152 float,@P153 float,@P154 numeric(38,0),@P155 numeric(38,0),@P156 numeric(38,0),@P157 numeric(38,0),@P158 float,@P159 float,@P160 float,@P161 float,@P162 float,@P163 float,@P164 float,@P165 numeric(38,0),@P166 nvarchar(4000),@P167 numeric(38,0),@P168 numeric(38,0),@P169 numeric(38,0),@P170 numeric(38,0),@P171 nvarchar(4000),@P172 nvarchar(4000),@P173 numeric(38,0),@P174 nvarchar(4000),@P175 nvarchar(4000),@P176 nvarchar(4000),@P177 nvarchar(4000),@P178 nvarchar(4000),@P179 nvarchar(4000),@P180 nvarchar(4000),@P181 nvarchar(4000),@P182 nvarchar(4000),@P183 nvarchar(4000),@P184 nvarchar(4000),@P185 numeric(38,0),@P186 nvarchar(4000),@P187 nvarchar(4000),@P188 datetimeoffset,@P189 numeric(38,0),@P190 nvarchar(4000),@P191 nvarchar(4000),@P192 nvarchar(4000),@P193 nvarchar(4000),@P194 nvarchar(4000),@P195 numeric(38,0),@P196 numeric(38,0),@P197 numeric(38,0),@P198 nvarchar(4000),@P199 numeric(38,0),@P200 numeric(38,0))
	--update progress.dbo.DSAS_QUOTATION_MAIN  set  DWH_CDC_OPERTYPE = @P1 ,  DWH_PROCESS_ID = @P2 ,  DWH_TIME_UPDATE = @P3 ,  DWH_FACT_DATE = @P4 ,  DWH_INTEGRATION_ID = @P5 ,  DWH_INC_STATE = @P6 ,  DWH_SOURCE_CODE = @P7 ,  DWH_ID = @P8 ,  DWH_SOURCE_UPDATE_DATE = @P9 ,  PRINTSTATUS = @P10 ,  P_OSAGO_PREV_NUMBER = @P11 ,  Q_REPAIR_3_PERC
use progress
sp_spaceused DSAS_QUOTATION_MAIN
sp_who 112
select * from sys.sysprocesses where spid = 112 or blocked > 0

-- Estimate completion
SELECT R.session_id, 
R.percent_complete, R.total_elapsed_time/1000 AS elapsed_secs, R.wait_type,R.wait_time,R.last_wait_type,
DATEADD(s,100/((R.percent_complete)/ (R.total_elapsed_time/1000)), R.start_time) estim_completion_time,
ST.text, SUBSTRING(ST.text, R.statement_start_offset / 2, 
 (
 CASE WHEN R.statement_end_offset = -1 THEN DATALENGTH(ST.text)
 ELSE R.statement_end_offset
 END - R.statement_start_offset 
 ) / 2
) AS statement_executing
FROM sys.dm_exec_requests R
CROSS APPLY sys.dm_exec_sql_text(R.sql_handle) ST
WHERE  R.percent_complete > 0
--and R.command = 'KILLED/ROLLBACK'
--AND R.session_id <> @@spid
AND R.session_id = 83
AND R.session_id <> @@spid
OPTION(RECOMPILE);
