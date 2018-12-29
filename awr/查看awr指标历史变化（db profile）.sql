declare
  cursor c_snap is
    select snap_id, begin_interval_time
      from dba_hist_snapshot
     where INSTANCE_NUMBER = 2
     order by snap_id;
  v_snap_id   number;
  v_snap_time date;
  v_dbtime    varchar2(20);
  v_dbcpu     varchar2(20);
begin

  open c_snap;

  LOOP
    begin
      fetch c_snap
        into v_snap_id, v_snap_time;
    
      SELECT Round(NVL((e.value - s.value), -1) / 60 / 1000000, 2)
        into v_dbtime
        FROM DBA_HIST_SYS_TIME_MODEL s, DBA_HIST_SYS_TIME_MODEL e
       WHERE s.snap_id = v_snap_id
         AND e.snap_id = v_snap_id + 1
         anD e.dbid = s.dbid
         AND e.instance_number = s.instance_number
         AND e.instance_number = 2
         AND s.stat_name = 'DB time'
         AND e.stat_id = s.stat_id;
    
      SELECT Round(NVL((e.value - s.value), -1) / 60 / 1000000, 2)
        into v_dbcpu
        FROM DBA_HIST_SYS_TIME_MODEL s, DBA_HIST_SYS_TIME_MODEL e
       WHERE s.snap_id = v_snap_id
         AND e.snap_id = v_snap_id + 1
         anD e.dbid = s.dbid
         AND e.instance_number = s.instance_number
         AND e.instance_number = 2
         AND s.stat_name = 'DB CPU'
         AND e.stat_id = s.stat_id;
    
      dbms_output.put_line(to_char(v_snap_time, 'YYYY-MM-DD HH24:MI:SS') ||
                           ',db_time_hour,' || round(v_dbtime / 60, 2) ||
                           ',cpu_time,' || round(v_dbcpu / 60, 2));
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
