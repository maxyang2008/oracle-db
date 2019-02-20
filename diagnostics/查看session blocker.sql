SELECT aa.inst_id          ����ʵ��,
       aa.sid              ����Ự,
       aa.sql_text         ����sql,
       aa.module           ����ģ��,
       aa.event            �¼�,
       bb.inst_id          ��ʵ��,
       bb.blocking_session ��Ự,
       bb.sql_text         ��sql
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
