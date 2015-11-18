REQUIRE get-string ~nn/lib/getstr.f
REQUIRE PLACE lib/ext/string.f
REQUIRE PUSH-WINDOW ~nn/lib/win/windows/ops.f
REQUIRE SocketLine ~nn/lib/net/socketline.f
REQUIRE EVAL-SUBST ~nn/lib/subst1.f
REQUIRE [NONAME ~nn/lib/noname.f
REQUIRE toOEM ~nn/lib/convert.f

VARIABLE RemHost    HERE 1+ S" localhost" S", 0 C, RemHost !
VARIABLE RemPort    2002 RemPort !
SocketLine POINTER sl

: REST-OUT
    CRON-OUT TO H-STDOUT 
    CRON-OUT TO H-STDERR
;

: ConsoleName ( -- a u)
    S" nnCron console - [" PAD PLACE
    RemHost @ ASCIIZ> PAD +PLACE
    S" ]" PAD +PLACE
    PAD +PLACE0
    PAD COUNT
;
: CloseConsole sl Close sl SELF DELETE BYE ;

: bye CloseConsole ;

:NONAME { type -- }
    CTRL_CLOSE_EVENT type =
    IF
         BYE
    ELSE
        0
    THEN
; WNDPROC: handler_routine

: CONSOLE
    AllocConsole DROP
    CONSOLE-HANDLES
    ConsoleName DROP SetConsoleTitleA DROP
    TITLE
    1 ['] handler_routine SetConsoleCtrlHandler DROP
\    GUI-CONSOLE
;

: ActivateConsole ( -- ?) 
    ConsoleName DROP S" ConsoleWindowClass" DROP FindWindowA
    DUP IF DUP PUSH-WINDOW DROP THEN
;

VARIABLE CON-IOR

: ?CON-ERROR ( ior -- )
    ?DUP
    IF
        DUP CON-IOR !
        -1002 =
        IF
            S" Connection to '%RemHost @ ASCIIZ>%' is closed"
        ELSE
            S" Console error # %CON-IOR @%"
        THEN
        EVAL-SUBST DROP
         MB_SYSTEMMODAL
        ConsoleName DROP ROT 0 MessageBoxA DROP
        BYE
    THEN
;

: ConnectToRem
    [NONAME
        SocketLine NEW TO sl
        RemPort @ sl vPort !
        RemHost @ ASCIIZ> sl Addr!
        sl Create
        sl Connect
    NONAME] CATCH ?CON-ERROR
;

: SendToRem  
    [NONAME 
        SOURCE toANSI
        sl WriteLine 1 WORD DROP
    NONAME] CATCH ?CON-ERROR ;

VARIABLE isCMD
:NONAME DROP
    [NONAME
        BEGIN
            sl ReadLine 2DUP TYPE CR
            isCMD @ 
            IF 2DUP S" </CMD>" ICOMPARE 0=
               IF 2DROP isCMD OFF ELSE ['] EVALUATE CATCH THEN
            ELSE
               S" <CMD>" ICOMPARE 0= IF isCMD ON THEN
            THEN
        AGAIN    
    NONAME] CATCH ?CON-ERROR
; TASK: TASK-TO-READ

: MAIN-CON ( -- )
  BEGIN
    REFILL
  WHILE
    SendToRem
  REPEAT BYE
;

: MAIN-CONSOLE
    ONLY FORTH DEFINITIONS
    DECIMAL
\    ['] SendToRem TO <PRE>
    ['] NOOP TO <PRE>
    S0 @ SP! R0 @ RP!
    ActivateConsole DROP
    CONSOLE-HANDLES
    0 TASK-TO-READ START CLOSE-FILE DROP
    BEGIN
        0 TO SOURCE-ID
        [COMPILE] [
        ['] MAIN-CON CATCH
        ['] ERROR  CATCH DROP
    AGAIN
;


: Console \ hostname port ( -- )
    get-string ?DUP 
    IF S>ZALLOC RemHost !
       get-number ?DUP
       IF RemPort ! THEN
    ELSE
        SocketsStartup DROP
        256 PAD gethostname 0=
        IF PAD ASCIIZ> S>ZALLOC RemHost ! THEN
        SocketsCleanup DROP
    THEN
    ActivateConsole 0=
    IF
      [NONAME
          CONSOLE
          ConnectToRem
          MAIN-CONSOLE
      NONAME] CATCH DROP
    THEN
    BYE
;
