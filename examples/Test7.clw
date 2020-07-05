  PROGRAM

  INCLUDE('libpq.inc'), ONCE

  MAP
    Test7()   !- asyncronous queries
    INCLUDE('CWUTIL.INC'),ONCE    !- BytoToHex
  END

  CODE
  Test7()
  
Test7                         PROCEDURE()
dbconn                          TPostgreConn
res                             TPostgreRes
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

  IF NOT dbconn.ExecAsync('SELECT i, t, b FROM Test1 LIMIT 10')
    MESSAGE('SELECT failed: '& dbconn.ErrMsg())
    RETURN
  END

  LOOP WHILE dbconn.GetResultAsync(res)
    CLEAR(DataQ)
    res.ToQueue(DataQ)
  END
  
  LOOP qIndex = 1 TO RECORDS(DataQ)
    GET(DataQ, qIndex)
    pq::DebugInfo('   i='& DataQ:i)
    pq::DebugInfo('   t='& DataQ:t)
  END

  dbconn.Disconnect()
  MESSAGE('Done!')

