REQUIRE <TIB ~nn/lib/tib.f
\ ~nn/LIB/WINCON.F
\ WIN32.F

 0 [IF]
WINAPI: GetDesktopWindow USER32.DLL
WINAPI: GetProcessWindowStation USER32.DLL
WINAPI: SetProcessWindowStation USER32.DLL
WINAPI: CloseWindowStation USER32.DLL
WINAPI: OpenWindowStationA USER32.DLL
WINAPI: OpenDesktopA USER32.DLL
WINAPI: CloseDesktop USER32.DLL
WINAPI: GetThreadDesktop USER32.DLL
WINAPI: SetThreadDesktop USER32.DLL
WINAPI: RpcImpersonateClient RPCRT4.DLL
WINAPI: RpcRevertToSelf RPCRT4.DLL

USER-VALUE HWINSTA-SAVE
USER-VALUE HDESK-SAVE
USER-VALUE HWINSTA
USER-VALUE HDESK

: (SET-WINSTA) ( -- ?)
    0 TO HWINSTA
    0 TO HDESK
    0 TO HWINSTA-SAVE
    0 TO HDESK-SAVE
    GetDesktopWindow DROP
    GetProcessWindowStation TO HWINSTA-SAVE
    GetCurrentThreadId GetThreadDesktop TO HDESK-SAVE
    0 RpcImpersonateClient DROP
    MAXIMUM_ALLOWED TRUE  S" WinSta0" DROP OpenWindowStationA TO HWINSTA
    HWINSTA 0=
        IF RpcRevertToSelf DROP FALSE EXIT THEN
    HWINSTA SetProcessWindowStation DROP
    MAXIMUM_ALLOWED TRUE 0 S" Default" DROP OpenDesktopA TO HDESK
    RpcRevertToSelf DROP
    HDESK 0=
        IF HWINSTA-SAVE SetProcessWindowStation DROP
           HWINSTA CloseWindowStation DROP
           0 TO HWINSTA
           FALSE EXIT THEN
    HDESK SetThreadDesktop DROP
    TRUE
;
: SET-WINSTA ( -- ?)
    (SET-WINSTA)
;

: RESTORE-WINSTA ( --)
    HDESK-SAVE ?DUP IF SetThreadDesktop DROP THEN
    HWINSTA-SAVE ?DUP IF SetProcessWindowStation DROP THEN
    HDESK ?DUP IF CloseDesktop DROP THEN
    HWINSTA ?DUP IF CloseWindowStation DROP THEN
;

: OPEN-WINSTA ( -- handle)
    MAXIMUM_ALLOWED
    TRUE
    S" WinSta0\Default" DROP OpenWindowStationA
    [ DEBUG? ] [IF]  DUP ." OPEN-WINDOW-STATION " .
                     GetLastError . CR
               [THEN]
;

 [THEN]

: \2CRLF ( a u -- a1 u1 )
    2DUP <TIB
    DUP 128 + ALLOCATE IF TIB> EXIT THEN >R
    R@ 0!
    0
    BEGIN 
        DUP 80 <
        IF
          [CHAR] \ PARSE ?DUP 
        ELSE 
          0 FALSE
        THEN
    WHILE
        R@ +ZPLACE
        LT LTL @ R@ +ZPLACE
        1+
    REPEAT
    2DROP 2DROP
    R> ASCIIZ> 
    TIB>
;

: MessageBox ( flags S" Message" -- result)
    DROP ( DUP >R) SWAP 
\    WinVista? IF MB_DEFAULT_DESKTOP_ONLY OR THEN
    MB_SYSTEMMODAL OR SWAP ServiceName DROP SWAP 0 MessageBoxA 
    ( R> FREE DROP)
;

0 [IF]
0 \ typedef struct { 
1 CELLS -- mb.cbSize      \  UINT      cbSize; 
1 CELLS -- mb.hwndOwner   \  HWND      hwndOwner; 
1 CELLS -- mb.hInstance   \  HINSTANCE hInstance; 
1 CELLS -- mb.lpszText    \  LPCTSTR   lpszText; 
1 CELLS -- mb.lpszCaption \  LPCTSTR   lpszCaption; 
1 CELLS -- mb.dwStyle     \  DWORD     dwStyle; 
1 CELLS -- mb.lpszIcon    \  LPCTSTR   lpszIcon; 
1 CELLS -- mb.dwContextHelpId  \  DWORD_PTR dwContextHelpId; 
1 CELLS -- mb.lpfnMsgBoxCallback \  MSGBOXCALLBACK lpfnMsgBoxCallback; 
1 CELLS -- mb.dwLanguageId \  DWORD     dwLanguageId; 
CONSTANT /MSGBOXPARAMS \ } MSGBOXPARAMS, *PMSGBOXPARAMS; 

: MessageBox { flags a u \ mb -- result }
    /MSGBOXPARAMS ALLOCATE THROW TO mb
    mb /MSGBOXPARAMS ERASE
    /MSGBOXPARAMS mb !
    IMAGE-BASE mb mb.hInstance !
    a mb mb.lpszText !
    flags MB_USERICON OR mb mb.dwStyle !
    0 32 32 IMAGE_ICON 1 IMAGE-BASE LoadImageA mb mb.lpszIcon !
    ServiceName DROP mb mb.lpszCaption !
    mb MessageBoxIndirectA
;

[THEN]

: MsgBox ( addr u --)  MB_OK MB_ICONINFORMATION OR ROT ROT MessageBox DROP ;
: ErrMsgBox ( a u -- )
    MB_OK MB_ICONSTOP ( MB_ICONEXCLAMATION) OR ROT ROT MessageBox DROP ;


USER-CREATE MSG-RESULT 4 CELLS USER-ALLOT
\ 1 cell  - (in) flags / (out) result           0 +
\ 2 cells - (in) addres of string and count     1 CELLS +
\ 1 cell  - (out) thread id                     3 CELLS +


:NONAME  { buf -- }
     GetCurrentThreadId buf 3 CELLS + !
     buf @ ( flags )
     buf CELL+ 2@ ( message )
     MessageBox \ ." TimeMSG: " DUP . CR
     buf !
     buf 3 CELLS + 0!
; 
TASK: TIME-MESSAGE-BOX-TASK

:NONAME ( par hwnd -- ?)
    NIP 0 0 ROT WM_CLOSE SWAP SendMessageA DROP
    TRUE
;
WNDPROC: CLOSE-WINDOW-PROC

: CLOSE-WINDOW-AND-STOP ( thread-id tread-handle -- )
    SWAP ?DUP
    IF
       0 ['] CLOSE-WINDOW-PROC ROT EnumThreadWindows DROP
    THEN
    TRUE 10 0 
    DO 100 PAUSE MSG-RESULT 3 CELLS + @ 0= 
       IF DROP FALSE LEAVE THEN LOOP
    IF STOP ELSE DROP THEN
;


: TimeMessageBox ( time-out flags addr u -- result ?)
\ result - результат, возвращенный MessageBox'ом
\ ?      - true - если была нажата кнопка, false - если был таймаут
    MSG-RESULT CELL+ 2!
    MSG-RESULT !  \ flags
    0 MSG-RESULT 3 CELLS + !  \ thread id
    MSG-RESULT TIME-MESSAGE-BOX-TASK START ?DUP
    IF >R
       1000 * R@ WAIT THROW 0=
       IF ( TimeOut ) 
            MSG-RESULT 3 CELLS + @ R@ CLOSE-WINDOW-AND-STOP
            0 FALSE
       ELSE
            MSG-RESULT @ TRUE
       THEN
       R> CLOSE-FILE DROP
    ELSE
       DROP 0 FALSE
    THEN
;

: TimeMsgBox ( addr u time-in-sec --)
        MB_OK MB_ICONINFORMATION OR 2SWAP TimeMessageBox 2DROP ;

: TimeErrMsgBox  MB_OK MB_ICONSTOP OR 2SWAP TimeMessageBox 2DROP ;

: TQUERY { a u timeout default -- ? }
   timeout MB_YESNO MB_ICONQUESTION OR a u TimeMessageBox 
   IF IDYES = ELSE DROP default THEN 
;

: QUERY ( a u -- ?) MB_YESNO MB_ICONQUESTION OR  ROT ROT MessageBox IDYES = ;
