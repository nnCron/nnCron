REQUIRE LoadIcon  ~nn/lib/win/image.f
REQUIRE TrayIcon  ~nn/lib/win/trayicon.f
REQUIRE MENU  ~nn/lib/win/menu.f
REQUIRE MessageLoop ~nn/lib/win/messageloop.f
REQUIRE EXIT-95-START exit95.f
REQUIRE is-admin? ~nn/lib/sec/isadmin.f
REQUIRE LOGGEDON? ~nn/lib/win/windows/logged.f

VARIABLE ItemExit    ItemExit ON
VARIABLE ItemOptions ItemOptions ON
VARIABLE ItemConsole ItemConsole ON
VARIABLE ItemReload  ItemReload ON
VARIABLE ItemSuspend ItemSuspend ON

2VARIABLE menuHotkey
USER OnBalloonClick

VARIABLE vHelpFile

: HelpFile: get-string s, vHelpFile ! ;
: HelpFile vHelpFile @ COUNT 
    2DUP S" :" SEARCH NIP NIP 0=
    IF S" %ModuleDirName%%1 esPICKS%" EVAL-SUBST THEN ;

HelpFile: readme.txt


CREATE si-def HERE /STARTUPINFO ALLOT /STARTUPINFO ERASE
/STARTUPINFO si-def cbSILength !

VARIABLE GUI-APP-CMD
VARIABLE GUI-APP-Sem
VARIABLE GUI-HIDE
QUEUE POINTER QAPP-CMD
: ?INIT-QAPP-CMD QAPP-CMD NULL? IF GLOBAL 16 QUEUE NEW TO QAPP-CMD LOCAL THEN ;
\ CRON-LIST @
SPEC-TASK? ON
:TASK GUI-APP
DEBUG? 0= [IF] NoLog [THEN]
NoActive
AsLoggedUser
Action:
    GUI-HIDE @ IF SWHide ELSE ShowNormal THEN
    NormalPriority
    StartIn: %NNCRON-HOME-DIR%
    \ START-APP: %GUI-APP-CMD @AZ%
    ?INIT-QAPP-CMD
    QAPP-CMD Get DUP ASCIIZ> START-APP
    GLOBAL FREE DROP LOCAL
    -1 CUR-NODE CRON-SESSIONID !
;
TASK;
SPEC-TASK? OFF
\ CRON-LIST !

: GUI-APP-SESSION! GUI-APP @ CRON-SESSIONID ! ;

: GUIStartApp ( si a u -- )
    GUI-APP-Sem GET
    [NONAME
    ?INIT-QAPP-CMD
    GLOBAL S>ZALLOC LOCAL QAPP-CMD Put ( GUI-APP-CMD !) DROP
    WinNT? NOT-SERVICE? 0= AND \ GUIAsUser @ 0<> AND
    IF
        GUI-APP @ >R
\        GUI-APP 100 DUMP
        GUIAsUser @
        IF
            GUIUser @       R@ CRON-USER !
            GUIDomain @     R@ CRON-DOMAIN !
            GUIPassword @   R@ CRON-PASSWORD !
        THEN
        R@ CRON-SU-FLAGS 0!
        CF-ASLOGGED GUILoadProfile @ IF CF-LOAD-PROFILE OR THEN
          R@ CRON-FLAGS @ OR R@ CRON-FLAGS !
        RDROP
    ELSE
        CF-ASLOGGED ( GUILoadProfile @ IF CF-LOAD-PROFILE OR THEN) -1 XOR
          GUI-APP @ CRON-FLAGS @ AND GUI-APP @ CRON-FLAGS !
\        StartApp DROP
    THEN
   GUI-APP @ EXEC-ACTION-TASK-U START-TASK
   NONAME] CATCH IF 2DROP DROP THEN
   100 PAUSE
   GUI-APP-Sem RELEASE
;

TrayIcon OBJECT: CronIcon

VARIABLE TrayChange

0 VALUE TrayBusy
: (msgbox) ( a -- )
    TRUE TO TrayBusy
    10 MB_OK ROT ASCIIZ> EVAL-SUBST TimeMessageBox 2DROP
    FALSE TO TrayBusy
;

' (msgbox) TASK: msgbox-task

: msgbox ( a u -- )
    TrayBusy 0=
    IF DROP msgbox-task START CLOSE-FILE DROP
    ELSE 2DROP THEN ;


\ : rbd  S" Right button down" msgbox ;
: OnLB S" Click right button on this icon" msgbox ;

0 VALUE hw

VARIABLE MenuID
VARIABLE TaskMenuList
0 VALUE TaskMenuAction

: NextMenuID ( -- id)
    MenuID 1+! MenuID @ ;

: azTaskName ( cron-node -- a u )
    >R
    PAD 0!
    R@ CRON-FLAGS @ CF-ACTIVE AND 0= IF S" -- " PAD +ZPLACE THEN
    R@ CRON-NAME @ COUNT PAD +ZPLACE
\    R@ CRON-FLAGS @ CF-ACTIVE AND IF S"  --" PAD +ZPLACE THEN
    PAD ASCIIZ>
    RDROP
;
0
CELL -- MENU-ID
CELL -- MENU-ACTION
CELL -- MENU-PAR
CONSTANT /MENU

0 VALUE only-crontab

: ADD-CRON-MENU-ITEM { cron-node id \ item -- }
    /MENU ALLOCATE THROW TO item
    id item MENU-ID !
    TaskMenuAction item MENU-ACTION !
    cron-node item MENU-PAR !
    item TaskMenuList AddNode
;

: CRON-MENUITEM { cron-node \ menu-id -- ? }
    cron-node CRON-NAME @ COUNT CLASSIC? 0=
\ *     only-crontab ?DUP IF COUNT 2DUP TYPE SPACE cron-node CRON-FILENAME @ COUNT 2DUP TYPE CR COMPARE 0= AND THEN
    IF
        NextMenuID TO menu-id
        cron-node menu-id ADD-CRON-MENU-ITEM
        
        cron-node azTaskName menu-id MENUITEM
        TRUE
    ELSE
        FALSE
    THEN
;
27 VALUE #menu-lines

: MakeTaskMenu { list \ cnt -- }
    0 TO cnt
    list
    BEGIN @ ?DUP WHILE
        DUP CRON-NAME @ 1+ C@
        IF
            DUP CRON-MENUITEM
            IF
                cnt 1+ TO cnt
                cnt #menu-lines > OVER @ 0= 0= AND
                  IF POPUP RECURSE S" more..." END-POPUP EXIT THEN
            THEN
        THEN
    REPEAT
;

: del-menu-item ( list-node --)
    NodeValue FREE THROW
;
: start-task-action ( cron-node -- )
    EXEC-ACTION-TASK-U START-TASK \ CLOSE-FILE DROP
;

USER-CREATE exe-buf 256 USER-ALLOT
VARIABLE Editor
: Editor: get-string EVAL-SUBST S>ZALLOC Editor ! ;
: .txt S" .txt" ;
: edit-file ( a u -- )
    Editor @ DUP 
    IF PAD SWAP ASCIIZ> 
        SEARCH-PATH NIP NIP 0=
    THEN
    IF
        Editor @ ASCIIZ> exe-buf ZPLACE TRUE
    ELSE
        .txt GET-EXE-BY-EXT DUP >R exe-buf ZPLACE R> 0<>
    THEN
    IF
        S"  " exe-buf +ZPLACE
        exe-buf +ZPLACE
        0 exe-buf ASCIIZ> GUIStartApp
    ELSE
        2DROP
        ERR-MSG: "You have not default text editor."
    THEN
;


: STARTW START >R -1 R@ WAIT THROW DROP  R> CloseHandle DROP ;
CREATE ES-BUF 256 ALLOT
:NONAME
    >R R@ COUNT EVAL-SUBST R@ PLACE
    R> +PLACE0
; TASK: EVAL-SUBST-TASK

: EVAL-SUBST1 ( a u -- a u1 )
    ES-BUF PLACE ES-BUF EVAL-SUBST-TASK STARTW
    ES-BUF COUNT ;

: show-log  cron.log EVAL-SUBST1 edit-file ;

\ : edit-task-action ( cron-node -- )
\    CRON-FILENAME @ COUNT edit-file ;
CREATE <qt> 1 C,  CHAR " C,     \ "
: qt <qt> COUNT ;

: edit-task-action { cron-node -- }
    tm.exe exe-buf PLACE
    S" EditTask " exe-buf +PLACE
    qt exe-buf +PLACE cron-node CRON-FILENAME @ COUNT exe-buf +PLACE qt exe-buf +PLACE
    S"  " exe-buf +PLACE
    cron-node CRON-NAME @ COUNT exe-buf +PLACE
    exe-buf +PLACE0
\    exe-buf COUNT TYPE CR
    0 exe-buf COUNT GUIStartApp
;

0 VALUE is-crontab-set
: (set-first-crontab)
    is-crontab-set IF DROP EXIT THEN
    NodeValue DUP TAB-FILENAME @ COUNT EVAL-SUBST EXIST?
    IF TAB-FILENAME @ COUNT EVAL-SUBST exe-buf +PLACE
        TRUE TO is-crontab-set
    ELSE DROP THEN
;
: set-first-crontab
    0 TO is-crontab-set
    ['] (set-first-crontab) TAB-LIST DoList
    is-crontab-set 0= IF S" nncron.tab" exe-buf +PLACE THEN
;
: place-crontab
    qt exe-buf +PLACE set-first-crontab qt exe-buf +PLACE ;

: StartTM ( a u -- )
    tm.exe exe-buf PLACE
    exe-buf +PLACE exe-buf +PLACE0
    0 exe-buf COUNT GUIStartApp
;

: START-CONSOLE2
    BEGIN RemConsoleIsStarted @ 0= WHILE 1000 PAUSE REPEAT
    S"  Console localhost %RemConsolePort @%" EVAL-SUBST
    StartTM
;

:NONAME { delay -- }
    BEGIN LOGGEDON? 0= WHILE 1000 PAUSE REPEAT
    RemConsole @
    IF
        delay PAUSE
        START-CONSOLE2
    ELSE
        START-CONSOLE1
    THEN
; TASK: START-CONSOLE-TASK

: (START-CONSOLE) START-CONSOLE-TASK START CLOSE-FILE DROP ;
: START-CONSOLE 0 (START-CONSOLE) ;
: START-CONSOLE-AT-START 5000 (START-CONSOLE) ;

: add-new-task
    tm.exe exe-buf PLACE
    S"  AddTask " exe-buf +PLACE
    place-crontab
    exe-buf +PLACE0
\    exe-buf COUNT TYPE CR
    0 exe-buf COUNT GUIStartApp
;
: add-reminder
    tm.exe exe-buf PLACE
    S"  AddReminder " exe-buf +PLACE
    place-crontab
    exe-buf +PLACE0
    0 exe-buf COUNT GUIStartApp
;

: options S" Options" StartTM ;
: about   S" About %SVERSION%" EVAL-SUBST 2DUP TYPE CR StartTM ;
: winspy  S" WinSpy"  StartTM ;
: reload-crontab TAB-EVENT ?DUP IF SetEvent DROP THEN ;

: TMMessage ( a u -- )
    tm.exe exe-buf PLACE
    S"  Message " exe-buf +PLACE
    exe-buf +PLACE
    exe-buf +PLACE0
    0 exe-buf COUNT GUIStartApp
;


: edit-crontab-action ( name -- )  COUNT EVAL-SUBST1 edit-file ;

: CRONTAB-MENUITEM { crontab-item \ tab-name menu-id -- }
    crontab-item NodeValue TAB-FILENAME @ TO tab-name
    tab-name COUNT EVAL-SUBST1 EXIST?
    IF
\ *         POPUP
            NextMenuID TO menu-id
            tab-name menu-id ADD-CRON-MENU-ITEM
\ *             ( PAD COUNT) S" Entire crontab" menu-id MENUITEM
\ *             tab-name TO only-crontab
\ *             DBG( ." only-crontab=" only-crontab . CR )
\ *             ['] edit-task-action TO TaskMenuAction CRON-LIST MakeTaskMenu
            tab-name COUNT EVAL-SUBST1 S" Crontab: " PAD PLACE PAD +PLACE PAD +PLACE0
            PAD COUNT menu-id MENUITEM
\ *             PAD COUNT
\ *         END-POPUP
    THEN
;

: MakeCrontabMenu   ['] CRONTAB-MENUITEM TAB-LIST DoList ;

101 CONSTANT MI_OPTIONS
102 CONSTANT MI_ADDTASK
103 CONSTANT MI_EXIT
104 CONSTANT MI_HELP
105 CONSTANT MI_ADDRMNDR
106 CONSTANT MI_ABOUT
107 CONSTANT MI_SHOWLOG
108 CONSTANT MI_REGISTER
109 CONSTANT MI_WINSPY
110 CONSTANT MI_CONSOLE
111 CONSTANT MI_RELOAD
112 CONSTANT MI_DISABLE
113 CONSTANT MI_ENABLE


CEZ: MakePopup \ -- h
\ Получить размер десктопа
\ *     0 0 0 0 SP@ GetDesktopWindow GetClientRect DROP
\ *     2DROP DROP 640 = IF 20 ELSE 30 THEN TO #menu-lines

    120 MenuID ! TaskMenuList 0!
    POPUPMENU
       ItemOptions @ IF 10 RES MI_OPTIONS  MENUITEM THEN
       11 RES MI_HELP     MENUITEM
       POPUP
          21 RES MI_WINSPY MENUITEM
          ItemConsole @ IF  22 RES MI_CONSOLE MENUITEM THEN
          20 RES END-POPUP
       MENUSEPARATOR
       0 TO only-crontab
       ['] start-task-action TO TaskMenuAction
       POPUP CRON-LIST MakeTaskMenu 12 RES END-POPUP
       POPUP
            ['] edit-crontab-action TO TaskMenuAction
                MakeCrontabMenu
            0 TO only-crontab
            ['] edit-task-action TO TaskMenuAction
            CRON-LIST MakeTaskMenu
         13 RES END-POPUP
       18 RES MI_SHOWLOG MENUITEM
       ItemReload @ IF 23 RES MI_RELOAD MENUITEM THEN
       MENUSEPARATOR
       14 RES MI_ADDTASK MENUITEM
       16 RES MI_ADDRMNDR MENUITEM
       MENUSEPARATOR
       ItemSuspend @
       IF
           DISABLE-CRON? IF 25 RES MI_ENABLE ELSE 24 RES MI_DISABLE THEN MENUITEM
       THEN
       17 RES MI_ABOUT MENUITEM
       ItemExit @ IF 15 RES MI_EXIT MENUITEM THEN
       kfil EXIST? 0=
       IF
           MENUSEPARATOR
           19 RES MI_REGISTER MENUITEM
       THEN

    END-MENU
\    DUP popupMenu !
;CEZ

: CalcMenuYX ( -- y x)
    0 0 SP@ GetCursorPos DROP
\    ." Cursor pos:" 2DUP . . CR
;
0 VALUE CHOICED-MENU-ID

: exec-menu-item { list-node \ menu-item -- }
    list-node
        NodeValue
        TO menu-item
    menu-item MENU-ID @ CHOICED-MENU-ID =
    IF  menu-item MENU-PAR @
        menu-item MENU-ACTION @ EXECUTE
    THEN
;

: edit-tab-file
    TAB-LIST @ ?DUP
    IF CELL+ @ TAB-FILENAME @ COUNT EVAL-SUBST edit-file THEN
;

: rus? 160 RES S" Понедельник" COMPARE 0= ;

: buy
    rus?
    IF S" xReg" StartTM
    ELSE
\        S" To register nnCron go to\%777 RES%"  EVAL-SUBST
\        TMMessage
        GUI-HIDE ON
        0 S" %ComSpec% /c Start %QUOTE% %QUOTE% %QUOTE%%777 RES%%QUOTE%" EVAL-SUBST 2DUP TYPE CR GUIStartApp
        1000 PAUSE
        GUI-HIDE OFF
    THEN
;

: open-help { \ chm? -- }
    0 HelpFile GUIStartApp
(
    0 TO chm?
    rus?
    IF
        S" nnCron_ru.chm" 2DUP EXIST? DUP TO chm?
        0= IF 2DROP S" txt\readme.rus.txt" THEN
    ELSE
        S" nnCron.chm" 2DUP EXIST? DUP TO chm?
        0= IF 2DROP S" readme.txt" THEN
    THEN

\    chm?
\    IF
        0 ROT ROT GUIStartApp
\    ELSE
\        edit-file
\    THEN
)
;

: LOGGEDON-ADMIN? { \ tray-pid htoken -- ? }
    LOGGEDON?
    IF
        AT tray-pid LOGGEDON? GetWindowThreadProcessId DROP
[ DEBUG? ] [IF] ." LOGGEDON-ADMIN?: tray-pid= " tray-pid . CR [THEN]
        tray-pid GET-PROC-TOKEN ?DUP
            IF [ DEBUG? ] [IF] ." Can't get token. ERROR: " DUP . CR [THEN] 2DROP FALSE EXIT THEN
[ DEBUG? ] [IF] ." LOGGEDON-ADMIN?: htoken= " DUP . CR [THEN]            
        TO htoken
        htoken ['] is-admin? CATCH ?DUP
            htoken CLOSE-FILE DROP
        IF [ DEBUG? ] [IF] ." is-admin ERROR: " DUP . CR [THEN]  DROP FALSE THEN
\         TRUE
    ELSE FALSE THEN
;



: AdminIcon? WinNT? IconForAdminsOnly @ AND IF LOGGEDON-ADMIN? ELSE TRUE THEN ;



VARIABLE hIcon
VARIABLE hIconX
VARIABLE hCurIcon

: GetHIcon
    hIcon @ 0=
    IF
        S" icon16" DROP LoadIconResource16 hIcon !
        S" icon16x" DROP LoadIconResource16 hIconX !
\        S" icon16" DROP  HINST LoadIcon hIcon !
\        S" icon16x" DROP HINST LoadIcon hIconX !
    THEN
    DISABLE-CRON? IF  hIconX ELSE hIcon THEN @
;

: set-icon
   SysTrayIcon? AdminIcon? AND
   IF CronIcon BalloonOFF GetHIcon DUP CronIcon ModifyIcon
   ELSE 0 THEN
   hCurIcon !
;
: ?-NNCRON-HOME-DIR 
    nnCronHomeDir @ 
    IF
        S" %CRLF%%nnCronHomeDir @ ASCIIZ>%" EVAL-SUBST 
    ELSE S" " THEN 
;
: TrayIconToolTip
    S" %ServiceName%%?-NNCRON-HOME-DIR%" EVAL-SUBST
;
: create-icon
    [ DEBUG? ] [IF] ." create icon begin" CR [THEN]
    AdminIcon?
    IF 
       CronIcon BalloonOFF
       \ ServiceName 
       TrayIconToolTip GetHIcon CronIcon Create
       set-icon
    ELSE CronIcon CreateWindow THEN
    [ DEBUG? ] [IF] ." create icon end" CR [THEN]
;

: SUSPEND-CRON suspend.flg FCREATE set-icon S" nnCron is suspended" CRON-LOG ;
: RESUME-CRON  suspend.flg DELETE-FILE DROP set-icon S" nnCron is resumed" CRON-LOG ;

: DISABLE-CRON SUSPEND-CRON ;
: ENABLE-CRON RESUME-CRON ;

: test-icon
    SysTrayIcon? AdminIcon? AND
    IF
        GetHIcon hCurIcon @ <>
        IF
           DISABLE-CRON? IF DISABLE-CRON ELSE ENABLE-CRON THEN
        THEN
    THEN
;


: START-MENU-ITEM ( menu-id )
\    DUP . CR
    DUP TO CHOICED-MENU-ID
    CASE
        MI_EXIT OF EXIT-CRON ENDOF
        MI_OPTIONS OF options ENDOF
        MI_ADDTASK OF add-new-task ENDOF
        MI_HELP OF open-help ENDOF
        MI_ADDRMNDR OF add-reminder ENDOF
        MI_ABOUT OF about ENDOF
        MI_SHOWLOG OF show-log ENDOF
        MI_REGISTER OF buy ENDOF
        MI_WINSPY OF winspy ENDOF
        MI_CONSOLE OF START-CONSOLE ENDOF
        MI_RELOAD OF reload-crontab ENDOF
        MI_DISABLE OF DISABLE-CRON set-icon ENDOF
        MI_ENABLE OF ENABLE-CRON set-icon ENDOF
\        ." exec-menu-item list" CR
        ['] exec-menu-item TaskMenuList DoList
    ENDCASE
;


WINAPI: TrackPopupMenuEx USER32.DLL

: menu
    [ DEBUG? ] [IF] ." Try to get menuObj" CR [THEN]
    menuObj GET
    [ DEBUG? ] [IF] ." Get menuObj ok" CR [THEN]

\    GetForegroundWindow >R

\    100 PAUSE

    test-icon

    CronIcon hWnd @ SetForegroundWindow DROP
    [ DEBUG? ] [IF] ." Start Make popup" CR [THEN]
    MakePopup >R
    [ DEBUG? ] [IF] ." Stop Make popup" CR [THEN]

    0 MI_OPTIONS R@ SetMenuDefaultItem DROP
    [ DEBUG? ] [IF] ." Track popup" CR [THEN]
    0 CronIcon hWnd @ ( 0) CalcMenuYX
    TPM_RETURNCMD R@ TrackPopupMenuEx
    [ DEBUG? ] [IF] ." Choose popup" DUP . CR [THEN]
    ?DUP IF START-MENU-ITEM THEN
    R> DestroyMenu DROP
\    2DROP 2DROP 2DROP
    ['] del-menu-item TaskMenuList DoList
    TaskMenuList FreeList
    0 0 WM_USER CronIcon hWnd @ PostMessageA DROP
\    R> SetForegroundWindow DROP
\    R@ SetActiveWindow DROP
\    R@ SetFocus DROP
\    R@ SetForegroundWindow DROP
\    R> BringWindowToTop DROP
    menuObj RELEASE
;

: nncron-options
    CronINI edit-file
\    S" NNCron.%crlf%%crlf%Click right button on this icon to display menu." msgbox
;

\ UINT SetTimer(
\  HWND hWnd,              // handle of window for timer messages
\  UINT nIDEvent,          // timer identifier
\  UINT uElapse,           // time-out value
\  TIMERPROC lpTimerFunc   // address of timer procedure
\ );

VARIABLE h-tray-task
VARIABLE hTrayWnd

: set-tray-text CronIcon ModifyText ;

: TrayStop
  CronIcon hWnd @ IF 0 0 WM_ENDSESSION CronIcon hWnd @ PostMessageA DROP THEN ;

:NONAME { dwTime idEvent uMsg hwnd -- }
\    [ DEBUG? ] [IF] ." Loggedon: " LOGGEDON? . hTrayWnd @ . CR  [THEN]
    LOGGEDON? hTrayWnd @ <>
    IF  TrayChange ON TrayStop \ h-tray-task @ STOP
    ELSE
        test-icon
        \ SysTrayIcon @ 0= IF 0 0 WM_QUERYENDSESSION hwnd PostMessageA DROP THEN
    THEN
    0
; WNDPROC: tray-test

VARIABLE tray-timer-id
: set-tray-timer
    ['] tray-test 30000 0xAAA
    CronIcon hWnd @ SetTimer tray-timer-id !
;

: menuHotkey? menuHotkey 2@ OR 0<> ;

' options VALUE TrayIconDoubleClick
' menu    VALUE TrayIconRightButton
' NOOP    VALUE TrayIconBalloonClick

: TrayIconDoubleClick: get-string SFIND IF TO TrayIconDoubleClick ELSE 2DROP THEN ;
: TrayIconRightButton: get-string SFIND IF TO TrayIconRightButton ELSE 2DROP THEN ;
: TrayIconBalloonClick: get-string SFIND IF TO TrayIconBalloonClick ELSE 2DROP THEN ;

:NONAME
    [ DEBUG? ] [IF] ." Start TRAY " LOGGEDON? . CR  [THEN]
    2000 PAUSE
    10 0 DO ['] create-icon CATCH 0=
            IF LEAVE ELSE 10000 PAUSE THEN LOOP
    TrayIconDoubleClick CronIcon On2LB !
    TrayIconRightButton CronIcon OnRB !
    TrayIconBalloonClick CronIcon OnBalloonClick !
\    ['] OnLB CronIcon OnLB !
    ['] menu CronIcon OnHotkey !
    set-tray-timer
    menuHotkey? IF menuHotkey 2@ SWAP CronIcon SELF CronIcon hWnd @ RegisterHotKey DBG( ." menu RegisterHotKey=" DUP . GetLastError . CR) DROP THEN

    LOGGEDON? hTrayWnd !
    MessageLoop
    menuHotkey? IF CronIcon SELF CronIcon hWnd @ UnregisterHotKey DBG( ." menu UnregisterHotKey=" DUP . GetLastError . CR) DROP THEN
    CronIcon Delete
    tray-timer-id @ ?DUP IF KillTimer DROP THEN
    [ DEBUG? ] [IF] ." Stop TRAY " LOGGEDON? . CR  [THEN]
; TASK: make-tray1-task


VARIABLE isLogon

:NONAME DROP
debugWatchLogon IF .TIME  ." set-logon-task start " CR THEN
    BEGIN EXIT-95-HTASK @ 0= WHILE 1000 PAUSE REPEAT
\    300 0 DO watch-started @ IF LEAVE ELSE 1000 PAUSE THEN LOOP
    0 0 NN_IS_LOGON Send2CronWait
debugWatchLogon IF .TIME  ." set-logon-task stop " CR THEN    
    ; TASK: set-logon-task

: SetLogonEvent 0 set-logon-task START CLOSE-FILE DROP ;

: atStart? 
    GetTickCount [ 60 1000 * 2 * ] LITERAL < 
debugWatchLogon IF  .TIME ." atStart? = " DUP . CR THEN
    ;

: ExplorerDoesNotExistOrJustStarted?
    { \ pid -- ? }
    ExplorerExist ?DUP
    IF
        AT pid SWAP GetWindowThreadProcessId DROP
        debugWatchLogon IF .TIME ." pid = " pid . CR THEN
        pid ProcActiveTime 
        debugWatchLogon IF .TIME ." ProcActiveTime = " 2DUP D. ."  ms" CR THEN
        [ 60 1000 * ] LITERAL S>D D<
    ELSE TRUE THEN
debugWatchLogon IF .TIME ." ExplorerDoesNotExistOrJustStarted? = " DUP . CR THEN
;

:NONAME DROP
  WinNT? IF Event TO hTRAYev
            EXIT-95-START  THEN

  BEGIN
    S" make-tray-task" SP-TEST
    TrayChange @ 0=
        ExplorerDoesNotExistOrJustStarted?
        atStart? 
        OR
        AND
        isLogon !

    TrayChange OFF
debugWatchLogon IF .TIME ." Wait Explorer ... "  CR THEN
    BEGIN ExplorerExist 0= WHILE 1000 PAUSE REPEAT
debugWatchLogon IF .TIME ." Explorer exist "  CR THEN
debugWatchLogon IF .TIME ." isLogon = " isLogon @ . CR THEN

    isLogon @ IF SetLogonEvent THEN

    WinNT? 0= IF EXIT-95-START THEN

    SysTrayIcon?
    IF
        0 make-tray1-task START DUP h-tray-task !
        -1 SWAP WAIT THROW DROP h-tray-task @ CLOSE-FILE DROP
        h-tray-task 0!
        WinNT? 0= IF EXIT-95-HTASK @ STOP  EXIT-95-HTASK @ CLOSE-FILE DROP THEN
    ELSE
        WinNT?
        IF
            -1 hTRAYev WAIT THROW DROP
            hTRAYev ResetEvent DROP
        ELSE
            -1 EXIT-95-HTASK @ WAIT THROW DROP
             EXIT-95-HTASK @ CLOSE-FILE DROP
        THEN
    THEN
\    CB-STOP

    TrayChange @ 0=
    IF
        BEGIN ExplorerExist WHILE 1000 PAUSE REPEAT
    THEN

  AGAIN
; TASK: make-tray-task

: StartWinService 0 make-tray-task START CLOSE-FILE DROP ;
: DisableCronIcon CronIcon Delete SysTrayIcon OFF ;

WARNING @ WARNING 0!
: BeforeStop
    SysTrayIcon @ IF DisableCronIcon THEN
    BeforeStop
;
WARNING !

:NONAME
    TrayChange ON
    SysTrayIcon?
    SysTrayIcon OFF
    IF
        TrayStop
    THEN
; TO HIDE-ICON

:NONAME
    TrayChange ON
    SysTrayIcon @ 0= LOGGEDON? 0<> AND
    SysTrayIcon ON
    IF
\        CtrlWnd @ IF 0 0 WM_QUERYENDSESSION CtrlWnd @ PostMessageA DROP THEN
        hTRAYev SetEvent DROP
    THEN
; TO SHOW-ICON

VARIABLE BalloonIcon    1 BalloonIcon !
VARIABLE BalloonTime    10 1000 * BalloonTime !

: BALLOON ( a-title u1 a-text u2 -- )
    OnBalloonClick @ ?DUP 0= IF TrayIconBalloonClick THEN CronIcon OnBalloonClick !
    BalloonIcon @ BalloonTime @ CronIcon Balloon
;

: BALLOON: eval-string, eval-string, POSTPONE BALLOON ; IMMEDIATE

: MenuHotKey: get-string get-hot-key DBG( ." MenuHotkey=" 2DUP . . CR ) menuHotkey 2! ;
