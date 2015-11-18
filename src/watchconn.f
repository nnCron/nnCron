1 CONSTANT RASCN_Connection    \ #define RASCN_Connection        0x00000001
2 CONSTANT RASCN_Disconnection \ #define RASCN_Disconnection     0x00000002

VARIABLE is-wait-conn?
VARIABLE is-wait-disconn?
VARIABLE prev-conn-state
128 CONSTANT conn-nlen
CREATE prev-conn-name conn-nlen ALLOT prev-conn-name conn-nlen ERASE

1 [IF]
: LAST-CONNECTION prev-conn-name ASCIIZ> ;

VARIABLE WATCH-CONN-DEBUG
: WATCH-CONN/DISCON-START { what \ ev -- handle}
    [ DEBUG? ] [IF] ." WATCH-CONN/DISCON:" GetCurrentThreadId . CR [THEN]    
\    h_ev_con=CreateEvent(NULL,TRUE,FALSE,ev_name_con);
    S" WATCH-CONN-DISCON-START" NamedEvent ?DUP \ 0 FALSE TRUE 0 CreateEventA ?DUP
    IF
        TO ev
        \    res=RasConnectionNotification(NULL,h_ev_con,RASCN_Connection);
        BEGIN
           what ev 0 RasConnectionNotificationA DUP 711 =
           \ WATCH-CONN-DEBUG @ IF OVER 5 = OR THEN
           OVER 5 = OR
        WHILE
            WATCH-CONN-DEBUG @ IF .TIME ."  WATCH-CONN/DISCON-START Error # 711" CR THEN
            DROP 1000 PAUSE
        REPEAT
        WATCH-CONN-DEBUG @ IF .TIME ."  WATCH-CONN/DISCON-START result " DUP . CR THEN
        ?DUP
        IF
            TO WATCH-ERR
            S" 'RasConnectionNotification' ERROR # %WATCH-ERR N>S% : "
            LOG-WATCH
        THEN
        ev
        WATCH-CONN-DEBUG @ IF .TIME ."  WATCH-CONN/DISCON-START ev " DUP . CR THEN
    ELSE
        0
    THEN
    [ DEBUG? ] [IF] ." WATCH-CONN/DISCON HANDLE:" DUP . CR [THEN]    
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\    CloseHandle DROP
\    0 0 1 0 CreateEventA ." h = " DUP . CR
;

\ : pcn-free
\    prev-conn-name @ ?DUP
\    IF GLOBAL FREE LOCAL DROP 
\       prev-conn-name 0!
\    THEN
\ ;

: CONN-STATE? ( -- ?)
    [ DEBUG? ] [IF] ." CONN-STATE:" GetCurrentThreadId . [THEN]    
    S" " ['] SONLINE? CATCH ?DUP IF ." CONN-STATE: SONLINE? ERROR #" . CR 2DROP FALSE EXIT THEN
    ( DROP prev-conn-state @ 0=) 
    DUP prev-conn-state ! DUP
    IF  
        ['] CONNECTION CATCH ?DUP IF ." CONN-STATE: CONNECTION ERROR #" . CR EXIT THEN
        ?DUP IF conn-nlen 1- MIN prev-conn-name ZPLACE ELSE DROP THEN
    THEN
    [ DEBUG? ] [IF] DUP . CR [THEN]    
;


: WATCH-CONNECT-START ( -- handle )
    RASCN_Connection is-wait-disconn? @ 0= IF RASCN_Disconnection OR THEN
    WATCH-CONN/DISCON-START 
    CONN-STATE? NUM-PASS 2 < AND
    IF DUP SetEvent DROP prev-conn-state OFF THEN
;

: WATCH-DISCONNECT-START ( -- handle )
    RASCN_Disconnection is-wait-conn? @ 0= IF RASCN_Connection OR THEN
    WATCH-CONN/DISCON-START ;

: WATCH-CONN-RULE ( -- ?)
    [ DEBUG? ] [IF] ." WATCH-CONN-RULE " [THEN]
    prev-conn-state @ 0=
    CONN-STATE? 0<> AND
    [ DEBUG? ] [IF] DUP . CR [THEN]
;

: WatchConnect (  -- )
    CRON-NODE ACTIVE? IF is-wait-conn? ON THEN
    POSTPONE WATCH:
    ['] WATCH-CONN-RULE WATCH-NODE WATCH-RULE !
    POSTPONE WATCH-CONNECT-START
    POSTPONE END-WATCH
;  IMMEDIATE


: WATCH-DISCON-RULE
    [ DEBUG? ] [IF] ." WATCH-DISCON-RULE " [THEN]
    prev-conn-state @ 0<>
    CONN-STATE? 0= AND
    [ DEBUG? ] [IF] DUP . CR [THEN]
;

: WatchDisconnect (  -- )
    CRON-NODE ACTIVE? IF CONN-STATE? DROP is-wait-disconn? ON THEN
    POSTPONE WATCH:
    ['] WATCH-DISCON-RULE  WATCH-NODE WATCH-RULE !
    POSTPONE WATCH-DISCONNECT-START
    POSTPONE END-WATCH
;  IMMEDIATE

[ELSE]

: WATCH-CONN/DISCON-START ( what S" event-name"  -- handle)
\    h_ev_con=CreateEvent(NULL,TRUE,FALSE,ev_name_con);
    DROP FALSE TRUE 0 CreateEventA
    DUP
    IF
        \    res=RasConnectionNotification(NULL,h_ev_con,RASCN_Connection);
        >R R@ 0 RasConnectionNotificationA ?DUP
        IF
            TO WATCH-ERR
            S" 'RasConnectionNotification' ERROR # %WATCH-ERR N>S% : "
            LOG-WATCH
        THEN
        R>
    ELSE
        DROP
    THEN
;
: WATCH-CONNECT-START ( -- handle )
    RASCN_Connection  S" nncron_watch_connect_event"
    WATCH-CONN/DISCON-START ;

: WATCH-DISCONNECT-START ( -- handle )
    RASCN_Disconnection S" nncron_watch_disconnect_event"
    WATCH-CONN/DISCON-START ;

: WatchConnect (  -- )
    POSTPONE WATCH:
    POSTPONE WATCH-CONNECT-START
    POSTPONE END-WATCH
;  IMMEDIATE

: WatchDisconnect (  -- )
    POSTPONE WATCH:
    POSTPONE WATCH-DISCONNECT-START
    POSTPONE END-WATCH
;  IMMEDIATE

[THEN]

\ -- MonitorResponseTime specifies minimal time in ms before two 
\    'watch' event (See WatchDir:, WatchFile: etc.) 
: MonitorResponseTime: 
    get-number
    ?DUP IF TO MonitorResponseTime THEN ; IMMEDIATE

WARNING @ WARNING 0!
: BeforeCrontabLoading
    is-wait-conn? OFF
    is-wait-disconn? OFF
\    prev-conn-state 0!
    BeforeCrontabLoading
;
 
: BeforeStop
    BeforeStop
;
WARNING !

