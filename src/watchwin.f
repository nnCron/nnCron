\ Watch windows
\ Creation, destroy, title change
REQUIRE PROC-EXIST? ~nn/lib/proc.f

0x8FEB6800 CONSTANT WinWatchTag

VARIABLE WinWatchCnt
VARIABLE hHookDLL
VARIABLE HookRes
VARIABLE WatchWinCreateDelay 100 WatchWinCreateDelay !
VARIABLE WatchWindowDelay 100 WatchWindowDelay !
3 VALUE IdleHookMask
\ 1 - mouse
\ 2 - keyboard


VARIABLE <INTERCEPT-SHUTDOWN>
VARIABLE <CONTINUE-SHUTDOWN>
VARIABLE <INTERCEPT-LOGOFF>

: LoadHookDLL
\    DBG( ." LoadHookDLL" CR )
    S" nnhook.dll" DROP LoadLibraryA hHookDLL ! ;
: ExecHookProc ( ... a u ? -- )
    >R
    DROP
    hHookDLL @ 0= IF LoadHookDLL THEN
    hHookDLL @ 0= IF DROP RDROP EXIT THEN
    hHookDLL @ GetProcAddress ?DUP
    IF API-CALL DUP HookRes ! 0<> R@ 0= AND
       IF S" Hook error # %HookRes @%" CRON-LOG THEN
    THEN
    R> IF HookRes @ THEN
;

: set_shell_hook    S" set_shell_hook"    0 ExecHookProc ;
: reset_shell_hook  S" reset_shell_hook"  0 ExecHookProc ;
: set_idle_hook     IdleHookMask SWAP S" set_idle_hook"     0 ExecHookProc ;
: reset_idle_hook   S" reset_idle_hook"   0 ExecHookProc ;
Win2k?
[IF]
: GetIdleTime  ( -- ticks)
    Win2k?
    IF
        GetTickCount 0 8 SP@ GetLastInputInfo 2DROP -
    ELSE
        S" GetIdleTime"       1 ExecHookProc
    THEN
       ;
[ELSE]
: GetIdleTime  ( -- ticks)
        S" GetIdleTime"       1 ExecHookProc
;
[THEN]

: ResetHook
    hHookDLL @
    IF
        DBG( ." Reset hooks" CR )
        reset_shell_hook
        reset_idle_hook
        hHookDLL @ FreeLibrary DROP
    THEN
    hHookDLL OFF
    WinWatchCnt OFF
;

: ?LoadHookDLL hHookDLL @ 0= IF LoadHookDLL THEN ;

: (InitShellHook)
    DBG( ." Init Shell Hook" CR )
    ?LoadHookDLL CtrlClassName 
    DBG( ." Init Shell Hook CtrlClassName=" 2DUP TYPE CR )
    DROP hHookDLL @ set_shell_hook 
;

:NONAME
    BEGIN LOGGEDON? 0= WHILE 1000 PAUSE REPEAT
DBG( ." InitShellHookTask is logged" CR )
\          S" explorer.exe" PROC-EXIST? ?DUP
\          IF ( pid )
\  DBG( ." InitShellHookTask explorer.exe exists " DUP . CR )
        5000 WIN-WAIT
DBG( ." InitShellHookTask WIN-WAIT ok" CR )
\              0 STANDARD_RIGHTS_REQUIRED OpenProcess
\  DBG( ." InitShellHookTask OpenProcess=" DUP . CR )
\              ?DUP 
\              IF
\                  >R
\                  60000 R@ WaitForInputIdle
\  DBG( ." InitShellHookTask WaitForInputIdle=" DUP . CR )
\                  R> CloseHandle DROP
\              THEN
            (InitShellHook)
\          THEN
; TASK: (InitShellHookTask)

: InitShellHook
    WinWatchCnt @ 0<> 
    IF
        Win9x?
        IF
            \ (InitShellHook)
            0 (InitShellHookTask) START CLOSE-FILE DROP
        ELSE
            (InitShellHook)
        THEN
    THEN
;

: InitIdleHook ?LoadHookDLL hHookDLL @ set_idle_hook ;

: NextWinWatch ( -- #)  WinWatchCnt DUP @ SWAP 1+! ;
: WATCH-WIN-START ( a u -- handle)
    NextWinWatch DROP
\    xstr, CUR-WATCH WATCH-OBJECT !
    WATCH-OBJECT-S!
\    InitShellHook
    Event
\    0
;

(
: FREE-WTITLE
    CUR-WATCH WATCH-PAR1 @ ?DUP
    IF GLOBAL FREE LOCAL DROP
       CUR-WATCH WATCH-PAR1 0! THEN ;

: SET-WTITLE
    FREE-WTITLE
    512 ALLOCATE THROW >R R@
    CUR-WATCH WATCH-PAR2 @ \ WIN-HANDLE
    GetWindowTextA
    R@ SWAP GLOBAL S>ZALLOC LOCAL CUR-WATCH WATCH-PAR1 !
    R> FREE DROP
;
)

: FREE-WTITLE
    vTask vtWIN-TITLE @ ?DUP
    IF GLOBAL FREE LOCAL DROP
       vTask vtWIN-TITLE 0! THEN ;

: WIN-TITLE! GLOBAL S>ZALLOC LOCAL vTask vtWIN-TITLE ! ;
: WIN-HANDLE vTask vtWIN-HANDLE @ ;
: SET-WTITLE
\     ." 1:" DEPTH . CR
    FREE-WTITLE
\     ." 2:" DEPTH . CR
    512 DUP ALLOCATE THROW >R R@
\     ." 3:" DEPTH . CR
    WIN-HANDLE \ WIN-HANDLE
\     ." 4:" DEPTH . CR
    GetWindowTextA
\     ." 5:" DEPTH . CR
    R@ SWAP WIN-TITLE!
\     ." 6:" DEPTH . CR
    R> FREE DROP
\     ." 7:" DEPTH . CR    
;

: WIN-TITLE vTask vtWIN-TITLE @ ?DUP
    IF ASCIIZ>
    ELSE
        FOUND-WINDOW
    THEN ;

: WATCH-WIN-RULE ( -- ?)
    DBG( ." <WATCH-WIN-RULE 1:"  DEPTH . CR )
    CUR-WATCH WATCH-PAR1 @ vTask vtWIN-TITLE !
    CUR-WATCH WATCH-PAR2 @ vTask vtWIN-HANDLE !

    DBG( ." WinRule=" vTask vtWIN-HANDLE @ . vTask vtWIN-TITLE @ ASCIIZ> TYPE CR )

    CUR-WATCH WATCH-PAR @ DUP HSHELL_WINDOWCREATED WinWatchTag OR =
    SWAP HSHELL_WINDOWACTIVATED WinWatchTag OR = OR
    vTask vtWIN-TITLE @ C@ 0= AND
 DBG( ." WATCH-WIN-RULE 2: "  DEPTH . CR )
    IF
 DBG( ." WATCH-WIN-RULE 3: "  DEPTH . CR )
        10 0 DO
           WatchWinCreateDelay @ PAUSE
           SET-WTITLE
\ [ DEBUG? ] [IF]  ." Title1: " CUR-WATCH WATCH-PAR1 @ ASCIIZ> TYPE CR [THEN]
           vTask vtWIN-TITLE @ C@
           IF LEAVE THEN
        LOOP
 DBG( ." WATCH-WIN-RULE 4: "  DEPTH . CR )
    ELSE
 DBG( ." WATCH-WIN-RULE 5: "  DEPTH . CR )    
    CUR-WATCH WATCH-PAR @ HSHELL_REDRAW WinWatchTag OR =
    IF
 DBG( ." WATCH-WIN-RULE 6: "  DEPTH . CR )    
      WatchWindowDelay @ PAUSE
      SET-WTITLE
 DBG( ." WATCH-WIN-RULE 7: "  DEPTH . CR )      
\ [ DEBUG? ] [IF]  ." Title2: " CUR-WATCH WATCH-PAR1 @ ASCIIZ> TYPE CR [THEN]
    THEN THEN
 DBG( ." WATCH-WIN-RULE 8: "  DEPTH . CR )
    vTask vtWIN-TITLE @ ?DUP IF ASCIIZ> ELSE S" " THEN
    DBG( ." final1=" 2DUP TYPE SPACE DEPTH . CR )
    WATCH-OBJECT@ WC|RE-COMPARE
\    OVER C@ [CHAR] / = IF RE-MATCH ELSE WC-COMPARE THEN
    DBG( ." match_res1=" DUP . DEPTH . CR )    
    ?DUP 0=
    IF
       vTask vtWIN-HANDLE @ ?DUP
       IF 256 DUP TEMP-ALLOC DUP >R ROT GetClassNameA R> SWAP ELSE S" " THEN
       DBG( ." final2=" 2DUP TYPE SPACE DEPTH . CR )
       WATCH-OBJECT@ WC|RE-COMPARE
\       OVER C@ [CHAR] / = IF RE-MATCH ELSE WC-COMPARE THEN
       DBG( ." match_res2=" DUP . DEPTH . CR )           
    THEN
    DBG( ." result=" DUP . CR )
\ [ DEBUG? ] [IF]  ." Rule result=" DUP . CR [THEN]
\    ." LEAVE" CR
  DBG( ." WATCH-WIN-RULE> "  DEPTH . CR )
;


: WATCH-WIN-CONTINUE
    DEF-WATCH-CONTINUE
\    FREE-WTITLE
;

: (WATCH-WIN) ( numEvent -- )
    >R
    POSTPONE WATCH:
    R> WinWatchTag OR       WATCH-NODE WATCH-PAR !
    ['] WATCH-WIN-RULE      WATCH-NODE WATCH-RULE !
    ['] WATCH-WIN-CONTINUE  WATCH-NODE WATCH-CONTINUE !
    eval-string, POSTPONE WATCH-WIN-START
    POSTPONE END-WATCH
;
: WatchWinCreate:   HSHELL_WINDOWCREATED (WATCH-WIN) ; IMMEDIATE
: WatchWinActivate: HSHELL_WINDOWACTIVATED (WATCH-WIN) ; IMMEDIATE
: WatchWinDestroy:  HSHELL_WINDOWDESTROYED (WATCH-WIN) ; IMMEDIATE
: WatchWindow:      HSHELL_REDRAW (WATCH-WIN) ; IMMEDIATE

:NONAME  { w -- }
   ew-par1 @ ew-par2 @ ( a u ) GLOBAL S>ZALLOC LOCAL w WATCH-PAR1 !
   w WATCH-HANDLE @ SetEvent DROP
DBG( ." SetWinWatchEvent=" w WATCH-CRON-NODE @ CRON-NAME @ COUNT TYPE CR )
    \ w qWS Put
   ew-par3 @ ( hwnd) w WATCH-PAR2 !
;

: SetWinWatchEvent ( hwnd a u typ -- )
    >R
    ew-par2 ! ew-par1 ! ew-par3 ! R> WinWatchTag 
    LITERAL
    ENUM-AW-BY-TAG ;

: IDLE ( s -- ? ) GetIdleTime 1000 / > 0= ;
: IDLE:
    Win2k? 0=
    IF InitIdleHook THEN
    number,
    POSTPONE IDLE
; IMMEDIATE

\ Shutdown/logoff

0x15027300 CONSTANT WinOffTag

: (WATCH-EXIT) ( #event )
    >R
    POSTPONE WATCH:
    R> WinOffTag OR       WATCH-NODE WATCH-PAR !
    30000 WATCH-NODE WATCH-RESPONSE-TIME !
\    POSTPONE Event
    POSTPONE 0
    POSTPONE END-WATCH
;

: WatchLogoff   0 (WATCH-EXIT) ; IMMEDIATE
: WatchShutdown 1 (WATCH-EXIT) ; IMMEDIATE
: WatchLogon    2 (WATCH-EXIT) ; IMMEDIATE
: WatchQueryLogoff   8 (WATCH-EXIT) ; IMMEDIATE
: WatchQueryShutdown 9 (WATCH-EXIT) ; IMMEDIATE


: WATCH-LOGON-RULE ( -- ?)
DBG( ." Watch logon:" CR )
    USERNAME
DBG( ." Username=" 2DUP TYPE CR )
    WATCH-OBJECT@
DBG( ." Mask=" 2DUP TYPE CR )
    WC-COMPARE
DBG( ." Compare Result=" DUP . CR )
;

: WatchLogon:
    get-string s, 1+
    POSTPONE WATCH:
                         WATCH-NODE WATCH-OBJECT !
    2 WinOffTag OR       WATCH-NODE WATCH-PAR !
    30000                WATCH-NODE WATCH-RESPONSE-TIME !
    ['] WATCH-LOGON-RULE WATCH-NODE WATCH-RULE !
    \ POSTPONE Event
    POSTPONE 0
    POSTPONE END-WATCH
; IMMEDIATE

CREATE last-logged 64 ALLOT last-logged 0!

: last-logged! LOGGEDON? IF USERNAME last-logged PLACE ELSE last-logged 0! THEN ;

: WATCH-LOGOFF-RULE ( -- ?) last-logged COUNT WATCH-OBJECT@ WC|RE-COMPARE ;

: WatchLogoff:
    get-string s, 1+
    POSTPONE WATCH:
                         WATCH-NODE WATCH-OBJECT !
    0 WinOffTag OR       WATCH-NODE WATCH-PAR !
    30000                WATCH-NODE WATCH-RESPONSE-TIME !
    ['] WATCH-LOGOFF-RULE WATCH-NODE WATCH-RULE !
    \ POSTPONE Event
    POSTPONE 0
    POSTPONE END-WATCH
; IMMEDIATE

\ * :NONAME ( w -- )
\ * \    DBG( ." Set Event=" DUP WATCH-CRON-NODE @ CRON-NAME @ COUNT TYPE CR )
\ *     WATCH-HANDLE @ SetEvent DROP ;


\ * : SetWinOffEvent ( typ -- ) WinOffTag SetWatchEvent ;
: SetWinOffEvent ( typ -- ) WinOffTag StartWatchByTypeTag ;

0x28066800 CONSTANT WatchPowTag

: (NUM-TAG-WATCH) ( num tag -- )
    OR >R
    POSTPONE WATCH:
    R> WATCH-NODE WATCH-PAR !
    POSTPONE 0
    POSTPONE END-WATCH
;
: (WATCH-POWER) ( numEvent -- ) WatchPowTag (NUM-TAG-WATCH) ;
: WatchSuspend     4 (WATCH-POWER) ; IMMEDIATE
: WatchResumeAuto  18 (WATCH-POWER) ; IMMEDIATE
: WatchResume      7 (WATCH-POWER) ; IMMEDIATE

: WatchStandby 5 (WATCH-POWER) ; IMMEDIATE
: WatchResumeStandby 8 (WATCH-POWER) ; IMMEDIATE

: WatchQuerySuspend  0 (WATCH-POWER) ; IMMEDIATE
: WatchQueryStandby  1 (WATCH-POWER) ; IMMEDIATE

: WatchBatteryLow  9 (WATCH-POWER) ; IMMEDIATE

\ * : SetPowEvent ( typ -- ) WatchPowTag SetWatchEvent ;
: SetPowEvent ( typ -- ) WatchPowTag StartWatchByTypeTag ;


WARNING @ WARNING 0!
: BeforeCrontabLoading
    ResetHook
    BeforeCrontabLoading
;

: AfterWatchStart
    InitShellHook
    AfterWatchStart
;

: BeforeStop
    ResetHook
    BeforeStop
;

WARNING !

: INTERCEPT-SHUTDOWN
    <INTERCEPT-SHUTDOWN> 1+!
;

: CONTINUE-SHUTDOWN
    <CONTINUE-SHUTDOWN> 1+!
    <INTERCEPT-SHUTDOWN> @ DUP IF 1- DUP <INTERCEPT-SHUTDOWN> ! THEN
    0= IF FORCE-POWEROFF THEN
;
