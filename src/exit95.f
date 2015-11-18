\ REQUIRE  WinClass ~nn/lib/win/winclass.f
REQUIRE  TrayIcon ~nn/lib/win/trayicon.f
REQUIRE { ~nn/lib/locals.f \ }
REQUIRE MessageLoop ~nn/lib/win/messageloop.f

\ 0x02B1 CONSTANT WM_WTSSESSION_CHANGE

: SysTrayIcon? SysTrayIcon @ ;
0 VALUE hTRAYev


VARIABLE EXIT-95-HTASK
VARIABLE good_time

0
1 CELLS -- cp-dwData
1 CELLS -- cp-cbData
1 CELLS -- cp-lpData
DROP

VECT SHOW-ICON
VECT HIDE-ICON

: CB-DEL
    IsCBMonitor @
    IF
        CtrlWnd @
        IF CB-NEXT-HWND @ CtrlWnd @ ChangeClipboardChain DROP THEN
    THEN
    IsCBMonitor OFF
;


VARIABLE is-deferred-shutdown
VARIABLE deferred-shutdown-timer-id
5000 VALUE deferred-shutdown-delay
:NONAME { dwTime idEvent uMsg hwnd -- }
    is-deferred-shutdown @
    IF
        SHUTDOWN
    THEN
; WNDPROC: deferred-shutdown-task

: set-deferred-shutdown-timer { hwnd -- }
    ['] deferred-shutdown-task deferred-shutdown-delay 0xABC
    hwnd SetTimer deferred-shutdown-timer-id !
;

: ENDSESSION ( lparam -- )
    ENDSESSION_LOGOFF AND 0<>
    IF
\        ." LOGOFF" CR
        \ Logoff
        0 SetWinOffEvent
    ELSE
        \ Shutdown
\        ." SHUTDOWN" CR
        1 SetWinOffEvent
    THEN
    WinNT? SysTrayIcon? 0= AND
    IF hTRAYev SetEvent DROP THEN
;

: WinFLAG IF 1 ELSE 0 THEN ;

: WAIT-INTERCEPT { v -- 0/1}
    50 0 DO 100 PAUSE v @ IF LEAVE THEN LOOP
    v @ 0= WinFLAG
;

: QUERYENDSESSION ( lparam -- 1/0)
    ENDSESSION_LOGOFF AND 0<>
    IF
\        ." QLOGOFF" CR
        \ QueryLogoff
        <INTERCEPT-LOGOFF> OFF
        8 SetWinOffEvent
        \ wait for 5 sec
        <INTERCEPT-LOGOFF> WAIT-INTERCEPT
    ELSE
        \ QueryShutdown
\        ." QSHUTDOWN" CR
        <INTERCEPT-SHUTDOWN> OFF
        9 SetWinOffEvent
        
        <CONTINUE-SHUTDOWN> @ 0=
        IF
            \ wait for 5 sec
            <INTERCEPT-SHUTDOWN> WAIT-INTERCEPT
        ELSE
            1
        THEN
    THEN
;

: RELOAD-CRONTAB TAB-EVENT ?DUP IF SetEvent DROP THEN ;

: n-az ( a n -- a )  0 ?DO ASCIIZ> + 1+ LOOP ;

0 VALUE WM_DEVICECHANGE-DEBUG
0 VALUE HOTKEY-DEBUG
VARIABLE POWER-DEBUG
\ VARIABLE xCNT
:NONAME  { lparam wparam uMsg hwnd \ buf -- }
\    xCNT 1+! xCNT @ DUP . CR 100 >
\    IF 0 S" xxxx" DROP S" xxxx" DROP 0 MessageBoxA DROP
\        xCNT 0!
\    THEN

\    DBG( ." CtrlWin: " uMsg HEX . wparam . lparam . DECIMAL CR )

    uMsg WM_QUERYENDSESSION = IF
        WinNT? 
        IF 
            lparam QUERYENDSESSION EXIT
        ELSE 
            lparam ENDSESSION 3000 PAUSE  0 PostQuitMessage DROP 
            1 EXIT
        THEN
    THEN

\    uMsg WM_ENDSESSION = IF ." ENDSESSION: " HEX lparam . wparam . DECIMAL CR THEN

    uMsg WM_ENDSESSION = wparam 0<> AND
    IF
\        ." ENDSESSION OK: " HEX lparam . wparam . DECIMAL CR
        \ Endsession
        CB-DEL
        WinNT? IF lparam ENDSESSION ELSE 0 PostQuitMessage DROP THEN
    THEN

    uMsg
    CASE
    WM_WTSSESSION_CHANGE OF
        DBG( ." *********** WM_WTSSESSION_CHANGE: wparam=" wparam . ." lparam=" lparam . CR )
        wparam lparam SetWTSEvent
        0
    ENDOF
    WM_POWERBROADCAST OF
\        DBG( ." WM_POWERBROADCAST=" wparam . CR )
        POWER-DEBUG @
        IF
            ." WM_POWERBROADCAST: wparam=" wparam . ." lparam=" lparam . CR
        THEN
        wparam SetPowEvent
        1
        ENDOF
    WM_DESTROY OF CB-DEL 0
        [ DEBUG? ] [IF] ." WM_DESTROY" CR [THEN]
        ENDOF

    WM_COPYDATA OF
        wparam RUN_TASK =
        IF
            [ DEBUG? ] [IF] ." RUN TASK: "  lparam cp-lpData @ lparam cp-cbData @ TYPE CR [THEN]
            lparam cp-lpData @ lparam cp-cbData @  \ 2DUP PAD1 ZPLACE
            SFIND
            IF
               EXECUTE @ EXEC-ACTION-TASK-U START-TASK
               TRUE
            ELSE 2DROP
                FALSE
            THEN
        ELSE
        wparam NN_TEST_LOGON =
        IF
            512 ALLOCATE THROW TO buf
            lparam cp-lpData @ buf lparam cp-cbData @ CMOVE
            0 SP@
            LOGON32_PROVIDER_DEFAULT
            lparam cp-dwData @ \ DUP . CR
            buf 1 n-az \ DUP ASCIIZ> TYPE CR
            buf 2 n-az \ DUP ASCIIZ> TYPE CR
            buf        \ DUP ASCIIZ> TYPE CR
            LogonUserA
            IF
                CLOSE-FILE DROP
                0
            ELSE
                DROP
                GetLastError
            THEN
            buf FREE DROP
        ELSE
            wparam
            lparam cp-lpData @ lparam cp-cbData @
            lparam cp-dwData @
    [ DEBUG? ] [IF] ." WM_COPYDATA: " DUP .  >R 2DUP TYPE R> CR  [THEN]
            SetWinWatchEvent
            TRUE
        THEN THEN
        ENDOF

    WM_HOTKEY OF
        [ DEBUG? ] [IF] ." hot key is pressed " HEX lparam . wparam . DECIMAL CR [THEN]
        wparam SetHotKeyEvent
        TRUE
        ENDOF

    NN_REG_HOT_KEY OF
    HOTKEY-DEBUG IF ." NN_REG_HOT_KEY " CR THEN
                    hwnd RegisterHotKeys TRUE  ENDOF

    NN_UNREG_HOT_KEY OF
    HOTKEY-DEBUG IF ." NN_UNREG_HOT_KEY " CR THEN
                    hwnd UnregisterHotKeys TRUE ENDOF

    NN_REG_HOT_KEY1 OF
    HOTKEY-DEBUG IF ." NN_REG_HOT_KEY1 " CR THEN
                    ( lparam is WATCH)
                    lparam WATCH-PAR1 @
                    lparam WATCH-PAR2 @
                    lparam WATCH-PAR @ 0xFF AND
                    hwnd RegisterHotKey DROP
                    TRUE  ENDOF

    NN_UNREG_HOT_KEY1 OF
    HOTKEY-DEBUG IF ." NN_UNREG_HOT_KEY1 " CR THEN
                    lparam WATCH-PAR @ 0xFF AND hwnd UnregisterHotKey DROP
                    TRUE ENDOF

    MY_EXIT OF  0 PostQuitMessage DROP   good_time ON  TRUE   ENDOF

    TAB_RELOAD OF RELOAD-CRONTAB ( TAB-EVENT ?DUP IF SetEvent DROP THEN) 0   ENDOF

    WM_DEVICECHANGE OF
        WM_DEVICECHANGE-DEBUG
        IF
            ." WM_DEVICECHANGE " wparam . lparam . CR
            lparam ?DUP IF 18 DUMP CR THEN
        THEN
        wparam DBT_DEVICEARRIVAL =
        wparam DBT_DEVICEREMOVECOMPLETE = OR
        IF  [ DEBUG? ] [IF] ." WM_DEVICECHANGE " lparam . wparam . CR [THEN]
            lparam wparam
            CASE DBT_DEVICEARRIVAL        OF 0    ENDOF
                 DBT_DEVICEREMOVECOMPLETE OF 0x80 ENDOF
            ENDCASE
            SetWatchCDEvent 1
        THEN
        ENDOF

    NN_HIDE_ICON OF  HIDE-ICON 1 ENDOF

    NN_SHOW_ICON OF  SHOW-ICON TRUE  ENDOF


    NN_CB_START OF
        [ DEBUG? ] [IF] ." NN_CB_START " wparam . lparam . CR [THEN]
        0 SetLastError DROP
        hwnd SetClipboardViewer DUP hwnd <> IF DUP CB-NEXT-HWND ! THEN
        0=
         IF GetLastError DUP 0= IsCBMonitor !
            IF S" SetClipboardViewer ERROR # %GetLastError%" CRON-LOG THEN
         THEN
        TRUE
        ENDOF

    NN_CB_STOP OF
        [ DEBUG? ] [IF] ." NN_CB_STOP " wparam . lparam . CR [THEN]
        CB-DEL
        TRUE
        ENDOF

    NN_IS_LOGON
        OF
            last-logged!
            2 SetWinOffEvent
            1
        ENDOF

    WM_CHANGECBCHAIN OF
        [ DEBUG? ] [IF] ." WM_CHANGECBCHAIN WinCtrl=" hwnd . wparam . lparam . CR [THEN]
        wparam CB-NEXT-HWND @ =
        IF
            lparam CB-NEXT-HWND !
        ELSE
            CB-NEXT-HWND @
            IF lparam wparam uMsg CB-NEXT-HWND @ SendMessageA DROP THEN
        THEN
        0 ENDOF

    WM_DRAWCLIPBOARD OF
        [ DEBUG? ] [IF] ." WM_DRAWCLIPBOARD " wparam . lparam .  hwnd . CB-NEXT-HWND @ . CR [THEN]
\        GetClipboardSequenceNumber DUP
\        CBSeqN @ <>
\        IF CBSeqN !
            FREE-<CLIPBOARD>
            SetCBEvent
\        ELSE DROP THEN
        CB-NEXT-HWND @
        IF lparam wparam uMsg CB-NEXT-HWND @ SendMessageA DROP THEN
        0
        ENDOF

        lparam wparam uMsg hwnd DefWindowProcA SWAP
    ENDCASE
;
WNDPROC: ctrl-proc

WinClass POINTER pCtrlClass

0 VALUE CtrlId

: CtrlClass ( -- id )
    CtrlId ?DUP IF EXIT THEN
    WinClass NEW TO pCtrlClass
    ['] ctrl-proc pCtrlClass lpfnWndProc !
    0 pCtrlClass style !
    CtrlClassName  DROP pCtrlClass lpszClassName !
    pCtrlClass Register TO CtrlId
    CtrlId
;

: nnCronWindowTitle
    ServiceName PAD ZPLACE
    S"  control window" PAD +ZPLACE
    PAD ;

WITH TrayIcon
: EXIT-95-LOOP
\  S" Ok. EXIT-95 started" MsgBox
  good_time OFF
  CtrlClass 0 0 Window CtrlWnd !
  GetCurrentThreadId CtrlThrId !
  CtrlWnd @ 0= IF ( S" Can't create window" MsgBox) EXIT THEN
  nnCronWindowTitle 0 WM_SETTEXT CtrlWnd @ SendMessageA DROP
  C" AfterControlWindowCreating" FEX

\  0 GetKeyboardLayout [CHAR] p VkKeyScanExA
\  MOD_ALT MOD_CONTROL OR 1 CtrlWnd @ RegisterHotKey
\  ." RegisterHotKey=" . CR

  MessageLoop
  good_time @ IF EXIT-CRON THEN
;

ENDWITH
' EXIT-95-LOOP TASK: EXIT-95-TASK

: EXIT-95-START
    EXIT-95-HTASK 0!
    0 EXIT-95-TASK START EXIT-95-HTASK ! ;


: (Send2Cron) ( par1 par2 msg -- ?)
    0 CtrlClassName DROP FindWindowA ?DUP
    IF SendMessageA ELSE 2DROP DROP 0 THEN ;

: Send2Cron (Send2Cron) DROP ;

0 VALUE debugWatchLogon

:NONAME { msg -- }
\ debugWatchLogon  IF .TIME  ." Send2CronTask start. msg = " msg . CR THEN
    CtrlWnd @ 0= IF 300 0 DO 100 PAUSE CtrlWnd @ IF LEAVE THEN LOOP THEN
    CtrlWnd @
    IF
\ debugWatchLogon  IF .TIME  ." CtrlWnd exist." CR THEN
\        0 SP@ CtrlWnd @ GetWindowThreadProcessId NIP
\ debugWatchLogon  IF .TIME  ." CtrlWnd Thread = " DUP . CR THEN
\        ThreadActiveTime
\ debugWatchLogon  IF .TIME  ." ThreadActiveTime = " 2DUP D. CR THEN
\        2DROP
        0 0 msg CtrlWnd @ SendMessageA
\ debugWatchLogon  IF .TIME  ." SendMessageA = " DUP .
\            ." GetLastError = " GetLastError . CR THEN
        DROP
    ELSE
        S" Control window not ready"  CRON-LOG
    THEN
; TASK: Send2CronTask

: Send2CronWait ( msg -- ) Send2CronTask START CLOSE-FILE DROP 50 PAUSE ;

: CB-START ( 5000 PAUSE) IsCBMonitor @ IF NN_CB_START Send2CronWait THEN ;

: CB-STOP ( 5000 PAUSE) IsCBMonitor @ IF NN_CB_STOP Send2CronWait THEN ;


WARNING @ WARNING 0!
VARIABLE NN_UNREG_FirstTime NN_UNREG_FirstTime ON
: BeforeCrontabLoading
    \ UnregisterHotKeys
    NN_UNREG_FirstTime @
    IF
        NN_UNREG_FirstTime OFF
    ELSE
        NN_UNREG_HOT_KEY Send2CronWait
        CB-STOP
    THEN
    BeforeCrontabLoading
;

: AfterWatchStart
    CB-START
    AfterWatchStart
;

: AfterCrontabLoading
    \ RegisterHotKeys
    NN_REG_HOT_KEY Send2CronWait
    AfterCrontabLoading
;

: BeforeStop
    CB-STOP
    NN_UNREG_HOT_KEY Send2CronWait
    BeforeStop
;

WARNING !


