SELECT aa.inst_id          被阻实例,
       aa.sid              被阻会话,
       aa.sql_text         被阻sql,
       aa.module           被阻模块,
       aa.event            事件,
       bb.inst_id          阻实例,
       bb.blocking_session 阻会话,
       bb.sql_text         阻sql
  from (SELECT distinct a.sid,
                        a.sql_id,
                        a.inst_id,
                        a.blocking_instance,
                        a.blocking_session,
                        s.sql_text,
                        a.module,
                        a.event
          FROM gv$session a, gv$sql s
         where a.sql_id = s.sql_id
           and a.blocking_session is not null) aa
 INNER JOIN (SELECT distinct a.sid,
                             a.sql_id,
                             a.inst_id,
                             a.blocking_instance,
                             a.blocking_session,
                             s.sql_text,
                             a.module,
                             a.event,
                             a.event
               FROM gv$session a, gv$sql s
              where a.sql_id = s.sql_id) bb
    ON a.blocking_session = b.sid
   and a.blocking_instance = b.inst_id;
