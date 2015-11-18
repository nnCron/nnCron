REQUIRE XSLITERAL ~nn/lib/longstr.f
REQUIRE get-string ~nn/lib/getstr.f
REQUIRE EVAL-SUBST ~nn/lib/subst1.f
REQUIRE PICK lib/ext/core-ext.f
REQUIRE WC-COMPARE ~nn/lib/wcmatch.f
REQUIRE N>S ~nn/lib/num2s.f
REQUIRE WC|RE-COMPARE ~nn/lib/wcre.f

: s,  ( a u -- a1 ) HERE >R DUP C, HERE SWAP DUP ALLOT CMOVE 0 C, R> ;
: xs, ( a u -- a1 ) HERE >R DUP , HERE SWAP DUP ALLOT CMOVE 0 C, R> ;
: string, get-string [COMPILE] XSLITERAL ;
: eval-string, string, POSTPONE EVAL-SUBST ;

0 [IF] -- This is old piece. See ~nn/lib/win/windows/ops.f
0 
1 CELLS -- EW.GetText
1 CELLS -- EW.hwnd
1 CELLS -- EW.result
1 CELLS -- EW.exact-match
1       -- EW.text

USER-VALUE WIN-HWND
USER-VALUE WIN-CHILD-HWND

C" GetWindowTextA" FIND NIP 0= [IF] WINAPI: GetWindowTextA USER32.DLL [THEN]
C" GetClassNameA" FIND NIP 0= [IF] WINAPI: GetClassNameA USER32.DLL [THEN]
C" EXACT-MATCH?" FIND NIP 0= [IF] USER-VALUE EXACT-MATCH? [THEN]

: WIN-TEXT ( hwnd -- a u )
    DUP GetWindowTextLengthA ?DUP
    IF   ['] GetWindowTextA SWAP 1+ 
    ELSE ['] GetClassNameA 128 THEN
    DUP ALLOCATE THROW >R
    R@ 2SWAP EXECUTE
    R> SWAP ;

USER <FOUND-WINDOW>
: FOUND-WINDOW
    <FOUND-WINDOW> @ ?DUP IF FREE DROP THEN
    WIN-HWND ?DUP
    IF WIN-TEXT OVER <FOUND-WINDOW> !
    ELSE S" " THEN
;

:NONAME  ( param hwnd -- ?)
    >R
    256 PAD1 R@ 3 PICK EW.GetText @ EXECUTE ?DUP
    IF
\      [ DEBUG? ] [IF] ." WND@TEXT: " PAD1 OVER TYPE ." <" CR [THEN]
      PAD1 SWAP 2 PICK EW.text COUNT
      4 PICK EW.exact-match @ IF WC-COMPARE ELSE WC-MATCH THEN
      DUP 2 PICK EW.result !
      IF
        R@ OVER EW.hwnd !
        FALSE
      ELSE
        TRUE
      THEN
    ELSE
      TRUE
    THEN
    RDROP
    NIP
;

WNDPROC: WIN-COMPARE

: WIN-INIT-ENUM ( addr u CFA --)
          PAD EW.GetText !
          PAD EW.text PLACE
    FALSE PAD EW.result !
    0     PAD EW.hwnd !
    EXACT-MATCH? PAD EW.exact-match !
;
    
: WIN-EXIST? ( S" win-name-substring" -- ?)
\    [ DEBUG? ] [IF] ." WND@EnumWindows" CR [THEN]
    ['] GetWindowTextA WIN-INIT-ENUM
    PAD ['] WIN-COMPARE EnumWindows DROP
    PAD EW.result @ 0=
    IF  \ Try find as class name
\        [ DEBUG? ] [IF] ." WND@EnumWindows-CLASS" CR [THEN]
        ['] GetClassNameA PAD EW.GetText !
        PAD ['] WIN-COMPARE EnumWindows DROP
        PAD EW.result @
    ELSE
        TRUE
    THEN
    PAD EW.hwnd @ TO WIN-HWND
    FALSE TO EXACT-MATCH?
\    [ DEBUG? ] [IF] DUP IF ." WND@EXIST: " ELSE ." WND@NOT EXIST: " THEN
\                    PAD EW.text COUNT TYPE CR [THEN]
;

: WIN-CHILD-EXIST? ( S" substring" hwnd -- ?)
\    [ DEBUG? ] [IF] ." WND@EnumChildWindows" CR [THEN]
    >R
    ['] GetWindowTextA WIN-INIT-ENUM
    PAD ['] WIN-COMPARE R@ EnumChildWindows DROP
    PAD EW.result @ 0=
    IF  \ Try find as class name
\        [ DEBUG? ] [IF] ." WND@EnumChildWindows-CLASS" CR [THEN]
        ['] GetClassNameA PAD EW.GetText !
        PAD ['] WIN-COMPARE R@ EnumChildWindows DROP
        PAD EW.result @
    ELSE
        TRUE
    THEN
    DUP IF PAD EW.hwnd @ TO WIN-CHILD-HWND THEN
    RDROP
\    [ DEBUG? ] [IF] DUP IF ." WND-CHILD@EXIST: "
\                                    ELSE ." WND-CHILD@NOT EXIST: " THEN
\                    PAD EW.text COUNT TYPE CR [THEN]
;

: SET-ACTIVE-WINDOW ( hwnd -- prev_hwnd )
    >R
    0 SP@  R@ GetWindowThreadProcessId NIP 
    TRUE SWAP GetCurrentThreadId 2DUP <>
    IF DROP TRUE
    ELSE
        SWAP AttachThreadInput
\        DUP 0= IF GetLastError ." SETWINDOW ERROR " . CR THEN
    THEN
    R> SWAP IF SetActiveWindow THEN
;

: PUSH-WINDOW ( hwnd -- prev-hwnd)
    DUP SetActiveWindow >R
    DUP SetFocus DROP
    DUP SetForegroundWindow DROP
        BringWindowToTop DROP
    R>
;

: POP-WINDOW ( hwnd -- ) SetForegroundWindow DROP ;

: WIN-CLICK ( S" win-pattern" S" button-pattern" --)
    2SWAP WIN-EXIST?
    IF
        WIN-HWND WIN-CHILD-EXIST?
        IF
            0 0 0 0 SP@ WIN-CHILD-HWND GetWindowRect DROP \ GetWindowRect(hw,&rect);
            0 0 SP@ GetCursorPos DROP 2>R      \ GetCursorPos(&pnt);
            WIN-HWND PUSH-WINDOW >R
            ( bottom right top left --)
            \ ROT + 2/ >R + 2/ R> SetCursorPos DROP
            2SWAP 2DROP 2 + SWAP 2 + SWAP SetCursorPos DROP
            0 0 BM_CLICK WIN-CHILD-HWND PostMessageA DROP
            R> POP-WINDOW
            2R> SetCursorPos DROP   \ SetCursorPos(pnt.x,pnt.y);
        THEN
    ELSE 2DROP THEN
;

: WIN-MSG ( lpar wpar msgid S" win-pattern" --)
    WIN-EXIST?
    IF
         WIN-HWND SendMessageA DROP
    ELSE 2DROP DROP
    THEN
;

: WIN-CHILD-MSG ( lpar wpar msgid S" win-pattern" S" button-pattern" --)
    2SWAP WIN-EXIST?
    IF   [ DEBUG? ] [IF] ." Ok. Window exist = " WIN-HWND . CR [THEN]
        WIN-HWND WIN-CHILD-EXIST?
        IF
            [ DEBUG? ] [IF]  ." Ok. Button exist = " WIN-CHILD-HWND . CR [THEN]
            WIN-CHILD-HWND SendMessageA 
            [ DEBUG? ] [IF]  DUP . CR [THEN]
            DROP
        ELSE
          2DROP DROP
        THEN
    ELSE 2DROP 2DROP DROP
    THEN
;

: SHOW-WIN ( S" win-pattern" SW_ -- )
    >R WIN-EXIST?
    IF R@ WIN-HWND ShowWindow DROP THEN RDROP ;

: WIN-MINIMIZE SW_MINIMIZE SHOW-WIN ;
: WIN-MAXIMIZE SW_MAXIMIZE SHOW-WIN ;
: WIN-RESTORE SW_RESTORE SHOW-WIN ;
: WIN-HIDE  SW_HIDE SHOW-WIN ;
: WIN-SHOW  WIN-RESTORE ;


: WIN-CLOSE ( S" win-pattern" )
    WIN-EXIST?
    IF  0 0 WM_CLOSE WIN-HWND  PostMessageA DROP  THEN ;

: WIN-TERMINATE ( S" win-pattern" -- )
    WIN-EXIST?
    IF
         0 SP@ WIN-HWND GetWindowThreadProcessId DROP ( threadID)
         ?DUP
         IF ( pid)
            FALSE PROCESS_ALL_ACCESS OpenProcess ( hProc) 
            ?DUP
            IF DUP 0 TerminateProcess DROP
               CloseHandle DROP
            THEN
         THEN
    THEN
;
: WIN-DESTROY ( S" winname" --)
    WIN-EXIST? IF WIN-HWND DestroyWindow DROP THEN
;
: WIN-ACTIVATE ( S" winname" --)
    WIN-EXIST? IF  WIN-HWND PUSH-WINDOW DROP  THEN ;

[THEN]

: ThreadId ( -- addr u) GetCurrentThreadId  0x7FFFFFFF AND S>D <# #S #> ;


: ACTIVE-WINDOW ( -- a u)
    GetForegroundWindow 
    ?DUP IF 256 PAD ROT GetWindowTextA PAD SWAP ELSE PAD 0 THEN
;

: ACTIVE-WINDOW-CLASS ( -- a u)
    GetForegroundWindow 
    ?DUP IF 256 PAD ROT GetClassNameA PAD SWAP ELSE PAD 0 THEN
;

: WIN-ACTIVE? { a u -- ? }
    ACTIVE-WINDOW a u WC|RE-COMPARE ?DUP 0=
    IF ACTIVE-WINDOW-CLASS a u WC|RE-COMPARE THEN ;

: EXACT TRUE TO EXACT-MATCH? ;


WINAPI: PlaySound winmm.dll
\ BOOL PlaySound(LPCSTR pszSound, HMODULE hmod, DWORD fdwSound);

: PLAY-SOUND ( flags a u -- )
    DROP
    SWAP SND_FILENAME OR SND_NODEFAULT OR SWAP
    0 SWAP
    PlaySound 
\    [ DEBUG? ] [IF] DUP 0= IF ." Sound error" THEN [THEN] 
    DROP
;

