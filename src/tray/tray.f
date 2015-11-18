\ $Id: tray.f,v 1.11 2004/11/18 15:00:29 nncron38 Exp $
\ Author: Nicholas Nemtsev
\ Creation time: 2004-11-14 

REQUIRE JenXPARSER ~nn/lib/xml/jenx.f
REQUIRE TrayIcon ~nn/lib/win/trayicon.f
REQUIRE S>TEMP ~nn/lib/memory/tempalloc.f
REQUIRE MENU  ~nn/lib/win/menu.f
REQUIRE AddNode ~nn/lib/list.f
REQUIRE [NONAME ~nn/lib/noname.f    \ ]
REQUIRE PROPERTY: ~nn/lib/lisp.f
REQUIRE LOGGEDON? ~nn/lib/win/windows/logged.f 
REQUIRE MessageLoop ~nn/lib/win/messageloop.f
REQUIRE STRING-FROM-FILE: ~nn/lib/fstring.f
REQUIRE BUILD! ~nn/lib/build.f
REQUIRE EXIST? ~nn/lib/find.f
REQUIRE JMP ~nn/lib/jmp.f
REQUIRE LoadIconResource16 ~nn/lib/win/image.f
REQUIRE FEX ~nn/lib/fex.f
REQUIRE GLOBAL ~nn/lib/globalloc.f

S" utils.f" INCLUDED
S" connect.f" INCLUDED
S" request.f"  INCLUDED
S" menu.f"    INCLUDED
S" options.f" INCLUDED

VARIABLE TrayChange
VARIABLE hTrayWnd
VARIABLE SESSIONID  
    -1 SESSIONID !


TrayIcon OBJECT: CronIcon

VARIABLE hIcon
VARIABLE hIconX

: get-hicon
    hIcon @ 0=
    IF
        S" icon16" DROP LoadIconResource16 hIcon !
        S" icon16x" DROP LoadIconResource16 hIconX !
\        S" icon16" DROP  HINST LoadIcon hIcon !
\        S" icon16x" DROP HINST LoadIcon hIconX !
    THEN
    DISABLE-CRON? IF  hIconX ELSE hIcon THEN @
;
: refresh-icon
    S" icontext" OPTION S" %1 esPICKS% [%SESSIONID @%]" EVAL-SUBST CronIcon ModifyText
    get-hicon CronIcon ModifyIcon
;
: create-icon
    CronIcon BalloonOFF
    S" " get-hicon CronIcon Create
    refresh-icon
;

: menu ." [" DEPTH . CR
    get-menu 0= OVER 0<> AND
    IF  >R
        CronIcon hWnd @ SetForegroundWindow DROP
\        MakePopup >R
        0 defaultId @ R@ SetMenuDefaultItem DROP
        0  CronIcon hWnd @ CalcMenuYX 
        TPM_RETURNCMD R@ TrackPopupMenuEx
        ?DUP IF START-MENU-ITEM THEN
        R> DestroyMenu DROP
        0 0 WM_USER CronIcon hWnd @ PostMessageA DROP
        [NONAME NodeValue DELETE NONAME] TRAY-MENU-LIST DoList
    ELSE DROP THEN
    ." ]" DEPTH . CR
;
: options ;
: menu-and-refresh
\    ONLY FORTH DECIMAL
    get-options DROP
    refresh-icon
    menu
;
' BYE VALUE TrayIconDoubleClick
' menu-and-refresh    VALUE TrayIconRightButton
' NOOP    VALUE TrayIconBalloonClick

: test-icon
;

: TrayStop
  CronIcon hWnd @ IF 0 0 WM_ENDSESSION CronIcon hWnd @ PostMessageA DROP THEN ;
:NONAME { dwTime idEvent uMsg hwnd -- }
    LOGGEDON? hTrayWnd @ <>
    IF  TrayChange ON TrayStop \ h-tray-task @ STOP
    ELSE
        test-icon
    THEN
    0
; WNDPROC: tray-test

VARIABLE tray-timer-id

: set-tray-timer
    ['] tray-test 30000 0xAAA
    CronIcon hWnd @ SetTimer tray-timer-id !
;

: main-loop
    10 0 DO ['] create-icon CATCH 0=
            IF LEAVE ELSE 10000 PAUSE THEN LOOP
    TrayIconDoubleClick CronIcon On2LB !
    TrayIconRightButton CronIcon OnRB !
    TrayIconBalloonClick CronIcon OnBalloonClick !
    set-tray-timer
    LOGGEDON? hTrayWnd !
    MessageLoop
    CronIcon Delete
    tray-timer-id @ ?DUP IF KillTimer DROP THEN
;

WARNING @ WARNING 0!
: BYE
    [NONAME CronIcon Delete NONAME] CATCH DROP
    BYE
;
WARNING !
: wait-logon BEGIN LOGGEDON? 0= WHILE ." ." 1000 PAUSE REPEAT ;
: wait-logoff BEGIN LOGGEDON? WHILE ." *" 1000 PAUSE REPEAT ;

: main
    get-options DROP
    BEGIN
        wait-logon
        TrayChange OFF
        main-loop
        TrayChange @ 0= IF wait-logoff THEN 
    AGAIN
;

: Tray \ hostname ( port sessionid -- )
    DUP . SESSIONID ! DUP . RemPort !
    get-string 2DUP TYPE CR S>ZALLOC RemHost !
    main
;

: CrashTest
    BEGIN
      DEPTH .
      get-menu 0= OVER 0<> AND
      IF ." ok"  DestroyMenu DROP ELSE ." bad" DROP THEN
      100 PAUSE CR
    AGAIN
;
VARIABLE num.out
: tray.num.out 
    <# 0 HOLD S" .out" HOLDS num.out @ S>D # # # # 
        S" out\" HOLDS  #> ;
: open-tray.num.out
    TRAY-OUT IF CLOSE-FILE DROP THEN
    tray.num.out R/W CREATE-FILE-SHARED
    IF DROP
    ELSE
      TO TRAY-OUT
      TRAY-OUT TO H-STDOUT
      TRAY-OUT TO H-STDERR
    THEN
    num.out 1+!
;
: CrashTest2
    10 0 DO
      open-tray.num.out
      S" MEM BYE" Request . TYPE CR
      100 PAUSE CR
    LOOP
    BYE
;
VARIABLE numCrashTest3
: CrashTest3
    CON-DONT-ALLOC ON
    1000 0
    DO
      numCrashTest3 @ 100 MOD 0= 
      IF
        open-tray.num.out
        S" MEM BYE"  Request DROP 2DROP 
        open-tray.out
      THEN

      S" BYE" Request DROP 2DROP
      100 PAUSE CR
      numCrashTest3 1+!
    LOOP
;


TRUE TO SPF-INIT?
:NONAME
   open-tray.out
; ' SPF-INI JMP

' main TO <MAIN>
TRUE TO ?GUI
0 MAINX !

CR .( End of building.) CR
DEBUG? [IF] BUILD! [ELSE] BUILD++ [THEN]
256 1024 * TO IMAGE-SIZE

REQUIRE RESOURCES: ~nn/~yz/resources.f

RESOURCES: tray.fres

S" tray.exe" SAVE

0 HALT
