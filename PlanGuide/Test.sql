sp_help 
create table xmike_tab1 (col1 int, col2 varchar(10))
insert into xmike_tab1 values (1, 'aaa')
insert into xmike_tab1 values (2, 'bbb')
insert into xmike_tab1 values (3, 'ccc')
create clustered index xmike_idx1 on xmike_tab1 (col1)

-- Bad
EXEC sp_create_plan_guide   
    @name =  N'Guide1',  
    @stmt = N'SELECT T1.col2 from xmike_tab1 T1 where T1.col1 = @P1',  
    @type = N'SQL',  
    @module_or_batch = NULL,  
    @params = '	@P1 int',  
    @hints = N'OPTION (OPTIMIZE FOR (	@P1=1	))';  

-- Good
DECLARE @stmt nvarchar(max);
DECLARE @params nvarchar(max);
EXEC sp_get_query_template 
    N'SELECT T1.col2 from xmike_tab1 T1 where T1.col1 = 1',
    @stmt OUTPUT, 
    @params OUTPUT;
select @stmt
select @params
EXEC sp_create_plan_guide 
    @name = N'TemplateGuide1', 
    @stmt = @stmt, 
    @type = N'TEMPLATE', 
    @module_or_batch = NULL, 
    @params = @params, 
    @hints = N'OPTION(PARAMETERIZATION FORCED)';

-- bad
EXEC sp_create_plan_guide   
    @name = N'TemplateGuide2',  
    @stmt = N'SELECT T1.col2 from xmike_tab1 T1 where T1.col1 = @0',  
    @type = N'TEMPLATE',  
    @module_or_batch = NULL,  
    @params = N'@0 int',  
    @hints = N'OPTION(PARAMETERIZATION FORCED)';

use test_ast
SELECT * FROM sys.plan_guides
EXEC sp_control_plan_guide N'DROP', N'TemplateGuide1'
--EXEC sp_control_plan_guide N'ENABLE', N'Guide1'
SELECT * FROM sys.plan_guides 	CROSS APPLY sys.fn_validate_plan_guide (plan_guide_id) WHERE name = 'TemplateGuide1'


use test_ast
declare @P0 int =2;
select T1.col2 from xmike_tab1 T1 where  T1.col1 = @P0

exec sp_executesql N'SELECT T1.col2 from xmike_tab1 T1 where T1.col1 = @P1',N'@P1 int', 2
exec sp_executesql N'select T1.col2 from xmike_tab1 T1 where T1.col1 =3'

select T1.col2 from xmike_tab1 T1 where T1.col1 =5


