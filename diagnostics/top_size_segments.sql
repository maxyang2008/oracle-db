-- query top segments
SELECT *
  FROM (SELECT S.OWNER,
               S.SEGMENT_NAME,
               S.SEGMENT_TYPE,
               ROUND(S.BYTES / 1024 / 1024 / 1024, 1) SIZE_GB
          FROM DBA_SEGMENTS S
         ORDER BY S.BYTES DESC)
 WHERE ROWNUM <= 10
