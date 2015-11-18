VARIABLE Guard
VARIABLE hGuard

: TAB-EXIST? ( addr u -- ? )
    EVAL-SUBST PAD PLACE
    TAB-LIST @
    BEGIN ?DUP WHILE
      DUP CELL+ @ TAB-FILENAME @ COUNT EVAL-SUBST
      PAD COUNT ICOMPARE 0=
      IF DROP TRUE EXIT THEN
      @
    REPEAT
    FALSE
;

: ADD-TAB ( addr u -- )
    2DUP TAB-EXIST? 0=
    IF
        /TAB ALLOCATE THROW TO CUR-TAB
        DUP CELL+ ALLOCATE THROW >R
        R@ PLACE 0 R@ COUNT + C!
        R> CUR-TAB TAB-FILENAME !
        CUR-TAB TAB-LAST-TIME 0!
        CUR-TAB TAB-LIST AppendNode
    ELSE
        2DROP
    THEN
;

: ADD-TAB64 ( addr u -- )
	0 TO CUR-TAB
	ADD-TAB
	CUR-TAB 
	IF
		CUR-TAB TAB-FLAG ON
	THEN
;


: DEF-CRONTAB-FILENAME S" nncron.tab" ;
\ Default TAB node
\ HERE
\ DEF-CRONTAB-FILENAME , 0 , 0 ,
\ HERE  \ def list node
\ 0 , SWAP ,
\ CONSTANT TAB-DEF-NODE

: INI-TAB-LIST TAB-LIST 0! ;

: TEST-FILE-TIME { a u dtime -- }
    a ['] FIND-FIRST-FILE CATCH IF DROP EXIT THEN
    IF DROP
        __FFB ftLastWriteTime 2@ 2DUP
        dtime 2@ DNEGATE D+ OR
        IF
            \ dtime 2! 
            2DROP
            TRUE
        ELSE
            2DROP FALSE
        THEN
        NEED-LOAD? OR TO NEED-LOAD?
   THEN
   FIND-CLOSE
;

: SET-CUR-TAB-TIME
    CUR-TAB TAB-FILENAME @ COUNT EVAL-SUBST DROP 
    ['] FIND-FIRST-FILE CATCH IF DROP EXIT THEN
    IF DROP
        __FFB ftLastWriteTime 2@ CUR-TAB TAB-LAST-TIME 2!
    THEN
    FIND-CLOSE    
;

: (NEWEST) ( node -)
\    DUP .
\      ." ------- (NEWEST) ------- " DEPTH . 
    NodeValue TO CUR-TAB
    CUR-TAB TAB-FILENAME @ COUNT EVAL-SUBST
\      2DUP TYPE
    CUR-TAB TAB-LAST-TIME TEST-FILE-TIME
\      ."  ok " DEPTH . CR
;


VARIABLE INI-TIME 0 ,

: TEST-INI ( -- )
    CronINI CUR-OR-HOME-FILE? DROP INI-TIME TEST-FILE-TIME ;

: NEWEST? ( -- ?)
    0 TO NEED-LOAD?
    ['] (NEWEST) TAB-LIST DoList
\    TEST-INI
    NEED-LOAD?
;

0 VALUE LAST-LINE
: SAVE-LINE
    TIB #TIB @ PAD PLACE
    PAD TO LAST-LINE
\    LAST-LINE COUNT TYPE CR
;
0 [IF]
VARIABLE Ired

: RK&DTest
    Ired OFF
    ServiceName RKL 0=
    IF
        GET-CUR-TIME
        DateDays@ R-DATE - ( DUP . ."  days" CR) 30 >
        IF
            Ired ON
\            5 60 * 60 * 1000 * PAUSE
        THEN
    THEN
;
[THEN]


CEZ: ?IredMsg
    Ired @ \ S" nn.key" EXIST? 0= AND
    IF
        GetTickCount 60 MOD 0=
        IF
            S" Evaluation period has expired.%%crlf%%To buy nnCron go to%%crlf%%%777 RES%%%crlf%%%%crlf%%%rdates%" EVAL-SUBST
            TMMessage
        THEN
    THEN
;CEZ

: DailyWork ProgramName RK&DTest ;

: LOADED?  ( addr u -- ?)
    LOADED-LIST @
    BEGIN ?DUP WHILE
        >R
        2DUP R@ CELL+ COUNT ICOMPARE 0=
        IF RDROP 2DROP TRUE EXIT THEN
        R> @
    REPEAT
    2DROP
    FALSE ;

: ADD-TO-LOADED-LIST ( addr u -- )
    HERE LOADED-LIST @ , LOADED-LIST !
    >R R@ HERE PLACE R> 1+ ALLOT 0 C,
;

CREATE fulltn MAX_PATH ALLOT

IGT-BEG

USER <temp_name>
: temp_name!
	GetTickCount DUP 2DUP START-SEQUENCE
	S" %TMP%\~%100000000 RANDOM%" EVAL-SUBST S>ZALLOC  <temp_name> ! ;
: temp_name <temp_name> @AZ ;

: INCLUDED64x ( a u -- )
	['] FILE CATCH THROW
	7 TO 64offset
	temp_name!
	DUP 2* ALLOCATE THROW >R
	R@ debase64 temp_name ['] FWRITE CATCH THROW
    6 temp_name DROP SetFileAttributesA DROP
	R> FREE DROP
	temp_name ['] INCLUDED CATCH 
    temp_name DELETE-FILE DROP
	temp_name DROP FREE DROP
	THROW
; 

: START-SEQ ( a u -- )
    0 ROT ROT OVER + SWAP
    DO I C@ + LOOP
    DUP 2DUP .S START-SEQUENCE
;

USER df-ibuf
USER df-obuf
USER df-hi
USER df-ho
63 CONSTANT df-BLK-LEN

: decode-file ( a u a2 u2 -- )
    2OVER ONLYNAME START-SEQ
    df-BLK-LEN 2* ALLOCATE THROW df-ibuf !
    df-BLK-LEN 2* ALLOCATE THROW df-obuf !
    2SWAP R/O OPEN-FILE-SHARED THROW df-hi !
    2DUP DELETE-FILE DROP
    W/O CREATE-FILE-SHARED THROW df-ho !
    BEGIN df-ibuf @ df-BLK-LEN 2* df-hi @ READ-LINE THROW WHILE
        64 RANDOM TO 64offset
        df-ibuf @ SWAP df-obuf @ debase64 df-ho @ WRITE-FILE THROW
    REPEAT
    DROP
    df-hi @ CLOSE-FILE DROP
    df-ho @ CLOSE-FILE DROP
    df-ibuf @ FREE DROP
    df-obuf @ FREE DROP
;

: INCLUDED64 ( a u -- )
	temp_name! temp_name decode-file
    6 temp_name DROP SetFileAttributesA DROP
	temp_name ['] INCLUDED CATCH 
    temp_name DELETE-FILE DROP
	temp_name DROP FREE DROP
	THROW
; 

IGT-END NOOP

: LOAD-1-TAB ( node -- )
    restr-off
    STATE @ >R
    ['] <PRE> BEHAVIOR >R
    [ DEBUG? ] [IF] ." LOAD-1-TAB: NODE=" DUP . ."  NODE VALUE=" DUP NodeValue .  DEPTH . CR [THEN]
    NodeValue TO CUR-TAB
    SET-CUR-TAB-TIME
    CSP @ >R
    CSP!
    POSTPONE [
    ['] Classic: TO <PRE>
    CUR-TAB TAB-FILENAME @ COUNT EVAL-SUBST
    fulltn ROT ROT GET-FULL-PATH
    2DUP LOADED? 0=
    IF
        2DUP ADD-TO-LOADED-LIST
        2DUP EXIST?
        IF
            2DUP CRON-LOG
            2DUP HERE DUP TO CUR-TAB-FILENAME
                OVER 1+ ALLOT PLACE 0 C,
            CSP @ >R
            CUR-TAB TAB-FLAG @ 0= IF ['] INCLUDED ELSE ['] INCLUDED64 THEN
            CATCH ?DUP
             R> CSP !
            IF >R 2DROP
               R> 10011 ?LOG-ERROR ( LOG-CRONTAB-ERROR)
            ELSE
               S" CRONTAB LOADING" CSP?
            THEN
        ELSE
            2DROP
        THEN
    ELSE
        S" Already loaded." CRON-LOG
    THEN
    R> CSP !
\    POSTPONE [
    R> TO <PRE>
    R> STATE !
    [ DEBUG? ] [IF] ." LOAD-TAB OK " DEPTH . CR [THEN]
;

: SHOW-INCLUDE-ERROR
  CURFILE @
    IF
        <# CURSTR @ S>D #S
           [CHAR] : HOLD
           CURFILE @ ASCIIZ> HOLDS
           S" Loading error: " HOLDS
        #> PAD PLACE PAD COUNT \ CRON-LOG
        -1 ROT ROT ?LOG-SERROR
\        CURFILE @ FREE THROW  CURFILE 0!
    THEN
;

: INIT-DICT
    FORTH DEFINITIONS
    SAVE-LATEST CONTEXT @ !
    SAVE-LATEST LAST !

    SAVE-DP ?DUP IF (FORGET) ( HERE - ALLOT) THEN
    HERE TO SAVE-DP
\    LH-UNLINK
;

CREATE default-ini S" conf\nncron.ini" FILE HERE SWAP DUP ALLOT MOVE 0 C,
CREATE default-tab S" conf\nncron.tab" FILE HERE SWAP DUP ALLOT MOVE 0 C,
CREATE default-deleted-tab S" conf\deleted.tab" FILE HERE SWAP DUP ALLOT MOVE 0 C,

: deleted.tab S" deleted.tab" ;
: nncron.tab S" nncron.tab" ;

: ?save-def-ini
    CronINI CUR-OR-HOME-FILE? 0=
    IF default-ini ASCIIZ> EVAL-SUBST 2SWAP FWRITE ELSE 2DROP THEN ;

: ?save-def-tab
    TAB-LIST @ 0= 
    IF DEF-CRONTAB-FILENAME ELSE TAB-LIST @ NodeValue TAB-FILENAME @ COUNT THEN 
    EVAL-SUBST CUR-OR-HOME-FILE? 0=
    IF default-tab ASCIIZ> EVAL-SUBST 2SWAP FWRITE ELSE 2DROP THEN 
    deleted.tab EVAL-SUBST CUR-OR-HOME-FILE? 0=
    IF default-deleted-tab ASCIIZ> EVAL-SUBST 2SWAP FWRITE ELSE 2DROP THEN 
;

: LOAD-INI
    ?save-def-ini
    \ DLL-LIST 0!
    INI-TAB-LIST
\    INIT-DICT
    CRON-NODE /CRON-NODE ERASE
    POSTPONE [
    CronINI CUR-OR-HOME-FILE? DROP ['] INCLUDED CATCH
    IF 2DROP
       SHOW-INCLUDE-ERROR
    THEN
    POSTPONE [
    CRON-NODE DEF-CRON-NODE /CRON-NODE CMOVE
    RES-INIT 0= IF S" Language: english" EVALUATE THEN
    TAB-LIST @ 0= 
    IF DEF-CRONTAB-FILENAME ADD-TAB THEN
    ?save-def-tab  
;

: ?load-crontab
    CSP!
    GET-CUR-TIME
    NEWEST?
    IF
        menuObj GET
        C" BeforeCrontabLoading" FEX
        S" Load crontab" CRON-LOG
        CRON-LIST 0!
        LOADED-LIST 0!
        SET-LIST 0!
        INIT-DICT
\        LOAD-INI
\        ['] NOOP TO <PRE>
\        S" #( $$$every-day NoLog Time: 0 0 * * * * A: DailyWork )#" EVALUATE
        NUM-TASK 0!
        ['] LOAD-1-TAB TAB-LIST DoList
        [ DEBUG? ] [IF] ." After load crontab: " HERE . CR [THEN]
        OPEN-WATCH-TASKS
\        [ DEBUG? ] [IF] ." After open watch: " HERE . CR [THEN]
\        ProcWatchCount @ IF 0 WATCH-PROC-TASK START ProcWatchHandle ! THEN
        C" AfterCrontabLoading" FEX
        SetProcWorkSet

        50 PAUSE
        menuObj RELEASE

[ DEBUG? ] [IF] ." crontabs are loaded" CR [THEN]
    THEN
    FALSE TO FORCE-STOP
    ( S" MAIN:LOAD-CRONTAB") 10012 RES CSP?
;

: PASS-CRON ( --)
\    ." ENTER" .S CR
    ['] CRON-TEST CATCH ?DUP IF S" ERROR PASS # %0 esPICK%" EVAL-SUBST CRON-LOG THEN
\    ." EXIT" .S CR
;
VARIABLE DOUB-MUT

: DoubleInstance? ( -- ?)
    SerializeName FALSE CREATE-MUTEX ?DUP IF NIP EXIT THEN
    DOUB-MUT !
    5 DOUB-MUT @ WaitForSingleObject WAIT_TIMEOUT =
;

: DoubleInstancePrevent
    DoubleInstance?
    IF S" Another instance is running. Exit." CRON-LOG
      BYE
    THEN
;
WINAPI: SetCurrentDirectoryA KERNEL32.DLL

(
: GET-DESKTOP
    hDesk OFF
    WINSTA_ALL_ACCESS STANDARD_RIGHTS_ALL OR 0 S" WinSta0" DROP OpenWindowStationA ?DUP
    IF
        SetProcessWindowStation
        IF
            DESKTOP_ALL_ACCESS STANDARD_RIGHTS_ALL OR 0 DF_ALLOWOTHERACCOUNTHOOK S" Default" DROP OpenDesktopA
            ?DUP IF hDesk ! THEN
        THEN
    THEN
    hDesk @ ?DUP IF SetThreadDesktop DROP THEN
\    GetLastError . CR
;
)

2VARIABLE saveEMIT ' EMIT 2@ saveEMIT 2!
2VARIABLE saveCR   ' CR   2@ saveCR 2!
2VARIABLE saveTYPE ' TYPE 2@ saveTYPE 2!

: EMIT-TYPE-OFF
  ['] DROP ['] EMIT JMP  
  ['] 2DROP ['] TYPE JMP
  ['] NOOP ['] CR JMP
;

: EMIT-TYPE-ON
    saveEMIT 2@ ['] EMIT 2!
    saveCR 2@   ['] CR 2!
    saveTYPE 2@ ['] TYPE 2!
;
: SET-CRON-OUT
    ?GUI IF
            CronOUT EXIST? 0<> RUN-FILE 0= AND
            S" nodelout" EXIST? 0<> AND
            IF
                CronOUT S" %MM%-%DD%-%hh%-%mm%-%CronOUT%" EVAL-SUBST 
                FRENAME \ GetLastError S>D <# 0 HOLD #S #> MsgBox
            THEN

            CronOUT 2DUP EXIST? RUN-FILE 0<> AND
               IF R/W OPEN-FILE-SHARED ELSE R/W CREATE-FILE-SHARED THEN
            IF DROP
               S" Can't create nncron.out file" CRON-LOG
            ELSE
                TO CRON-OUT
                CRON-OUT TO H-STDOUT
                CRON-OUT TO H-STDERR
                H-STDOUT >EOF
                \ FILE-SIZE THROW
                \ H-STDOUT REPOSITION-FILE THROW
            THEN
         THEN
;
: INIT-CRON
\    ['] ModuleNameInTEMP ['] ModuleName JMP
    EMIT-TYPE-OFF
    IGT
\    USER-INIT
    QLOG-START
    SEM_FAILCRITICALERRORS SEM_NOOPENFILEERRORBOX OR SetErrorMode DROP
    0 TO NUM-PASS
\    LOG-MUTEX 0!
    0 TO #TASK
    0 TO EXACT-MATCH?
    0 TO SAVE-DP
    TASK-LIST 0!
    GetCurrentThreadId MainThrId !

\    DIAL-SEMAPHORES

    GET-CUR-TIME
    SET-MIN-YEAR

    RUN-FILE 0= IF SET-DIR THEN
    
\    GET-DESKTOP
\   ['] re_load CATCH DROP
    LOAD-INI
    Outfile @ IF SET-CRON-OUT EMIT-TYPE-ON THEN
    ProgramName RK&DTest
    0. MODIF-TIME 2!
    FORTH DEFINITIONS LATEST TO SAVE-LATEST

\    ['] re_load CATCH DROP
(
    DESKTOP_HOOKCONTROL DESKTOP_CREATEWINDOW OR TRUE DF_ALLOWOTHERACCOUNTHOOK S" Default" DROP OpenDesktopA ?DUP
    IF
        SetThreadDesktop
      [ DEBUG? ] [IF] DUP 0= IF ." SetThreadDesktop=" GetLastError . CR THEN [THEN]
        DROP
    ELSE
      [ DEBUG? ] [IF] ." OpenDesktop=" GetLastError . CR [THEN]
    THEN
)
;


CEZ: MY-TITLE
\    TITLE
    S" %ServiceName%. v %SVERSION%" EVAL-SUBST TYPE CR
    S" Copyright (C) 2000-%YYYY% nnSoft. email:%nnmail%" EVAL-SUBST TYPE CR
    xUR? IF FNCUO TYPE CR THEN
;CEZ


: (EXIT-CRON)
    MainIsRun @ 
    IF   
        C" BeforeStop" FEX
        100 PAUSE
        S" Service stopped." CRON-LOG
    THEN
    hGuard @ ?DUP  IF 0 SWAP TerminateProcess DROP 500 PAUSE THEN
    I'mService @
    IF ServiceName DoStopService 100 PAUSE BYE
    ELSE BYE THEN
;

' (EXIT-CRON) TO EXIT-CRON

\ HANDLE CreateEvent(
\  LPSECURITY_ATTRIBUTES lpEventAttributes,
\                      // pointer to security attributes
\  BOOL bManualReset,  // flag for manual-reset event
\  BOOL bInitialState, // flag for initial state
\  LPCTSTR lpName      // pointer to event-object name
\ );

CREATE TabEventAttr 3 CELLS , 0 , TRUE

: CREATE-TAB-EVENT
    ServiceName PAD ZPLACE S" TabEvent" PAD +ZPLACE
    PAD FALSE TRUE TabEventAttr CreateEventA TO TAB-EVENT
;

: FORCE TRUE TO FORCE-STOP ;

: WAIT-TAB { ms \ start-ms stop-ms -- }
    GetTickCount TO start-ms
    start-ms ms + 1- TO stop-ms
    BEGIN
        stop-ms GetTickCount - DUP 0 >
        IF TAB-EVENT ?DUP
            IF SetProcWorkSet WAIT IF DROP FALSE THEN
            ELSE SetProcWorkSet PAUSE FALSE THEN
            IF FORCE ?load-crontab
               TAB-EVENT ResetEvent DROP
            THEN
        ELSE DROP THEN
        GetTickCount stop-ms >
    UNTIL
;

VARIABLE ReloadImmediately

\ CRON-LIST @
SPEC-TASK? ON
:TASK WAIT-TAB-TASK
DEBUG? 0= [IF] NoLog [THEN]
WatchDir: .
WATCH-CHANGE-LAST-WRITE
Rule: ReloadImmediately @ NEWEST? AND ; 
Action:
[ DEBUG? ] [IF] ." WAIT-TAB-TASK " .TIME CR [THEN]
    SP@ >R
[ DEBUG? ] [IF] DEPTH >R [THEN]
\    0 0 TAB_RELOAD Send2Cron
    RELOAD-CRONTAB
[ DEBUG? ] [IF] DEPTH  R> <> 
                IF ." WAIT-TAB-TASK *** DEPTH = " DEPTH . 
                   ." VALUE = " DUP . CR THEN [THEN]
    R> SP!
;
TASK;
SPEC-TASK? OFF
\ CRON-LIST !

\ : yy ( # -- )
\    >R SP@ R> SWAP
\    R> R@ SWAP >R
\    <> IF ." GARB:" . CR ELSE DROP THEN ;

: RUN-TASK-ERR S" Task '%RUN-TASK COUNT%' not found" EVAL-SUBST ErrMsgBox ;

: PID GetCurrentProcessId ;
: START-GUARD
    0
    WinNT? 0= NOT-SERVICE? OR
    IF S" nnguard.exe %PID% nncron.exe %-ns-string%"
    ELSE S" nnguard.exe %PID% net start %ServiceName%" THEN
    EVAL-SUBST
\    2DUP TYPE CR
    CREATE_NEW_PROCESS_GROUP APP-Flags !
    StartAppNC
    IF APP-pi .hThread @ CLOSE-FILE DROP
       APP-pi .hProcess @
    ELSE 0 THEN
    hGuard !
;


\ WARNING @ WARNING 0!
\ : BeforeCrontabLoading
\     BeforeCrontabLoading
\     ReloadImmediately @
\     IF WAIT-TAB-TASK @ CRON-WATCH @ (close-watch) THEN
\ ;
\ 
\ : AfterCrontabLoading
\     AfterCrontabLoading
\     ReloadImmediately @
\     IF WAIT-TAB-TASK @ CRON-WATCH @ (open-watch) THEN
\ ;
\ WARNING !

VARIABLE DelayOnStartup
2VARIABLE prevPassTime

: MAIN-CRON \ 1 2 3
    IS-SVC? 0= TO NOT-SERVICE?
    IS-SVC? I'mService !
    INIT-CRON
    DoubleInstancePrevent
    atStart? RUN-TASK 0= AND DelayOnStartup @ 0<> AND IF DelayOnStartup @ PAUSE THEN
    \ LOAD-INI
    CREATE-TAB-EVENT
    MY-TITLE
    S" Start nnCron" CRON-LOG
\    S" MAIN-CRON" THID.
\      RUN-TASK 0= IF StartWinService THEN
    WinNT? IF SHUTDOWN_NORETRY 0x100 SetProcessShutdownParameters
\              [ DEBUG? ] [IF] ." SetProcessShutdownParameters=" DUP . CR [THEN]
                DROP
           THEN

    READ-ONCE

    0 RUN-WATCHES-BY-QUEUE-TASK START CLOSE-FILE 10 PAUSE
    PerfMonitor @ IF ?START-PERF-MONITOR THEN
    last-logged!
    BEGIN GET-CUR-TIME Sec@ 50 > WHILE 1000 PAUSE REPEAT
    START-TIME!

    ?load-crontab

    RUN-TASK ?DUP
        IF FIND
           IF EXECUTE @ EXEC-ACTION-TASK-U START-TASK
              LAST-THREAD IF 60000 LAST-THREAD WAIT 2DROP THEN
           ELSE DROP RUN-TASK-ERR THEN
           EXIT-CRON
        THEN
    
    RUN-TASK 0= IF StartWinService THEN
    
\    1480 S" web" WEB-SERVER
\    1481 S" web\low" WEB-SERVER
    RemConsole @ IF RemConsolePort @ START-CONSOLE-SERVER THEN
    Console @ IF START-CONSOLE-AT-START THEN
    Guard @ IF START-GUARD THEN

\ *     GET-CUR-TIME
\ *     Sec@ 10 > IF 60 Sec@ - 1000 * PAUSE THEN
\ *     START-TIME!
    0 0 prevPassTime 2!
    BEGIN
        ?IredMsg
        GET-CUR-TIME
        Min@ TO PrevMin
        
\          prevPassTime 2@ OR 
\          IF 
\              FT-CUR prevPassTime 2@ FT- FT>MIN
\              1 > 
\              IF 
\                  100 100 MOUSE-MOVER
\                  -100 -100 MOUSE-MOVER
\                  TDBG( ." it is power on from hibernate, possible" CR )
\              THEN
\          THEN
\          FT-CUR prevPassTime 2!        
        
        CSP! CSP @ >R
        PASS-CRON   R> CSP !
        S" MAIN:PASS-CRON" CSP?

        1000 PAUSE  tiWRITE  fiWRITE WRITE-ONCE

        GET-CUR-TIME
        Min@ PrevMin =
        IF
\            SetProcWorkSet
            60 Sec@ - 500 * WAIT-TAB
            #TASK IF CLOSE-ALL-INACTIVE THEN
            ?load-crontab
            BEGIN GET-CUR-TIME Min@ PrevMin = WHILE
              60 Sec@ - 1000 * WAIT-TAB
            REPEAT
        ELSE
            ?load-crontab
        THEN
\        WRITE-ONCE
\        [ DEBUG? ] [IF] ." After one minute: " HERE . CR [THEN]
\        TestTrayIcon
    FALSE
    UNTIL
    S" Stop nnCron" CRON-LOG
;


' MAIN-CRON TASK: TASK-MAIN-CRON


WARNING @ WARNING 0!
: SAVE
    CRON-LIST 0!
    SAVE
;
WARNING !
