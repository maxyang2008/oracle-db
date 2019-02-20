-- 检查表空间使用率
SELECT a.tablespace_name,
       a.bytes / 1024 / 1024 / 1024 "total(GB)",
       b.bytes / 1024 / 1024 / 1024 "used(GB)",
       c.bytes / 1024 / 1024 / 1024 "free(GB)",
       (b.bytes * 100) / a.bytes "% USED ",
       (c.bytes * 100) / a.bytes "% FREE "
  FROM sys.sm$ts_avail a, sys.sm$ts_used b, sys.sm$ts_free c
 WHERE a.tablespace_name = b.tablespace_name
   AND a.tablespace_name = 'APPS_TS_TX_DATA'
   AND a.tablespace_name = c.tablespace_name;

--检查最大表占用的空间
SELECT segment_name, SUM(bytes) / 1024 / 1024 / 1024 "Byte(GB)" --258576
  FROM dba_segments
 WHERE segment_name IN
       (SELECT l.table_name
          FROM cux_arch_header h, cux_arch_lines l
         WHERE h.header_id = l.header_id
           AND h.application_short_code LIKE 'SFYHWM%')
 GROUP BY segment_name
 ORDER BY SUM(bytes) DESC;

--检查锁表情况，不存在该模块的表被锁表情况下才可以运行降低高水位
SELECT t2.username,
       t2.sid,
       t2.serial#,
       t3.object_name,
       t2.osuser,
       t2.machine,
       t2.program,
       t2.logon_time,
       t2.command,
       t2.lockwait,
       t2.saddr,
       t2.paddr,
       t2.taddr,
       t2.sql_address,
       t1.locked_mode
  FROM v$locked_object t1, v$session t2, dba_objects t3
 WHERE t1.session_id = t2.sid
   AND t1.object_id = t3.object_id
   AND t3.object_name IN
       (SELECT l.table_name
          FROM cux_arch_lines l, cux_arch_header h
         WHERE h.header_id = l.header_id
           AND h.application_short_code LIKE 'SFYHWM%')
 ORDER BY t2.logon_time;

--降低高水位
--第一个参数是要处理的模块，比如WIP,PAC,INV
--第二个参数是表名，可以为空，则该模块所列的表将会全部降低高水位
--第三个是后台JOB运行的开始时间
/*
BEGIN
  cux_arch_high_water_mark_pkg.run_job_back(p_schema     => 'SFYHWM1',
                                            p_table_name => NULL,
                                            p_begin_date => to_date('2015-04-17 11:00:00',
                                                                    'YYYY-MM-DD HH24:MI:SS')); 
                                                                    
  cux_arch_high_water_mark_pkg.run_job_back(p_schema     => 'SFYHWM2',
                                            p_table_name => NULL,
                                            p_begin_date => to_date('2015-04-17 11:00:00',
                                                                    'YYYY-MM-DD HH24:MI:SS'));
                                                                    
  cux_arch_high_water_mark_pkg.run_job_back(p_schema     => 'SFYHWM3',
                                            p_table_name => NULL,
                                            p_begin_date => to_date('2015-04-17 11:00:00',
                                                                    'YYYY-MM-DD HH24:MI:SS'));
                                                                    
  cux_arch_high_water_mark_pkg.run_job_back(p_schema     => 'SFYHWM4',
                                            p_table_name => NULL,
                                            p_begin_date => to_date('2015-04-17 11:00:00',
                                                                    'YYYY-MM-DD HH24:MI:SS'));                                                                                                                                                                                                      
END;
*/
--查看JOB
SELECT *
  FROM dba_jobs t
 WHERE t.what LIKE '%CUX_ARCH_HIGH_WATER_MARK_PKG%';

--查看锁表
SELECT t2.username,
       t2.sid,
       t2.serial#,
       t3.object_name,
       t2.osuser,
       t2.machine,
       t2.program,
       t2.logon_time,
       t2.command,
       t2.lockwait,
       t2.saddr,
       t2.paddr,
       t2.taddr,
       t2.sql_address,
       t1.locked_mode
  FROM v$locked_object t1, v$session t2, dba_objects t3
 WHERE t1.session_id = t2.sid
   AND t1.object_id = t3.object_id
   AND t2.osuser LIKE 'ora%'
 ORDER BY t2.logon_time;

--查看进度
SELECT t.table_name,
       t.begin_date,
       t.hwm_begin_date,
       t.hwm_end_date,
       t.index_begin_date,
       t.index_end_date,
       t.attribute2,
       t.process_status,
       t.process_message,
       t.attribute1,
       t.attribute3
  FROM cux_arch_hwm_history t
 WHERE t.applcation_code LIKE 'SFYHWM%'
 ORDER BY decode(t.hwm_begin_date,
                 NULL,
                 to_date('4444-01-01', 'YYYY-MM-DD'),
                 t.hwm_begin_date);

--检查对象有效性
SELECT t.* FROM all_objects t WHERE t.status <> 'VALID';

--检查索引有效性 对于分区表的索引状态是N/A
SELECT t.*
  FROM dba_indexes t, cux_arch_header h, cux_arch_lines l
 WHERE t.status <> 'VALID'
   AND h.header_id = l.header_id
   AND t.table_owner = l.table_schma
   AND t.table_name = l.table_name
   AND h.application_short_code LIKE 'SFYHWM%';

--检查分区表索引有效性
SELECT *
  FROM dba_ind_partitions t
 WHERE t.index_owner = 'XLA'
   AND t.partition_name IN ('CST', 'AR')
   AND t.status <> 'USABLE';
