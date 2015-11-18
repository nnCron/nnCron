\ cron

S" ~nemnick\lib\lh.f" INCLUDED

S" LIB\EXT\CORE-EXT1.F" INCLUDED
S" LIB\EXT\JMP.F" LH-INCLUDED
S" LIB\EXT\EOF.F" LH-INCLUDED
S" LIB\ext\tools.f" INCLUDED
WARNING @ WARNING 0!
: WINAPI: >IN @ >R
    BL WORD FIND NIP 
    0= IF R> >IN ! WINAPI: 
       ELSE RDROP BL WORD DROP THEN
;
WARNING !

\ : INCLUDED 2DUP TYPE ." ..." INCLUDED ." ok" CR ;

S" ~nemnick\lib\qdebug.f" INCLUDED
DEBUG?
[IF]
    CREATE SVC-NAME C" NNTM" ", 0 C, 
[ELSE]
    CREATE SVC-NAME C" NNTM" ", 0 C, 
[THEN]

: ServiceName SVC-NAME COUNT ;

ServiceName TYPE CR

S" LIB\EXT\STRING.F" INCLUDED

0 VALUE CUR-TAB-FILENAME
0 VALUE PrevMin
0 VALUE SAVE-LATEST
0 VALUE SAVE-DP

0 VALUE CRONLOG-FILENAME  HERE C" nncron.log" ", 0 C, TO CRONLOG-FILENAME
0 VALUE CRONLOG-TIME-FORMAT HERE C" %WW% %DD%-%MM%-%YYYY% %hh%:%mm% %ThreadId%" ", 0 C,
            TO CRONLOG-TIME-FORMAT

CREATE CRONOUT-FILENAME C" nncron.out" ", 0 C,

CREATE CRONINI-FILENAME C" nncron.ini" ", 0 C, 

0x00200000 CONSTANT MB_SERVICE_NOTIFICATION

S" ~nemnick/lib/win/wfunc.f" INCLUDED
S" ~nemnick/lib/wincon.f"  LH-INCLUDED
S" ~nemnick/lib/find.f" INCLUDED
S" ~nemnick/lib/list.f" INCLUDED
S" ../winver.f" INCLUDED
S" ../win32.f" INCLUDED
S" LIB/EXT/MUTEX.F" INCLUDED
S" ~nemnick/lib/time.f" INCLUDED
S" ~nemnick/lib/getstr.f" INCLUDED 
S" ../subst.f" INCLUDED
S" ../add.f" INCLUDED
S" ~nemnick/lib/log.f" INCLUDED

: CRON-LOG  ( a u --)
    EVAL-SUBST
    CRONLOG-FILENAME COUNT EVAL-SUBST
    LOG ;

S" csp.f" INCLUDED
S" ~nemnick/lib/process.f" INCLUDED
S" ~nemnick/lib/ras.f" INCLUDED
S" tl.f" INCLUDED
S" sec.f" INCLUDED
S" crontab.f" INCLUDED
S" watch.f" INCLUDED
S" ~nemnick/lib/nnsvc.f" INCLUDED
S" ~nemnick/lib/nnsvc95.f" INCLUDED
S" ~nemnick/lib/regkey.f"  INCLUDED
S" reg.f" INCLUDED
S" ~nn/lib/win/sec/priv.f" INCLUDED
S" ~nn/lib/build.f" INCLUDED
VECT vCALL_DIAL
VECT vCALL_HANGUP
S" e2/dial-sem.txt" INCLUDED
S" proc.f" INCLUDED

S" ping/ping.f" INCLUDED
S" main.f" INCLUDED


: -install
     INIT-CRON
     WinNT?
     IF ServiceName doCreateService
     ELSE ServiceName InstallService95 0= THEN
     IF
        S" Service installed." CRON-LOG
        \ MB_OK MB_SERVICE_NOTIFICATION + ServiceName DROP 
        \ S" Service installed." DROP 0 MessageBoxA DROP
     ELSE
        S" Service installation error # %GetLastError% N>S" EVAL-SUBST
        MsgBox
     THEN
     1000 PAUSE BYE
;

: -remove
     INIT-CRON
     WinNT?
     IF ServiceName doDeleteService
     ELSE ServiceName UninstallService95 0= THEN
     IF
        S" Service uninstalled." CRON-LOG
        \ MB_OK MB_SERVICE_NOTIFICATION + ServiceName DROP
        \ S" Service uninstalled." 
        \ DROP 0 MessageBoxA DROP
     THEN
     1000 PAUSE BYE
;

: -install95 
     ServiceName InstallService95 0= 
     IF S" Service 95 installed." 2DUP CRON-LOG MsgBox THEN
     1000 PAUSE BYE
;
: -remove95
     ServiceName UninstallService95 0= 
     IF S" Service 95 uninstalled." 2DUP CRON-LOG MsgBox THEN
     1000 PAUSE BYE
;
: -debug    TRUE TO DEBUG? ;

: NNSERVICE
  DECIMAL
  ServiceName doStartService
  0= IF S" Service stopped." CRON-LOG THEN
  WinNT? IF BYE THEN
;

' NNSERVICE TASK: NNSERVICE-TASK


: StartNNServiceTask  ( 0 NNSERVICE-TASK START DROP) NNSERVICE ;

0 VALUE NOT-SERVICE?

: MAIN
    ['] THROW TO ERROR
    WinNT? 0= NOT-SERVICE? OR
    IF
        MAIN-CRON
    ELSE
\        S" SeShutdownPrivilege" PrivOn DROP
        StartNNServiceTask
        -1 PAUSE
    THEN
;

: -ns TRUE TO NOT-SERVICE? ;


: CRONLOG-TIME ( -- addr u) CRONLOG-TIME-FORMAT COUNT EVAL-SUBST ;
' CRONLOG-TIME TO LOG-TIME

: C", ( -- addr)
    get-string TUCK HERE >R R@ PLACE
    1+ ALLOT 0 C, R> ;

: -v
    #BUILD S>D
    <# 0 HOLD #S S" NNCron V 1.04 Build " HOLDS #> MsgBox BYE ;

: Crontab: get-string ADD-TAB ;
: Cronlog:  C", TO CRONLOG-FILENAME ;
: LogTimeFormat: C", TO CRONLOG-TIME-FORMAT ;

S" ~nemnick/lib/for-files3.f" INCLUDED
S" macros.f" INCLUDED
S" tray.f" INCLUDED

' MAIN-CRON TO ServiceProc

' MAIN TO <MAIN>
TRUE TO ?GUI
0 MAINX !
' BYE ' QUIT JMP

S" ico\nncron32x32.ico" R/O OPEN-FILE THROW 
DUP I32 22   ROT READ-FILE THROW DROP
DUP I32 744  ROT READ-FILE THROW DROP CLOSE-FILE DROP

S" ico\nncron16x16.ico" R/O OPEN-FILE THROW 
DUP I16 22  ROT READ-FILE THROW DROP
DUP I16 296 ROT READ-FILE THROW DROP CLOSE-FILE DROP

CR .( End of building.) CR 
DEBUG? 0= [IF] SET-BUILD [THEN]
150 1024 * TO IMAGE-SIZE 
\ HEX 4C8821 100 - 200 DUMP

\ S" lib/ext/dis486.f" INCLUDED

S" nncron.exe" SAVE
BYE

