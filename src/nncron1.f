\ cron

\ : z . THREAD-HEAP @ . CR ;

(
: ALLOCATE
  22 z
  CELL+ DUP . 8  23 z THREAD-HEAP @ DUP . 24 z HeapAlloc 25 z
  DUP IF R@ OVER ! CELL+ 0 ELSE -300 THEN
;
)
\ : INCLUDED ( a u ) 2DUP TYPE INCLUDED ."  ok" CR ;

HERE C" nncron.out" ", 0 C, \ "
VARIABLE CRONOUT-FILENAME CRONOUT-FILENAME !

HERE C" nncron.ini" ", 0 C,     \ "
VARIABLE CRONINI-FILENAME CRONINI-FILENAME !

: CronOUT CRONOUT-FILENAME @ COUNT ;
: CronINI CRONINI-FILENAME @ COUNT ;

: nnmail S" nemtsev@nncron.ru" ;
0 VALUE CRON-OUT

0 VALUE NOT-SERVICE?
VARIABLE cronIsRan  \ mutex
VARIABLE I'mService

REQUIRE LH-INCLUDED ~nn/lib/lh.f

S" LIB/EXT/CORE-EXT1.F" INCLUDED
S" ~nn/lib/JMP.F" INCLUDED
S" LIB/ext/tools.f" INCLUDED
S" ~nn/lib/EOF.F" INCLUDED
S" LIB/EXT/CASE.F" INCLUDED

REQUIRE { ~nn/lib/locals.f
S" locals.f" INCLUDED

REQUIRE MODULE: ~nn\lib\spf4\spf_modules.f


: WINAPI: >IN @ >R
    BL WORD FIND NIP
    0= IF R> >IN ! ['] WINAPI: CATCH
          IF SOURCE TYPE CR THEN
       ELSE RDROP BL WORD DROP THEN
;
\ : INCLUDED 2DUP TYPE ." ..." INCLUDED ." ok" CR ;

VARIABLE Console

S" ~nn/lib/qdebug.f" INCLUDED
DEBUG?
[IF]
    : .S CR ." Depth is " DEPTH . CR .S ;
    : ServiceName S" nnCronD" ;
    : CtrlClassName S" NNCronCtrlClassD" ;
    : cbClassName S" NNCronCBClassD" ;
    : SerializeName S" NNCronDSerialize" ;
[ELSE]
    : ServiceName S" nnCron" ;
    : CtrlClassName S" NNCronCtrlClass" ;
    : cbClassName S" NNCronCBClass" ;
    : SerializeName S" NNCronSerialize" ;
[THEN]
: "CLASSIC" S" CLASSIC-TASK-#-" ;
: CLASSIC? "CLASSIC" NIP MIN "CLASSIC" COMPARE 0= ;
\ : ServiceName SVC-NAME COUNT ;
: ProgramName S" nnCron" ;

ServiceName TYPE CR

: TMName S" tm.exe" ;


: BeforeCrontabLoading ;
: BeforeStop ;
: AfterCrontabLoading ;
: AfterWatchStart ;
\ S" LIB\EXT\STRING.F" INCLUDED

0 VALUE CUR-TAB-FILENAME
0 VALUE PrevMin
0 VALUE SAVE-LATEST
0 VALUE SAVE-DP
0 VALUE TAB-EVENT
0 VALUE RUN-TASK
0 VALUE RUN-FILE

VARIABLE CtrlThrId
VARIABLE MainThrId
VARIABLE hDesk

0 VALUE <cron.log>  HERE C" nncron.log" ", 0 C, 1+ TO <cron.log>
0 VALUE CRONLOG-TIME-FORMAT HERE C" %WW% %DD%-%MM%-%YYYY% %hh%:%mm% %ThreadId%" ", 0 C, \ "
            TO CRONLOG-TIME-FORMAT
: cron.log <cron.log> ASCIIZ> ;

VARIABLE SysTrayIcon
VARIABLE IconForAdminsOnly

REQUIRE OFF ~nn/lib/onoff.f
REQUIRE ON ~nn/lib/onoff.f

VECT EXIT-CRON  ' BYE TO EXIT-CRON

CREATE MODIF-TIME 2 CELLS ALLOT

0 VALUE CRONTAB-FILE

0
1 CELLS -- TAB-FILENAME
2 CELLS -- TAB-LAST-TIME
CONSTANT /TAB
0 VALUE CUR-TAB
VARIABLE TAB-LIST
0 VALUE NEED-LOAD?
VARIABLE LOADED-LIST


0x00200000 CONSTANT MB_SERVICE_NOTIFICATION

C" UseDLL" FIND NIP 0=
[IF] S" ~nn\lib\usedll.f" LH-INCLUDED [THEN]
 UseDLL USER32.DLL
 UseDLL KERNEL32.DLL
 UseDLL GDI32.DLL
 UseDLL ADVAPI32.DLL

\ S" ~nn/lib/win/wfunc.f" INCLUDED

C" WCONSTS" FIND NIP 0=
[IF] S" ~nn/lib/wincon.f"  LH-INCLUDED [THEN]

S" ~nn/lib/noname.f" INCLUDED
S" ~nn/lib/find.f" INCLUDED

WARNING @ WARNING 0!
: BYE
    CRON-OUT CLOSE-FILE DROP
    S" nodelout2" EXIST? 0=
    IF CronOUT DELETE-FILE DROP THEN
    BYE
; WARNING !

REQUIRE S>UNICODE ~nn/lib/unicode.f
\ S" ~nn/lib/qwndproc.f" INCLUDED
S" ~nn/lib/list.f" INCLUDED
S" agents/pop3rules/wcmatch.f" INCLUDED
S" ~nn/lib/lisp.f" INCLUDED
\ S" ~nn/lib/winver.f" INCLUDED
USER-VALUE EXACT-MATCH?
: WC-MATCH1 EXACT-MATCH? IF WC-COMPARE ELSE WC-MATCH THEN ;
S" win32.f" INCLUDED
S" ~nn/lib/beep.f" INCLUDED
\ S" LIB\EXT\MUTEX.F" INCLUDED
S" ~nn/lib/mutex.f" INCLUDED
S" ~nn/lib/getstr.f" INCLUDED
REQUIRE PLACE lib/ext/string.f

30 VALUE QueryStartTimeout

CREATE QueryStartAnswer 5 ALLOT S" Yes" QueryStartAnswer PLACE
: QueryStartTimeout: get-number ?DUP IF TO QueryStartTimeout THEN ;
: QueryStartAnswer: get-string 3 MIN QueryStartAnswer PLACE ;
: QDefAnswer QueryStartAnswer COUNT ;
: QDefAnswer? ( -- ?)
    QDefAnswer DROP C@ DUP [CHAR] y =  SWAP [CHAR] Y = OR ;

: FEX FIND IF EXECUTE ELSE DROP THEN ;

S" winsta.f" INCLUDED
REQUIRE GET-CUR-TIME ~nn/lib/time.f
REQUIRE EVAL-SUBST ~nn/lib/subst1.f
: tm.exe S" %TMName% -ini %CronINI% " EVAL-SUBST ;
S" ~nn/lib/win.f" INCLUDED
S" ~nn/lib/mouse.f" INCLUDED
S" ~nn/lib/process.f" INCLUDED
\ S" ~nn/lib/process2.f" INCLUDED
S" ~nn/lib/asuser/asuser.f" INCLUDED
S" ~nn/lib/win/windows/ops.f" INCLUDED
S" add.f" INCLUDED
S" ~nn/lib/folders.f" INCLUDED
S" ~nn/lib/delfolder.f" INCLUDED

S" ~nn/lib/log.f" INCLUDED

S" error.f" INCLUDED

S" ~nn/lib/net/console.f" INCLUDED
S" ~nn/lib/net/2console.f" INCLUDED
S" console.f" INCLUDED

REQUIRE USERNAME ~nn/lib/win/sec/username.f
S" ~nn/lib/set.f" INCLUDED
S" csp.f" INCLUDED
S" ~nn/lib/shellstart.f" INCLUDED
S" ~nn/lib/ras.f" INCLUDED
S" tl.f" INCLUDED
S" sec.f" INCLUDED
S" ~nn/lib/bak.f" INCLUDED
REQUIRE FOR-FILES ~nn/lib/for-files3.f
REQUIRE FMOVE ~nn/lib/file.f
S" ~nn/lib/keyemul.f" INCLUDED
REQUIRE D- lib/ext/double.f
S" once.f" INCLUDED
S" crontab.f" INCLUDED
S" watch.f" INCLUDED
S" watchdir.f" INCLUDED
S" watchconn.f" INCLUDED
S" watchwin.f" INCLUDED
S" watchkey.f" INCLUDED
S" watchCD.f" INCLUDED
S" clipboard2.f" INCLUDED
S" watchevlog.f" INCLUDED
S" ~nn/lib/nnsvc.f" INCLUDED
S" ~nn/lib/nnsvc95.f" INCLUDED
S" ~nn/lib/registry.f" INCLUDED
S" watchreg.f" INCLUDED
S" ~nn/lib/regkey.f"  INCLUDED
S" ~nn/lib/win/tray/refresh.f" INCLUDED
\ S" reg.f" INCLUDED
S" ~nn/lib/win/sec/priv.f" INCLUDED
S" ~nn/lib/build.f" INCLUDED
VECT vCALL_DIAL
VECT vCALL_HANGUP
S" e2/dial-sem.txt" INCLUDED
S" ~nn/lib/proc.f" INCLUDED
S" ~nn/lib/for-proc.f" INCLUDED

S" ping/ping.f" INCLUDED
S" ~nn/lib/net/pop3chk.f" INCLUDED
REQUIRE RE-MATCH ~nn/lib/re.f

S" ~nn/lib/freespace.f" INCLUDED
S" ~nn/lib/win/sys/genv.f" INCLUDED
S" ~nn/lib/win/mm/cdaudio.f" INCLUDED
S" macros.f" INCLUDED
S" ~nn/lib/tempfile.f" INCLUDED
S" hint.f" INCLUDED
S" watchproc2.f" INCLUDED
S" ~nn/lib/time-vars.f" INCLUDED

S" options.f" INCLUDED
S" tray.f" INCLUDED
\ S" ~nn/lib/win/tray/win2tray.f" INCLUDED
\ : WIN-TO-TRAY: eval-string, POSTPONE WIN-TO-TRAY ; IMMEDIATE

S" reminder.f" INCLUDED
S" ~nn/lib/web/server.f" INCLUDED
S" ~nn/lib/script.f" INCLUDED
' START-APPW TO StartScriptApp
S" ~nn/lib/workset.f" INCLUDED
S" ~nn/lib/win/sys/monitor.f" INCLUDED
S" ~nn/lib/win/sys/power.f" INCLUDED
S" ~nn/lib/win/mm/mixer.f" INCLUDED

REQUIRE ?FREE ~nn/lib/free.f

S" main.f" INCLUDED
S" restr.f" INCLUDED

S" install.f" INCLUDED
S" ~nn/lib/fvar.f" INCLUDED
S" ~nn/lib/regvar.f" INCLUDED
S" task.f" INCLUDED


: -debug    TRUE TO DEBUG? ;

: -stop
    CtrlClassName WIN-EXIST?
    IF
        0 0 MY_EXIT WIN-HWND SendMessageA DROP
    THEN
    BYE
;

: NNSERVICE
  DECIMAL
  ServiceName doStartService
  0= IF EXIT-CRON THEN
  WinNT? IF BYE THEN
;

' NNSERVICE TASK: NNSERVICE-TASK


: StartNNServiceTask  ( 0 NNSERVICE-TASK START DROP) NNSERVICE ;


KERN: RegisterServiceProcess
\ DWORD RegisterServiceProcess(
\  DWORD dwProcessId,
\  DWORD dwType
\ );



: -ns TRUE TO NOT-SERVICE? ;

: ?RUN-TASK { \ cpdat -- }
    RUN-TASK
    IF
        DoubleInstance?
        IF
           3 CELLS ALLOCATE THROW TO cpdat
           RUN_TASK cpdat !
           RUN-TASK COUNT cpdat CELL+ !
                          cpdat CELL+ CELL+ !
           cpdat RUN_TASK WM_COPYDATA (Send2Cron)
           0= IF RUN-TASK-ERR THEN
           BYE
        THEN
    THEN
;

: -run
    -ns
    get-string s, TO RUN-TASK
    ?RUN-TASK
;

0 VALUE RUN-ERR
0 VALUE RUN-POS

VARIABLE runfile-time
DEBUG? 
[IF]
: time-elapsed ( # -- )
    S>D
    GetTickCount runfile-time @ - S>D
    <#
       #S 2DROP
       S" : runfile time elapsed: "
       #S
    #>
;
[THEN]

: -runfile
    GetTickCount runfile-time !
    get-string s, TO RUN-FILE
    [ DEBUG? ] [IF] 1 time-elapsed [THEN]
    INIT-CRON
    [ DEBUG? ] [IF] 2 time-elapsed [THEN]    
    CRON-NODE /CRON-NODE ERASE
    CRON-NODE TO CUR-NODE
    CF-LOGGING CRON-FLAG0

    INIT-ACTION
    [ DEBUG? ] [IF] 3 time-elapsed [THEN]
    RUN-FILE COUNT 2DUP EXIST?
    IF
        ['] INCLUDED CATCH DUP TO RUN-ERR
    [ DEBUG? ] [IF] 4 time-elapsed [THEN]        
        IF  >IN @ TO RUN-POS
            S" ERROR # %RUN-ERR%%crlf%File: '%CURFILE @ ASCIIZ>%'%crlf%Line: %CURSTR @%%crlf%Pos: %RUN-POS%" EVAL-SUBST ErrMsgBox
        ELSE
            C" main" FIND
            IF CATCH DROP
            ELSE DROP S" 'main' not found!" ErrMsgBox THEN
    [ DEBUG? ] [IF] 5 time-elapsed [THEN]
        THEN
    ELSE
        2DROP
        S" File '%RUN-FILE COUNT%' not found" EVAL-SUBST ErrMsgBox
    THEN
    GetTickCount runfile-time @ - S>D 
    <# S"  ms" HOLDS #S S" , run time: " HOLDS 
        RUN-FILE COUNT HOLDS S" -runfile " HOLDS #> 
        CRON-LOG
    BYE
;

: -hi 0 0 NN_HIDE_ICON Send2Cron BYE ;
: -si 0 0 NN_SHOW_ICON Send2Cron BYE ;


: MAIN \ { \ atom -- }
\    ['] THROW TO ERROR
\    WinNT? IF SET-DESKTOP THEN
    WinNT? 0= NOT-SERVICE? OR
    IF
        NOT-SERVICE? 0=
        IF 1 GetCurrentProcessId RegisterServiceProcess DROP THEN
        MAIN-CRON
    ELSE
\        S" SeShutdownPrivilege" PrivOn DROP
        I'mService ON
        StartNNServiceTask
        -1 PAUSE
    THEN
;


: CRONLOG-TIME ( -- addr u) CRONLOG-TIME-FORMAT COUNT EVAL-SUBST ;
' CRONLOG-TIME TO LOG-TIME

: C", ( -- addr)
    get-string TUCK HERE >R R@ PLACE
    1+ ALLOT 0 C, R> ;

: -v -ns about 1000 PAUSE BYE
\    #BUILD S>D
\    <# 0 HOLD #S S" NNCron V 1.73 Build " HOLDS #> MsgBox BYE ;
;

: -ep -ns BL WORD COUNT EncP TMMessage 1000 PAUSE BYE ;
: -reload-tab
    0 0 TAB_RELOAD Send2Cron
    BYE
;
: -reload  -reload-tab ;

: Crontab: get-string ADD-TAB ;
: Cronlog:  get-string S>ZALLOC TO <cron.log> ;
: LogTimeFormat: C", TO CRONLOG-TIME-FORMAT ;

: DelNNCron S" %FOLDER-PROGRAMS%\NNCron" EVAL-SUBST DeleteFolder DROP ;

: -? -ns ( S" readme.txt" edit-file) LOAD-INI open-help 2000 PAUSE BYE ;
: /? -? ;
: /h -? ;
: /H -? ;
: /help -? ;

: az, HERE get-string S", 0 C, ;
: -ini az, CRONINI-FILENAME ! ;
: -out az, CRONOUT-FILENAME ! ;

' MY-TITLE ' TITLE JMP
' MAIN-CRON TO ServiceProc

TRUE TO SPF-INIT?
:NONAME
    [NONAME
    S" %ServiceName%_Is_Ran_Mutex" EVAL-SUBST DROP 0
    AllAllowedSA CreateMutexA cronIsRan !
    NONAME] CATCH DROP
; ' SPF-INI JMP

' MAIN TO <MAIN>
TRUE TO ?GUI
0 MAINX !
\ ' BYE ' QUIT JMP

\ S" icons.f" INCLUDED

REQUIRE MT-ALLOT ~nn/lib/allot.f

CR .( End of building.) CR
DEBUG? [IF] BUILD! [ELSE] BUILD++ [THEN]
768 1024 * TO IMAGE-SIZE
\ HEX 4C8821 100 - 200 DUMP

\ S" lib/ext/dis486.f" INCLUDED

: BYE
    [ ALSO sVOC ]
    sIO @
    IF
        BYE
    ELSE
        EXIT-CRON
    THEN
    [ PREVIOUS ]
;

REQUIRE RESOURCES: ~nn/~yz/resources.f

RESOURCES: nncron.fres

DEBUG? 0=
[IF]
\    RESOURCES: nncron.fres
    S" nncron.exe" SAVE
[ELSE]
\    RESOURCES: nncrond.fres
    S" nncrond.exe" SAVE
[THEN]

0 HALT

