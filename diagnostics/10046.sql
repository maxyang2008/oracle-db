-- Available from SQL*Plus since 8i (commandline utility prior to this.
SQL> CONN sys/password AS SYSDBA;  -- User must have SYSDBA.
SQL> ORADEBUG SETMYPID;            -- Debug current session.
SQL> ORADEBUG SETOSPID 1234;       -- Debug session with the specified OS process.
SQL> ORADEBUG SETORAPID 123456;    -- Debug session with the specified Oracle process ID.
SQL> ORADEBUG UNLIMIT;

SQL> ORADEBUG EVENT 10046 TRACE NAME CONTEXT FOREVER, LEVEL 12;
SQL> ORADEBUG TRACEFILE_NAME;      -- Display the current trace file.
SQL> ORADEBUG EVENT 10046 TRACE NAME CONTEXT OFF;
