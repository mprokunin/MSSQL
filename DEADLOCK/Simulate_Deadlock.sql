
------------------- Simulate Deadlock ------------------- 
------------------- First window
create table ##temp1 (id int)
create table ##temp2 (id int)

insert ##temp1 values(1), (2), (3)

insert ##temp2 values(1), (2), (3)

begin transaction
   update ##temp1 set id = 4 where id = 1

   waitfor delay '00:00:20'

   update ##temp2 set id = 4 where id = 1
commit transaction

drop table ##temp1
drop table ##temp2


------------------- Second window
begin transaction
   update ##temp2 set id = 4 where id = 1

   waitfor delay '00:00:20'

   update ##temp1 set id = 4 where id = 1
commit transaction
