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


  MAP
    MODULE('libpq')
      pq::DebugInfo(STRING pMsg)
    END
  END


TPostgreConn                  CLASS, TYPE, MODULE('libpq.clw'), LINK('libpq.clw')
conn                            PGconn, PROTECTED   !- connection handler

Construct                       PROCEDURE()
Destruct                        PROCEDURE(), VIRTUAL

Connect                         PROCEDURE(STRING pConnInfo), BOOL
Connect                         PROCEDURE(STRING pghost, STRING pgport, STRING dbName, STRING login, STRING pwd, <STRING pgoptions>, <STRING pgtty>), BOOL
Disconnect                      PROCEDURE()
Reset                           PROCEDURE()

Status                          PROCEDURE(), ConnStatusType

Exec                            PROCEDURE(STRING pCommand, <*TPostgreRes pRes>)

ErrMsg                          PROCEDURE(), STRING
                              END


TPostgreRes                   CLASS, TYPE, MODULE('libpq.clw'), LINK('libpq.clw')
res                             PGresult, PROTECTED

Construct                       PROCEDURE()
Destruct                        PROCEDURE(), VIRTUAL

Init                            PROCEDURE(PGconn res)
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
