
' CRON-LOG TO CON-LOG

VARIABLE RemConsolePort 2002 RemConsolePort !
VARIABLE RemConsole

: RemAllowed:    get-string S>ZALLOC RemAllowed AppendNode ;
: RemDisallowed: get-string S>ZALLOC RemDisallowed AppendNode ;
: RemConsolePort: get-number RemConsolePort ! ;

: REST-OUT
    CRON-OUT TO H-STDOUT 
    CRON-OUT TO H-STDERR
;

: CloseConsole
    REST-OUT
    FreeConsole DROP
;

: bye
    [ ALSO sVOC ]
    sIO @
    IF 
      BYE 
    ELSE 
      CloseConsole
      0 ExitThread DROP
    THEN
    [ PREVIOUS ]
;
WARNING @ WARNING OFF
: BeforeStop
    s2CON @ 
    IF
        ." <CMD>" CR
        ." BYE" CR
        ." </CMD>" CR
    THEN
    BeforeStop
;
WARNING !

: ConsoleName
    ServiceName PAD ZPLACE
    S"  console"  PAD +ZPLACE
    PAD ASCIIZ> ;

0 VALUE hQUIT

:NONAME { type -- }
    CTRL_CLOSE_EVENT type =
    IF
        hQUIT STOP
        hQUIT CLOSE-FILE DROP
        REST-OUT
        1
\        S" xxxxx" MsgBox
    ELSE
        0
    THEN
; WNDPROC: handler_routine

\ HEADER handler_routine
\ HEX 0C7 C, 0C0 C, 01 C, 0 C, 0 C, 0 C, 0C3 C, DECIMAL

: CONSOLE
    AllocConsole DROP
    CONSOLE-HANDLES
    ConsoleName DROP SetConsoleTitleA DROP
    TITLE
    CR ." Type 'bye<ENTER>' to close console" CR
    1 ['] handler_routine SetConsoleCtrlHandler DROP
\    GUI-CONSOLE
;

: ActivateConsole ( -- ?) 
    ConsoleName DROP S" ConsoleWindowClass" DROP FindWindowA
    DUP IF DUP PUSH-WINDOW DROP THEN
;

:NONAME
    DROP
    ONLY FORTH DEFINITIONS
    DECIMAL
\    S" WORDS" SFIND IF ." FOUND!" . CR ELSE 2DROP ." NOT FOUND!" CR THEN
    ['] NOOP TO <PRE>
    S0 @ SP! R0 @ RP!
    ActivateConsole DROP
    QUIT
; TASK: QUIT-TASK

: START-QUIT
    0 QUIT-TASK START TO hQUIT \ CLOSE-FILE DROP
;

: START-CONSOLE1
    ActivateConsole 0=
    IF
      CONSOLE
      START-QUIT
    THEN
;

USER <RemoteHostIP>
: isLocalHost? [ ALSO sVOC ] 
     <RemoteHostIP> @ DUP 
     IF ASCIIZ> S" 127.0.0.1" COMPARE 0= THEN [ PREVIOUS ] ;

:NONAME { \ a u -- ? }
    [ ALSO sVOC ]
    sIO @
    IF 
       sIOPeerIP S>ZALLOC <RemoteHostIP> !
       isLocalHost? IF Set2CON THEN
    THEN
    [ PREVIOUS ]
; TO CON-ON-CONNECT

:NONAME { \ a u -- ? }
    [ ALSO sVOC ]
    sIO @
    IF 
       isLocalHost? IF s2CON 0! THEN
    THEN
    [ PREVIOUS ]
; TO CON-ON-DISCONNECT
