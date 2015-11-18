\ Shutdown
0 VALUE DEBUG?
S" ~nemnick/lib/wincon.f" LH-INCLUDED
\ win32.f
WINAPI: ExitWindowsEx USER32.DLL

WINAPI: GlobalAlloc KERNEL32.DLL
WINAPI: GlobalFree KERNEL32.DLL
: GLOBAL-ALLOCATE ( bytes -- address ior)
    GPTR GlobalAlloc DUP 0= IF GetLastError ELSE 0 THEN ;
: GLOBAL-FREE ( address - ior) GlobalFree ;

~nn/lib/priv.f
winver.f

0 VALUE REBOOT?
0 VALUE LOGOFF?
0 VALUE FORCE?

: -r TRUE TO REBOOT? ;
: -o TRUE TO LOGOFF? ;
: -f TRUE TO FORCE? ;

: -R -r ; : /r -r ; : /R -r ;
: -O -o ; : /o -o ; : /O -o ;
: -F -f ; : /F -f ; : /f -f ;

: MY-TITLE
    ." Shutdown V 1.0 (22.Apr.2000)" CR
    ." Copyright (C) 2000 nnSoft. E-Mail:nemtsev@nncron.ru" CR
;

: -h
    MY-TITLE
    ." Usage: shutdown [-f] [-{r|o}]" CR
    ."   Switches:" CR
    ."     -f   - force shutdown" CR
    ."     -r   - reboot after shutdown" CR
    ."     -o   - logoff" CR
    BYE
;

: (SHUTDOWN) ( flags -- )
    WinNT? IF
              S" SeShutdownPrivilege" ['] PrivOn CATCH
              IF 2DROP FALSE THEN
           ELSE TRUE THEN
    IF 
        FORCE? IF EWX_FORCE + THEN 0 SWAP ExitWindowsEx DROP
    ELSE
        ." Set privelege error" CR
    THEN
;

: SHUTDOWN  EWX_SHUTDOWN (SHUTDOWN) ;
: REBOOT    EWX_REBOOT  (SHUTDOWN) ;
: LOGOFF    EWX_LOGOFF (SHUTDOWN) ;

: (MAIN)  -f  SHUTDOWN
;
: MAIN ['] (MAIN) CATCH DROP BYE ;
                  
' MAIN TO <MAIN>
0 MAINX !
' BYE ' QUIT JMP

S" offwin.exe" SAVE
BYE