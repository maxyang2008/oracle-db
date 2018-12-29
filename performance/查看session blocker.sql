SELECT a.inst_id          blocked_instance,
       a.sid              blocked_sid,
       a.blocking_session,
       b.inst_id          blocking_instance,
       a.sql_text         blocked_sql,
       b.sql_text         blocking_sql
  from (SELECT distinct a.sid,
                        a.sql_id,
                        a.inst_id,
                        a.blocking_instance,
                        a.blocking_session,
                        s.sql_text,
                        a.module
          FROM gv$session a, gv$sql s
         where a.sql_id = s.sql_id
           and a.blocking_session is not null) a
 INNER JOIN (SELECT distinct a.sid,
                             a.sql_id,
                             a.inst_id,
                             a.blocking_instance,
                             a.blocking_session,
                             s.sql_text,
                             a.module
               FROM gv$session a, gv$sql s
              where a.sql_id = s.sql_id) b
    ON a.blocking_session = b.sid
   and a.blocking_instance = b.inst_id;
