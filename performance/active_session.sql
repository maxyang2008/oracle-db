SET LINESIZE 250
SET PAGESIZE 200
COL PROGRAM FOR A25
COL MODULE FOR A25
COL EVENT FOR A50
COL STATE FOR A20
COL MACHINE FOR A30

SELECT SID, SERIAL# , SQL_ID, MACHINE, PROGRAM, MODULE, EVENT, STATE FROM V$SESSION
WHERE
STATUS = 'ACTIVE'
AND TYPE <> 'BACKGROUND'
ORDER BY 1
/
