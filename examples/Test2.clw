  PROGRAM

  INCLUDE('libpq.inc'), ONCE

  MAP
    Test2()
    INCLUDE('CWUTIL.INC'),ONCE    !- BytoToHex
  END

  CODE
  Test2()

Test2                         PROCEDURE()
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

  
!  dbconn.Exec('SET bytea_output = escape', res)
!  dbconn.Exec('SET bytea_output = hex', res)
!  IF NOT res.IsOk()
!    MESSAGE('SET bytea_output failed: '& dbconn.ErrMsg())
!    RETURN
!  END

  dbconn.Exec('SELECT i,t,b FROM test1', res)
  IF NOT res.IsOk()
    MESSAGE('SELECT failed: '& dbconn.ErrMsg())
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

