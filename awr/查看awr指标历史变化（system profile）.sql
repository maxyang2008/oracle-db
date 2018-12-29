declare
  cursor c_snap is
    select snap_id, begin_interval_time
      from dba_hist_snapshot
     where INSTANCE_NUMBER = 2
       AND begin_interval_time >
           to_date('2018-12-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
     order by snap_id;
  v_snap_id     number;
  v_snap_time   date;
  v_waits_hard  number;
  v_waits_total number;
begin

  dbms_output.put_line('DATE_TIME,v_waits_hard,v_waits_total');
  open c_snap;

  LOOP
    begin
      fetch c_snap
        into v_snap_id, v_snap_time;
      --dbms_output.put_line(v_snap_id);
    
      SELECT e.value - s.value
        into v_waits_hard
        FROM DBA_HIST_SYSSTAT s, DBA_HIST_SYSSTAT e
       WHERE s.snap_id = v_snap_id
         AND e.snap_id = v_snap_id + 1
         anD e.dbid = s.dbid
         AND e.instance_number = s.instance_number
         AND e.instance_number = 2
         AND e.stat_id = s.stat_id
         AND s.stat_name = 'parse count (hard)';
    
      SELECT e.value - s.value
        into v_waits_total
        FROM DBA_HIST_SYSSTAT s, DBA_HIST_SYSSTAT e
       WHERE s.snap_id = v_snap_id
         AND e.snap_id = v_snap_id + 1
         anD e.dbid = s.dbid
         AND e.instance_number = s.instance_number
         AND e.instance_number = 2
         AND e.stat_id = s.stat_id
         AND s.stat_name = 'parse count (total)';
    
      dbms_output.put_line(to_char(v_snap_time, 'YYYY-MM-DD HH24:MI:SS') || ',' ||
                           v_waits_hard || ',' || v_waits_total);
    
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
