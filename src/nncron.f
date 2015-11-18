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
: -ns TRUE TO NOT-SERVICE? ;

\ VARIABLE cronIsRan  \ mutex
VARIABLE I'mService
VARIABLE MainIsRun
VARIABLE CtrlWnd
VARIABLE menuObj

VARIABLE AppForAllUsers
VARIABLE AppForCurUser

2001 CONSTANT MY_EXIT
2002 CONSTANT TAB_RELOAD
2003 CONSTANT RUN_TASK
2004 CONSTANT NN_HIDE_ICON
2005 CONSTANT NN_SHOW_ICON
2006 CONSTANT NN_UNREG_HOT_KEY
2007 CONSTANT NN_REG_HOT_KEY
2008 CONSTANT NN_CB_START
2009 CONSTANT NN_CB_STOP
2010 CONSTANT NN_TEST_LOGON
2011 CONSTANT NN_IS_LOGON
2012 CONSTANT NN_UNREG_HOT_KEY1
2013 CONSTANT NN_REG_HOT_KEY1

2100 CONSTANT HOOK_BEG

USER <SP-TEST>
: SP-TEST ( a u -- )
    <SP-TEST> @ 0=
    IF
        2DROP    
        SP@ <SP-TEST> !
    ELSE
        SP@ 2 CELLS + <SP-TEST> @ <>
        IF 
            ." Stack error: " TYPE SPACE DEPTH . CR
        ELSE
            2DROP
        THEN
    THEN
;


REQUIRE LH-INCLUDED ~nn/lib/lh.f

\ S" LIB/ext/tools.f" INCLUDED
S" LIB/EXT/CORE-EXT.F" INCLUDED
S" ~nn/lib/JMP.F" INCLUDED
\ S" ~nn/lib/EOF.F" INCLUDED
S" LIB/EXT/CASE.F" INCLUDED

REQUIRE { ~nn/lib/locals.f  \ }

\ S" locals.f" INCLUDED

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

REQUIRE OFF ~nn/lib/onoff.f
REQUIRE ON ~nn/lib/onoff.f
REQUIRE EVAL-SUBST ~nn/lib/subst1.f

DEBUG?
[IF]
\    REQUIRE .RSTACK-TRACE ~nn/lib/memory/allocate.f
    : .S CR ." Depth is " DEPTH . CR .S ;
    : ServiceName S" nnCronD" ;
    : CtrlClassNameX S" NNCronCtrlClassD-%NNCRON-HOME-DIR-AS-NAME%" EVAL-SUBST ;
    : CtrlClassNameSvcX S" NNCronCtrlClassSvcD-%NNCRON-HOME-DIR-AS-NAME%" EVAL-SUBST ;
    : cbClassName S" NNCronCBClassD" ;
    : SerializeName S" NNCronSerialize-%NNCRON-HOME-DIR-AS-NAME%" EVAL-SUBST ;
[ELSE]
    : ServiceName S" nnCron" ;
    : CtrlClassNameX S" NNCronCtrlClass-%NNCRON-HOME-DIR-AS-NAME%" EVAL-SUBST ;
    : CtrlClassNameSvcX S" NNCronCtrlClassSvc-%NNCRON-HOME-DIR-AS-NAME%" EVAL-SUBST ;
    : cbClassName S" NNCronCBClass" ;
    : SerializeName S" NNCronSerialize-%NNCRON-HOME-DIR-AS-NAME%" EVAL-SUBST ;
[THEN]

: CtrlClassName 
\    AppForCurUser @ 0<> AppForAllUsers @ 0<> OR
    NOT-SERVICE?
    IF CtrlClassNameX ELSE CtrlClassNameSvcX THEN
;

: "CLASSIC" S" CLASSIC-TASK-#-" ;
: CLASSIC? "CLASSIC" NIP MIN "CLASSIC" COMPARE 0= ;
\ : ServiceName SVC-NAME COUNT ;
: ProgramName S" nnCron" ;

ServiceName TYPE CR

C" UseDLL" FIND NIP 0=
[IF] S" ~nn\lib\usedll.f" LH-INCLUDED [THEN]
 UseDLL USER32.DLL
 UseDLL KERNEL32.DLL
 UseDLL GDI32.DLL
 UseDLL ADVAPI32.DLL


: TMName S" %ModuleDirName%tm.exe" EVAL-SUBST ;


: BeforeCrontabLoading ;
: BeforeStop ;
: AfterCrontabLoading ;
: AfterWatchStart ;
: AfterControlWindowCreating ;
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

0 VALUE <cron.log>  HERE C" log\nncron.log" ", 0 C, 1+ TO <cron.log>
0 VALUE CRONLOG-TIME-FORMAT HERE C" %WW% %DD%-%MM%-%YYYY% %hh%:%mm% %ThreadId%" ", 0 C, \ "
            TO CRONLOG-TIME-FORMAT
: cron.log <cron.log> ASCIIZ> ;

VARIABLE SysTrayIcon
VARIABLE IconForAdminsOnly

VECT EXIT-CRON  ' BYE TO EXIT-CRON

CREATE MODIF-TIME 2 CELLS ALLOT

0 VALUE CRONTAB-FILE

0
1 CELLS -- TAB-FILENAME
2 CELLS -- TAB-LAST-TIME
1 CELLS -- TAB-FLAG
CONSTANT /TAB
0 VALUE CUR-TAB
VARIABLE TAB-LIST
0 VALUE NEED-LOAD?
VARIABLE LOADED-LIST

VARIABLE runfile-time

0x00200000 CONSTANT MB_SERVICE_NOTIFICATION

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
S" ~nn/lib/wcmatch.f" INCLUDED
S" ~nn/lib/lisp.f" INCLUDED
S" ~nn/lib/winver.f" INCLUDED
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
: ?-svc I'mService @ IF S" -svc" ELSE S" " THEN ;
: tm.exe S" %TMName% -ini %QUOTE%%CronINI%%QUOTE% -dir %QUOTE%%NNCRON-HOME-DIR%%QUOTE% %?-svc% " EVAL-SUBST 
\ : tm.exe S" %TMName% -ini %QUOTE%%CronINI%%QUOTE% -dir %QUOTE%%NNCRON-HOME-DIR%%QUOTE% " EVAL-SUBST 
\    2DUP TYPE CR
;
\ -svc %I'mService @% 
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
S" vars.f" INCLUDED
S" homedir.f" INCLUDED


S" error.f" INCLUDED
S" shutdown.f" INCLUDED

S" ~nn/lib/net/console.f" INCLUDED
S" ~nn/lib/net/2console.f" INCLUDED
S" console.f" INCLUDED

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
REQUIRE PROC-CPU-USAGE ~nn/lib/win/sys/ntqinfo.f
S" once.f" INCLUDED
S" crontab.f" INCLUDED
S" watch.f" INCLUDED
S" watchdir.f" INCLUDED
S" watchconn.f" INCLUDED
S" watchwin.f" INCLUDED
S" watchwts.f" INCLUDED
S" watchkey.f" INCLUDED
S" watchCD.f" INCLUDED
S" watchcpu.f" INCLUDED
S" clipboard2.f" INCLUDED
S" watchevlog.f" INCLUDED
S" ~nn/lib/nnsvc.f" INCLUDED
S" ~nn/lib/nnsvc95.f" INCLUDED
S" ~nn/lib/registry.f" INCLUDED
S" watchreg.f" INCLUDED
S" ~nn/lib/regkey.f"  INCLUDED
S" ~nn/lib/win/tray/refresh.f" INCLUDED
\ S" reg.f" INCLUDED
REQUIRE PrivOn ~nn/lib/win/sec/priv.f \ S" ~nn/lib/priv.f" INCLUDED
S" ~nn/lib/build.f" INCLUDED
VECT vCALL_DIAL
VECT vCALL_HANGUP
S" ~ac/e2/dial-sem.f" INCLUDED
REQUIRE PROC-EXIST? ~nn/lib/proc.f
S" ~nn/lib/for-proc.f" INCLUDED


S" ping/ping.f" INCLUDED
S" ~nn/lib/net/pop3chk.f" INCLUDED
REQUIRE RE-MATCH ~nn/lib/re.f

S" ~nn/lib/freespace.f" INCLUDED
S" ~nn/lib/win/sys/genv.f" INCLUDED
S" ~nn/lib/win/mm/cdaudio.f" INCLUDED
S" macros.f" INCLUDED
REQUIRE TempFile ~nn/lib/tempfile.f
S" hint.f" INCLUDED
S" watchproc2.f" INCLUDED
S" ~nn/lib/time-vars.f" INCLUDED

S" options.f" INCLUDED

REQUIRE GET-EXE-BY-EXT ~nn/lib/win/shell/shell.f
REQUIRE SEARCH-PATH ~nn/lib/file/search.f

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

S" ~nn/lib/spf3/spf_win_module.f" INCLUDED
\ REQUIRE ModuleDirInTEMP ~nn/lib/spf3/spf_win_module.f
S" ~nn/lib/forget.f" INCLUDED
S" main.f" INCLUDED
S" restr.f" INCLUDED

S" install.f" INCLUDED
S" ~nn/lib/fvar.f" INCLUDED
S" ~nn/lib/regvar.f" INCLUDED
S" task.f" INCLUDED
S" request.f" INCLUDED
S" ~nn/lib/security/md5dll.f" INCLUDED
S" input.f" INCLUDED

: -debug    TRUE TO DEBUG? ;

: -stop
    CtrlClassName
    WIN-EXIST?
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

: -wp without-plugins ON ;

: -runfile
    vOperations ON
    Logging OFF
    GetTickCount runfile-time !
    get-string s, TO RUN-FILE
    INIT-CRON
    CRON-NODE /CRON-NODE ERASE
    CRON-NODE TO CUR-NODE
    CF-LOGGING CRON-FLAG0

    INIT-ACTION
    RUN-FILE COUNT 2DUP EXIST?
    IF
        ['] INCLUDED CATCH DUP TO RUN-ERR
        IF  >IN @ TO RUN-POS
            S" ERROR # %RUN-ERR%%crlf%File: '%CURFILE @ ASCIIZ>%'%crlf%Line: %CURSTR @%%crlf%Pos: %RUN-POS%" EVAL-SUBST ErrMsgBox
        ELSE
            C" main" FIND
            IF CATCH DROP
            ELSE DROP S" 'main' not found!" ErrMsgBox THEN
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
    vInstall @ IF DoInstall THEN    \ выход (BYE) в самих DoInstall, DoRemove
    vRemove  @ IF DoRemove THEN
    MainIsRun ON
\     WinNT? 0= NOT-SERVICE? OR
\     IF
\         NOT-SERVICE? 0=
\         IF 1 GetCurrentProcessId RegisterServiceProcess DROP THEN
\         MAIN-CRON
\     ELSE
\        S" SeShutdownPrivilege" PrivOn DROP
\         I'mService ON
\         StartNNServiceTask
\         -1 PAUSE
\     THEN
    WinNT? 0= IF 1 GetCurrentProcessId RegisterServiceProcess DROP THEN
    ServiceName ['] MAIN-CRON START-SVC-OR-PROC
    EXIT-CRON
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
: Cronetab: get-string ADD-TAB64 ;
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
\     [NONAME
\     S" %ServiceName%_Is_Ran_Mutex" EVAL-SUBST DROP 0
\     AllAllowedSA CreateMutexA cronIsRan !
\     NONAME] CATCH DROP
     FREE-CRITICAL-SECTIONS
; ' SPF-INI JMP

' MAIN TO <MAIN>
TRUE TO ?GUI
0 MAINX !
\ ' BYE ' QUIT JMP

\ S" icons.f" INCLUDED

REQUIRE MT-ALLOT ~nn/lib/allot.f

CR .( End of building.) CR
DEBUG? [IF] BUILD! [ELSE] BUILD++ [THEN]
2048 1024 * TO IMAGE-SIZE
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

