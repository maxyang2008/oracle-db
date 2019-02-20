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
