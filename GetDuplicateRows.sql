
IF OBJECT_ID('tempdb..#INNS') IS NOT NULL DROP TABLE #INNS;

select INN, count(*) as Qty
into #INNS
from ActorFRUFrameList
where IsClient = '1'
group by INN
having count(*) > 1;

select * from ActorFRUFrameList join
#INNS on ActorFRUFrameList.INN = #INNS.INN
order by code;


