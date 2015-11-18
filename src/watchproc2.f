\ Watch Proc
REQUIRE AddPair ~nn/lib/lisp.f
REQUIRE ?UM/MOD ~nn/lib/ummod.f

WINAPI: OpenThread KERNEL32.DLL

0x9FEB6800 CONSTANT ProcWatchTag
2000 VALUE ProcWatchDelay
VARIABLE ProcWatchCount
VARIABLE ProcWatchHandle

WARNING @ WARNING 0!

: BeforeCrontabLoading
    ProcWatchCount OFF
    ProcWatchHandle @ ?DUP IF CLOSE-FILE DROP THEN
    ProcWatchHandle OFF
    BeforeCrontabLoading
;
WARNING !

: WATCH-PROC-ID WATCH-PAR2@ ;

: ProcCompareName  ( a u a-mask u-mask -- )
  2SWAP ONLYNAME 2SWAP WC|RE-COMPARE
;

REQUIRE PROC-EXIST? proc.f
\ BOOL GetProcessTimes(
\  HANDLE hProcess,           // handle to process
\  LPFILETIME lpCreationTime, // process creation time
\  LPFILETIME lpExitTime,     // process exit time
\  LPFILETIME lpKernelTime,   // process kernel-mode time
\  LPFILETIME lpUserTime      // process user-mode time
\ );
WINAPI: GetProcessTimes KERNEL32.DLL
USER-CREATE pCreationTime 2 CELLS USER-ALLOT
USER-CREATE pExitTime 2 CELLS USER-ALLOT
USER-CREATE pKernelTime 2 CELLS USER-ALLOT
USER-CREATE pUserTime 2 CELLS USER-ALLOT

: ProcTime ( pid -- ? )
    WinNT?
    IF
        FALSE PROCESS_QUERY_INFORMATION OpenProcess ?DUP
        IF  >R
            pUserTime pKernelTime pExitTime pCreationTime
            R@ GetProcessTimes
            R> CloseHandle DROP
        ELSE
            FALSE
        THEN
    ELSE DROP FALSE THEN
;

: ThreadTime ( tid -- ? )
    Win2k?
    IF
        FALSE THREAD_QUERY_INFORMATION OpenThread ?DUP
        IF  >R
            pUserTime pKernelTime pExitTime pCreationTime
            R@ GetThreadTimes
            R> CloseHandle DROP
        ELSE
            FALSE
        THEN
    ELSE DROP FALSE THEN
;

: (PTActiveTime) ( pid xt -- dms )
    EXECUTE
    IF
        /SYSTEMTIME RALLOT >R
        R@ GetSystemTime DROP
        0 0 SP@ R> SystemTimeToFileTime DROP SWAP
        pCreationTime 2@ SWAP D- FT>MS
        /SYSTEMTIME RFREE
    ELSE
        0.
    THEN
;

: ProcActiveTime ( pid -- dms ) ['] ProcTime (PTActiveTime) ;
: ThreadActiveTime ( tid -- dms ) ['] ThreadTime (PTActiveTime) ;


: PROC-TIME ( a u -- sec)
    PROC-EXIST? ?DUP
    IF  ProcActiveTime 1000 MD/ D>XS ELSE 0 THEN ;

: PROC-TIME: eval-string, POSTPONE PROC-TIME ; IMMEDIATE

VARIABLE PREV-SS
VARIABLE WORK-SS
VARIABLE STOPPED-LIST
VARIABLE STARTED-LIST

\ Создаёт список запущенных процессов
\ NodeValue:
\ CELL -- pid
\ CELL -- azProcFullPath

: MAKE-PROC-SS
    \ список не очищаем т.к. он сохранён в PREV-SS
    PROC-FULLPATH
    WORK-SS 0!
    [NONAME ( a u id -- ?)
        ROT ROT S>ZALLOC WORK-SS AddPair
        TRUE
    NONAME]
    WinNT? IF  WalkProcNT  ELSE  WalkProc95 THEN
;

: PidInList? ( pid list -- nodevalue/0)
    BEGIN @ ?DUP WHILE
      >R DUP R@ NodeValue @ = IF DROP R> NodeValue EXIT THEN
      R>
    REPEAT
    DROP 0
;

: DIFF-PROC-SS? ( -- ?)
    STOPPED-LIST FreeList
    [NONAME
        NodeValue DUP @ WORK-SS PidInList? 0=
        IF STOPPED-LIST AddNode ELSE DROP THEN
    NONAME] PREV-SS DoList

    STARTED-LIST FreeList
    [NONAME
        NodeValue DUP @ PREV-SS PidInList? 0=
        IF
            DUP @ ProcActiveTime D>S ProcWatchDelay 2* <
            IF STARTED-LIST AddNode ELSE DROP THEN
        ELSE DROP THEN
    NONAME] WORK-SS DoList
    STOPPED-LIST @ 0<> STARTED-LIST @ 0<> OR
;

: WORK-SS>PREV-SS
   [NONAME NodeValue DUP CELL+ @ FREE DROP FREE DROP NONAME] PREV-SS DoList
   PREV-SS FreeList
   WORK-SS @ PREV-SS !
;

VECT ProcCompare
: ProcInList? ( a u list -- nodevalue/0)
    BEGIN @ ?DUP WHILE
      >R R@ NodeValue CELL+ @AZ 2OVER ProcCompare
      IF 2DROP R> NodeValue EXIT THEN
      R>
    REPEAT
    2DROP 0
;

: ?ProcSetEvent { a u list w -- }
\ *     DBG( ." ?ProcSetEvent " a u TYPE CR )
     w WATCH-PAR1 @ TO ProcCompare
     a u list ProcInList? ?DUP
     IF @ w WATCH-PAR2 !
\ *         w WATCH-HANDLE @ SetEvent DROP
\ *         DBG( ." ******* ?ProcSetEvent *******" w . CR )
\ *          DBG( ." set proc event = " w WATCH-CRON-NODE @ CRON-NAME @ COUNT TYPE CR )
        w qWS Put
     THEN ;

: TEST-SS  { w \ typ pid -- }
\ *    DBG( ." wp=" w WATCH-CRON-NODE @ CRON-NAME @ COUNT TYPE CR )
   w WATCH-PAR @ 0xFFFFFF00 AND ProcWatchTag =
   IF
       w WATCH-OBJECT @ ASCIIZ>
       w WATCH-PAR @ 0xFF AND ( 1 - start, 0 - stop)
       IF STARTED-LIST ELSE STOPPED-LIST THEN
       w ?ProcSetEvent
   THEN
;


:NONAME
    [ DEBUG? ]  [IF] .TIME ." WATCH-PROC-TASK start " GetCurrentThreadId . CR [THEN]
    PREV-SS 0!
    WORK-SS 0!
    STOPPED-LIST 0!
    STARTED-LIST 0!
\    5000 PAUSE
    5000 hSTOPev0 WaitForSingleObject WAIT_OBJECT_0 =
    IF 
       [ DEBUG? ] [IF] .TIME ." Killed: WatchProc monitor " GetCurrentThreadId . CR [THEN]
       EXIT 
    THEN
    BEGIN
       S" WATCH-PROC-TASK" SP-TEST
       MAKE-PROC-SS
       DIFF-PROC-SS?
       IF
         [ DEBUG? ]
         [IF]
            [NONAME ." start: " NodeValue DUP @ DUP . ProcActiveTime D. CELL+ @AZ TYPE CR NONAME] STARTED-LIST DoList
            [NONAME ." stop: " NodeValue DUP @ . CELL+ @AZ TYPE CR NONAME] STOPPED-LIST DoList

         [THEN]

         ['] TEST-SS ENUM-ACTIVE-WATCH

       THEN

       WORK-SS>PREV-SS

       ProcWatchDelay hSTOPev0 WaitForSingleObject
       DUP WAIT_OBJECT_0 =
       IF DROP
          [ DEBUG? ] [IF] .TIME ." Killed: WatchProc monitor " GetCurrentThreadId . CR [THEN]
          EXIT THEN
       WAIT_TIMEOUT <>
       IF
          [ DEBUG? ] [IF] ." ProcWatchWait ERROR # " GetLastError . CR [THEN]
       THEN
    AGAIN
; TASK: WATCH-PROC-TASK

(
WARNING @ WARNING 0!
: BeforeStop

    BeforeStop
;
WARNING !
)
: WatchProcDelay: get-number TO ProcWatchDelay ; IMMEDIATE

: PROC-WAIT-IDLE ( pid --)
    FALSE 1024 OpenProcess >R
    -1 R@ WaitForInputIdle DROP
    R> CloseHandle DROP
;

CRITICAL-SECTION <WATCH-PROC-TASK-CS>
: ?WATCH-PROC-TASK-START 
    <WATCH-PROC-TASK-CS> CRIT-ENTER
    ProcWatchHandle @ 0= IF 0 WATCH-PROC-TASK START ProcWatchHandle ! THEN
    <WATCH-PROC-TASK-CS> CRIT-LEAVE
;

: WATCH-PROC-START ( a u -- handle)
\    xstr, CUR-WATCH WATCH-OBJECT !
\    ProcWatchCount 1+!
    ?WATCH-PROC-TASK-START
    2DUP DROP CUR-WATCH WATCH-OBJECT !
    S" \" SEARCH NIP NIP IF ['] WC|RE-COMPARE ELSE ['] ProcCompareName THEN
    CUR-WATCH WATCH-PAR1 !
\ *      Event
    0
;


: (WATCH-PROC) ( type -- )
    >R
    POSTPONE WATCH:
    R> ProcWatchTag OR      WATCH-NODE WATCH-PAR !
    get-string POSTPONE [ EVAL-SUBST ] POSTPONE XSLITERAL
\ *     eval-string,
    POSTPONE WATCH-PROC-START
    POSTPONE END-WATCH
;

: WatchProc:     1 (WATCH-PROC) ; IMMEDIATE
: WatchProcStop: 0 (WATCH-PROC) ; IMMEDIATE
