CREATE VIEW [dbo].[PartitionRanges] AS
select pf.name as [partition_function],
       ps.name as [partition_scheme],
       1 as [partition_number],
       case when prv.value is null then NULL else '<' end as [relation],
       prv.value as [boundary_value],
       type_name(pp.system_type_id) as [type],
       fg.name as [filegroup],
       case when ps.name is null then NULL else N'IN USE' end as [status]
  from sys.partition_functions pf
  join sys.partition_parameters pp on pp.function_id = pf.function_id
  left join sys.partition_schemes ps on ps.function_id = pf.function_id
  left join sys.destination_data_spaces dds
    on dds.partition_scheme_id = ps.data_space_id and dds.destination_id = 1 
  left join sys.filegroups fg on fg.data_space_id = dds.data_space_id
  left join sys.partition_range_values prv
    on prv.function_id = pf.function_id and prv.parameter_id = 1 and
       prv.boundary_id = 1
 where pf.boundary_value_on_right = 1
 union all
select pf.name as [partition_function],
       ps.name as [partition_scheme],
       prv.boundary_id + cast(pf.boundary_value_on_right as int) as [partition_number],
       case when pf.boundary_value_on_right = 0 then '<=' else '>=' end as [relation],
       prv.value as [boundary_value],
       type_name(pp.system_type_id) as [type],
       fg.name as [filegroup],
       case when ps.name is null then NULL else N'IN USE' end as [status]
  from sys.partition_functions pf
  join sys.partition_range_values prv on
       prv.function_id = pf.function_id and prv.parameter_id = 1
  join sys.partition_parameters pp on pp.function_id = pf.function_id
  left join sys.partition_schemes ps on ps.function_id = pf.function_id
  left join sys.destination_data_spaces dds
    on dds.partition_scheme_id = ps.data_space_id and
       dds.destination_id = prv.boundary_id + cast(pf.boundary_value_on_right as int)
  left join sys.filegroups fg on fg.data_space_id = dds.data_space_id
 union all
select pf.name as [partition_function],
       ps.name as [partition_scheme],
       pf.fanout as [partition_number],
       case when prv.value is null then NULL else '>' end as [relation],
       prv.value as [boundary_value],
       type_name(pp.system_type_id) as [type],
       fg.name as [filegroup],
       case when ps.name is null then NULL else N'IN USE' end as [status]
  from sys.partition_functions pf
  join sys.partition_parameters pp on pp.function_id = pf.function_id
  left join sys.partition_schemes ps on ps.function_id = pf.function_id
  left join sys.destination_data_spaces dds
    on dds.partition_scheme_id = ps.data_space_id and dds.destination_id = pf.fanout 
  left join sys.filegroups fg on fg.data_space_id = dds.data_space_id
  left join sys.partition_range_values prv
    on prv.function_id = pf.function_id and prv.parameter_id = 1 and
       prv.boundary_id = pf.fanout - 1
 where pf.boundary_value_on_right = 0
 union all
select pf.name as [partition_function],
       ps.name as [partition_scheme],
       NULL, NULL, NULL, NULL,
       fg.name as [filegroup],
       case when dds.destination_id = pf.fanout + 1
            then N'NEXT USED' else N'NOT USED'
       end as [status]
  from sys.partition_functions pf
  join sys.partition_schemes ps on ps.function_id = pf.function_id
  join sys.destination_data_spaces dds
    on dds.partition_scheme_id = ps.data_space_id and
       dds.destination_id > pf.fanout
  join sys.filegroups fg on fg.data_space_id = dds.data_space_id 
go



select * from PartitionRanges