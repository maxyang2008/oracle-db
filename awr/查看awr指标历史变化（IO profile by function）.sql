declare
  cursor c_snap is
    select snap_id, begin_interval_time
      from dba_hist_snapshot
     where INSTANCE_NUMBER = 1
    /*       AND begin_interval_time >
    to_date('2018-12-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS')*/
     order by snap_id;
  v_snap_id   number;
  v_snap_time date;
  v_reads     number;
  v_writes    number;
begin

  dbms_output.put_line('DATE_TIME,READS,WRITE');
  open c_snap;

  LOOP
    begin
      fetch c_snap
        into v_snap_id, v_snap_time;
      --dbms_output.put_line(v_snap_id);
    
      SELECT ROUND((SUM(E.small_read_megabytes) -
                   SUM(S.small_read_megabytes) +
                   SUM(E.large_read_megabytes) -
                   SUM(S.large_read_megabytes)) / 1024,
                   0)
        into v_reads
        FROM DBA_HIST_IOSTAT_FUNCTION s, DBA_HIST_IOSTAT_FUNCTION e
       WHERE s.snap_id = v_snap_id
         AND e.snap_id = v_snap_id + 1
         anD e.dbid = s.dbid
         AND e.function_id = s.function_id
         AND e.instance_number = s.instance_number
         AND e.instance_number = 2;
    
      SELECT ROUND((SUM(E.small_write_megabytes) -
                   SUM(S.small_write_megabytes) +
                   SUM(E.large_write_megabytes) -
                   SUM(S.large_write_megabytes)) / 1024,
                   0)
        into v_writes
        FROM DBA_HIST_IOSTAT_FUNCTION s, DBA_HIST_IOSTAT_FUNCTION e
       WHERE s.snap_id = v_snap_id
         AND e.snap_id = v_snap_id + 1
         anD e.dbid = s.dbid
         AND e.function_id = s.function_id
         AND e.instance_number = s.instance_number
         AND e.instance_number = 2;
    
      dbms_output.put_line(to_char(v_snap_time, 'YYYY-MM-DD HH24:MI:SS') || ',' ||
                           v_reads || ',' || v_writes);
    
    EXCEPTION
      WHEN NO_DATA_FOUND then
        null;
      
    end;
  
    EXIT WHEN c_snap%NOTFOUND;
  
  end loop;
  close c_snap;

EXCEPTION
  WHEN NO_DATA_FOUND then
    null;
  
end;
