declare
  cursor c_snap is
    select snap_id, begin_interval_time
      from dba_hist_snapshot
     where INSTANCE_NUMBER = 1
       AND begin_interval_time >
           to_date('2018-12-20 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
     order by snap_id;
  v_snap_id   number;
  v_snap_time date;
  v_gets      number;
  v_miss      number;
begin

  dbms_output.put_line('DATE_TIME,GETS,MISSES');
  open c_snap;

  LOOP
    begin
      fetch c_snap
        into v_snap_id, v_snap_time;
      --dbms_output.put_line(v_snap_id);
    
      SELECT e.gets - s.gets
        into v_gets
        FROM DBA_HIST_ROWCACHE_SUMMARY s, DBA_HIST_ROWCACHE_SUMMARY e
       WHERE s.snap_id = v_snap_id
         AND e.snap_id = v_snap_id + 1
         anD e.dbid = s.dbid
         AND e.instance_number = s.instance_number
         AND e.instance_number = 2
         AND e.parameter = s.parameter
            
         AND s.parameter = 'dc_constraints';
    
      SELECT e.GETMISSES - s.GETMISSES
        into v_miss
        FROM DBA_HIST_ROWCACHE_SUMMARY s, DBA_HIST_ROWCACHE_SUMMARY e
       WHERE s.snap_id = v_snap_id
         AND e.snap_id = v_snap_id + 1
         anD e.dbid = s.dbid
         AND e.instance_number = s.instance_number
         AND e.instance_number = 2
         AND e.parameter = s.parameter
            
         AND s.parameter = 'dc_constraints';
    
      dbms_output.put_line(to_char(v_snap_time, 'YYYY-MM-DD HH24:MI:SS') || ',' ||
                           v_gets || ',' || v_miss);
    
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
