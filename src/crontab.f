REQUIRE { ~nn/lib/locals.f  \ }
REQUIRE N-TEST ~nn/lib/time-test.f
REQUIRE RES ~nn/lib/res.f
REQUIRE GetTrayToken ~nn/lib/win/sec/traytoken.f
REQUIRE RCATCH ~nn/lib/rcatch.f
REQUIRE START-SEQUENCE ~nn/lib/ran4.f

VECT XT-IF-RULE-FALSE  ' NOOP TO XT-IF-RULE-FALSE  \ for WatchHotkey
VECT XT-IF-TIME-FALSE  ' NOOP TO XT-IF-TIME-FALSE  \ for WatchHotkey

CREATE START-TIME /SYSTEMTIME ALLOT
: START-TIME! GET-CUR-TIME LTIME START-TIME /SYSTEMTIME CMOVE ;

\ HINSTANCE FindExecutable(
\    LPCTSTR lpFile,
\    LPCTSTR lpDirectory,
\    LPTSTR lpResult
\ );
WINAPI: FindExecutableA Shell32.dll

VARIABLE TestSuspendTime
VARIABLE DefMissed

: DefaultRunMissedTime: get-string SH:M|D>MIN DefMissed ! ;
DefaultRunMissedTime: 360:00

VARIABLE SyntaxRestriction
0 VALUE widRestr
VOCABULARY Restricted ALSO Restricted CONTEXT @ TO widRestr
PREVIOUS
: restr: WARNING @ >R WARNING 0!
    >IN @ ALSO Restricted DEFINITIONS CREATE IMMEDIATE
    PREVIOUS DEFINITIONS
    >IN ! BL WORD  FIND C, ,
    R> WARNING !
    DOES>
     COUNT ?DUP
     IF 255 = STATE @ 0= OR
        IF @ EXECUTE ELSE @ COMPILE, THEN
     ELSE DROP THEN
;

: restr-on SyntaxRestriction @ IF ONLY Restricted THEN ;
: restr-off SyntaxRestriction @ IF ONLY FORTH THEN ;

: <( restr-off ;
: )> restr-on ;

0 VALUE NUM-PASS
0 VALUE LAST-THREAD
0 VALUE START-DIR
USER <HINT-POS>
USER <HINT-SIZE>
USER <HINT-FONT>
USER <HINT-FONT-SIZE>
USER <HINT-FONT-COLOR>
USER <HINT-COLOR>

VARIABLE DEF-APP-Flags
    CREATE_NEW_CONSOLE DEF-APP-Flags !
VARIABLE YearField
YearField ON

0
1 CELLS -- CRON-NEXT
1 CELLS -- CRON-NAME
1 CELLS -- CRON-TIME-LIST    \ time list
1 CELLS -- CRON-FLAGS
\ 1 CELLS -- CRON-COMMAND
\ 1 CELLS -- CRON-INTERNAL
\ 1 CELLS -- CRON-AFTER
1 CELLS -- CRON-RULE
1 CELLS -- CRON-ACTION
1 CELLS -- CRON-WATCH
1 CELLS -- CRON-USER
1 CELLS -- CRON-PASSWORD
1 CELLS -- CRON-DOMAIN
1 CELLS -- CRON-SU-FLAGS
1 CELLS -- CRON-SU-TOKEN
1 CELLS -- CRON-LOGON-FLAGS
1 CELLS -- CRON-HWINSTA
1 CELLS -- CRON-FILENAME
1 CELLS -- CRON-COUNTER
1 CELLS -- CRON-LAST-TIME
1 CELLS -- CRON-MISSED     \ if set value is minutes
1 CELLS -- CRON-IS-MISSED  \ true if task is missed
1 CELLS -- CRON-APP-Flags
1 CELLS -- CRON-CRC32
1 CELLS -- CRON-SESSIONID
/STARTUPINFO -- CRON-si

CONSTANT /CRON-NODE

0
1 CELLS -- CRON-NEXT-TIME
1 CELLS -- CRON-MIN
1 CELLS -- CRON-HOUR
1 CELLS -- CRON-DAY
1 CELLS -- CRON-WDAY
1 CELLS -- CRON-MON
1 CELLS -- CRON-YEAR
60      -- CRON-T-MIN
24      -- CRON-T-HOUR
31      -- CRON-T-DAY
7       -- CRON-T-WDAY
12      -- CRON-T-MON
YEAR-RANGE 1+ -- CRON-T-YEAR

CONSTANT /CRON-TIME

1   CONSTANT CF-LOGGING
2   CONSTANT CF-ACTIVE
4   CONSTANT CF-ERROR
8   CONSTANT CF-LOGINTERNAL
16  CONSTANT CF-ATSTART
32  CONSTANT CF-ATSTOP
64  CONSTANT CF-NODEL
128 CONSTANT CF-ONCE
256  CONSTANT CF-HOURLY
512  CONSTANT CF-DAILY
1024 CONSTANT CF-WEEKLY
2048 CONSTANT CF-MONTHLY
0x0F00 CONSTANT CRON-MASK-LY
0x1000 CONSTANT CF-PROFILE
0x2000 CONSTANT CF-NORUNAS
0x4000 CONSTANT CF-ALSO
\ 0x8000 CONSTANT CF-RUN-MISSED
0x10000 CONSTANT CF-ASLOGGED
0x20000 CONSTANT CF-LOAD-PROFILE
0x40000 CONSTANT CF-SINGLE
0x80000 CONSTANT CF-HYPER

VARIABLE CRON-LIST
VARIABLE SPEC-CRON-LIST
VARIABLE SPEC-TASK?

CREATE CRON-NODE /CRON-NODE ALLOT
CREATE CRON-TIME /CRON-TIME ALLOT

CREATE DEF-CRON-NODE /CRON-NODE ALLOT
        DEF-CRON-NODE /CRON-NODE ERASE
USER-VALUE CUR-NODE
USER-VALUE CUR-TIME

: AND? AND 0<> ;
: CUR-FLAG? ( mask -- ? ) CUR-NODE CRON-FLAGS @ AND? ;
: CF-ACTIVE?  CF-ACTIVE CUR-FLAG? ;
: CF-ERROR?   CF-ERROR CUR-FLAG? ;
: CF-LOGGING? CF-LOGGING CUR-FLAG? ;
: CF-ATSTART? CF-ATSTART CUR-FLAG? ;
: CF-ATSTOP?  CF-ATSTOP CUR-FLAG? ;
: CF-NODEL?   CF-NODEL CUR-FLAG? ;
: CF-ONCE?    CF-ONCE CUR-FLAG? ;
: CF-HOURLY?  CF-HOURLY CUR-FLAG? ;
: CF-DAILY?   CF-DAILY CUR-FLAG? ;
: CF-WEEKLY?  CF-WEEKLY CUR-FLAG? ;
: CF-MONTHLY? CF-MONTHLY CUR-FLAG? ;
: CF-LY?      CRON-MASK-LY CUR-FLAG? ;
: CF-PROFILE? CF-PROFILE CUR-FLAG? ;
: CF-ALSO?    CF-ALSO CUR-FLAG? ;
: CF-RUN-MISSED? CUR-NODE CRON-MISSED @ 0<> ;  \ CF-RUN-MISSED  CUR-FLAG? ;
: CF-ASLOGGED? CF-ASLOGGED  CUR-FLAG? ;
: CF-LOAD-PROFILE? CF-LOAD-PROFILE CUR-FLAG? ;
: CF-SINGLE? CF-SINGLE CUR-FLAG? ;
: CF-HYPER? CF-HYPER CUR-FLAG? ;

: ?CRON-LOG CF-LOGGING? IF CRON-LOG ELSE 2DROP THEN ;

: CRON-TASK-NAME
    CRON-NODE CRON-NAME @
    ?DUP IF COUNT ELSE S"  " THEN
;

: CUR-TASK-NAME
    CUR-NODE ?DUP IF CRON-NAME @ ?DUP
                     IF COUNT ELSE HERE 0 THEN
                  ELSE HERE 0 THEN
;

\ : TDBG( POSTPONE DBG( POSTPONE CUR-TASK-NAME POSTPONE TYPE POSTPONE SPACE ; IMMEDIATE
DEBUG?
[IF]
    : TDBG-NAME CUR-TASK-NAME TYPE SPACE ;
    : TDBG( [CHAR] ) POSTPONE .TIME POSTPONE TDBG-NAME WORD COUNT >R PAD R@ CMOVE PAD R> EVALUATE ; IMMEDIATE
[ELSE]
    : TDBG( [CHAR] ) WORD DROP ; IMMEDIATE
[THEN]

S" taskinfo.f" INCLUDED

: LOG-NODE ( A # NODE --)
    TO CUR-NODE
    PAD PLACE
    CUR-TASK-NAME PAD +PLACE
    PAD COUNT ?CRON-LOG
;

:NONAME
    CUR-NODE
    IF CUR-TASK-NAME
    ELSE HERE 0 THEN
; TO LOG-ERR-PREF

: CRON-FLAG1 ( mask --)
    CRON-NODE CRON-FLAGS @ OR
    CRON-NODE CRON-FLAGS ! ;
: CRON-FLAG0 ( mask --)
    -1 XOR CRON-NODE CRON-FLAGS @ AND
    CRON-NODE CRON-FLAGS ! ;

: SET-CRON-FLAG (  NODE MASK --) >R CRON-FLAGS DUP @ R> OR SWAP ! ;
: CLR-CRON-FLAG (  NODE MASK --) -1 XOR >R CRON-FLAGS DUP @ R> AND SWAP ! ;


: GW, ( -- a/0) BL WORD DUP C@ IF DUP ", 0 C, ELSE DROP 0 THEN ; \ "
: end-def STATE @ IF RET, ( POSTPONE ;) [COMPILE] [ SMUDGE THEN ; \ ]
\ : end-def STATE @ IF POSTPONE ; THEN ;



USER >IN1

: TIME-ERROR  >IN @ >IN1 ! -1 10003 ?LOG-ERROR ;

VARIABLE t-is-year

: TEST-TIME-FIELD ( a u -- )
\    CR ." ENTER" CR
\    .S
    BEGIN ?DUP WHILE
        OVER C@ DUP [CHAR] * = SWAP [CHAR] ? = OR
        IF SKIP-CHAR
        ELSE
            TIME>NUMB DUP BEG-RANGE < SWAP END-RANGE > OR t-is-year @ 0= AND
            IF 2DROP TIME-ERROR EXIT THEN
        THEN
        DUP
        IF OVER C@ DUP [CHAR] , = OVER [CHAR] - = OR SWAP [CHAR] / = OR
           IF
             SKIP-CHAR
             ?DUP 0= IF DROP TIME-ERROR EXIT THEN
           ELSE
             2DROP TIME-ERROR EXIT
           THEN
        THEN
    REPEAT
    DROP
\    CR ." EXIT" CR
\    .S
;

: GTW, { \ beg -- addr }
    HERE TO beg  0 W,
    BEGIN
      GW, DUP
      IF
        COUNT beg +PLACE -3 ALLOT 0 C,
\        beg SHOW
        beg COUNT + 1- C@ DUP [CHAR] , = SWAP [CHAR] - = OR
      THEN
      0=
    UNTIL
    beg C@ 0=
    IF 0
    ELSE beg C@ 1 = beg 1+ C@ [CHAR] * = AND
        IF 0
        ELSE beg COUNT TEST-TIME-FIELD
             beg
        THEN
    THEN
;

S" ttable.f" INCLUDED

: M: end-def t-is-ny 0-59 GTW, DUP CRON-TIME CRON-MIN !
    CRON-TIME CRON-T-MIN START-TIME wMinute W@ set-cron-time-table
\    0 CRON-TIME CRON-MIN @ COUNT DROP DUP 0 MessageBoxA DROP
;  IMMEDIATE
: H: end-def t-is-ny 0-23 GTW, DUP CRON-TIME CRON-HOUR !
    CRON-TIME CRON-T-HOUR START-TIME wHour W@ set-cron-time-table
; IMMEDIATE
: W: end-def t-is-ny 1-7 GTW, DUP CRON-TIME CRON-WDAY !
    CRON-TIME CRON-T-WDAY START-TIME wDayOfWeek W@ ?DUP 0= IF 7 THEN set-cron-time-table
; IMMEDIATE
: D: end-def t-is-ny 1-31 GTW, DUP CRON-TIME CRON-DAY !
    CRON-TIME CRON-T-DAY START-TIME wDay W@ set-cron-time-table
; IMMEDIATE
: MON: end-def t-is-ny 1-12 GTW, DUP CRON-TIME CRON-MON !
    CRON-TIME CRON-T-MON START-TIME wMonth W@ set-cron-time-table
; IMMEDIATE
: Y: end-def t-is-y 2000-3000 GTW, DUP CRON-TIME CRON-YEAR !
    CRON-TIME CRON-T-YEAR START-TIME wYear W@ set-cron-time-table
; IMMEDIATE

: gevs, get-string EVAL-SUBST s, ;
: User: end-def gevs, CRON-NODE CRON-USER ! ; IMMEDIATE
: Domain: end-def gevs, CRON-NODE CRON-DOMAIN ! ; IMMEDIATE
: Password: end-def gevs, CRON-NODE CRON-PASSWORD ! ; IMMEDIATE
: SecPassword: end-def
    get-string EVAL-SUBST DecP s, CRON-NODE CRON-PASSWORD ! ; IMMEDIATE

VARIABLE DefaultUser
VARIABLE DefaultPassword
VARIABLE DefaultDomain
VARIABLE RunAsDefaultUser
VARIABLE DefaultLoadProfile

VARIABLE GUIUser
VARIABLE GUIPassword
VARIABLE GUIDomain
VARIABLE GUIAsUser
VARIABLE GUILoadProfile

: DefaultUser: gevs, DefaultUser ! ;
: DefaultPassword: get-string EVAL-SUBST DecP s, DefaultPassword ! ;
: DefaultDomain: gevs, DefaultDomain ! ;

: GUIUser: gevs, GUIUser ! ;
: GUIPassword: get-string EVAL-SUBST DecP s, GUIPassword ! ;
: GUIDomain: gevs, GUIDomain ! ;

: R: end-def
    HERE 0 ,
    CRON-NODE CRON-RULE
    BEGIN DUP @ ?DUP WHILE NIP REPEAT
    !
    :NONAME DROP ; IMMEDIATE
\ : C: end-def 1 WORD DUP ", 0 C, CRON-NODE CRON-COMMAND ! ;  IMMEDIATE
\ : I: end-def :NONAME CRON-NODE CRON-INTERNAL ! ;  IMMEDIATE
\ : A: end-def :NONAME CRON-NODE CRON-AFTER ! ;  IMMEDIATE
: A: end-def :NONAME CRON-NODE CRON-ACTION ! ;  IMMEDIATE

: Minutes:  [COMPILE] M: ; IMMEDIATE
: Hours:    [COMPILE] H: ; IMMEDIATE
: Days:     [COMPILE] D: ; IMMEDIATE
: WeekDays: [COMPILE] W: ; IMMEDIATE
: Months:   [COMPILE] MON: ; IMMEDIATE
: Years:    [COMPILE] Y: ; IMMEDIATE

: Rule:     [COMPILE] R: restr-off ; IMMEDIATE
\ : Internal: [COMPILE] I: ; IMMEDIATE
\ : After: [COMPILE] A: ; IMMEDIATE
\ : Command:  [COMPILE] C: ; IMMEDIATE

: NoLog    end-def CF-LOGGING CRON-FLAG0 ; IMMEDIATE
: NoActive end-def CF-ACTIVE CRON-FLAG0 ; IMMEDIATE
: NoDel    end-def CF-NODEL CRON-FLAG1 ; IMMEDIATE
: RunOnce  end-def CF-ONCE CRON-FLAG1 ; IMMEDIATE
: NoRunAs  end-def CF-NORUNAS CRON-FLAG1 ; IMMEDIATE
\ * : RunMissed  end-def CF-RUN-MISSED  CRON-FLAG1 ; IMMEDIATE
: RunMissed  end-def DefMissed @ CRON-NODE CRON-MISSED ! ; IMMEDIATE
: RunMissed:  end-def get-string SH:M|D>MIN CRON-NODE CRON-MISSED ! ; IMMEDIATE
: Hourly  end-def CF-HOURLY CRON-FLAG1 ; IMMEDIATE
: Daily   end-def CF-DAILY CRON-FLAG1 ; IMMEDIATE
: Weekly  end-def CF-WEEKLY CRON-FLAG1 ; IMMEDIATE
: Monthly end-def CF-MONTHLY CRON-FLAG1 ; IMMEDIATE
: AsLoggedUser end-def CF-ASLOGGED CRON-FLAG1 ; IMMEDIATE
: SingleInstance end-def CF-SINGLE CRON-FLAG1 ; IMMEDIATE
: HyperActive end-def CF-HYPER CRON-FLAG1 ; IMMEDIATE

: OnceAHour POSTPONE Hourly ; IMMEDIATE
: OnceADay POSTPONE Daily ; IMMEDIATE
: OnceAWeek POSTPONE Weekly ; IMMEDIATE
: OnceAMonth POSTPONE Monthly ; IMMEDIATE
: Also end-def CF-ALSO CRON-FLAG1 ; IMMEDIATE

\ : LogInternal end-def CF-LOGINTERNAL CRON-FLAG1 ;  IMMEDIATE
: Action:  [COMPILE] A: restr-off ; IMMEDIATE

1 CONSTANT LOGON_WITH_PROFILE
2 CONSTANT LOGON_NETCREDENTIALS_ONLY

: SU-FLAG! ( flag --) CRON-NODE CRON-SU-FLAGS DUP @ ROT OR SWAP ! ;
: LOGON-FLAG! ( flag --) CRON-NODE CRON-LOGON-FLAGS ! ;

USER WITH-PROFILE
: LoadProfile CF-LOAD-PROFILE CRON-FLAG1 ; IMMEDIATE
: WithoutProfile  CF-LOAD-PROFILE CRON-FLAG0 ; IMMEDIATE

: LogonBatch end-def LOGON32_LOGON_BATCH SU-FLAG! ; IMMEDIATE
: LogonInteractive end-def LOGON32_LOGON_INTERACTIVE SU-FLAG!
            LOGON_WITH_PROFILE LOGON-FLAG!
    ; IMMEDIATE
: LogonService end-def LOGON32_LOGON_SERVICE SU-FLAG! ; IMMEDIATE
: LogonNetwork end-def
    LOGON32_LOGON_NETWORK SU-FLAG! ; IMMEDIATE


: SET-SI-FLAGS ( flag node --)
    >R R@ CRON-si dwFlags @ OR
       R> CRON-si dwFlags ! ;

: (SET-SW) ( flag node )
    >R  R@ CRON-si wShowWindow W!
    STARTF_USESHOWWINDOW R> SET-SI-FLAGS ;

: SET-SW ( flag -- )
    STATE @ IF POSTPONE LITERAL POSTPONE CUR-NODE POSTPONE (SET-SW)
    ELSE CRON-NODE (SET-SW) THEN ;

: ShowNormal       SW_SHOWNORMAL      SET-SW ; IMMEDIATE
: SWHide           SW_HIDE            SET-SW ; IMMEDIATE
: ShowMaximized    SW_SHOWMAXIMIZED   SET-SW ; IMMEDIATE
\ : ShowMinimized    SW_SHOWMINIMIZED   SET-SW ; IMMEDIATE
: ShowMinimized    SW_SHOWMINNOACTIVE SET-SW ; IMMEDIATE
: ShowNoActivate   SW_SHOWNOACTIVATE  SET-SW ; IMMEDIATE

: (SET-APP-Flags) ( flag node -- )
    DEF-APP-Flags @ ROT OR SWAP
    CRON-APP-Flags ! ;

: SET-APP-Flags ( flag -- )
    STATE @ IF POSTPONE LITERAL POSTPONE CUR-NODE POSTPONE (SET-APP-Flags)
    ELSE CRON-NODE (SET-APP-Flags) THEN ;

: xNT WinNT? 0= IF RDROP THEN ;

: HighPriority   xNT   HIGH_PRIORITY_CLASS SET-APP-Flags ; IMMEDIATE
: IdlePriority   xNT   IDLE_PRIORITY_CLASS SET-APP-Flags ; IMMEDIATE
: NormalPriority xNT   NORMAL_PRIORITY_CLASS SET-APP-Flags ; IMMEDIATE
: RealtimePriority xNT REALTIME_PRIORITY_CLASS SET-APP-Flags ; IMMEDIATE
: AboveNormalPriority xNT   0x8000 SET-APP-Flags ; IMMEDIATE
: BelowNormalPriority xNT   0x4000 SET-APP-Flags ; IMMEDIATE

: (START-POS) ( x y node -- )
    >R   R@ CRON-si dwY !
         R@ CRON-si dwX !
    STARTF_USEPOSITION R> SET-SI-FLAGS ;
: START-POS CUR-NODE (START-POS) ;
: SET-START-POS ( x y -- )
    STATE @ IF
                SWAP POSTPONE LITERAL POSTPONE LITERAL
                POSTPONE START-POS
    ELSE CRON-NODE (START-POS) THEN ;
: StartPos: \ X Y ( -- )
    get-number get-number  SET-START-POS  ;  IMMEDIATE

: (START-SIZE) ( xSize ySize node --)
    >R   R@ CRON-si dwYSize !
         R@ CRON-si dwXSize !
    STARTF_USESIZE R> SET-SI-FLAGS ;
: START-SIZE CUR-NODE (START-SIZE) ;
: SET-START-SIZE ( x y --)
    STATE @ IF SWAP POSTPONE LITERAL POSTPONE LITERAL
               POSTPONE START-SIZE
    ELSE CRON-NODE (START-SIZE) THEN ;
: StartSize: \ X Y ( -- )
    get-number get-number  SET-START-SIZE  ;  IMMEDIATE

: CRON-NODE0!
    CRON-NODE /CRON-NODE ERASE
    DEF-CRON-NODE CRON-NODE /CRON-NODE CMOVE
    CRON-TIME /CRON-TIME ERASE

    CRON-TIME CRON-T-MIN [ 60 24 + 31 + 7 + 12 + YEAR-RANGE 1+ + ] LITERAL 1 FILL

    CF-LOGGING CRON-FLAG1
    CF-ACTIVE  CRON-FLAG1
    DefaultLoadProfile @ IF CF-LOAD-PROFILE CRON-FLAG1 THEN
    -1 CRON-NODE CRON-SESSIONID !
\    DETACHED_PROCESS CRON-NODE CRON-APP-Flags DUP @ ROT OR SWAP !
;

: by-time? MainThrId @ GetCurrentThreadId = ;

: ?TEST> N-TEST 0= IF RDROP FALSE THEN  ;

: TEST-NODE-1TIME ( -- ? )
    ['] def-name2num TO NAME2NUM
    0-59 CUR-TIME CRON-MIN @ Min@  START-TIME wMinute W@ ?TEST>
    0-23 CUR-TIME CRON-HOUR @ Hour@  START-TIME wHour W@ ?TEST>
    CUR-TIME CRON-WDAY @ 0=
    IF 1-31 CUR-TIME CRON-DAY @ Day@ START-TIME wDay W@ ?TEST> ELSE
    CUR-TIME CRON-DAY @ 0=
    IF 1-7  CUR-TIME CRON-WDAY @ WDay@  WEEKDAYS 0 ?TEST>
    ELSE
        1-31 CUR-TIME CRON-DAY @ Day@ START-TIME wDay W@ N-TEST
        1-7  CUR-TIME CRON-WDAY @ WDay@  WEEKDAYS 0 N-TEST AND
        0= IF FALSE EXIT THEN
    THEN THEN
    1-12 CUR-TIME CRON-MON @ Mon@  MONTHES START-TIME wMonth W@  ?TEST>
    2000-3000 YearField @ IF CUR-TIME CRON-YEAR @ Year@ 0 ?TEST> THEN
    TRUE
;

: TEST-NODE-TIME ( -- ?)
    CUR-NODE CRON-TIME-LIST
    BEGIN @ ?DUP WHILE
      TO CUR-TIME
      TEST-NODE-1TIME
      IF TRUE EXIT THEN
      CUR-TIME
    REPEAT
    FALSE
;


USER-VALUE LOGON-RESULT

: LOGON-USER ( S" User" S" Domain" S" Password" Flags -- Token ior)
    >R DROP NIP ROT DROP 2>R >R
    0 SP@ LOGON32_PROVIDER_DEFAULT
    R> 2R> R> SWAP 2SWAP SWAP
    LogonUserA ERR
\    [ DEBUG? ] [IF] DUP IF ." Logon error=" DUP . CR THEN [THEN]
;

: GET-CRON-PASSWORD
    CUR-NODE CRON-PASSWORD @ ?DUP
    IF COUNT ELSE S" " THEN
;

: GET-CRON-DOMAIN
    CUR-NODE CRON-DOMAIN @ ?DUP
    IF COUNT ELSE  0 0 ( S" COMPUTERNAME" ENV) THEN
;

: NoRunAs? CUR-NODE CRON-FLAGS @ CF-NORUNAS AND 0<> ;

: Interactive? CUR-NODE CRON-SU-FLAGS @ DUP 0= SWAP LOGON32_LOGON_INTERACTIVE AND OR 0<> ;
: RunForSession? CUR-NODE CRON-SESSIONID @ -1 <> ;
: GetUserToken ( -- h ior )
\ ." <GetUserToken " CUR-TASK-NAME TYPE SPACE DEPTH . CR 
    RunForSession?
    IF 
        
        CUR-NODE CRON-SESSIONID @ GetUserTokenBySession 
\        DBG( ." GetUserToken 1:" 2DUP . . )
    ELSE 
        GetCurrentUserTokenWait 
\        DBG( ." GetUserToken 2:" 2DUP . . )
    THEN
\ ." GetUserToken> " CUR-TASK-NAME TYPE SPACE DEPTH . CR 
;

: LOGON-NODE  ( -- )
    RunAsDefaultUser @ 0<>
    NoRunAs? 0= AND
    CUR-NODE CRON-USER @ 0= AND
    IF
        DefaultUser @       CUR-NODE CRON-USER !
        DefaultPassword @   CUR-NODE CRON-PASSWORD !
        DefaultDomain @     CUR-NODE CRON-DOMAIN !
    THEN

    CUR-NODE CRON-SU-TOKEN 0!
    WinNT? CUR-NODE CRON-USER @ 0<> CF-ASLOGGED? OR AND
    IF
        AsLoggedOk OFF
        CF-ASLOGGED? I'mService AND
        IF ( GetTrayToken) GetUserToken DUP 10002 ?LOG-ERROR
            DUP 0= AsLoggedOk !
        ELSE 0 1 THEN

        DUP 0<> CUR-NODE CRON-USER @ 0<> AND
        IF
          2DROP
          CUR-NODE CRON-USER @ COUNT   \   2DUP TYPE CR
          GET-CRON-DOMAIN              \   2DUP TYPE CR
          GET-CRON-PASSWORD            \   2DUP TYPE CR
          CUR-NODE CRON-SU-FLAGS @     \   DUP . CR
          ?DUP 0= IF LOGON32_LOGON_INTERACTIVE THEN
          LOGON-USER
\          ." LOGON-USER=" 2DUP . . CR
        THEN

        DUP 10001 ?LOG-ERROR
        0=
        IF
            CUR-NODE CRON-SU-TOKEN !
            CUR-NODE CRON-SU-TOKEN @ ImpersonateLoggedOnUser DROP
\            DBG( CUR-NODE CRON-NAME @ ?DUP IF COUNT TYPE CR THEN )
\            RunForSession? IF AsLoggedOk 0! THEN
            Interactive? IF CF-LOAD-PROFILE?  
                            CUR-NODE CRON-SU-TOKEN @ LoadUserProfile THEN
\            RevertToSelf DROP
\            OPEN-WINSTA CUR-NODE CRON-HWINSTA !
        ELSE
            DROP
        THEN
    THEN
;

: LOGOFF-NODE
    CUR-NODE CRON-SU-TOKEN @ ?DUP
    IF
        RevertToSelf DROP
\        CF-LOAD-PROFILE? IF 60000 PAUSE THEN
        Interactive? IF DUP UnloadUserProfile THEN
        CLOSE-FILE DROP
    THEN
;

0 VALUE CUR-POS

USER-VALUE ERR-CODE

: START-TIME? NUM-PASS 0= ;

USER ly-Y USER ly-M USER ly-D
USER ly-h USER ly-m USER ly-?

: ly-month? ly-Y @ Year@ = ly-M @ Mon@ = AND ;
: ly-today? ly-month? ly-D @ Day@ = AND ;

: FIT-LY? ( a u -- ?)
\    [ DEBUG? ] [IF] CUR-NODE CRON-NAME @ COUNT TYPE ." =" [THEN]
    <TIB
    NextWord 2DUP S" !" COMPARE
    IF
\    [ DEBUG? ] [IF] 2DUP TYPE ."  ? " [THEN]
        CUR-NODE CRON-NAME @ COUNT COMPARE 0=
        IF
            NextWord SDD.MM.YYYY ly-D ! ly-M ! ly-Y !
            NextWord SHH:MM ly-m ! ly-h !
            NextWord IF C@ [CHAR] + = ELSE DROP TRUE THEN ly-? !
            TRUE
        ELSE FALSE THEN
    ELSE 2DROP FALSE THEN
    TIB>
\    [ DEBUG? ] [IF] DUP . CR [THEN]
;

: TEST-LY ( -- ? )
\      CUR-TASK-NAME TYPE CR
\      ." Test LY" CR
    CF-LY?
    IF
\          ." LY" CR
\        OPEN-ONCE
        ['] FIT-LY? FIND-ONCE
\        CLOSE-ONCE
        IF
\              ." LY found" CR
            ly-? @ 0= ?DUP 0=
            IF
            CF-HOURLY?
            IF  ly-h @ Hour@ =
                IF ly-today? 0=
                ELSE TRUE THEN
            ELSE
            CF-DAILY?
            IF
\  ." LY daily" CR
                ly-today? 0=
\  ." LY daily result " DUP . CR
            ELSE
            CF-MONTHLY?
            IF
                ly-month? 0=
            ELSE
            CF-WEEKLY?
            IF
                WDay@
                Year@ Mon@ Day@ DAYS
                ly-Y @ ly-M @ ly-D @ DAYS -
                > 0=
            ELSE
                TRUE
            THEN THEN THEN THEN THEN
        ELSE
\            ." LY not found" CR
            TRUE
        THEN
    ELSE TRUE THEN
;

: CUR-NAME CUR-NODE CRON-NAME @ COUNT ;
: #00 S>D <# # # #> ;
: #0000 S>D <# # # # # #> ;
: LY-LINE
    IF
        S" %CUR-NAME% %DD%.%MM%.%YYYY% %hh%:%mm% +"
    ELSE
        S" %CUR-NAME% %ly-D @ #00%.%ly-M @ #00%.%ly-Y @ #0000% %ly-h @ #00%:%ly-m @ #00% -"
    THEN
;

: (WRITE-LY) ( type -- )
\    CF-LY?
\    IF
        LY-LINE ['] FIT-LY? UPDATE-ONCE
\    ELSE
\        DROP
\    THEN
;

: WRITE-LY
\    SP@ >R
\    LOGOFF-NODE
    TRUE (WRITE-LY)
\    LOGON-NODE
\    R> SP!
    tiBegin&Find
    IF
        FT-CUR FT>DD.MM.YYYY/hh:mm:ss   TI-EXECUTION-TIME   tiTable fput
        STRUE                           TI-FLAG-SUCCESS     tiTable fput
        \                               tiWRITE
    THEN
    tiEnd

;

: CLEAR-ONCE
    FALSE (WRITE-LY)
    tiBegin&Find
    IF
        \ FT-CUR FT>DD.MM.YYYY/hh:mm:ss   TI-EXECUTION-TIME   tiTable FPUT
        SFALSE                          TI-FLAG-SUCCESS     tiTable fput
        \                               tiWRITE
    THEN
    tiEnd
;

: CANCEL CLEAR-ONCE ;

: DISABLE CUR-NODE CF-ERROR SET-CRON-FLAG ;

: ?ATnum ( a -- ...)
    ?DUP 0= IF RDROP FALSE EXIT THEN
    COUNT ?DUP 0= IF DROP RDROP FALSE EXIT THEN
    2DUP S" *" COMPARE 0=  IF 2DROP RDROP FALSE EXIT THEN
    0 0 2SWAP >NUMBER IF DROP 2DROP RDROP FALSE EXIT THEN
    2DROP
;

S" assumed.f" INCLUDED

0 [IF]
            : LAUNCH-TIME ( -- d t= | -- f=)
            \ time of last launch in FILETIME
                ['] FIT-LY? FIND-ONCE
                IF
                    ly-? @ IF ly-Y @ ly-M @ ly-D @ ly-h @ ly-m @ 0 YMDHMS>FT TRUE ELSE FALSE THEN
                ELSE FALSE THEN
            ;

            : ASSUMED-LAUNCH-TIME { \ Y M D h m -- d t= | -- f=}
                Year@ TO Y
                CUR-TIME CRON-MIN @ ?ATnum TO m
                CUR-TIME CRON-HOUR @ ?ATnum TO h
                CUR-TIME CRON-DAY @ ?ATnum TO D
                CUR-TIME CRON-MON @ ?ATnum TO M
                YearField @ IF CUR-TIME CRON-YEAR @ ?ATnum TO Y THEN
                Y M D h m 0 YMDHMS>FT TRUE
            ;


            : MISSED? ( -- ?)
            \ true if task is overdue
                ASSUMED-LAUNCH-TIME
                IF ( d )
                    2DUP FT-CUR D<
                    IF
                        LAUNCH-TIME
                        IF ( d1 d2 )
                            2SWAP D<
                        ELSE 2DROP TRUE THEN
                    ELSE
                    \ ещё не пришло время
                        2DROP
                        FALSE
                    THEN
                ELSE
                    FALSE
                THEN
            ;

[THEN]

1 [IF]

: LAUNCH-TIME ( -- d t= | -- f=)
\ time of last launch in FILETIME
    TASK-EXECUTION-TIME
;

: MISSED? { \ n1 n2 n12 n22 -- ?}
\ true if task is missed
    DBG( ." MISSED?" CR )
    ASSUMED-PREV-TIME2
    IF ( d)
        TO n2 TO n1 TO n22 TO n12
        DBG( ." 1 --- " n1 n2 D. CR )
        TASK-EXECUTION-TIME
        IF ( d1 d2 )
            DBG( ." 2 --- " 2DUP D. CR )
            n12 n22 D<
        ELSE
            TASK-CREATION-TIME
            IF
                DBG( ." 3 --- " 2DUP D. CR )
                n1 n2 D<
            THEN
        THEN
    ELSE
        FALSE
    THEN
    DUP
    IF
        \ проверяем, а не прошло ли время для missed?
        FT-CUR n1 n2 FT- FT>MIN
        DBG( ." 4 --- " DUP . CR )
        DUP 0 >
        IF
            CUR-NODE CRON-MISSED @ >
            IF DROP FALSE THEN
        ELSE DROP THEN
        DBG( ." 5 --- " DUP . CR )
    THEN
;
[THEN]

: TASK-LAUNCH-TIME ( a -- d t= | -- f=)
    CUR-NODE >R
    @ TO CUR-NODE
    LAUNCH-TIME
    R> TO CUR-NODE
;

: RUN-MISSED? ( -- ?)
    CF-RUN-MISSED? by-time?  AND
    IF
        MISSED?
        DUP CUR-NODE CRON-IS-MISSED !
    ELSE
        FALSE
    THEN
;

: TEST-NODE ( Node --?)
    TO CUR-NODE
    CF-ACTIVE? 0= CF-ERROR? OR IF FALSE EXIT THEN
    TEST-NODE-TIME ?DUP 0=
    IF
        RUN-MISSED?
    THEN
    
    DUP IF DROP TEST-LY THEN
\    TEST-FOR-MONTH
\    DBG( DEPTH . CUR-TASK-NAME TYPE SPACE GetTickCount >R ['] ASSUMED-NEXT-TIME CATCH ?DUP IF ." ASSUMED-NEXT-TIME # " . ELSE IF FT>DD.MM.YYYY/hh:mm:ss TYPE ELSE ." no" THEN SPACE THEN GetTickCount R> - . DEPTH . CR )
\    DBG( test-prev&next )
\    CF-ATSTART? IF NUM-PASS 0= AND THEN
;

USER-VALUE vTask  ( user values)
0
1 CELLS -- vtFIRST
1 CELLS -- vtWIN-TITLE
1 CELLS -- vtWIN-HANDLE
1 CELLS -- vtWATCH
1 CELLS -- vtPROC-ID
1 CELLS -- vtPROC-NAME
CONSTANT /VTASK

: vt-ALLOC /VTASK ALLOCATE THROW ;
: vt-NEW ( -- ) vTask 0= IF vt-ALLOC TO vTask THEN ;

: vt-DUP ( -- a)
    GLOBAL ['] vt-ALLOC CATCH LOCAL THROW >R
    vTask R@ /VTASK CMOVE
    R> ;

: vt-COPY ( a -- )
    vt-ALLOC TO vTask
    DUP vTask /VTASK CMOVE
    GLOBAL FREE  LOCAL THROW
;

: START-TASK ( par task -- )
    vt-NEW
    SWAP vTask vtFIRST !
    vt-DUP SWAP START
\    [ DEBUG? ] [IF] DUP S>D <# #S S" Thread handle is " HOLDS #> CRON-LOG [THEN]
    ?DUP IF DUP TO LAST-THREAD ADD-TASK ELSE vTask FREE THROW THEN ;
\ : START-TASK START ?DUP IF CloseHandle THEN ;


: CRON-NEED-DELETE? ( -- ?) CF-NODEL? 0=  CF-ONCE? AND ;

\ Удаление уже отработанных
\ Дополнение к 'crontab.f'

1 [IF]
S" tm/delete_task.f" INCLUDED

: CUR-NODE-DELETE
    S" Delete task: " CUR-NODE LOG-NODE
    CUR-NODE CRON-FILENAME @ COUNT
    CUR-NODE CRON-NAME @ COUNT
    TRUE DELETE-TASK ( atab utab atask utask flag-backup -- )
;

[ELSE]
0 VALUE CRON-DEL-NEW-FILE
0 VALUE TASK-FOUND?
0 VALUE hDELETED

: DELETED-FILENAME S" deleted.tab" ;

\ Текущий адрес элемента нах-ся в CUR-NODE (value)

: COPY-LINE-TO-NEW-FILE TIB #TIB @ CRON-DEL-NEW-FILE WRITE-LINE DROP ;

: ?COMMENT
    HERE 1+ C@ [CHAR] # =
    IF 1 WORD DROP THEN
;

: IS-BEG-TASK?
    BEGIN BL WORD COUNT ?DUP WHILE
        S" #(" COMPARE 0=
        IF BL WORD COUNT
            CUR-NODE CRON-NAME @ COUNT COMPARE 0= EXIT
        ELSE
            ?COMMENT
        THEN
    REPEAT
    DROP FALSE
;

: IS-END-TASK?
    BEGIN BL WORD COUNT ?DUP WHILE
        S" )#" COMPARE 0= IF TRUE EXIT THEN
        ?COMMENT
    REPEAT
    DROP FALSE
;

: WRITE-TO-DELETED
    hDELETED IF SOURCE hDELETED WRITE-LINE DROP THEN
;

: CRON-DELETE-PREFIX
    TASK-FOUND?
    IF
        WRITE-TO-DELETED
        IS-END-TASK?
        IF
            FALSE TO TASK-FOUND?
        THEN
    ELSE
        IS-BEG-TASK?
        IF
            WRITE-TO-DELETED
            IS-END-TASK? 0=
            IF TRUE TO TASK-FOUND? THEN
        ELSE
            COPY-LINE-TO-NEW-FILE
        THEN
    THEN
    1 WORD DROP
;

: LOG-DEL ( # -- ) 10006 ?LOG-ERROR ;

: DELETE-CRON-NODE    0 CUR-NODE CRON-NAME @ 1+ C! ;

: CRON-DELETE
    S" Delete task: " CUR-NODE LOG-NODE
    CUR-NODE CRON-FILENAME @ COUNT MAKE-BAK ?DUP
        IF LOG-DEL EXIT THEN
    CUR-NODE CRON-FILENAME @ COUNT W/O CREATE-FILE ?DUP
        IF LOG-DEL DROP EXIT THEN
        TO CRON-DEL-NEW-FILE
    DELETED-FILENAME ['] OPEN/CREATE CATCH
    \ DELETED-FILENAME W/O OPEN-FILE
    ?DUP
        IF LOG-DEL DROP 0 THEN TO hDELETED
    hDELETED IF hDELETED >EOF THEN
    FALSE TO TASK-FOUND?
    ['] CRON-DELETE-PREFIX TO <PRE>
    CUR-NODE CRON-FILENAME @ COUNT MAKE-BAK-PATH ['] INCLUDED CATCH ?DUP
                    IF LOG-DEL 2DROP THEN
    ['] NOOP TO <PRE>
    CRON-DEL-NEW-FILE CLOSE-FILE DROP
    hDELETED ?DUP IF  CLOSE-FILE DROP THEN
    DELETE-CRON-NODE
;
[THEN]


: ?CRON-DELETE CRON-NEED-DELETE? IF CUR-NODE-DELETE THEN ;

USER AS-SERVICE
: AsService AS-SERVICE ON ;
    
: SET-DIR
    NNCRON-HOME-DIR vOperations @ 0= IF 2DUP ?CREATE-NNCRON-HOME-DIR-STRUCTURE THEN
    S>ZALLOC
    DUP SetCurrentDirectoryA  DROP
    FREE DROP
;

: INIT-ACTION
    RUN-FILE 0= IF SET-DIR THEN
    DECIMAL
    SP@ S0 !
    0 0 SEND-KEYS-DELAY
    0 <HINT-POS> !
    0 <HINT-SIZE> !
    -1 <HINT-FONT-COLOR> !
    -1 <HINT-COLOR> !
    
    AS-SERVICE OFF
    APP-Dir 0!
    FF-RECURSIVE? 0!
\    GetTickCount DUP 2DUP START-SEQUENCE
    GetCurrentThreadId 0 GetTickCount 0 START-SEQUENCE
    0 TO EXACT-MATCH?
\    RunAsDefaultUser @ DefaultLoadProfile @ AND NoRunAs? 0= AND
\        IF LoadProfile THEN
;

USER TEST-RULE?

: TEST-1RULE ( addr -- ? )
\    DBG( ." Rule1: " .S CR )
    CELL+
\    CSP!
    0 1 RCATCH ?DUP \ TO ERR-CODE
    IF
        DUP -2 =
        IF
         DROP -1 10005 ?LOG-ERROR
        ELSE
         DISABLE
         10004 ?LOG-ERROR \ S" Rule error # %ERR-CODE N>S%:" CUR-NODE LOG-NODE
        THEN
        FALSE
    THEN
\    ( S" RULE STACK ERROR") 10005 RES CSP?
\    CSP-DIFF IF  \ S" Stack error in task:" CUR-NODE LOG-NODE
\                 DROP DISABLE FALSE EXIT THEN
\    DBG( ." Rule2: " .S CR )
;

: suspend.flg S" disable" ;
: SUSPEND-CRON?  suspend.flg EXIST? ;
: DISABLE-CRON? SUSPEND-CRON? ;

: considerSUSPEND DUP IF SUSPEND-CRON? 0= CF-HYPER? OR AND THEN ;
: TEST-RULE ( -- ?)
    TEST-RULE? @ 0= IF TRUE EXIT THEN
    TRUE considerSUSPEND 0= IF FALSE EXIT THEN
    CUR-NODE CRON-RULE @ ?DUP
    IF
       BEGIN ?DUP WHILE
         DUP TEST-1RULE IF DROP TRUE EXIT THEN
         @
       REPEAT
       FALSE
    ELSE TRUE THEN
;

: RESET-ACTION
    CUR-NODE CRON-IS-MISSED 0!
;

\ USER hIDesk
\ REQUIRE SET-DESKTOP ~nn/lib/win/windows/desktop.f

: IC--  -1 CUR-NODE CRON-COUNTER +! ;
: IC++ CUR-NODE CRON-COUNTER 1+! ;

: RunMissed? CUR-NODE CRON-IS-MISSED @ 0<> ;
: [missed] RunMissed? IF S"  [missed]" ELSE S" " THEN ;
: (EXEC-ACTION) ( -- )
    INIT-ACTION
    LOGON-NODE
    WinNT? CF-ASLOGGED? AND CUR-NODE CRON-SU-TOKEN @ 0= AND IF EXIT THEN
    TEST-RULE 0=
    IF
        XT-IF-RULE-FALSE
        LOGOFF-NODE EXIT
    THEN
\    WinNT? IF SET-DESKTOP THEN
\    CtrlThrId @ ?DUP IF GetThreadDesktop ?DUP IF SetThreadDesktop DROP THEN THEN
\    hDesk @ ?DUP IF SetThreadDesktop DROP THEN
\    WinNT? IF DESKTOP_ALL_ACCESS STANDARD_RIGHTS_ALL OR 1 DF_ALLOWOTHERACCOUNTHOOK OpenInputDesktop
\              ?DUP IF hIDesk ! THEN
\              hIDesk @ ?DUP IF SetThreadDesktop DROP THEN
\           THEN
    CSP!
    CUR-NODE CRON-NAME @ COUNT CLASSIC? 0=
    IF \ no classic
        S" TASK%[missed]%: " CUR-NODE LOG-NODE
    THEN
    CF-ONCE? IF CUR-NODE CF-ACTIVE CLR-CRON-FLAG THEN
\    DEBUG? IF  LOG-TASK THEN
    CUR-NODE CRON-ACTION @
    IF
        WRITE-LY
        CUR-NODE CRON-ACTION @
        0 0 RCATCH ?DUP
        IF
          DUP -2 =
          IF DROP
            -1 10014 ?LOG-ERROR
          ELSE
              DISABLE
              \ S" Internal err # %ERR-CODE N>S%:" CUR-NODE LOG-NODE
              10009 ?LOG-ERROR
          THEN
        THEN
    THEN
    ?CRON-DELETE
    ( S" TASK STACK ERROR") 10010 RES CSP?
\    CSP-DIFF IF  S" Stack error in task:" CUR-NODE LOG-NODE THEN
\    WinNT? IF hIDesk @ ?DUP IF CloseDesktop DROP THEN THEN

    LOGOFF-NODE
    WRITE-ONCE
    RESET-ACTION
\    0 ExitThread
;

: (EXEC-ACTION2) ( VTASK -- )
    vt-COPY
    vTask @ TO CUR-NODE
    CF-SINGLE? CUR-NODE CRON-COUNTER @ 0<> AND 0=
    IF IC++ (EXEC-ACTION) IC-- THEN ;

: EXEC-ACTION0 TEST-RULE? OFF (EXEC-ACTION2) ;
: EXEC-ACTION  TEST-RULE? ON  (EXEC-ACTION2) ;

' EXEC-ACTION TASK: EXEC-ACTION-TASK
' EXEC-ACTION0 TASK: EXEC-ACTION-TASK-U \ unconditionally


USER-VALUE COMMAND-RESULT
USER-CREATE COMMAND-STRING 2 CELLS USER-ALLOT
USER EXEC-PATH


0 [IF]
USER-VALUE SH_EXE_INF
: FILL-FOR-SHELL-EXEC
    /SHELLEXECUTEINFO ALLOCATE THROW TO SH_EXE_INF
    SH_EXE_INF /SHELLEXECUTEINFO ERASE
    COMMAND-STRING 2@ DROP SH_EXE_INF sei_lpFile !
    APP-Dir @ SH_EXE_INF sei_lpDirectory !
    CUR-NODE CRON-si wShowWindow W@ SH_EXE_INF sei_nShow !
;
[THEN]


: (START-APP1) ( si a u wait -- ?)
    >R
    CUR-NODE CRON-SU-TOKEN @ ?DUP
    IF
\        WITH-PROFILE @
\        IF
\            R@ IF StartAppAsUserWithProfileWait ELSE
\                    StartAppAsUserWithProfile
\               THEN
\
\        ELSE
            R@ IF StartAppAsUserWait ELSE
                    AS-SERVICE @
                    IF StartAppAsUserNC ELSE StartAppAsUser THEN
               THEN
\        THEN
    ELSE
        R@ IF StartAppWait ELSE
                AS-SERVICE @
                IF StartAppNC ELSE StartApp THEN
           THEN
    THEN
    RDROP
;

: app-quote  COMMAND-STRING
    2@
    S"  " SEARCH NIP NIP IF QUOTE ELSE S" " THEN ;

: (START-APP) ( addr u wait-flag -- )
    >R
\    2DUP TYPE CR
\    2DUP ?CRON-LOG
    EVAL-SUBST
\    S" %H-STDOUT%" EVAL-SUBST MsgBox
    [ DEBUG? ] [IF] ." START-APP: " 2DUP TYPE CR [THEN]
    DUP CELL+ ALLOCATE THROW >R R@ SWAP 1+ CMOVE
    R> ASCIIZ> COMMAND-STRING 2!
\    FILL-FOR-SHELL-EXEC
    ALL>ENV
    S" Start: %COMMAND-STRING 2@%" ?CRON-LOG
    CUR-NODE CRON-APP-Flags @ APP-Flags !
    CUR-NODE CRON-si \ DUP /STARTUPINFO DUMP CR
    COMMAND-STRING 2@ \ ." Run: " 2DUP TYPE CR
    0 SetLastError DROP
    R@ (START-APP1) 0=
    IF
      GetLastError
      [ DEBUG? ] [IF] ." StartApp ERROR # " DUP . CR [THEN]
\      SH_EXE_INF R@ IF ShellStartAppWait ELSE ShellStartApp THEN
      1024 ALLOCATE THROW DUP EXEC-PATH !
      APP-Dir @ COMMAND-STRING 2@ DROP FindExecutableA DUP 32 >
      IF DROP \ Found
        CUR-NODE CRON-si
        S" %EXEC-PATH @ ASCIIZ>% %app-quote%%COMMAND-STRING 2@%%app-quote%" EVAL-SUBST
        R@ (START-APP1) IF DROP 0 THEN
      ELSE
        [ DEBUG? ] [IF] ." FindExecutable ERROR # " DUP . CR [THEN]
        DROP
        CUR-NODE CRON-si
        S" %ComSpec% /c %COMMAND-STRING 2@%" EVAL-SUBST
        R@ (START-APP1) IF DROP 0 THEN
      THEN
      EXEC-PATH @ FREE THROW
    ELSE 0 THEN TO COMMAND-RESULT
    S" Start result: %COMMAND-RESULT%" ?CRON-LOG
    COMMAND-STRING 2@ DROP FREE DROP
\    SH_EXE_INF FREE DROP
\    AS-SERVICE OFF
\    WITH-PROFILE OFF
    RDROP
 ;

: START-APP FALSE (START-APP) ;
: START-APPW TRUE (START-APP) ;
: to-eol BL SKIP 1 PARSE ;
: to-eol, to-eol [COMPILE] XSLITERAL ;
: START-APP:  to-eol, POSTPONE START-APP ; IMMEDIATE
: START-APPW: to-eol, POSTPONE START-APPW ; IMMEDIATE
: WaitFor APP-Wait ! ;
: WaitFor: NextWord 2DUP S" :" SEARCH NIP NIP
    IF SH:M>Min 60000 * ELSE S>NUM THEN
    POSTPONE LITERAL
    POSTPONE WaitFor ; IMMEDIATE

\ *********************************
\ start application with query
\ **********************************

: START-APP? ( addr u -- )
     <#
        0 HOLD
        HOLDS LT LTL @ HOLDS
        30 RES HOLDS
        0 0
     #>
     QueryStartTimeout
     MB_YESNO MB_ICONQUESTION OR
     QDefAnswer? IF MB_DEFBUTTON1 ELSE MB_DEFBUTTON2 THEN OR
     2SWAP
     TimeMessageBox
     IF IDYES =
     ELSE DROP
        QDefAnswer?
     THEN
;

: QSTART-APP ( addr u -- )
    2DUP START-APP?
    IF START-APP
    ELSE 2DROP THEN
;

: QSTART-APPW ( addr u -- )
    2DUP START-APP?
    IF START-APPW
    ELSE 2DROP THEN
;

: QSTART-APP:  to-eol, POSTPONE QSTART-APP ; IMMEDIATE
: QSTART-APPW: to-eol, POSTPONE QSTART-APPW ; IMMEDIATE

: S?
    2>R ?DUP
    IF 2R> TYPE SPACE COUNT TYPE CR
    ELSE 2R> 2DROP THEN
;
(
: VIEW-CRON-NODE \ NODE --
    TO CUR-NODE
    CUR-NODE CRON-NAME      @ S" Name:"     S?
    CUR-NODE CRON-MIN       @ S" Min:"      S?
    CUR-NODE CRON-HOUR      @ S" Hour:"     S?
    CUR-NODE CRON-DAY       @ S" Day:"      S?
    CUR-NODE CRON-WDAY      @ S" WDay:"     S?
    CUR-NODE CRON-MON       @ S" Mon:"      S?
    CUR-NODE CRON-YEAR      @ S" Year:"     S?
\    CUR-NODE CRON-COMMAND   @ S" Command:"  S?
\    CUR-NODE CRON-INTERNAL
\    CUR-NODE CRON-RULE
;

: .NODES
    CRON-LIST @ TO CUR-POS
    BEGIN CUR-POS WHILE
      CUR-POS VIEW-CRON-NODE
      CUR-POS CRON-NEXT @ TO CUR-POS
    REPEAT
;
)

: N? BL WORD SWAP 0 N-TEST 0= IF ." Not " THEN ." OK" CR ;

: ?EXEC-ACT
    CUR-NODE CRON-ACTION @ 0<>
    CF-SINGLE? IF CUR-NODE CRON-COUNTER @ 0= AND THEN
    IF CUR-NODE EXEC-ACTION-TASK START-TASK  THEN ;

: ?EXEC-ACT-LY  TEST-LY IF ?EXEC-ACT THEN ;

: CRON-TEST-NODE ( NODE -- )
    TO CUR-NODE
    0 TO LAST-THREAD
    CUR-NODE TEST-NODE
    IF ?EXEC-ACT ELSE CF-ALSO? 0= IF XT-IF-TIME-FALSE THEN THEN
;
: (CRON-TEST) 
    @ TO CUR-POS
    BEGIN CUR-POS WHILE
      CUR-POS CRON-WATCH @ 0=
      CUR-POS CRON-FLAGS @ CF-ALSO AND? OR
      IF CUR-POS CRON-TEST-NODE THEN
      CUR-POS CRON-NEXT @ TO CUR-POS
    REPEAT
;

: CRON-TEST
    CRON-LIST (CRON-TEST)
    SPEC-CRON-LIST (CRON-TEST)
    NUM-PASS 1+ TO NUM-PASS
;


: BLANK-LINE?
    >IN @ >R
    BL WORD DUP C@
    IF 1+ C@ [CHAR] # =
    ELSE DROP TRUE THEN
    R> >IN !
;

: SKIP-LINE 1 WORD DROP ;

VARIABLE NUM-TASK
: CRON-VALUE! ( char Addr --)
        SWAP WORD DUP C@
        IF DUP 1+ C@ [CHAR] * - OVER C@ 1 > OR
           IF HERE ROT ! ", 0 C,        \ "
           ELSE
             DROP 0!
           THEN
        ELSE
           DROP 0!
        THEN ;

: toEnchanced? ( -- ?)
    >IN @
    BL WORD COUNT 2DUP S" #(" COMPARE 0= >R
                       S" <%" COMPARE 0= R> OR
    SWAP >IN !
;

: NEXT-WORD? ( S" " -- ?)
    >IN @ >R
    BL WORD COUNT ICOMPARE 0= DUP
    IF
       RDROP
    ELSE
       R> >IN !
    THEN
;

\ : SET-START-TIME  CF-ATSTART CRON-FLAG1 ;
: SET-STOP-TIME   CF-ATSTOP CRON-FLAG1 ;

: ClassicTime
     S" START-TIME" NEXT-WORD? IF S" Time: ? ? ? ?" EVALUATE EXIT THEN
     S" STOP-TIME"  NEXT-WORD? IF SET-STOP-TIME EXIT THEN
\     CF-ATSTART CRON-FLAG0
     CF-ATSTOP  CRON-FLAG0
     POSTPONE M:
     POSTPONE H:
     POSTPONE D:
     POSTPONE MON:
     POSTPONE W:
     YearField @ IF POSTPONE Y: THEN

\     BL CRON-TIME CRON-MIN   CRON-VALUE!
\     BL CRON-TIME CRON-HOUR  CRON-VALUE!
\     BL CRON-TIME CRON-DAY   CRON-VALUE!
\     BL CRON-TIME CRON-MON   CRON-VALUE!
\     BL CRON-TIME CRON-WDAY  CRON-VALUE!
\     BL CRON-TIME CRON-YEAR  CRON-VALUE!
;

: AddTime ( -- )
    HERE >R
    /CRON-TIME ALLOT
    CRON-TIME R@ /CRON-TIME CMOVE
    CRON-NODE CRON-TIME-LIST @  R@ CRON-NEXT-TIME !
    R> CRON-NODE CRON-TIME-LIST !
    CRON-TIME /CRON-TIME ERASE
;
: TIME0?
    CRON-TIME CRON-MIN   @ 0=
    CRON-TIME CRON-HOUR  @ 0= AND
    CRON-TIME CRON-DAY   @ 0= AND
    CRON-TIME CRON-WDAY  @ 0= AND
    CRON-TIME CRON-MON   @ 0= AND
    YearField IF CRON-TIME CRON-YEAR  @ 0= AND THEN
;

: Time: end-def TIME0? 0= IF AddTime THEN ClassicTime ; IMMEDIATE

VARIABLE LAST-TASK

: :TASK
    end-def
    restr-on
    CRON-NODE0!
    CRON-NODE TO CUR-NODE
    CREATE
    HERE 0 , LAST-TASK !
    LATEST CRON-NODE CRON-NAME !
    [COMPILE] [ ; IMMEDIATE \ ]

VECT WATCH-CRON-NODE! ' DROP TO WATCH-CRON-NODE!

: TASK;
   end-def
   CRON-NODE CRON-ACTION @
   IF
\     ." End task: " CRON-NODE CRON-NAME @ COUNT TYPE CR
     AddTime
     CUR-TAB-FILENAME CRON-NODE CRON-FILENAME !
     HERE >R /CRON-NODE ALLOT
     R@ TO CUR-NODE
     R@ LAST-TASK @ !
     CRON-NODE R@ /CRON-NODE CMOVE
     SPEC-TASK? @ 
     IF SPEC-CRON-LIST ELSE CRON-LIST THEN 
     DUP @ R@ ROT !
     R@ CRON-NEXT !
     R@ CRON-WATCH @
     IF
        R@ WATCH-CRON-NODE!
     THEN
     R@ renewTI
     RDROP
   THEN
   0 TO CUR-NODE
;

: RUN ( task -- )
    @ CRON-ACTION @
    ?DUP IF EXECUTE THEN
;

: LAUNCH ( task -- )
    @ DUP CRON-ACTION @
    IF EXEC-ACTION-TASK START-TASK
    ELSE DROP THEN ;

: ?START-IN
    START-DIR ?DUP
    IF
      [COMPILE] LITERAL
      POSTPONE COUNT
      POSTPONE EVAL-SUBST
      POSTPONE START-IN
      0 TO START-DIR
    THEN
;
: StartIn:
    STATE @
    IF eval-string, POSTPONE START-IN
    ELSE
        GW, TO START-DIR THEN  ;  IMMEDIATE

: Title DROP APP-Title ! ;
: Title: eval-string, POSTPONE Title ; IMMEDIATE

: ?PROFILE WITH-PROFILE @ IF POSTPONE LoadProfile THEN ;
: Command:  end-def [COMPILE] Action:
    ?PROFILE
    ?START-IN [COMPILE] START-APP: ; IMMEDIATE
: QCommand:  end-def [COMPILE] Action:
    ?PROFILE
    ?START-IN [COMPILE] QSTART-APP: ; IMMEDIATE

\ : NO-OP CR ." LINE:" CURSTR @ . .S ;
: CLASSIC-TASK
    NUM-TASK 1+!
    NUM-TASK @ S>D <# #S "CLASSIC" HOLDS S" :TASK " HOLDS #> EVALUATE
    ClassicTime
    [COMPILE] Command:
    TASK;
;

VARIABLE CRONTAB-ERR
\ VARIABLE SSOURCE 0 ,

( : LOG-CRONTAB-ERROR
    CURSTR @ S>D
    <# #S S" CRONTAB ERROR # %CRONTAB-ERR @%: %CUR-TAB-FILENAME COUNT% Task %CRON-TASK-NAME% line: " HOLDS #>
    PAD PLACE PAD COUNT
    CRON-LOG
    C" CRONTAB-ERROR" FIND IF EXECUTE THEN
;
)

VECT >CLASSIC
: TAB>BL OVER + SWAP ?DO I C@ 9 = IF BL I C! THEN LOOP ;
VARIABLE SAVED>IN
: is\? ( -- ?)
    SOURCE ?DUP IF + 1- C@ [CHAR] \ = ELSE DROP FALSE THEN ;
    
\ 0 VALUE CRONTAB-ERR

: EVAL-CRONTAB-LINE { a u \ sp -- }
    a u ['] EVALUATE CATCH ?DUP
    IF
        CRONTAB-ERR !
        2DROP
        >IN @ SAVED>IN !
        ONLY FORTH
        SP@ TO sp
        end-def ['] NOOP TO <PRE>
        C" CRONTAB-ERROR" FIND IF EXECUTE THEN
        sp SP!
        CRONTAB-ERR @ 10011 ?LOG-ERROR \ LOG-CRONTAB-ERROR
        BEGIN
          SOURCE S" )#" SEARCH NIP NIP 0=
          IF REFILL 0= ELSE TRUE THEN
        UNTIL
        CRON-NODE0!
        0 TO CUR-NODE
        >CLASSIC
    THEN
;

: ENH-PRE { \ sp buf prev-save is-eot -- }
    0 TO buf
    0 TO is-eot
    CRONTAB-ERR 0!
    SOURCE TAB>BL
    is\?
    IF
       ['] <PRE> BEHAVIOR TO prev-save
       ['] NOOP TO <PRE>
       10240 ALLOCATE THROW TO buf
       SOURCE 1- buf ZPLACE
\       ." buf=" buf ASCIIZ> TYPE CR
       BEGIN
        REFILL
        IF
\          SOURCE TYPE CR
          is\? DUP
          SOURCE ROT IF 1- THEN 
          NextWord 2DUP S" )#" COMPARE 0=
          ROT ROT       S" #)" COMPARE 0= OR
          IF TRUE TO is-eot 2DROP DROP 
             FALSE
          ELSE
              buf +ZPLACE
          THEN
          0=
        ELSE TRUE THEN
       UNTIL
       prev-save TO <PRE>
    THEN

    NextWord S" /" COMPARE 0= IF SKIP-LINE EXIT THEN
\    SOURCE SSOURCE 2!
    
    buf ?DUP IF ASCIIZ> ELSE SOURCE THEN
    EVAL-CRONTAB-LINE
    is-eot CRONTAB-ERR @ 0= AND IF SOURCE EVAL-CRONTAB-LINE THEN
    SKIP-LINE
    buf ?DUP IF FREE DROP THEN
    
;

: Classic:
    toEnchanced?
    IF ['] ENH-PRE TO <PRE>
    ELSE
        BLANK-LINE? 0=
        IF
            BL SKIP
            CharAddr 4 S" SET " COMPARE 0=
            CharAddr 8 S" SYS-SET " COMPARE 0= OR
            IF
                1 PARSE EVALUATE
            ELSE
                CLASSIC-TASK
            THEN
        THEN
        SKIP-LINE
    THEN
;

: (>CLASSIC) ['] Classic: TO <PRE> ;
' (>CLASSIC) TO >CLASSIC


VECT PARSE-CONV
VECT PARSE-PERIOD
: (PARSE-INTERVAL) ( addr u xt-con xt-period -- first last period)
    TO PARSE-PERIOD
    TO PARSE-CONV
    2DUP S" /" SEARCH
    IF SKIP-CHAR PARSE-PERIOD ELSE 2DROP 1 THEN >R
    2DUP S" -" SEARCH
    IF
        SKIP-CHAR
        PARSE-CONV >R
        PARSE-CONV R>
    ELSE
        2DROP
        PARSE-CONV DUP
    THEN
    R>
;
: TO-NUMB ( a u - u1) S>US 2DROP ;

: PARSE-INTERVAL ['] SH:M>Min ['] SH:M>Min (PARSE-INTERVAL) ;
: PARSE-DATE-INTERVAL ['] SD.M.Y>Day ['] TO-NUMB (PARSE-INTERVAL) ;
: 0..24 1440 MOD ;

: INTERVAL ( first-time-in-min last-time-in-min period-in-min -- ? )
    >R
    1440 ROT - >R
    R@ + 0..24
    TimeMin@ R> + 0..24 TUCK
    < 0= SWAP R> MOD 0= AND
;

\ Sintax: INTERVAL: hh:mm-hh:mm[/hh:mm]
: INTERVAL: ( "hh:mm-hh:mm[/hh:mm]" -- )
    get-string PARSE-INTERVAL
    ROT     POSTPONE LITERAL
    SWAP    POSTPONE LITERAL
            POSTPONE LITERAL
    POSTPONE INTERVAL
; IMMEDIATE

: DATE-INTERVAL ( first last period -- ?)
    >R
    Days@ ROT 2DUP - >R
    OVER > 0= ROT ROT < 0= AND \ ." DATE interval IS " DUP . CR
    R> R>    \ ." Days: " 2DUP SWAP . . CR
    MOD 0= AND
;

: DATE-INTERVAL: ( "dd1.mm1.yyyy1-dd2.mm2.yyyy2/days" -- )
    get-string PARSE-DATE-INTERVAL
    ROT     POSTPONE LITERAL
    SWAP    POSTPONE LITERAL
            POSTPONE LITERAL
    POSTPONE DATE-INTERVAL
; IMMEDIATE


: #( [COMPILE] :TASK ; IMMEDIATE
: #) [COMPILE] TASK; ['] Classic: TO <PRE> ; IMMEDIATE
: )# [COMPILE] TASK; ['] Classic: TO <PRE> SKIP-LINE ; IMMEDIATE
: ;) [COMPILE] TASK; ; IMMEDIATE

: <% ['] NOOP TO <PRE> ; IMMEDIATE
: %> ['] Classic: TO <PRE> ; IMMEDIATE
