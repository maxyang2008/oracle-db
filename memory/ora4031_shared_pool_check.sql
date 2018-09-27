REM srdc_db_ora4031sp.sql - Collect information for ORA-4031 analysis on shared pool
define SRDCNAME='DB_ORA4031SP'
SET MARKUP HTML ON PREFORMAT ON
set TERMOUT off FEEDBACK off VERIFY off TRIMSPOOL on HEADING off
COLUMN SRDCSPOOLNAME NOPRINT NEW_VALUE SRDCSPOOLNAME
select 'SRDC_'||upper('&&SRDCNAME')||'_'||upper(instance_name)||'_'||
       to_char(sysdate,'YYYYMMDD_HH24MISS') SRDCSPOOLNAME from v$instance;
set TERMOUT on MARKUP html preformat on
REM
spool &SRDCSPOOLNAME..htm
select '+----------------------------------------------------+' from dual
union all
select '| Diagnostic-Name: '||'&&SRDCNAME' from dual
union all
select '| Timestamp:       '||
       to_char(systimestamp,'YYYY-MM-DD HH24:MI:SS TZH:TZM') from dual
union all
select '| Machine:         '||host_name from v$instance
union all
select '| Version:         '||version from v$instance
union all
select '| DBName:          '||name from v$database
union all
select '| Instance:        '||instance_name from v$instance
union all
select '+----------------------------------------------------+' from dual
/
set HEADING on MARKUP html preformat off
REM === -- end of standard header -- ===
REM
SET PAGESIZE 9999
SET LINESIZE 256
SET TRIMOUT ON
SET TRIMSPOOL ON
COL 'Total Shared Pool Usage' FORMAT 99999999999999999999999
COL bytes FORMAT 999999999999999
COL current_size FORMAT 999999999999999
COL name FORMAT A40
COL value FORMAT A20
ALTER SESSION SET nls_date_format='DD-MON-YYYY HH24:MI:SS';

SET MARKUP HTML ON PREFORMAT ON

/* Database identification */
SET HEADING OFF
SELECT '**************************************************************************************************************' FROM dual
UNION ALL
SELECT 'Database identification:' FROM dual
UNION ALL
SELECT '**************************************************************************************************************' FROM dual;
SET HEADING ON
SELECT name, platform_id, database_role FROM v$database;
SELECT * FROM v$version WHERE banner LIKE 'Oracle Database%';

/* Current instance parameter values */
SET HEADING OFF
SELECT '**************************************************************************************************************' FROM dual
UNION ALL
SELECT 'Current instance parameter values:' FROM dual
UNION ALL
SELECT '**************************************************************************************************************' FROM dual;
SET HEADING ON
SELECT n.ksppinm name, v.KSPPSTVL value
FROM x$ksppi n, x$ksppsv v
WHERE n.indx = v.indx
AND (n.ksppinm LIKE '%shared_pool%' OR n.ksppinm IN ('_kghdsidx_count', '_ksmg_granule_size', '_memory_imm_mode_without_autosga'))
ORDER BY 1;

/* Current memory settings */
SET HEADING OFF
SELECT '**************************************************************************************************************' FROM dual
UNION ALL
SELECT 'Current instance parameter values:' FROM dual
UNION ALL
SELECT '**************************************************************************************************************' FROM dual;
SET HEADING ON
SELECT component, current_size FROM v$sga_dynamic_components;

/* Memory resizing operations */
SET HEADING OFF
SELECT '**************************************************************************************************************' FROM dual
UNION ALL
SELECT 'Memory resizing operations:' FROM dual
UNION ALL
SELECT '**************************************************************************************************************' FROM dual;
SET HEADING ON
SELECT start_time, end_time, component, oper_type, oper_mode, initial_size, target_size, final_size, status
FROM v$sga_resize_ops
ORDER BY 1, 2;

/* Historical memory resizing operations */
SET HEADING OFF
SELECT '**************************************************************************************************************' FROM dual
UNION ALL
SELECT 'Historical memory resizing operations:' FROM dual
UNION ALL
SELECT '**************************************************************************************************************' FROM dual;
SET HEADING ON
SELECT start_time, end_time, component, oper_type, oper_mode, initial_size, target_size, final_size, status
FROM dba_hist_memory_resize_ops
ORDER BY 1, 2;

/* Shared pool 4031 information */
SET HEADING OFF
SELECT '**************************************************************************************************************' FROM dual
UNION ALL
SELECT 'Shared pool 4031 information:' FROM dual
UNION ALL
SELECT '**************************************************************************************************************' FROM dual;
SET HEADING ON
SELECT request_failures, last_failure_size FROM v$shared_pool_reserved;

/* Shared pool reserved 4031 information */
SET HEADING OFF
SELECT '**************************************************************************************************************' FROM dual
UNION ALL
SELECT 'Shared pool reserved 4031 information:' FROM dual
UNION ALL
SELECT '**************************************************************************************************************' FROM dual;
SET HEADING ON
SELECT requests, request_misses, free_space, avg_free_size, free_count, max_free_size FROM v$shared_pool_reserved;

/* Shared pool memory allocations by size */
SET HEADING OFF
SELECT '**************************************************************************************************************' FROM dual
UNION ALL
SELECT 'Shared pool memory allocations by size:' FROM dual
UNION ALL
SELECT '**************************************************************************************************************' FROM dual;
SET HEADING ON
SELECT name, bytes FROM v$sgastat WHERE pool = 'shared pool' AND (bytes > 999999 OR name = 'free memory') ORDER BY bytes DESC;

/* Total shared pool usage */
SET HEADING OFF
SELECT '**************************************************************************************************************' FROM dual
UNION ALL
SELECT 'Total shared pool usage:' FROM dual
UNION ALL
SELECT '**************************************************************************************************************' FROM dual;
SET HEADING ON
SELECT SUM(bytes) "Total Shared Pool Usage" FROM v$sgastat WHERE pool = 'shared pool' AND name != 'free memory';

/* Cursor sharability problems */
/* This version is for >= 10g; for <= 9i substitute ss.kglhdpar for ss.address!!!! */
SET HEADING OFF
SELECT '**************************************************************************************************************' FROM dual
UNION ALL
SELECT 'Cursor sharability problems (this version is for >= 10g; for <= 9i substitute ss.kglhdpar for ss.address!!!!):' FROM dual
UNION ALL
SELECT '**************************************************************************************************************' FROM dual;
SET HEADING ON
SELECT sa.sql_text,sa.version_count,ss.*
FROM v$sqlarea sa,v$sql_shared_cursor ss
WHERE sa.address=ss.address AND sa.version_count > 50
ORDER BY sa.version_count ;

SPOOL OFF
EXIT