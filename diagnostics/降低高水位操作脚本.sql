-- ����ռ�ʹ����
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

--�������ռ�õĿռ�
SELECT segment_name, SUM(bytes) / 1024 / 1024 / 1024 "Byte(GB)" --258576
  FROM dba_segments
 WHERE segment_name IN
       (SELECT l.table_name
          FROM cux_arch_header h, cux_arch_lines l
         WHERE h.header_id = l.header_id
           AND h.application_short_code LIKE 'SFYHWM%')
 GROUP BY segment_name
 ORDER BY SUM(bytes) DESC;

--�����������������ڸ�ģ��ı���������²ſ������н��͸�ˮλ
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

--���͸�ˮλ
--��һ��������Ҫ�����ģ�飬����WIP,PAC,INV
--�ڶ��������Ǳ���������Ϊ�գ����ģ�����еı���ȫ�����͸�ˮλ
--�������Ǻ�̨JOB���еĿ�ʼʱ��
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
--�鿴JOB
SELECT *
  FROM dba_jobs t
 WHERE t.what LIKE '%CUX_ARCH_HIGH_WATER_MARK_PKG%';

--�鿴����
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

--�鿴����
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

--��������Ч��
SELECT t.* FROM all_objects t WHERE t.status <> 'VALID';

--���������Ч�� ���ڷ����������״̬��N/A
SELECT t.*
  FROM dba_indexes t, cux_arch_header h, cux_arch_lines l
 WHERE t.status <> 'VALID'
   AND h.header_id = l.header_id
   AND t.table_owner = l.table_schma
   AND t.table_name = l.table_name
   AND h.application_short_code LIKE 'SFYHWM%';

--��������������Ч��
SELECT *
  FROM dba_ind_partitions t
 WHERE t.index_owner = 'XLA'
   AND t.partition_name IN ('CST', 'AR')
   AND t.status <> 'USABLE';
