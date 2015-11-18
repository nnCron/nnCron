\ * OLD
\ * OLD
\ * OLD
\ * OLD
\ * OLD
\ * OLD
\ * OLD
\ * OLD
\ * OLD
\ * OLD
\ * OLD
\ * OLD
\ * OLD
\ * OLD
\ * OLD
\ * OLD
\ * OLD
\ * OLD
\ * OLD
\ * OLD
\ * OLD
\ * OLD
\ * OLD
\ * OLD
\ * OLD
\ * OLD
\ * OLD
\ * OLD

REQUIRE  TrayIcon ~nn/lib/win/trayicon.f
REQUIRE { ~nn/lib/locals.f  \ }
REQUIRE MessageLoop ~nn/lib/win/messageloop.f

WINAPI: CreateEventA KERNEL32.DLL
\ HANDLE CreateEvent(
\  LPSECURITY_ATTRIBUTES lpEventAttributes,
\                      // pointer to security attributes
\  BOOL bManualReset,  // flag for manual-reset event
\  BOOL bInitialState, // flag for initial state
\  LPCTSTR lpName);    // pointer to event-object name


WINAPI: SetClipboardViewer USER32.DLL
\ HWND SetClipboardViewer(HWND hWndNewViewer );
WINAPI: ChangeClipboardChain USER32.DLL
\ BOOL ChangeClipboardChain(
\  HWND hWndRemove,  // handle to window to remove
\  HWND hWndNewNext);  // handle to next window

WINAPI: GetClipboardData USER32.DLL
\ HANDLE GetClipboardData( UINT uFormat )

WINAPI: SetClipboardData USER32.DLL
\ HANDLE SetClipboardData(  UINT uFormat, HANDLE hMem);

WINAPI: OpenClipboard USER32.DLL
\ BOOL OpenClipboard(
\   HWND hWndNewOwner   // handle to window opening clipboard

WINAPI: EmptyClipboard USER32.DLL
\ BOOL EmptyClipboard(VOID)

WINAPI: CloseClipboard USER32.DLL

WINAPI: IsClipboardFormatAvailable  USER32.DLL
\ BOOL IsClipboardFormatAvailable(UINT format);

WINAPI: GlobalLock kernel32.DLL
\ LPVOID GlobalLock( HGLOBAL hMem );

WINAPI: GlobalUnlock kernel32.DLL
\ BOOL GlobalUnlock( HGLOBAL hMem );

0x21033300 CONSTANT WATCH-CB-TAG

VARIABLE CB-HTASK
VARIABLE CB-NEXT-HWND
VARIABLE CB-HWND
VARIABLE <CLIPBOARD>

: FREE-<CLIPBOARD>
    <CLIPBOARD> @ ?DUP IF GLOBAL FREE DROP LOCAL THEN
    <CLIPBOARD> OFF ;

0 VALUE CB-MUTEX

: GET-CB-MUTEX
    CB-MUTEX 0=
    IF
        GetCurrentProcessId S>D
        <# 0 HOLD #S S" CBMutex" HOLDS ServiceName HOLDS #> \ 2DUP TYPE CR
        FALSE CREATE-MUTEX THROW TO CB-MUTEX
    THEN
    INFINITE CB-MUTEX WAIT THROW DROP
;

: FREE-CB-MUTEX   CB-MUTEX ?DUP IF RELEASE-MUTEX THROW THEN ;

: CB-ERR1 S" CLIPBOARD: can't open clipboard." CUR-NODE LOG-NODE ;

: CLIPBOARD@ ( -- a u )
[ DEBUG? ] [IF] ." Open clipboard" CR [THEN]
    GET-CB-MUTEX
\ *     <CLIPBOARD> @ 0=
\ *     IF
    FREE-<CLIPBOARD>
       0 OpenClipboard
       IF
[ DEBUG? ] [IF] ." Open clipboard ok" CR [THEN]
           CF_TEXT IsClipboardFormatAvailable
           IF
[ DEBUG? ] [IF] ." CF_TEXT is in clipboard" CR [THEN]
               CF_TEXT GetClipboardData ?DUP
               IF
                  DUP GlobalLock
                  ASCIIZ> \ 2DUP DUMP CR CR
[ DEBUG? ] [IF] ." CB text is=" 2DUP TYPE CR [THEN]
                  DUP CELL+ GLOBAL ALLOCATE LOCAL THROW <CLIPBOARD> !
                  <CLIPBOARD> @ SWAP 1+ CMOVE
                  GlobalUnlock DROP
               THEN
           ELSE
\             S" CLIPBOARD: text unavailable." CUR-NODE LOG-NODE
           THEN
           CloseClipboard DROP
       ELSE
[ DEBUG? ] [IF] ." Error open clipboard=" GetLastError . CR [THEN]
         CB-ERR1
       THEN
\ *     THEN
    <CLIPBOARD> @ ?DUP IF ASCIIZ> ELSE PAD 0! PAD 0 THEN
    FREE-CB-MUTEX
;

: CLIPBOARD! ( a u -- )
    GET-CB-MUTEX
    0 OpenClipboard
    IF
        EmptyClipboard DROP
        FREE-<CLIPBOARD>
        DUP 1+ GMEM_MOVEABLE GMEM_DDESHARE OR GlobalAlloc ?DUP
        IF  DUP GlobalLock
            2SWAP ROT
            2DUP + 0 SWAP C!
            SWAP CMOVE
            DUP GlobalUnlock DROP
            CF_TEXT SetClipboardData DROP
        ELSE
          2DROP S" CLIPBOARD: not enough memory." CUR-NODE LOG-NODE
        THEN
        CloseClipboard DROP
    ELSE
        2DROP
        CB-ERR1
    THEN
    FREE-CB-MUTEX
;

: (CB@) CLIPBOARD@ RDROP ;

: CLIPBOARD (CB@) [ 0 , ] CLIPBOARD! ;

: CLIPBOARD:  eval-string, POSTPONE CLIPBOARD! ; IMMEDIATE

: RUN-CB ( -- ) 0 WATCH-CB-TAG SetWatchEvent ;

:NONAME  { lparam wparam uMsg hwnd -- }

    uMsg WM_QUERYENDSESSION = IF 0 PostQuitMessage DROP TRUE EXIT THEN

    uMsg WM_DESTROY =
    IF
        CB-NEXT-HWND @ CB-HWND @ ChangeClipboardChain DROP
        0 PostQuitMessage DROP
        0
    ELSE
    uMsg WM_CHANGECBCHAIN =
    IF
        wparam CB-NEXT-HWND @ =
        IF
            lparam CB-NEXT-HWND !
        ELSE
            CB-NEXT-HWND @
            IF lparam wparam uMsg CB-NEXT-HWND @ SendMessageA DROP THEN
        THEN
        0
    ELSE
    uMsg WM_DRAWCLIPBOARD =
    IF
        FREE-<CLIPBOARD>
        RUN-CB
        CB-NEXT-HWND @
        IF lparam wparam uMsg CB-NEXT-HWND @ SendMessageA DROP THEN
        0
    ELSE
        lparam wparam uMsg hwnd DefWindowProcA
    THEN THEN THEN
;

WNDPROC: cb-proc

: CB-STOP
    CB-HTASK @ ?DUP
    IF
        CB-NEXT-HWND @ CB-HWND @ ChangeClipboardChain DROP
        STOP
        CB-HTASK @ CLOSE-FILE DROP
    THEN
;

WinClass POINTER pcbClass

0 VALUE cbId

: cbClass ( -- id )
    cbId ?DUP IF EXIT THEN
    WinClass NEW TO pcbClass
    ['] cb-proc pcbClass lpfnWndProc !
    0 pcbClass style !
    cbClassName  DROP pcbClass lpszClassName !
    pcbClass Register TO cbId
    cbId
;

WITH TrayIcon

:NONAME  ( x -- )
  DROP
  CB-HWND 0!
  cbClass 0 0 Window CB-HWND !
  CB-HWND @ 0= IF ( S" Can't create window" MsgBox) EXIT THEN
  CB-HWND @ SetClipboardViewer CB-NEXT-HWND !
  MessageLoop
;
TASK: CB-TASK

ENDWITH


: CB-START
    CB-HTASK 0!
    0 CB-TASK START CB-HTASK ! ;

: WATCH-CB-START ( a u -- handle)
    WATCH-OBJECT-S!
    WATCH-CB-TAG CUR-WATCH WATCH-PARAMETR !
    Event \    0 0 TRUE 0 CreateEventA
;

: WATCH-CB-CONTINUE
    CUR-WATCH WATCH-HANDLE @ ?DUP IF ResetEvent DROP THEN
;

(
: WATCH-CB-STOP
    CB-LIST
    BEGIN DUP @ ?DUP WHILE
      DUP CELL+ @ CUR-WATCH WATCH-HANDLE @ =
      IF
        @ OVER !
      ELSE
        NIP
      THEN
    REPEAT
    DROP
    DEF-WATCH-STOP
;
)

: WATCH-CB-RULE ( -- ?)
    CLIPBOARD ?DUP
    IF WATCH-OBJECT@ WC-MATCH
    ELSE
        DROP FALSE
    THEN
;

: WatchClipboard: ( "pattern" -- )
    POSTPONE WATCH:
    ['] WATCH-CB-CONTINUE  WATCH-NODE WATCH-CONTINUE !
\    ['] WATCH-CB-STOP      WATCH-NODE WATCH-STOP !
    ['] WATCH-CB-RULE      WATCH-NODE WATCH-RULE !
    eval-string, POSTPONE WATCH-CB-START
    POSTPONE END-WATCH
;
