\ Watch's definitions

\ 1000 VALUE WatchDirDelay    \ 2 sec
100 VALUE MonitorResponseTime \ ms
VARIABLE watch-started
1000 60 * 1 * VALUE MonitorDirTimeout \ ms

\ WINAPI: WaitForMultipleObjects KERNEL32.DLL
REQUIRE FILE>DIR ~nn/lib/filename.f

WINAPI: FindFirstChangeNotificationA KERNEL32.DLL
WINAPI: FindCloseChangeNotification KERNEL32.DLL
WINAPI: FindNextChangeNotification KERNEL32.DLL
WINAPI: RasConnectionNotificationA RASAPI32.DLL
WINAPI: CreateEventA KERNEL32.DLL
WINAPI: ResetEvent KERNEL32.DLL

0
1 CELLS -- WATCH-NEXT
1 CELLS -- WATCH-CRON-NODE
1 CELLS -- WATCH-PROC
1 CELLS -- WATCH-HANDLE
1 CELLS -- WATCH-OBJECT
1 CELLS -- WATCH-PAR
1 CELLS -- WATCH-PAR1
1 CELLS -- WATCH-PAR2
1 CELLS -- WATCH-PAR3
\ 1 CELLS -- WATCH-LAST-TIME
1 CELLS -- WATCH-RESPONSE-TIME
1 CELLS -- WATCH-RULE
1 CELLS -- WATCH-START
1 CELLS -- WATCH-CONTINUE
1 CELLS -- WATCH-STOP
1 CELLS -- WATCH-FLAGS
1 CELLS -- WATCH-THREAD
1 CELLS -- WATCH-ACTION-THREAD
2 CELLS -- WATCH-HBUF
2 CELLS -- WATCH-CTIME
2 CELLS -- WATCH-WTIME
1 CELLS -- WATCH-NEED-LOGON
1 CELLS -- WATCH-DIR-TIMEOUT
1 CELLS -- WATCH-FFN-FLAGS
1 CELLS -- WATCH-XT-IF-RULE-FALSE
\ 2 CELLS -- WATCH-FSIZE

CONSTANT /WATCH
1 CONSTANT WF-ACTIVE
2 CONSTANT WF-SUBTREE
4 CONSTANT WF-DIR

0 VALUE hSTOPev
0 VALUE hSTOPev0    \ Ёто дл€ прибиваемых в первую очередь

0 VALUE #WATCH      \  оличество WATCH'ей

USER-VALUE CUR-WATCH    \ адрес текущего вотча
USER-VALUE WATCH-ERR

USER ew-par1
USER ew-par2
USER ew-par3
USER ew-typ
USER ew-tag
USER ew-xt


: WATCH-PAR1@ vTask ?DUP IF vtWATCH @ ?DUP IF WATCH-PAR1 @ ELSE 0 THEN ELSE 0 THEN ;
: WATCH-PAR2@ vTask ?DUP IF vtWATCH @ ?DUP IF WATCH-PAR2 @ ELSE 0 THEN ELSE 0 THEN ;
: WATCH-PAR3@ vTask ?DUP IF vtWATCH @ ?DUP IF WATCH-PAR3 @ ELSE 0 THEN ELSE 0 THEN ;

: WATCH-PAR-WT CUR-WATCH WATCH-PAR @ 0xFF AND ;
: WATCH-PAR-T CUR-WATCH WATCH-PAR @ 0xFFFFFF00 AND ;

0 VALUE WATCH-NODE  \ указатель на текущий вотч

VARIABLE NoStartWCnt
VARIABLE NoStartWCntSem
: NoStartWCnt-- NoStartWCntSem GET -1 NoStartWCnt +! NoStartWCntSem RELEASE ;
: NoStartWCnt++ NoStartWCntSem GET NoStartWCnt 1+! NoStartWCntSem RELEASE ;

USER evtCOUNT

: Event evtCOUNT 1+! S" Event-%evtCOUNT @%-%GetCurrentThreadId%-%hh%-%mm%-%ss%" EVAL-SUBST DROP 0 1 0 CreateEventA ;
: NamedEvent ( a u -- handle ) 
    evtCOUNT 1+! 
    S" Event-%1 esPICKS%-%evtCOUNT @%-%GetCurrentThreadId%-%hh%-%mm%-%ss%" EVAL-SUBST DROP 
    0 1 0 CreateEventA ;

: CreateSTOPev ( -- )
    hSTOPev  0= IF Event TO hSTOPev THEN
    hSTOPev0 0= IF Event TO hSTOPev0 THEN
;

: WATCH-OBJECT@ CUR-WATCH WATCH-OBJECT @ ASCIIZ> ;
: WATCH-OBJECT-S! S>ZALLOC CUR-WATCH WATCH-OBJECT ! ;

: DEF-WATCH-START ( -- handle/0) 0 ;

: DEF-WATCH-STOP
    CUR-WATCH WATCH-HANDLE @ ?DUP
    CUR-WATCH WATCH-HANDLE 0!
    IF CloseHandle DROP THEN
;

: LOG-WATCH ( a u -- )
    GET-CUR-TIME
    CUR-WATCH WATCH-CRON-NODE @ TO CUR-NODE
    CUR-NODE LOG-NODE ;

: DEF-WATCH-CONTINUE
    CUR-WATCH WATCH-HANDLE @ ?DUP
    IF ResetEvent 0=
        IF GetLastError TO WATCH-ERR
           S" WATCH-CONTINUE:ResetEvent ERROR # %WATCH-ERR N>S% : " LOG-WATCH
        THEN
    THEN ;
: DEF-WATCH-RULE TRUE ;

: ?watch-error ( n -- )
   WAIT_OBJECT_0 1+ <>
   IF
       GetLastError TO WATCH-ERR
       S" task-watch:WaitObject ERROR # %WATCH-ERR N>S% : " LOG-WATCH
   ELSE
       [ DEBUG? ] [IF]
               CUR-WATCH WATCH-CRON-NODE @ CRON-NAME @ ID.
               ."  stopped by STOPev" GetCurrentThreadId . CR [THEN]
   THEN
;


: ACTIVE? CRON-FLAGS @ CF-ACTIVE AND 0<> ;

: ENUM-WATCHES ( xt cron-node -- )
    CRON-WATCH @ ?DUP
    IF
      SWAP >R
      BEGIN ?DUP WHILE
\        ." enum=" DUP . CR
        DUP R@ EXECUTE
        WATCH-NEXT @
      REPEAT
      RDROP
    ELSE
      DROP
    THEN
;

: (ENUM-ACTIVE-WATCH) { xt list -- }
    list
    BEGIN @ ?DUP WHILE
        DUP ACTIVE?  OVER CRON-WATCH @ 0<> AND
        IF
           xt OVER ENUM-WATCHES
        THEN
    REPEAT
;

: ENUM-ACTIVE-WATCH ( xt -- )
    DUP CRON-LIST (ENUM-ACTIVE-WATCH)
    SPEC-CRON-LIST (ENUM-ACTIVE-WATCH)
;

:NONAME { w -- }
\    DBG( ." ENUM-ACTIVE-WATCH=" w WATCH-PAR @ HEX U. ew-tag @ U. ew-typ @ . DECIMAL CR )
    w WATCH-PAR @ 0xFFFFFF00 AND ew-tag @  =
    w WATCH-PAR @ 0xFF AND ew-typ @  = AND
    IF w ew-xt @ EXECUTE THEN
;

: ENUM-AW-BY-TAG ( typ tag xt -- )
   ew-xt ! ew-tag ! ew-typ ! LITERAL ENUM-ACTIVE-WATCH ;

: SetWatchEventByTypeTag ( typ tag -- )
    [NONAME ( w -- )
        \    DBG( ." Set Event=" DUP WATCH-CRON-NODE @ CRON-NAME @ COUNT TYPE CR )
        WATCH-HANDLE @ SetEvent DROP
    NONAME]
    ENUM-AW-BY-TAG ;


:NONAME ( w -- ) CUR-NODE SWAP WATCH-CRON-NODE ! ;
:NONAME ( cron-node -- ) [ SWAP ] LITERAL SWAP ENUM-WATCHES ;
  TO WATCH-CRON-NODE!

: DelayIsPassed? ( -- ?)
    GetTickCount DUP
    CUR-WATCH WATCH-CRON-NODE @ CRON-LAST-TIME @
\    DBG( ." LastTime=" DUP . CUR-WATCH WATCH-CRON-NODE @ CRON-NAME @ COUNT TYPE CR )
    - ABS
    CUR-WATCH WATCH-RESPONSE-TIME @ >
    CUR-WATCH WATCH-CRON-NODE @ CRON-LAST-TIME @ 0= OR
    IF
        CUR-WATCH WATCH-CRON-NODE @ CRON-LAST-TIME !
        TRUE
    ELSE
        DROP FALSE
    THEN
;

: ?RUN-WATCH (  -- )
\   DBG( ." ?RUN-WATCH=" CUR-WATCH WATCH-CRON-NODE @ CRON-NAME @ COUNT TYPE CR )
   CUR-WATCH WATCH-RULE @ EXECUTE
   IF
       DelayIsPassed?
       IF
         CUR-WATCH vTask vtWATCH !
         CUR-WATCH WATCH-CRON-NODE @ TO CUR-NODE
         0 TO LAST-THREAD
         CF-ALSO? IF ?EXEC-ACT-LY ELSE CUR-NODE CRON-TEST-NODE THEN
         LAST-THREAD ?DUP
         IF
           CUR-WATCH WATCH-ACTION-THREAD !
\           INFINITE
\           CUR-WATCH WATCH-ACTION-THREAD @
\           WaitForSingleObject DROP
         THEN
       THEN
   THEN
   CUR-WATCH WATCH-CONTINUE @ EXECUTE
;

QUEUE POINTER qWS
:NONAME
    vt-NEW
    50 QUEUE NEW TO qWS
    BEGIN
        S" RUN-WATCHES-BY-QUEUE-TASK" SP-TEST
        qWS Get TO CUR-WATCH
        ?RUN-WATCH
    AGAIN
; TASK: RUN-WATCHES-BY-QUEUE-TASK

: StartWatchByTypeTag ( typ tag -- )
    [NONAME ( w -- )
        DBG( ." StartWatchTypeTag=" DUP WATCH-CRON-NODE @ CRON-NAME @ COUNT TYPE CR )
        qWS Put
    NONAME]
    ENUM-AW-BY-TAG ;

: StartWatchByTypeTagPar2! ( typ par2 tag -- )
    SWAP ew-par2 !
    [NONAME ( w -- )
        ew-par2 @ OVER WATCH-PAR2 !
        DBG( ." StartWatchTypeTagPar2=" DUP WATCH-CRON-NODE @ CRON-NAME @ COUNT TYPE SPACE DUP WATCH-PAR2 @ . CR )
        qWS Put
    NONAME]
    ENUM-AW-BY-TAG ;
: WATCH-TASK-NAME CUR-WATCH WATCH-CRON-NODE @ CRON-NAME @ 
    ?DUP IF COUNT ELSE S" <?>" THEN ;
: DEF-WATCH-PROC
   BEGIN
       S" DEF-WATCH-PROC: %WATCH-TASK-NAME%" EVAL-SUBST SP-TEST
       INFINITE
       CUR-WATCH WATCH-HANDLE @ CUR-WATCH WATCH-HBUF !
       hSTOPev                  CUR-WATCH WATCH-HBUF CELL+ !
       0 CUR-WATCH WATCH-HBUF 2 WaitForMultipleObjects DUP
DBG( CUR-WATCH WATCH-CRON-NODE @ CRON-NAME @ ID. ."  event=" DUP . CR )
       WAIT_OBJECT_0 = CUR-WATCH WATCH-HANDLE @ 0<> AND
       IF  DROP
           ?RUN-WATCH
       ELSE
            ?watch-error
            EXIT
       THEN
   AGAIN
;

: WATCH-NODE0!
    WATCH-NODE /WATCH ERASE
    ['] DEF-WATCH-START     WATCH-NODE WATCH-START !
    ['] DEF-WATCH-STOP      WATCH-NODE WATCH-STOP !
    ['] DEF-WATCH-CONTINUE  WATCH-NODE WATCH-CONTINUE !
    ['] DEF-WATCH-RULE      WATCH-NODE WATCH-RULE !
    ['] DEF-WATCH-PROC      WATCH-NODE WATCH-PROC !
    MonitorResponseTime WATCH-NODE WATCH-RESPONSE-TIME !
    MonitorDirTimeout   WATCH-NODE WATCH-DIR-TIMEOUT !
;


: WATCH-LOGON CUR-WATCH WATCH-NEED-LOGON @ IF LOGON-NODE THEN ;
: WATCH-LOGOFF CUR-WATCH WATCH-NEED-LOGON @ IF LOGOFF-NODE THEN ;

\ VARIABLE TASK-WATCH-SEM

:NONAME ( vtask -- )
\   TASK-WATCH-SEM GET
   vt-COPY
   vTask @ TO CUR-WATCH
   DBG( ." Open watch=" CUR-WATCH . CR )
   S0 @ SP!
   CUR-WATCH WATCH-CRON-NODE @ TO CUR-NODE
   WATCH-LOGON
   CUR-WATCH WATCH-START @ EXECUTE
   NoStartWCnt--
   DBG( ." TASK-WATCH NoStartWCnt=" NoStartWCnt @ . CR )
\   [ DEBUG? ] [IF] ." After watch start: "
\                   CUR-WATCH WATCH-CRON-NODE @  CRON-NAME @ COUNT TYPE
\                   SPACE
\                   HERE . CR [THEN]
\    TASK-WATCH-SEM RELEASE
   ?DUP
   IF
        CUR-WATCH WATCH-HANDLE !
        CUR-WATCH WATCH-PROC @ EXECUTE
   THEN
   WATCH-LOGOFF
;

TASK: TASK-WATCH

: (open-watch) { w -- }
    NoStartWCnt++
    DBG( ." open watch NoStartWCnt=" NoStartWCnt @ . CR )
    w TASK-WATCH START-TASK
        ( START-TASK выдел€ет пам€ть дл€ vTask и копирует в первый параметр w)
    LAST-THREAD w WATCH-THREAD !
    #WATCH 1+ TO #WATCH
;

: OPEN-WATCH-TASKS
    CreateSTOPev
    hSTOPev  ResetEvent DROP
    hSTOPev0 ResetEvent DROP
    0 TO #WATCH
    NoStartWCnt OFF
\    TASK-WATCH-SEM GET
    ['] (open-watch) ENUM-ACTIVE-WATCH
\    TASK-WATCH-SEM RELEASE
    30 0 DO  NoStartWCnt @ 0=
            IF
            [ DEBUG? ] [IF] ." NoStartWCnt=" I . CR [THEN]
            LEAVE ELSE 100 PAUSE THEN LOOP
    C" AfterWatchStart" FEX
    watch-started ON
;

: (close-watch) { w -- }
    [ DEBUG? ] [IF] ." STOP:" w WATCH-CRON-NODE @ CRON-NAME @ ID. CR [THEN]
    w TO CUR-WATCH
    w WATCH-STOP @ EXECUTE
\                CUR-WATCH WATCH-THREAD @ ?DUP
\                IF STOP THEN

;

: CLOSE-WATCH-TASKS
    [ DEBUG? ] [IF] ." CLOSE-WATCH-TASKS" CR [THEN]
    #WATCH IF hSTOPev0 SetEvent DROP 1000 PAUSE
              hSTOPev SetEvent DROP 1000 PAUSE THEN
    ['] (close-watch) ENUM-ACTIVE-WATCH
    watch-started OFF
;

: END-WATCH RET, POSTPONE [ SMUDGE ; IMMEDIATE  \ ]
\ : END-WATCH POSTPONE ; ; IMMEDIATE  \ ]

: WATCH:
    end-def
    HERE /WATCH ALLOT TO WATCH-NODE
    WATCH-NODE0!
    CRON-NODE CRON-WATCH @ WATCH-NODE WATCH-NEXT !
    WATCH-NODE CRON-NODE CRON-WATCH !
    :NONAME WATCH-NODE WATCH-START !
; IMMEDIATE

: WNEED-LOGON WATCH-NODE WATCH-NEED-LOGON ON ;

:NONAME
    by-time? 0=
    IF
        vTask vtWATCH @
        ?DUP
        IF
            TO CUR-WATCH
            CUR-WATCH WATCH-XT-IF-RULE-FALSE @ ?DUP
            IF EXECUTE THEN
        THEN
    THEN
;
DUP     TO XT-IF-RULE-FALSE
        TO XT-IF-TIME-FALSE


WARNING @ WARNING 0!
: BeforeCrontabLoading
    CLOSE-WATCH-TASKS
    BeforeCrontabLoading
;

: BeforeStop
    CLOSE-WATCH-TASKS
    BeforeStop
;
WARNING !
