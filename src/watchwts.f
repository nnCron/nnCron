\ WTS related tools

: WATCH-SESSIONID CUR-NODE CRON-SESSIONID @ ;

REQUIRE WM_WTSSESSION_CHANGE ~nn/lib/win/sec/wts.f
0x31070400 CONSTANT WatchWTSTag

: (WTS-WATCH) ( n -- )  WatchWTSTag (NUM-TAG-WATCH) ;

: WTSWatchConnect WTS_CONSOLE_CONNECT (WTS-WATCH) ; IMMEDIATE
: WTSWatchDisconnect WTS_CONSOLE_DISCONNECT (WTS-WATCH) ; IMMEDIATE
: WTSWatchLogon  WTS_SESSION_LOGON (WTS-WATCH) ; IMMEDIATE
: WTSWatchLogoff WTS_SESSION_LOGOFF (WTS-WATCH) ; IMMEDIATE
: WTSWatchLock   WTS_SESSION_LOCK (WTS-WATCH) ; IMMEDIATE
: WTSWatchUnlock WTS_SESSION_UNLOCK (WTS-WATCH) ; IMMEDIATE
: WTSWatchRemoteConnect WTS_REMOTE_CONNECT (WTS-WATCH) ; IMMEDIATE
: WTSWatchRemoteDisconnect WTS_REMOTE_DISCONNECT (WTS-WATCH) ; IMMEDIATE

: StartWatchByTypeSessionIdTag ( typ sessionid tag -- )
    SWAP ew-par2 !
    [NONAME ( w -- )
        ew-par2 @ OVER WATCH-CRON-NODE @ CRON-SESSIONID !
        DBG( ." StartWatchTypeTagSessionId=" DUP WATCH-CRON-NODE @ DUP CRON-NAME @ COUNT TYPE SPACE CRON-SESSIONID @ . CR )
        qWS Put
    NONAME]
    ENUM-AW-BY-TAG ;
: SetWTSEvent ( typ sessionid -- ) WatchWTSTag StartWatchByTypeSessionIdTag ;

: ENUM-SESSIONS { \ buf cnt -- }
    AT cnt AT buf 1 0 WTS_CURRENT_SERVER_HANDLE WTSEnumerateSessionsA
    IF
        buf cnt /WTS_SESSION_INFO * OVER + SWAP
        DO
            ." Session "
            I sesiSessionId @ .
            I sesipWinStationName @AZ TYPE SPACE 
            I sesiState @ .WTSState CR
        /WTS_SESSION_INFO +LOOP
        buf WTSFreeMemory
    THEN
;

:NONAME { par \ evMask -- }
    BEGIN
        S" WTS-WAIT-TASK" SP-TEST
        0 TO evMask
        AT evMask
        [ WTS_EVENT_CONNECT WTS_EVENT_DISCONNECT OR 
            WTS_EVENT_LOGOFF OR WTS_EVENT_LOGON OR ] LITERAL
        WTS_CURRENT_SERVER_HANDLE
        WTSWaitSystemEvent 0<> evMask 0<> AND
[ DEBUG? ] [IF] CR ." ---------------------------" CR 
                .TIME
                ." WTSWaitSystemEvent: " 
        evMask WTS_EVENT_CONNECT AND IF ." WTS_EVENT_CONNECT " THEN
        evMask WTS_EVENT_DISCONNECT AND IF ." WTS_EVENT_DISCONNECT " THEN
        evMask WTS_EVENT_LOGOFF AND IF ." WTS_EVENT_LOGOFF " THEN
        evMask WTS_EVENT_LOGON AND IF ." WTS_EVENT_LOGON " THEN
        CR
        [THEN]
        IF
            menuObj GET
            \ try to start task
\             evMask WTS_EVENT_CONNECT AND IF 
            ENUM-SESSIONS
            .WTS-PROCESSES
            menuObj RELEASE
        THEN
    AGAIN
;

TASK: WTS-WAIT-TASK 

: SetWTSNotification
    WinXP?
    IF
        NOTIFY_FOR_ALL_SESSIONS CtrlWnd @ 
        WTSRegisterSessionNotification DROP
    ELSE
    Win2kServ? WinTS? AND
    IF
\        0 WTS-WAIT-TASK START CLOSE-FILE
    THEN THEN
;

WARNING @ WARNING 0!

: AfterControlWindowCreating
  SetWTSNotification
  AfterControlWindowCreating
;
WARNING !

SPEC-TASK? ON
:TASK WTS-TRAY-TASK
DEBUG? 0= [IF] NoLog [THEN]
NoActive
WTSWatchLogon 
AsLoggedUser
Rule: 
    WATCH-SESSIONID 
[ DEBUG? ] [IF] ." WTS-TRAY-TASK: sessionid= " DUP . CR [THEN]    
    0<> ;
Action:
    5000 PAUSE
    60 0 DO CPU-USAGE 10 < IF LEAVE THEN LOOP 
    NormalPriority
    StartIn: %ModuleDirName%
    START-APP: %ModuleDirName%\tray.exe %RemConsolePort @% %WATCH-SESSIONID% Tray localhost 
;
TASK;
SPEC-TASK? OFF

