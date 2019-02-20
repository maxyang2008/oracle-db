select *
  from gv$session s
 where s.inst_id = 1
   and s.sid in (5181, 6024, 6537, 12541, 14042, 14054, 14367)
union all
select *
  from gv$session s
 where s.inst_id = 2
   and s.sid in (6711, 7540, 108
   66, 11357, 13882, 14889, 15390)
