select n.NAME, s.*
  from gv$sesstat s, v$statname n
 where s.STATISTIC# = n.STATISTIC#
   and n.name like '%physical read bytes%'
 order by s.VALUE desc;
