SELECT S1.SID,
       S1.USERNAME,
       S1.PROGRAM,
       S1.MODULE,
       S1.EVENT,
       S1.STATE,
       S1.SECONDS_IN_WAIT,
       S2.SID               造成锁SID,
       S2.USERNAME          造成锁USERNAME,
       S2.PROGRAM           造成锁PROGRAM,
       S2.MODULE            造成锁MODULE,
       S2.CLIENT_IDENTIFIER 造成锁用户识别,
       O.OWNER              锁的对象OWNER,
       O.OBJECT_NAME        锁的对象,
       S2.SQL_ID            造成锁SQL_ID,
       S2.PREV_SQL_ID       造成锁上次SQL_ID
  FROM V$SESSION S1, V$LOCKED_OBJECT LO, V$SESSION S2, DBA_OBJECTS O
 WHERE S1.BLOCKING_SESSION = S2.SID
   AND LO.SESSION_ID = S2.SID
   AND LO.OBJECT_ID = O.OBJECT_ID
   ;
