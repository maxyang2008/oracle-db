select p.spid, s.MACHINE, s.PROGRAM, s.*
  from gv$session s, gv$process p
 where s.inst_id = p.inst_id
   and s.PADDR = p.addr
   and s.INST_ID = 1
   and s.type <> 'BACKGROUND'
   and s.status = 'ACTIVE'
   and p.spid in
       (159562, 116230, 159898, 159480, 158783, 158902, 160099, 159902)
