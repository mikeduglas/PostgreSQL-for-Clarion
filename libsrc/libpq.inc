PGconn                        EQUATE(LONG)
PGresult                      EQUATE(LONG)
Oid                           EQUATE(LONG)

PostgresPollingStatusType     EQUATE(LONG)
                              ITEMIZE(0)
PGRES_POLLING_FAILED            EQUATE
PGRES_POLLING_READING           EQUATE      !- These two indicate that one may
PGRES_POLLING_WRITING           EQUATE      !- use select before polling again.
PGRES_POLLING_OK                EQUATE
PGRES_POLLING_ACTIVE            EQUATE      !- unused; keep for awhile for backwards compatibility
                              END

PGPing                        EQUATE(LONG)
                              ITEMIZE(0)
PQPING_OK                       EQUATE      !- server is accepting connections
PQPING_REJECT                   EQUATE      !- server is alive but rejecting connections
PQPING_NO_RESPONSE              EQUATE      !- could not establish connection
PQPING_NO_ATTEMPT               EQUATE      !- connection not attempted (bad params)
                              END

ConnStatusType                EQUATE(LONG)
                              ITEMIZE(0)
CONNECTION_OK                   EQUATE
CONNECTION_BAD                  EQUATE
!- Non-blocking mode only below here
CONNECTION_STARTED              EQUATE      !- Waiting for connection to be made.
CONNECTION_MADE                 EQUATE      !- Connection OK; waiting to send.
CONNECTION_AWAITING_RESPONSE    EQUATE      !- Waiting for a response from the postmaster.
CONNECTION_AUTH_OK              EQUATE      !- Received authentication; waiting for backend startup.
CONNECTION_SETENV               EQUATE      !- Negotiating environment.
CONNECTION_SSL_STARTUP          EQUATE      !- Negotiating SSL.
CONNECTION_NEEDED               EQUATE      !- Internal state: connect() needed
CONNECTION_CHECK_WRITABLE       EQUATE
CONNECTION_CONSUME              EQUATE
                              END

PGTransactionStatusType       EQUATE(LONG)
                              ITEMIZE(0)
PQTRANS_IDLE                    EQUATE      !- connection idle
PQTRANS_ACTIVE                  EQUATE      !- command in progress
PQTRANS_INTRANS                 EQUATE      !- idle, within transaction block
PQTRANS_INERROR                 EQUATE      !- idle, within failed transaction
PQTRANS_UNKNOWN                 EQUATE      !- cannot determine status
                              END

ExecStatusType                EQUATE(LONG)
                              ITEMIZE(0)
PGRES_EMPTY_QUERY               EQUATE      !- The string sent to the server was empty.
PGRES_COMMAND_OK                EQUATE      !- Successful completion of a command returning no data.
PGRES_TUPLES_OK                 EQUATE      !- Successful completion of a command returning data (such as a SELECT or SHOW).
PGRES_COPY_OUT                  EQUATE      !- Copy Out (from server) data transfer started.
PGRES_COPY_IN                   EQUATE      !- Copy In (to server) data transfer started.
PGRES_BAD_RESPONSE              EQUATE      !- The server's response was not understood.
PGRES_NONFATAL_ERROR            EQUATE      !- A nonfatal error (a notice or warning) occurred.
PGRES_FATAL_ERROR               EQUATE      !- A fatal error occurred.
PGRES_COPY_BOTH                 EQUATE      !- Copy In/Out (to and from server) data transfer started.
PGRES_SINGLE_TUPLE              EQUATE      !- The PGresult contains a single result tuple from the current command. This status occurs only when single-row mode has been selected for the query.
                              END

PGVerbosity                   EQUATE(LONG)
                              ITEMIZE(0)
PQERRORS_TERSE                  EQUATE      !- single-line error messages
PQERRORS_DEFAULT                EQUATE      !- recommended style
PQERRORS_VERBOSE                EQUATE      !- all the facts, ma'am
                              END

PGContextVisibility           EQUATE(LONG)
                              ITEMIZE(0)
PQSHOW_CONTEXT_NEVER            EQUATE      !- never show CONTEXT field
PQSHOW_CONTEXT_ERRORS           EQUATE      !- show CONTEXT for errors only (default)
PQSHOW_CONTEXT_ALWAYS           EQUATE      !- always show CONTEXT field
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

ExecAsync                       PROCEDURE(STRING pCommand, BOOL pSingleRowMode = FALSE), BOOL, VIRTUAL
GetResultAsync                  PROCEDURE(*TPostgreRes pRes), BOOL
OnsumeInput                     PROCEDURE(), BOOL
IsBusy                          PROCEDURE(), BOOL

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
StatusText                      PROCEDURE(), STRING
IsOk                            PROCEDURE(), BOOL !- retruns true for PGRES_COMMAND_OK or PGRES_TUPLES_OK
ErrMsg                          PROCEDURE(), STRING
VerboseErrMsg                   PROCEDURE(PGVerbosity verbosity = PQERRORS_DEFAULT, PGContextVisibility show_context = PQSHOW_CONTEXT_ERRORS), STRING

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
