declare
  cursor c_snap is
    select snap_id, begin_interval_time
      from dba_hist_snapshot
     where INSTANCE_NUMBER = 2
       AND begin_interval_time >
           to_date('2018-12-25 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
     order by snap_id;
  v_snap_id   number;
  v_snap_time date;
  v_waits     number;
begin

  open c_snap;

  LOOP
    begin
      fetch c_snap
        into v_snap_id, v_snap_time;
      --dbms_output.put_line(v_snap_id);
    
      SELECT e.total_waits - s.total_waits
        into v_waits
        FROM DBA_HIST_SYSTEM_EVENT s, DBA_HIST_SYSTEM_EVENT e
       WHERE s.snap_id = v_snap_id
         AND e.snap_id = v_snap_id + 1
         anD e.dbid = s.dbid
         AND e.instance_number = s.instance_number
         AND e.instance_number = 2
         AND e.event_name = s.event_name
         AND s.event_name = 'latch: row cache objects';
    
      dbms_output.put_line(to_char(v_snap_time, 'YYYY-MM-DD HH24:MI:SS') || ',' ||
                           v_waits);
    
      EXIT WHEN c_snap%NOTFOUND;
    
    EXCEPTION
      WHEN NO_DATA_FOUND then
        null;
      
    end;
  end loop;
  close c_snap;

EXCEPTION
  WHEN NO_DATA_FOUND then
    null;
  
end;
