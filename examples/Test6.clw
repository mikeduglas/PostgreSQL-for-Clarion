  PROGRAM

  INCLUDE('libpq.inc'), ONCE

  MAP
    Test6()   !- query viewer
  END

  CODE
  Test6()
  
Test6                         PROCEDURE()
Window                          WINDOW('PG Query Viewer'),AT(,,490,258),CENTER,GRAY,SYSTEM,FONT('Segoe UI',12)
                                  TEXT,AT(2,2,,35),FULL,USE(?txtQuery)
                                  BUTTON('Run query'),AT(443,41),USE(?bRun)
                                  LIST,AT(2,58,,198),FULL,USE(?lstResult),HVSCROLL
                                END
qViewer                         TPostgreViewer
res                             TPostgreRes
  CODE
  !- Make a connection to the database.
  !- Check to see that the backend connection was successfully made.
  IF NOT qViewer.Connect('localhost', '', 'postgres', 'postgres', '1234')
    MESSAGE('Connection to database failed: '& qViewer.ErrMsg())
    RETURN
  END
  
  OPEN(Window)
  
  !- set listbox
  qViewer.SetListbox(?lstResult)
  
  ACCEPT
    CASE ACCEPTED()
    OF ?bRun
      !- execute query and display result/error
      qViewer.Exec(?txtQuery{PROP:Text}, res)
      IF NOT res.IsOk()
        !- show error
        MESSAGE(res.VerboseErrMsg(), 'PG Query Viewer', ICON:Exclamation)
      END
    END
  END

