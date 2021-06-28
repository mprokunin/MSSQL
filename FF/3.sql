--Структура
if schema_id('TestCars') is null
  exec('create schema [TestCars]')
go

if object_id('[TestCars].[Points]') is null
  -- Точки
  create table [TestCars].[Points]
  (
    [Id]          int     not null identity(1,1),
    [Type_Id]     char(1) not null,               -- тип точки: D = Склад; S = Магазин
    primary key clustered ([Id]),
    check ([Type_Id] in ('D', 'S'))
  )
go

if object_id('[TestCars].[Cars]') is null
  -- Машины
  create table [TestCars].[Cars]
  (
    [Id]          int     not null identity(1,1),
    [Capacity]    int     not null,               -- Грузоподьемность
    primary key clustered ([Id])
  )
go

if object_id('[TestCars].[Routes]') is null
  -- Машины
  create table [TestCars].[Routes]
  (
    [Id]            int       not null identity(1,1),
    [Point_Id]      int       not null,
    [Car_Id]        int       not null,
    [Load]          int       not null,               -- Изменение загрузки авто при посещении данной точки. +N = в авто дозагрузили N кг; -N = из машины выгрузили N кг
                                                      -- При этом в магазине точка разгружается, а при посещении склада загружается/дозагружается
    [ArrivalTime]   datetime  not null,
    [DepartureTime] datetime  not null,
    primary key clustered ([Id]),
    foreign key ([Point_Id]) references [TestCars].[Points] ([Id]),
    foreign key ([Car_Id]) references [TestCars].[Cars] ([Id])
  )
go
/*
Есть таблица точек [TestCars].[Points]. Точками являются склады или магазины.
Есть таблица машин [TestCars].[Cars]. У каждой машины может быть своя грузоподъемность.
Есть точки маршрута машин [TestCars].[Routes], которые посещены машинами.
В течение дня машина совершает несколько поездок по маршрутам. Каждая поездка начинается с загрузки машины на складе. Далее машина посещает несколько магазинов, в каждом из которых частично разгружается. Затем машина может прибыть на один из складов, дозагрузиться и начать следующий маршрут. Каждый маршрут всегда проезжается в течение одного календарного дня (нет поездок по маршрутам с началом и концом в разных днях).
Машина движется всегда с одной и той же скоростью, скорости разных машин могут отличаться. По одному и тому же маршруту может проехать несколько различных машин. Маршрут – последовательность точек типа Склад-Магазин-…-Магазин.

Задание
1. найти топ-3 неэффективных маршрутов и топ-3 неэффективных машин по каждому из критериев:
1.1. Недозагруженность машины, т.е. отношение «загрузка машины/грузоподъемность» после выезда со склада в начале маршрута
1.2. Размер остатка в машине после посещения всех магазинов на маршруте
2. Найти самую быструю машину, когда это возможно. Когда невозможно – дать ошибку.
*/

insert into [TestCars].[Cars] values (10);
insert into [TestCars].[Cars] values (20);
insert into [TestCars].[Cars] values (30);
select * from [TestCars].[Cars]
update [TestCars].[Cars] set Capacity = 100 where Id = 1;
update [TestCars].[Cars] set Capacity = 200 where Id = 2;
update [TestCars].[Cars] set Capacity = 300 where Id = 3;

insert into [TestCars].[Points] values ('D');
insert into [TestCars].[Points] values ('D');
insert into [TestCars].[Points] values ('S');
insert into [TestCars].[Points] values ('S');
insert into [TestCars].[Points] values ('S');
select * from [TestCars].[Points]

truncate table [TestCars].[Routes];
insert into [TestCars].[Routes] values (1,1,100,'2021-06-07 08:00:00','2021-06-07 09:00:00');
insert into [TestCars].[Routes] values (3,1,-30,'2021-06-07 10:00:00','2021-06-07 11:00:00');
insert into [TestCars].[Routes] values (4,1,-60,'2021-06-07 12:00:00','2021-06-07 13:00:00');
insert into [TestCars].[Routes] values (2,1,40,'2021-06-07 15:00:00','2021-06-07 16:00:00');
insert into [TestCars].[Routes] values (4,1,-20,'2021-06-07 19:00:00','2021-06-07 20:00:00');

insert into [TestCars].[Routes] values (1,2,200,'2021-06-07 09:00:00','2021-06-07 10:00:00');
insert into [TestCars].[Routes] values (5,2,-100,'2021-06-07 16:00:00','2021-06-07 17:00:00');
insert into [TestCars].[Routes] values (4,2,-50,'2021-06-07 19:00:00','2021-06-07 20:00:00');


insert into [TestCars].[Routes] values (2,3,250,'2021-06-07 08:00:00','2021-06-07 09:00:00');
insert into [TestCars].[Routes] values (4,3,-100,'2021-06-07 13:30:00','2021-06-07 14:00:00');
insert into [TestCars].[Routes] values (3,3,-100,'2021-06-07 15:30:00','2021-06-07 16:00:00');
insert into [TestCars].[Routes] values (5,3,-50,'2021-06-07 19:00:00','2021-06-07 19:30:00');

select * from [TestCars].[Routes]


--1.1 Недозагруженность
--drop table #Rt;
create table #Rt (
Id int not null,
Car_Id int not null,
Eff numeric(3,2) not null,
Rem int not null,
Dsc varchar(max) not null
)
--drop table #CurCarRt;
create table #CurCarRt (
Id int not null,
Car_Id int not null
)

insert into #Rt (Id,Car_Id,Eff,Rem,Dsc)
select  r.Id, c.Id,1.0*r.Load/c.Capacity,0,CONVERT(varchar(10), r.Point_Id)
from [TestCars].[Routes] r join [TestCars].[Cars] c
on c.Id = r.Car_Id
where r.Load > 0;

declare @Id int, @Car_Id int, @Load int, @Point_Id int, @PrevRem int
DECLARE r_cursor CURSOR FOR   
    select Id,Car_Id,Load,Point_Id from [TestCars].[Routes] order by ArrivalTime
	for read only
OPEN r_cursor  
FETCH NEXT FROM r_cursor INTO @Id, @Car_Id, @Load, @Point_Id
WHILE @@FETCH_STATUS = 0  
BEGIN
if (@Load > 0)
	begin
	--Считаем, что в начале маршрута машина содержми остаток с предыдущего маршрута 
	select @PrevRem = Rem from #Rt r join #CurCarRt c on
	r.Id = c.Id and r.Car_Id = c.Car_Id
	where c.Car_Id = @Car_Id

	delete from #CurCarRt where Car_Id = @Car_Id
	insert into #CurCarRt (Id, Car_Id) values (@Id, @Car_Id)
	update #Rt set Rem = Rem + @Load + coalesce(@PrevRem,0) where Id = @Id and Car_Id = @Car_Id
	end
else
	update #Rt set Rem = r.Rem + @Load, Dsc = Dsc + '->' + CONVERT(varchar(10), @Point_Id)
	from #Rt r join #CurCarRt c on
	r.Id = c.Id and r.Car_Id = c.Car_Id
	where c.Car_Id = @Car_Id
FETCH NEXT FROM r_cursor INTO @Id, @Car_Id, @Load, @Point_Id
END
CLOSE r_cursor; 
deallocate r_cursor
--select * from [TestCars].[Routes] where Car_Id = 1 order by ArrivalTime
select top 3 Eff as 'Efficiency', Dsc as 'Route', Car_Id 
	from #Rt order by Eff;
select top 3 min(Eff) as 'Efficiency', Car_Id from #Rt group by CAR_id order by 1

--1.2 Остаток
select Car_Id, Rem as 'Remained', Dsc as 'Route' from #Rt order by 1,3;

--2. Самая Быстрая
--drop table #Seg;
create table #Seg (
id int null,
st int not null,
fn int null,
car int not null,
dep datetime not null,
arr datetime null,
tmp int null
)

declare @old_start int = 0, @old_id int = 0, @rId int, 
	@rPoint_Id int, @rCar_Id int, @rLoad int, @Arrival datetime, @Departure datetime
DECLARE s_cursor CURSOR FOR   
    select Id,Point_Id,Car_Id,Load,ArrivalTime,DepartureTime from [TestCars].[Routes] order by Car_Id, ArrivalTime
	for read only
OPEN s_cursor  
FETCH NEXT FROM s_cursor INTO @rId, @rPoint_Id, @rCar_Id, @rLoad, @Arrival, @Departure
WHILE @@FETCH_STATUS = 0  
BEGIN
insert into #Seg (id,st,car,dep) values (@rId,@rPoint_Id,@rCar_Id,@Departure)
if (@Load < 0 and @old_id > 0)
	update #Seg set fn = @rPoint_Id, arr = @Arrival where id = @old_id
set @old_id = @rId
FETCH NEXT FROM s_cursor INTO @rId, @rPoint_Id, @rCar_Id, @rLoad, @Arrival, @Departure
END
CLOSE s_cursor; 
deallocate s_cursor;

delete #Seg where fn is null
update #Seg set tmp = st where st > fn
update #Seg set st = fn, fn = tmp where st > fn

declare @car_cnt int
select @car_cnt = count (Id) from [TestCars].[Cars]
--drop table #Win;
create table #Win (
st int,
fn int,
cnt int
)

insert into #Win
select top 1 st, fn, count(car) from #Seg group by st, fn having count(car) = @car_cnt
if exists (select 1 from #Win) 
begin	
	select 1.0/DATEDIFF(mi,s.dep,s.arr) as 'Speed',s.car--,s.st,s.fn 
	from #Seg s
	join #Win w on w.st = s.st and w.fn = s.fn
	order by 1 desc,2
end
else 
select 'Failed to find fastest car' as 'Answer';



