 S" WIN32.F" INCLUDED
 S" ~NEMNICK\LIB\WINCON.F" INCLUDED
WINAPI: OpenProcessToken ADVAPI32.DLL
WINAPI: AdjustTokenPrivileges ADVAPI32.DLL
WINAPI: LookupPrivilegeValueA ADVAPI32.DLL
WINAPI: GetCurrentProcess KERNEL32.DLL 
WINAPI: GetCurrentThread KERNEL32.DLL 
WINAPI: OpenThreadToken ADVAPI32.DLL
0
1 CELLS -- TP.Count
2 CELLS -- TP.LUid
1 CELLS -- TP.Attributes
CONSTANT /TOKEN_PRIVILEGES

USER-CREATE TokenPriv /TOKEN_PRIVILEGES USER-ALLOT
USER hToken


: PrivOn ( S" SeShutdownPrivilege" -- ?)
    [ DEBUG? ] [IF] ." PrivON: " 2DUP TYPE CR [THEN]
    DROP TokenPriv TP.LUid SWAP 0 LookupPrivilegeValueA 0=
    IF ." Privilege not exist" CR FALSE EXIT THEN
    hToken TOKEN_ALL_ACCESS GetCurrentProcess OpenProcessToken
    IF  \ hToken @ . CR
        1 TokenPriv TP.Count !
        SE_PRIVILEGE_ENABLED TokenPriv TP.Attributes !
        0 0 0 TokenPriv 0 hToken @ AdjustTokenPrivileges  DROP
        GetLastError
        DUP IF ." Can't adjust token privelege. Error # " DUP . CR THEN
        0=
        hToken @ CloseHandle DROP
    ELSE
      ." Can't open token. Error # " GetLastError . CR
      FALSE
    THEN
;

: (SHUTDOWN) ( flags -- )
    S" SeShutdownPrivilege" PrivOn
    IF
        EWX_FORCE + 0 SWAP ExitWindowsEx DROP
    ELSE
        ." Set priveleg error" 
    THEN
;

: SHUTDOWN  EWX_SHUTDOWN (SHUTDOWN) ;
SHUTDOWNP.F
P.F
