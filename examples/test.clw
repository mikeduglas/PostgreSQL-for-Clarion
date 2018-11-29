  PROGRAM

  INCLUDE('libpq.inc'), ONCE

  MAP
    Test1()
    Test2()
    Test3()   !- events
    INCLUDE('CWUTIL.INC'),ONCE
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
  LOOP cIndex = 1 TO 20
    pq::DebugInfo('   b['& cIndex &']='& ByteToHex(VAL(ba[cIndex])))
  END
  DISPOSE(ba)

  dbconn.Disconnect()
  MESSAGE('Done!')
  
  
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
  LOOP cIndex = 1 TO 20
    pq::DebugInfo('   b['& cIndex &']='& ByteToHex(VAL(ba[cIndex])))
  END
  DISPOSE(ba)

  dbconn.Disconnect()
  MESSAGE('Done!')


Test1                         PROCEDURE()
dbconn                          TPostgreConn
conninfo                        STRING(256)
res                             TPostgreRes
i                               LONG, AUTO
j                               LONG, AUTO

DBInfoQ                         QUEUE
datname                           STRING(32)
datdba                            STRING(10)
encoding                          LONG
datcollate                        STRING(32)
datctype                          STRING(32)
datistemplate                     BOOL
datallowconn                      BOOL
datconnlimit                      LONG
datlastsysoid                     STRING(20)
datfrozenxid                      STRING(20)
datminmxid                        STRING(20)
dattablespace                     STRING(20)
datacl                            STRING(256)
                                END
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
  
  !- Our test case here involves using a cursor, for which we must be inside
  !- a transaction block.  We could do the whole thing with a single
  !- PQexec() of "select * from pg_database", but that's too trivial to make
  !- a good example.
  
  !- Start a transaction block
!  dbconn.Exec('BEGIN', res)
!  IF NOT res.IsOk()
!    MESSAGE('BEGIN failed: '& dbconn.ErrMsg())
!    RETURN
!  END
  IF NOT dbconn.BeginTran()
    MESSAGE('BEGIN failed: '& dbconn.ErrMsg())
    RETURN
  END
  
  !- Fetch rows from pg_database, the system catalog of databases
  dbconn.Exec('DECLARE myportal CURSOR FOR select * from pg_database', res)
  IF NOT res.IsOk()
    MESSAGE('DECLARE CURSOR failed: '& dbconn.ErrMsg())
    RETURN
  END

  dbconn.Exec('FETCH ALL in myportal', res)
  IF NOT res.IsOk()
    MESSAGE('FETCH ALL CURSOR failed: '& dbconn.ErrMsg())
    RETURN
  END

  !- first, print out the attribute names
  pq::DebugInfo('*** attribute names ***')
  LOOP i = 1 TO res.NumFields()
    pq::DebugInfo(res.FieldName(i))
  END
  
  !- next, print out the rows
  pq::DebugInfo('*** rows ***')
  LOOP i = 1 TO res.NumRows()
    LOOP j = 1 TO res.NumFields()
      pq::DebugInfo(res.GetValue(i, j))
    END
  END
  
  !- same task, using queue by name
  pq::DebugInfo('*** QUEUE BY nAME ***')
  FREE(DBInfoQ)
  res.ToQueue(DBInfoQ, FALSE)
  LOOP i = 1 TO RECORDS(DBInfoQ)
    pq::DebugInfo('  ROW '& i)
    GET(DBInfoQ, i)
    pq::DebugInfo('   datname='& DBInfoQ:datname)
    pq::DebugInfo('   datdba='& DBInfoQ:datdba)
    pq::DebugInfo('   encoding='& DBInfoQ:encoding)
    pq::DebugInfo('   datcollate='& DBInfoQ:datcollate)
    pq::DebugInfo('   datctype='& DBInfoQ:datctype)
    pq::DebugInfo('   datistemplate='& DBInfoQ:datistemplate)
    pq::DebugInfo('   datallowconn='& DBInfoQ:datallowconn)
    pq::DebugInfo('   datconnlimit='& DBInfoQ:datconnlimit)
    pq::DebugInfo('   datlastsysoid='& DBInfoQ:datlastsysoid)
    pq::DebugInfo('   datfrozenxid='& DBInfoQ:datfrozenxid)
    pq::DebugInfo('   datminmxid='& DBInfoQ:datminmxid)
    pq::DebugInfo('   dattablespace='& DBInfoQ:dattablespace)
    pq::DebugInfo('   datacl='& DBInfoQ:datacl)
  END
  
  
  !- same task, using queue by number
  pq::DebugInfo('*** QUEUE BY NUMBER ***')
  FREE(DBInfoQ)
  res.ToQueue(DBInfoQ, TRUE)
  LOOP i = 1 TO RECORDS(DBInfoQ)
    pq::DebugInfo('  ROW '& i)
    GET(DBInfoQ, i)
    pq::DebugInfo('   datname='& DBInfoQ:datname)
    pq::DebugInfo('   datdba='& DBInfoQ:datdba)
    pq::DebugInfo('   encoding='& DBInfoQ:encoding)
    pq::DebugInfo('   datcollate='& DBInfoQ:datcollate)
    pq::DebugInfo('   datctype='& DBInfoQ:datctype)
    pq::DebugInfo('   datistemplate='& DBInfoQ:datistemplate)
    pq::DebugInfo('   datallowconn='& DBInfoQ:datallowconn)
    pq::DebugInfo('   datconnlimit='& DBInfoQ:datconnlimit)
    pq::DebugInfo('   datlastsysoid='& DBInfoQ:datlastsysoid)
    pq::DebugInfo('   datfrozenxid='& DBInfoQ:datfrozenxid)
    pq::DebugInfo('   datminmxid='& DBInfoQ:datminmxid)
    pq::DebugInfo('   dattablespace='& DBInfoQ:dattablespace)
    pq::DebugInfo('   datacl='& DBInfoQ:datacl)
  END
  
  !- close the portal ... we don't bother to check for errors ...
  dbconn.Exec('CLOSE myportal')
  
  !- end the transaction
!  dbconn.Exec('END')
  dbconn.EndTran()

  dbconn.Disconnect()
  
  MESSAGE('Done!')
