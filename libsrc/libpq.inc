PGconn                        EQUATE(LONG)
PGresult                      EQUATE(LONG)
Oid                           EQUATE(LONG)

PostgresPollingStatusType     EQUATE(LONG)
                              ITEMIZE(0)
PGRES_POLLING_FAILED            EQUATE
PGRES_POLLING_READING           EQUATE
PGRES_POLLING_WRITING           EQUATE
PGRES_POLLING_OK                EQUATE
PGRES_POLLING_ACTIVE            EQUATE
                              END

PGPing                        EQUATE(LONG)
                              ITEMIZE(0)
PQPING_OK                       EQUATE
PQPING_REJECT                   EQUATE
PQPING_NO_RESPONSE              EQUATE
PQPING_NO_ATTEMPT               EQUATE
                              END

ConnStatusType                EQUATE(LONG)
                              ITEMIZE(0)
CONNECTION_OK                   EQUATE
CONNECTION_BAD                  EQUATE
CONNECTION_STARTED              EQUATE
CONNECTION_MADE                 EQUATE
CONNECTION_AWAITING_RESPONSE    EQUATE
CONNECTION_AUTH_OK              EQUATE
CONNECTION_SETENV               EQUATE
CONNECTION_SSL_STARTUP          EQUATE
CONNECTION_NEEDED               EQUATE
CONNECTION_CHECK_WRITABLE       EQUATE
CONNECTION_CONSUME              EQUATE
                              END

PGTransactionStatusType       EQUATE(LONG)
                              ITEMIZE(0)
PQTRANS_IDLE                    EQUATE
PQTRANS_ACTIVE                  EQUATE
PQTRANS_INTRANS                 EQUATE
PQTRANS_INERROR                 EQUATE
PQTRANS_UNKNOWN                 EQUATE
                              END

ExecStatusType                EQUATE(LONG)
                              ITEMIZE(0)
PGRES_EMPTY_QUERY               EQUATE
PGRES_COMMAND_OK                EQUATE
PGRES_TUPLES_OK                 EQUATE
PGRES_COPY_OUT                  EQUATE
PGRES_COPY_IN                   EQUATE
PGRES_BAD_RESPONSE              EQUATE
PGRES_NONFATAL_ERROR            EQUATE
PGRES_FATAL_ERROR               EQUATE
PGRES_COPY_BOTH                 EQUATE
PGRES_SINGLE_TUPLE              EQUATE
                              END

PQconninfoOption              GROUP, TYPE
keyword                         &CSTRING
envvar                          &CSTRING
compiled                        &CSTRING
val                             &CSTRING
label                           &CSTRING
dispchar                        &CSTRING
dispsize                        LONG
                              END

!- events
PGEventId                     EQUATE(LONG)
                              ITEMIZE(0)
PGEVT_REGISTER                  EQUATE
PGEVT_CONNRESET                 EQUATE
PGEVT_CONNDESTROY               EQUATE
PGEVT_RESULTCREATE              EQUATE
PGEVT_RESULTCOPY                EQUATE
PGEVT_RESULTDESTROY             EQUATE
                              END

TPGEventRegister              GROUP, TYPE
conn                            PGconn
                              END

TPGEventConnReset             GROUP, TYPE
conn                            PGconn
                              END

TPGEventConnDestroy           GROUP, TYPE
conn                            PGconn
                              END

TPGEventResultCreate          GROUP, TYPE
conn                            PGconn
result                          PGresult
                              END

TPGEventResultCopy            GROUP, TYPE
src                             PGresult
dest                            PGresult
                              END


TPGEventResultDestroy         GROUP, TYPE
result                          PGresult
                              END

  MAP
    MODULE('libpq')
      pq::DebugInfo(STRING pMsg)
    END
  END


TPostgreConn                  CLASS, TYPE, MODULE('libpq.clw'), LINK('libpq.clw')
conn                            PGconn, PROTECTED   !- connection handler

Construct                       PROCEDURE()
Destruct                        PROCEDURE(), VIRTUAL

RegisterEventhandler            PROCEDURE(*TPostgreEvent evtHandler), BOOL, PROC

Connect                         PROCEDURE(STRING pConnInfo), BOOL, VIRTUAL
Connect                         PROCEDURE(STRING pghost, STRING pgport, STRING dbName, STRING login, STRING pwd, <STRING pgoptions>, <STRING pgtty>), BOOL, VIRTUAL
Disconnect                      PROCEDURE(), VIRTUAL
Reset                           PROCEDURE(), VIRTUAL

Status                          PROCEDURE(), ConnStatusType
Ping                            PROCEDURE(<STRING pConnInfo>), PGPing, VIRTUAL

Host                            PROCEDURE(), STRING
Port                            PROCEDURE(), STRING
DbName                          PROCEDURE(), STRING
User                            PROCEDURE(), STRING
Pass                            PROCEDURE(), STRING

Exec                            PROCEDURE(STRING pCommand, <*TPostgreRes pRes>), VIRTUAL
ExecAsJson                      PROCEDURE(STRING pCommand), STRING, VIRTUAL

BeginTran                       PROCEDURE(), BOOL, PROC !- just calls Exec('BEGIN')
EndTran                         PROCEDURE(), BOOL, PROC !- just calls Exec('END')
CommitTran                      PROCEDURE(), BOOL, PROC !- just calls Exec('COMMIT')
RollbackTran                    PROCEDURE(), BOOL, PROC !- just calls Exec('ROLLBACK')

ErrMsg                          PROCEDURE(), STRING
                              END


TPostgreRes                   CLASS, TYPE, MODULE('libpq.clw'), LINK('libpq.clw')
res                             PGresult, PROTECTED
conn                            PGconn, PROTECTED   !- connection handler

Construct                       PROCEDURE()
Destruct                        PROCEDURE(), VIRTUAL

Init                            PROCEDURE(PGresult res, PGconn conn)
Kill                            PROCEDURE()

Status                          PROCEDURE(), ExecStatusType
IsOk                            PROCEDURE(), BOOL !- retruns true for PGRES_COMMAND_OK or PGRES_TUPLES_OK

NumFields                       PROCEDURE(), LONG
FieldName                       PROCEDURE(LONG column_number), STRING
NumRows                         PROCEDURE(), LONG
IsNull                          PROCEDURE(LONG row_number, LONG column_number), BOOL
IsBinary                        PROCEDURE(LONG column_number), BOOL
GetLength                       PROCEDURE(LONG row_number, LONG column_number), LONG
GetValue                        PROCEDURE(LONG row_number, LONG column_number, LONG pLength = 0), ?
GetByteArray                    PROCEDURE(LONG row_number, LONG column_number), *STRING
UnescapeBinary                  PROCEDURE(*CSTRING from_str), *STRING, PRIVATE
UnescapeBinary                  PROCEDURE(STRING from_str), *STRING

ToGroup                         PROCEDURE(*GROUP pGrp, LONG row_number = 1, BOOL matchByFieldNumber = FALSE)
ToQueue                         PROCEDURE(*QUEUE pQ, BOOL matchByFieldNumber = FALSE)
                              END

TPostgreEvent                 CLASS, TYPE, MODULE('libpq.clw'), LINK('libpq.clw')
Register                        PROCEDURE(LONG evtInfo), BOOL, VIRTUAL, PROTECTED
ConnReset                       PROCEDURE(LONG evtInfo), BOOL, VIRTUAL, PROTECTED
ConnDestroy                     PROCEDURE(LONG evtInfo), BOOL, VIRTUAL, PROTECTED
ResultCreate                    PROCEDURE(LONG evtInfo), BOOL, VIRTUAL, PROTECTED
ResultCopy                      PROCEDURE(LONG evtInfo), BOOL, VIRTUAL, PROTECTED
ResultDestroy                   PROCEDURE(LONG evtInfo), BOOL, VIRTUAL, PROTECTED
                              END
