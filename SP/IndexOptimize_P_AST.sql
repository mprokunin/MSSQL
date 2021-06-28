--drop procedure dbo.IndexOptimize_P_AST 

create procedure dbo.IndexOptimize_P_AST 
@Execute char(1) = 'Y'
as
begin
EXECUTE master.dbo.IndexOptimize
@Databases = 'P_AST',
@FragmentationLow = NULL,
@FragmentationMedium = 'INDEX_REORGANIZE,INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',
@FragmentationHigh = 'INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',
@UpdateStatistics = 'ALL',
@Indexes = 'P_AST.dbo._Document237
,P_AST.dbo._Document237_VT6826
,P_AST.dbo._AccRg9206       
,P_AST.dbo._AccRgAT09217               
,P_AST.dbo._AccRgAT19227               
,P_AST.dbo._AccRgAT29228               
,P_AST.dbo._AccRgAT39229               
,P_AST.dbo._AccRgED9231  
,P_AST.dbo._AccumRg9290 
,P_AST.dbo._AccumRgT9302              
,P_AST.dbo._AccumRgOpt9984         
,P_AST.dbo._AccumRg9303 
,P_AST.dbo._AccumRgT9315              
,P_AST.dbo._AccumRgOpt9985
,P_AST.dbo._AccumRg10868              
,P_AST.dbo._AccumRgT10885
,P_AST.dbo._AccumRgOpt10941
,P_AST.dbo._AccumRg10886              
,P_AST.dbo._AccumRgT10903            
,P_AST.dbo._AccumRgOpt10942                                      
,P_AST.dbo._AccumRg10904              
,P_AST.dbo._AccumRgTn10928         
,P_AST.dbo._AccumRgAggGridK10929           
,P_AST.dbo._AccumRgAggOptK10930
,P_AST.dbo._AccumRgAggDict1h10931
,P_AST.dbo._AccumRgAggDict2h10932
,P_AST.dbo._AccumRgAggDict3h10933
,P_AST.dbo._AccumRgAggDict4h10934
,P_AST.dbo._AccumRgAggDict5h10935
,P_AST.dbo._AccumRgAggDict6h10936
,P_AST.dbo._AccumRgAggDict7h10937
,P_AST.dbo._AccumRgSt10940
,P_AST.dbo._AccumRgOpt10943',
@OnlyModifiedStatistics = 'Y',
@LogToTable = 'Y',
@Execute = @Execute
end
go
grant exec on dbo.IndexOptimize_P_AST to public
go

--exec dbo.IndexOptimize_P_AST  @Execute = 'N'