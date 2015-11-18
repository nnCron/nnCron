REQUIRE  TrayIcon ~nn/lib/win/trayicon.f
REQUIRE { ~nn/lib/locals.f
REQUIRE MessageLoop ~nn/lib/win/messageloop.f

10240 VALUE MAX-CB-SIZE
: MaxClipboardSize: get-number TO MAX-CB-SIZE ;

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

0x21019600 CONSTANT WatchCBTag

VARIABLE <CLIPBOARD>

: FREE-<CLIPBOARD>
    <CLIPBOARD> @ ?DUP IF GLOBAL FREE DROP LOCAL THEN
    <CLIPBOARD> OFF ;

VARIABLE CB-MUTEX
VARIABLE CB-NEXT-HWND
VARIABLE IsCBMonitor
VARIABLE CBSeqN

: GET-CB-MUTEX CB-MUTEX GET ;

: FREE-CB-MUTEX  CB-MUTEX RELEASE ;

: CB-ERR1 S" CLIPBOARD: can't open clipboard." CUR-NODE LOG-NODE ;

: OpenClipboardWait ( cycles -- ? )
    FALSE SWAP
    0 ?DO 0 OpenClipboard IF DROP TRUE LEAVE ELSE 100 PAUSE THEN LOOP
;

: CLIPBOARD@ ( -- a u )
[ DEBUG? ] [IF] ." Open clipboard" CR [THEN]
    GET-CB-MUTEX
\ *     <CLIPBOARD> @ 0=
\ *     IF
    FREE-<CLIPBOARD>
       10 OpenClipboardWait
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
                  MAX-CB-SIZE MIN
                  DUP CELL+ GLOBAL ALLOCATE LOCAL THROW <CLIPBOARD> !
                  >R
                  <CLIPBOARD> @ R@ CMOVE
                  0 <CLIPBOARD> @ R> + C!
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
    10 OpenClipboardWait
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


: SetCBEvent ( -- ) 0 WatchCBTag SetWatchEventByTypeTag ;


: WATCH-CB-START ( a u -- handle)
\    xstr, CUR-WATCH WATCH-OBJECT !
    WATCH-OBJECT-S!
    WatchCBTag CUR-WATCH WATCH-PAR !
    Event
;

: WATCH-CB-CONTINUE
    CUR-WATCH WATCH-HANDLE @ ?DUP IF ResetEvent DROP THEN
;

: WATCH-CB-RULE ( -- ?)
    CLIPBOARD ?DUP
    IF WATCH-OBJECT@ WC|RE-COMPARE
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
    CRON-NODE CRON-FLAGS @ CF-ACTIVE AND IF IsCBMonitor ON THEN
; IMMEDIATE

