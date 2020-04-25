  PROGRAM

  INCLUDE('libpq.inc'), ONCE

  MAP
    Test6()   !- query viewer

    !- national characters support
    CurrentCharSet(), LONG
    MODULE('Win API')
      GetACP(), ULONG, PASCAL, NAME('GetACP')
    END
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

  !- server encoding is utf-8
  qViewer.SetEncodings(CP_UTF8, CP_ACP)
  
  OPEN(Window)
  
  !- change charset to current code page
  ?txtQuery{PROP:FontCharSet} = CurrentCharSet()
  ?lstResult{PROP:FontCharSet} = CurrentCharSet()

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

CurrentCharSet                PROCEDURE()
  CODE
  CASE GetACP() 
  OF 1252
    RETURN CHARSET:ANSI
  OF 1251
    RETURN CHARSET:CYRILLIC
  OF 1250
    RETURN CHARSET:EASTEUROPE
  OF 1253
    RETURN CHARSET:GREEK
  OF 1254
    RETURN CHARSET:TURKISH
  OF 1257
    RETURN CHARSET:BALTIC
  OF 1255
    RETURN CHARSET:HEBREW
  OF 1256
    RETURN CHARSET:ARABIC
  OF 932
    RETURN CHARSET:SHIFTJIS
  OF 949
    RETURN CHARSET:HANGEUL
  OF 936
    RETURN CHARSET:GB2312
  OF 950
    RETURN CHARSET:CHINESEBIG5
  ELSE
    RETURN CHARSET:DEFAULT
  END
