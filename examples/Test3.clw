  PROGRAM

  INCLUDE('libpq.inc'), ONCE

  MAP
    Test3()   !- events
    INCLUDE('CWUTIL.INC'),ONCE    !- BytoToHex
  END

  CODE
  Test3()
  
Test3                         PROCEDURE()
dbconn                          TPostgreConn
res                             TPostgreRes
evtHandler                      TPostgreEvent
DataQ                           QUEUE
i                                 LONG
t                                 STRING(20)
b                                 STRING(20)
                                END
qIndex                          LONG, AUTO
cIndex                          LONG, AUTO
ba                              &STRING
  CODE
  !- Make a connection to the database.
  !- Check to see that the backend connection was successfully made.
  IF NOT dbconn.Connect('localhost', '', 'postgres', 'postgres', '1234')
    MESSAGE('Connection to database failed: '& dbconn.ErrMsg())
    RETURN
  END

  IF NOT dbconn.RegisterEventhandler(evtHandler)
    MESSAGE('Cannot register PGEventProc')
    RETURN
  END

  IF dbconn.Ping() <> PQPING_OK
    MESSAGE('PING error')
    RETURN
  END
  
  dbconn.Exec('SELECT i,t,b FROM test1', res)
!  dbconn.Exec('SELECT i,t,x FROM test1', res)    !- invalid SELECT (column 'x' doesn't exist)
  IF NOT res.IsOk()
    MESSAGE('SELECT failed: '& res.ErrMsg())
!    MESSAGE('SELECT failed: '& res.VerboseErrMsg())
    RETURN
  END

  res.ToQueue(DataQ)
  LOOP qIndex = 1 TO RECORDS(DataQ)
    GET(DataQ, qIndex)
    pq::DebugInfo('   i='& DataQ:i)
    pq::DebugInfo('   t='& DataQ:t)
    !- byte array
!    LOOP cIndex = 1 TO 20
!      pq::DebugInfo('   b['& cIndex &']='& ByteToHex(VAL(DataQ:b[cIndex])))
!    END
  END
  
  ba &= res.GetByteArray(1, 3)
  pq::DebugInfo('   LEN(ba)='& LEN(ba))
  LOOP cIndex = 1 TO LEN(ba)
    pq::DebugInfo('   b['& cIndex &']='& ByteToHex(VAL(ba[cIndex])))
  END
  DISPOSE(ba)

  dbconn.Disconnect()
  MESSAGE('Done!')
