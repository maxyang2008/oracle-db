select 'alter system kill session ' || chr(39) || S.SID || ',' || S.SERIAL# ||
       chr(39) || ';'
  FROM GV$SESSION S
 WHERE S.INST_ID = 2
   AND S.TYPE <> 'BACKGROUND'
   AND S.STATUS = 'ACTIVE'
   AND MACHINE = 'jtdbalogvpra02'
;


SELECT * FROM GV$SESSION S
WHERE 1=1
-- AND S.EVENT = 'latch: row cache objects'
AND S.PROGRAM = 'hydeews_Clinet-8.exe'
;
