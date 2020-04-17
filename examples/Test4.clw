  PROGRAM

  INCLUDE('libpq.inc'), ONCE

  MAP
    Test4()   !- json response
  END

  CODE
  Test4()
  
Test4                         PROCEDURE()
dbconn                          TPostgreConn
jsonStr                         ANY
  CODE
  !- Make a connection to the database.
  !- Check to see that the backend connection was successfully made.
  IF NOT dbconn.Connect('localhost', '', 'postgres', 'postgres', '1234')
    MESSAGE('Connection to database failed: '& dbconn.ErrMsg())
    RETURN
  END
  
  jsonStr = dbconn.ExecAsJson('SELECT i,t,b FROM test1')
  IF jsonStr= ''
    MESSAGE('SELECT as JSON failed: '& dbconn.ErrMsg())
    RETURN
  END

  pq::DebugInfo('JSON OUTPUT: '& jsonStr)
  MESSAGE('Done!')

