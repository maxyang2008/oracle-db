select trunc(COMPLETION_TIME, 'HH') Hour,
       thread#,
       round(sum(BLOCKS * BLOCK_SIZE) / 1024 / 1024 / 1024) GB,
       count(*) Archives
  from gv$archived_log
 where 1=1
   AND COMPLETION_TIME >
       TO_DATE('2018-12-25 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
 group by trunc(COMPLETION_TIME, 'HH'), thread#
 order by 1;



WITH L1 AS
 (SELECT TO_CHAR(TRUNC(L.FIRST_TIME, 'HH24'), 'yyyy-mm-dd hh24:mi:ss') AS SWITCH_HOUR,
         SUM(decode(THREAD#, 1, 1, NULL)) COUNT1,
         SUM(decode(THREAD#, 2, 1, NULL)) COUNT2
    FROM GV$LOG_HISTORY L
   GROUP BY TRUNC(L.FIRST_TIME, 'HH24')),
T AS
 (SELECT LEVEL AS SEQ,
         TO_CHAR(TRUNC(SYSDATE, 'HH24') - LEVEL / 24,
                 'YYYY-MM-DD HH24:MI:SS') AS SWITCH_HOUR
    FROM DUAL
  CONNECT BY LEVEL < 24 * 10)
SELECT T.SWITCH_HOUR TIME_HOUR,
       NVL(L1.COUNT1, 0) SWITCH_TIMES1,
       NVL(L1.COUNT2, 0) SWITCH_TIMES2
  FROM T, L1
 WHERE T.SWITCH_HOUR = L1.SWITCH_HOUR(+)
 ORDER BY TIME_HOUR;
