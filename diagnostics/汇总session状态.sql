select s.INST_ID, s.EVENT, s.STATE, count(*)
  from gv$session s
 where type <> 'BACKGROUND'
   and status = 'ACTIVE'
   and state = 'WAITING'
 group by s.INST_ID, s.EVENT, s.STATE
 order by 2, 3, 4 desc
;



SELECT INST_ID,
       EVENT,
       DECODE(STATE,
              'WAITED SHORT TIME',
              'ON CPU',
              'WAITED KNOWN TIME',
              'ON CPU',
              STATE) ״̬,
       COUNT(*)
  FROM GV$SESSION S
 WHERE S.STATUS = 'ACTIVE'
   AND S.TYPE <> 'BACKGROUND'
   AND EVENT NOT IN ('Streams AQ: waiting for messages in the queue',
                     'Streams capture: waiting for archive log',
                     'PL/SQL lock timer')
 GROUP BY INST_ID, EVENT, STATE
 ORDER BY 1, 3
;
