REQUIRE Control ~nn/lib/win/control.f
REQUIRE ComboBox ~nn/lib/win/controls/combobox.f
REQUIRE RES res.f
REQUIRE OpenDialog ~nn/lib/win/filedialogs.f
REQUIRE FILE>DIR ~nn/lib/filename.f
REQUIRE Shedule sched.f
REQUIRE gethostname ~nn/lib/sock.f

CLASS: AddTaskDialog <SUPER FrameWindow
    215 CONSTANT width
    200 CONSTANT height    
    10  CONSTANT col1
    40  CONSTANT col2
    150 CONSTANT col3
     3  CONSTANT row1
     17 CONSTANT row2
\    100 CONSTANT tm_row1
     20 CONSTANT tm_w   
     10 CONSTANT tm_h
     10 CONSTANT hs
    150 CONSTANT width1
     : aster S" *" ;


     : row ( n -- n1 ) 1- hs 1+ * row1 + ;
     : tm_row1 9 row ;

    Static OBJ stTaskName
            :init  auto  visible  col1 1 row pos  30 10 size  2 RES text ;
    Edit   OBJ edTaskName
            :init  auto  visible  col2 1 row 1- pos  60 10 size 
                WS_TABSTOP vStyle ! ;
    Static OBJ stAction
            :init auto  visible  
                col1 2 row pos  30 10 size 3 RES text ;

    RadioButton OBJ rbApp
            :init auto visible
                col2 2 row  pos 40 10 size 60 RES text
                WS_GROUP WS_TABSTOP OR vStyle !    ;
    RadioButton OBJ rbScr
            :init auto visible
                col2 40 + 2 row  pos 30 10 size 61 RES text ;

    Static OBJ stApp
            :init auto col1 3 row pos 30 hs size  70 RES text ;
    Edit OBJ edApp                                     
            :init auto col2 3 row  pos  width1 hs size
                  WS_TABSTOP vStyle ! ;
    Button OBJ butApp
            :init auto col2 width1 + 3 + 3 row pos  10 hs size
                    S" ..." text ;

    Static OBJ stPars
            :init auto col1 4 row pos 30 hs size  71 RES text ;
    Edit   OBJ edPars
            :init auto col2 4 row pos width1 hs size
                WS_TABSTOP vStyle ! ;

    Static OBJ stDir
            :init auto col1 5 row pos 30 hs size  72 RES text ;
    Edit   OBJ edDir
            :init auto col2 5 row pos width1 hs size
                WS_TABSTOP vStyle ! ;

    Static OBJ stOpen
            :init auto col1 6 row pos  30 hs size   74 RES text ;
    ComboBox OBJ cbOpen
            :init auto col1 30 + 6 row pos  40 hs 5 * size 
                WS_TABSTOP vStyle ! ;

    Static OBJ stPrior
            :init auto col1 75 + 6 row pos  30 hs size   75 RES text ;

    ComboBox OBJ cbPrior
            :init auto col1 100 + 6 row pos  40 hs 5 * size 
                WS_TABSTOP vStyle ! ;

    CheckBox OBJ chkQuery
            :init auto col2 7 row pos  80 hs size
                90 RES text  WS_TABSTOP vStyle ! ;

    Static OBJ stScr
            :init auto col1 3 row  pos  30 hs size  73 RES text ;

    Edit OBJ edScr
            :init auto col2 3 row  pos  width1 hs 5 * size
                  WS_TABSTOP ES_MULTILINE OR
                  ES_WANTRETURN OR ES_AUTOVSCROLL OR
                  WS_VSCROLL OR
                  vStyle ! ;

    M: SetApp
        stApp Show  edApp Show  butApp Show
        stPars Show edPars Show
        stDir Show  edDir Show
        stOpen Show cbOpen Show
        stPrior Show cbPrior Show
        chkQuery Show

        stScr Hide  edScr Hide
        ;
    M: SetScr
        stApp Hide  edApp Hide butApp Show
        stPars Hide edPars Hide
        stDir Hide  edDir Hide
        stOpen Hide cbOpen Hide
        stPrior Hide cbPrior Hide
        chkQuery Hide

        stScr Show  edScr Show
    ;

    : tm_col ( num -- x ) tm_w 5 + * col1 + ;
    : tm_row ( num -- y ) tm_h * tm_row1 + ;
    GroupBox OBJ frame_time
            :init auto  visible  0 tm_col 5 - 0 tm_row 7 - pos
                            8 tm_col 10 - tm_h 4 * 10 - size
                            117 RES text ;

    Static  OBJ stMinute
            :init auto  visible  0 tm_col 0 tm_row pos
                                         tm_w tm_h size   110 RES text ;
    Edit    OBJ edMinute
            :init auto  visible  0 tm_col 1 tm_row pos  tm_w hs size
                    WS_TABSTOP vStyle ! ;
    Static  OBJ stHour
            :init auto  visible  1 tm_col 0 tm_row pos   tm_w tm_h size 111 RES text ;
    Edit    OBJ edHour
            :init auto  visible  1 tm_col 1 tm_row pos tm_w hs size
                WS_TABSTOP vStyle ! ;
    Static  OBJ stDay
            :init auto  visible  2 tm_col 0 tm_row pos   tm_w tm_h size 112 RES text ;
    Edit    OBJ edDay
            :init auto  visible  2 tm_col 1 tm_row pos tm_w hs size 
                WS_TABSTOP vStyle ! ;
    Static  OBJ stMonth
            :init auto  visible  3 tm_col 0 tm_row pos   tm_w tm_h size 113 RES text ;
    Edit    OBJ edMonth
            :init auto  visible  3 tm_col 1 tm_row pos tm_w hs size
                WS_TABSTOP vStyle ! ;
    Static  OBJ stWeekDay
            :init auto  visible  4 tm_col 0 tm_row pos   tm_w tm_h size 114 RES text ;
    Edit    OBJ edWeekDay
            :init auto  visible  4 tm_col 1 tm_row pos tm_w hs size
                WS_TABSTOP vStyle ! ;
    Static  OBJ stYear
            :init auto  visible  5 tm_col 0 tm_row pos   tm_w tm_h size 115 RES text ;
    Edit    OBJ edYear
            :init auto  visible  5 tm_col 1 tm_row pos tm_w hs size
                WS_TABSTOP vStyle ! ;

    M: SetTimeClick
        [ C" Schedule" FIND NIP ]
            [IF] Schedule [THEN]
    ;
    Button OBJ butTime
            :init auto  visible  6 tm_col 1 tm_row pos  40 11 size 
                    ['] SetTimeClick OnClick !
                    116 RES text  WS_TABSTOP vStyle ! ;

    GroupBox OBJ grpUser
            :init auto  visible  0 tm_col 5 - 12 row pos
                            8 tm_col 10 - hs 3 * size
                            94 RES text ;
    Static OBJ stUser
        :init auto visible  col1 13 row pos  15 hs size 91 RES text ;
    Edit OBJ edUser                
        :init auto visible  col1 18 + 13 row pos  35 hs size WS_TABSTOP vStyle ! ;

    Static OBJ stPassword
        :init auto visible  col1 60 + 13 row pos  30 hs size 92 RES text ;
    Edit OBJ edPassword
        :init auto visible  col1 90 + 13 row pos  35 hs size
            ES_PASSWORD WS_TABSTOP OR vStyle ! ;

    Static OBJ stDomain
        :init auto visible  col1 130 + 13 row pos  19 hs size 93 RES text ;
    Edit OBJ edDomain
        :init auto visible  col1 155 + 13 row pos  35 hs size WS_TABSTOP vStyle ! ;

    Bevel OBJ b1 
        :init auto visible  col1 15 row pos  100 hs size ;
    M: OkClick 0 Close ;
    M: CancelClick BYE ;

    Button OBJ butOk
        :init  auto  visible 
                width 100 - height 30 - pos
                40 11 size  101 RES text
                ['] OkClick OnClick !
                WS_TABSTOP BS_DEFPUSHBUTTON OR vStyle !
                ;
    Button OBJ butCancel
        :init  auto  visible
                width 50 - height 30 - pos
                40 11 size  102 RES text
                ['] CancelClick OnClick !
                WS_TABSTOP vStyle !
                ;


OpenDialog POINTER OpenDlg

FILTER: AppFilter
    NAME" Programs"             EXT" *.exe;*.com;*.bat;*.cmd"
    NAME" Text files"           EXT" *.txt"
    NAME" HTML files"           EXT" *.htm;*.html;*.xml"
    NAME" MS Office files"      EXT" *.doc;*.xls;*.mdb;*.mde;*.dot"
    NAME" All files (*.*)"      EXT" *.*"
;FILTER

M: SetPath
    OpenDialog NEW TO OpenDlg
    AppFilter OpenDlg SetFilter
    S" Choose application" DROP OpenDlg lpstrTitle !
    OFN_PATHMUSTEXIST OFN_HIDEREADONLY OR  OpenDlg Flags !
    OpenDlg Execute 
    IF
        OpenDlg FileName edApp SetText
        edDir GetText NIP 0=
        IF
            OpenDlg FileName PAD FILE>DIR
            edDir SetText
        THEN
        edPars SetFocus
    THEN
    OpenDlg SELF DELETE
;

M: AddScript

;
        
M: On...Click 
    rbApp GetState 
    IF
        SetPath
    ELSE
        AddScript
    THEN
;

M: OncbActionSelChange
    S" djkhfkjsdhk" ShowMessage 
;

M: Create
    WS_OVERLAPPED WS_SYSMENU OR WS_CAPTION OR  WS_MINIMIZEBOX OR 
       vStyle !
\    WS_EX_TOPMOST vExStyle !
    0 Create
    width height Center
    1 RES SetText
    AutoCreate
    edTaskName SetFocus
    -1 0 EM_SETSEL edTaskName SendMessage DROP

    ['] SetApp rbApp OnClick !
    ['] SetScr rbScr OnClick !
    ['] On...Click butApp OnClick !
    rbApp Checked  SetApp

    80 RES cbOpen Add
    81 RES cbOpen Add
    82 RES cbOpen Add
    83 RES cbOpen Add
    0 cbOpen Current!

    85 RES cbPrior Add
    86 RES cbPrior Add
    87 RES cbPrior Add        
    88 RES cbPrior Add        
    0 cbPrior Current!

    aster edMinute SetText
    aster edHour   SetText
    aster edDay    SetText
    aster edMonth  SetText
    aster edWeekDay SetText
    aster edYear SetText

\    SocketsStartup
\    256 PAD gethostname 0= IF PAD ASCIIZ> edDomain SetText THEN
\    SocketsCleanup

;

M: change_task_name
    S" task2" edTaskName SetText
    -1 0 EM_SETSEL edTaskName SendMessage DROP
;

;CLASS

AddTaskDialog POINTER w

: AddTask
    AddTaskDialog NEW TO w
    w Create
    w Show
    w Run
    w SELF DELETE
    BYE
;

S" ..\icons.f" INCLUDED

' AddTask TO <MAIN>
TRUE TO ?GUI
0 MAINX !
\ ' BYE ' QUIT JMP

S" addtask.exe" SAVE
AddTask