  PROGRAM

!  * Populate a database with the following commands
!  *
!  *   CREATE SCHEMA TESTLIBPQ2;
!  *   SET search_path = TESTLIBPQ2;
!  *   CREATE TABLE TBL1 (i int4);
!  *   CREATE TABLE TBL2 (i int4);
!  *   CREATE RULE r1 AS ON INSERT TO TBL1 DO
!  *     (INSERT INTO TBL2 VALUES (new.i); NOTIFY TBL2);
!  *
!  * Start DebugView to see the notifications handled by the program.
!  * Start this program, then execute the query from psql or pgAdmin:
!  *
!  *   INSERT INTO TESTLIBPQ2.TBL1 VALUES (10);

  INCLUDE('libpq.inc'), ONCE

  MAP
    Test8()   !- Test of the asynchronous notification interface
    INCLUDE('printf.inc'), ONCE
  END

  CODE
  Test8()
  
Test8                         PROCEDURE()
dbconn                          TPostgreConn              !- connection object
conninfo                        STRING(256), AUTO         !- connection string
res                             TPostgreRes               !- query result object
qNotifies                       QUEUE(TPQNotifications).  !- notifications list
i                               LONG, AUTO
Window                          WINDOW('Asynchronous notifications test'),AT(,,213,86),GRAY,FONT('Segoe UI',9), |
                                  TIMER(100)
                                  BUTTON('Exit'),AT(154,65,48),USE(?btnExit),STD(STD:Close)
                                END
bTestNotify                     BOOL(FALSE) !- just to test the Notify method
  CODE
  conninfo = 'dbname = postgres user=postgres password=1234'
 
  !- Make a connection to the database.
  !- Check to see that the backend connection was successfully made.
  IF NOT dbconn.Connect(conninfo)
    MESSAGE('Connection to database failed: '& dbconn.ErrMsg())
    RETURN
  END
  
  !- Set always-secure search path, so malicious users can't take control.
  dbconn.Exec('SELECT pg_catalog.set_config(''search_path'', '''', false)', res)
  IF NOT res.IsOk()
    MESSAGE('SET failed: '& dbconn.ErrMsg())
    RETURN
  END
  
  !- Should clear TPostgreRes whenever it is no longer needed to avoid memory leaks
  res.DoClear()
  
  !- Issue LISTEN command to enable notifications from the rule's NOTIFY.
  dbconn.Listen('TBL2')
  IF bTestNotify
    dbconn.Listen('test')
  END
  
  OPEN(Window)
  ACCEPT
    IF EVENT() = EVENT:Timer
      !- read pending notifications
      IF dbconn.TakeNotifications(qNotifies)
        LOOP i=1 TO RECORDS(qNotifies)
          GET(qNotifies, i)
          printd('Notify[%i]: (channel=%S, pid=%i, payload=%S)', i, qNotifies.Channel, qNotifies.PID, qNotifies.Payload)
          
          IF bTestNotify
            dbconn.Notify('test', 'hello!')
          END
        END
      END
    END
  END

  dbconn.Disconnect()

