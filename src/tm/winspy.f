REQUIRE Control ~nn/lib/win/control.f
REQUIRE RichEdit ~nn/lib/win/controls/richedit.f
REQUIRE HotKey ~nn/lib/win/controls/HotKey.f
REQUIRE RES! ~nn/lib/res.f
REQUIRE <TIB ~nn/lib/tib.f
REQUIRE ON ~nn/lib/onoff.f
REQUIRE get-number ~nn/lib/getstr.f
REQUIRE HOLDS lib/ext/string.f


: z0 S" " ;
CLASS: WinSpyDialog <SUPER FrameWindow

145 VALUE width
135  VALUE height
13 CONSTANT but_h
37 CONSTANT but_w

    Static OBJ st_main
        :init a v -1 0 4 1 ps S" Main window:" text ;

    Edit OBJ ed_rect
        :init a v -1 4 10 1 ps  ES_READONLY vStyle ! ;

    Static OBJ st_wtext
        :init a v 0 0 2 1 ps S" Text:" text ;
    Edit OBJ ed_wtext
        :init a v 0 2 12 1 ps  ES_READONLY vStyle ! ;

    Static OBJ st_wclass
        :init a v 1 0 2 1 ps S" Class:" text ;
    Edit OBJ ed_wclass
        :init a v 1 2 12 1 ps  ES_READONLY vStyle ! ;

    Static OBJ st_whwnd
        :init a v 2 0 2 1 ps S" Handle:" text ;
    Edit OBJ ed_whwnd
        :init a v 2 2 6 1 ps  ES_READONLY vStyle ! ;


    Static OBJ st_chaild
        :init a v 4 0 12 1 ps S" Child window:" text ;

    Edit OBJ ed_crect
        :init a v 4 4 10 1 ps  ES_READONLY vStyle ! ;

    Static OBJ st_wctext
        :init a v 5 0 2 1 ps S" Text:" text ;
    Edit OBJ ed_wctext
        :init a v 5 2 12 1 ps  ES_READONLY vStyle ! ;

    Static OBJ st_wcclass
        :init a v 6 0 2 1 ps S" Class:" text ;
    Edit OBJ ed_wcclass
        :init a v 6 2 12 1 ps  ES_READONLY vStyle ! ;

    Static OBJ st_wchwnd
        :init a v 7 0 2 1 ps S" Handle:" text ;
    Edit OBJ ed_wchwnd
        :init a v 7 2 6 1 ps  ES_READONLY vStyle ! ;

    Static OBJ st_pos
        :init a v 8 0 2 1 ps S" Pos:" text ;
    Edit OBJ ed_pos
        :init a v 8 2 12 1 ps  ES_READONLY vStyle ! ;

    Static OBJ st_hotkey
        :init a v 10 0 2 1 ps S" Hotkey:" text ;

    HotKey OBJ ht
        :init a v 10 2 6 1 ps  ;

    Static OBJ st_key
        :init a v 10 9 2 1 ps S" VK:" text ;
    Edit OBJ ed_key
        :init a v 10 10 4 1 ps  ES_READONLY vStyle ! ;
\ *     Button OBJ but_copy
\ *         :init a v 10 12 2 1 ps  S" Copy" text ;

: GET-PARENT { hwnd \ pw -- pw }
    hwnd GetParent ?DUP
    IF TO pw
        BEGIN pw GetParent ?DUP WHILE
          TO pw
        REPEAT
        pw
    ELSE 0 THEN
;

: -#S DUP >R ABS S>D #S 2DROP R> SIGN ;
: #XY ( y x -- )
    [CHAR] ) HOLD SWAP -#S
    BL HOLD [CHAR] , HOLD
    -#S [CHAR] ( HOLD ;

: #XxY ( y x --)  SWAP -#S BL HOLD [CHAR] x HOLD BL HOLD -#S ;
: RECT>S { bot rig top left -- a u }
   <#   bot top - 1+ rig left - 1+ #XxY BL HOLD BL HOLD
        bot rig #XY [CHAR] - HOLD top left #XY  0 0 #> ;

: SET-TEXT { a u ed -- }
    ed ->CLASS Edit GetText a u COMPARE
    IF a u ed ->CLASS Edit SetText THEN ;
: GET-WTEXT PAD 256 ROT WM_GETTEXT SWAP SendMessageA PAD SWAP ;
: GET-WCLASS 256 PAD ROT GetClassNameA PAD SWAP ;

: 0x0 BASE @ >R HEX S>D <# #S S" 0x" HOLDS #> R> BASE ! ;
W: WM_TIMER { \ hw hpw ax ay wx wy -- }
    0 0 SP@ GetCursorPos
    IF  TO ax TO ay
        ay ax WindowFromPoint ?DUP
        IF
            DUP TO hw TO hpw
            hw GET-PARENT ?DUP IF TO hpw THEN

            hpw GET-WTEXT ed_wtext SELF SET-TEXT
            hpw GET-WCLASS  ed_wclass SELF SET-TEXT
            0 0 0 0 SP@ hpw GetWindowRect DROP 2DUP TO wx TO wy
                RECT>S ed_rect SELF SET-TEXT
            hpw 0x0 ed_whwnd SELF SET-TEXT
            hw hpw <>
            IF
                hw GET-WTEXT   ed_wctext SELF SET-TEXT
                hw GET-WCLASS  ed_wcclass SELF SET-TEXT
                0 0 0 0 SP@ hw GetWindowRect DROP
                wx - SWAP wy - SWAP 2SWAP wx - SWAP wy - SWAP 2SWAP
                RECT>S ed_crect SELF SET-TEXT
                hw 0x0 ed_wchwnd SELF SET-TEXT
            ELSE
                z0 ed_wctext SetText
                z0 ed_wcclass SetText
                z0 ed_crect SetText
            THEN
            <# ay wy - ax wx - #XY S"   Rel: " HOLDS
               ay ax #XY S" Abs: " HOLDS 0 0 #>
            ed_pos SELF SET-TEXT
        ELSE
            <# ay ax #XY S" Abs: " HOLDS 0 0 #>  ed_pos SELF SET-TEXT
            z0 ed_wtext SetText
            z0 ed_wclass SetText
            z0 ed_wctext SetText
            z0 ed_wcclass SetText
        THEN
    ELSE 2DROP THEN
    0
;
\ * M: OnKey
\ *     ed_key isActive DUP
\ *     IF
\ *         BASE @ HEX
\ *         wparam @ 0 <# 0 HOLD #S S" 0x" HOLDS #> 1- ed_key SetText
\ *         BASE !
\ *     ELSE
\ *         S" " ed_key SetText
\ *     THEN
\ * ;

M: OnHKChange
    BASE @ HEX
    ht getVK 0
    <# 0 HOLD S" }" HOLDS #S S" {0x" HOLDS
\        ht getWin IF S" $" HOLDS THEN
        ht getShift IF S" +" HOLDS THEN
        ht getAlt IF S" @" HOLDS THEN
        ht getCtrl IF S" ^" HOLDS THEN
    #> 1- ed_key SetText
    BASE !
;

\ * M: OnCopy
\ *     handle @ OpenClipboard
\ *     IF
\ *         EmptyClipboard DROP
\ *         ed_key GetText
\ *         DUP 1+ GMEM_MOVEABLE GMEM_DDESHARE OR GlobalAlloc ?DUP
\ *         IF  DUP GlobalLock
\ *             2SWAP ROT
\ *             2DUP + 0 SWAP C!
\ *             SWAP CMOVE
\ *             DUP GlobalUnlock DROP
\ *             CF_TEXT SetClipboardData
\ *             ?DUP IF CloseHandle DROP THEN
\ *         ELSE
\ *           2DROP
\ *         THEN
\ *         CloseClipboard DROP
\ *     THEN
\ * ;

M: Create
     WS_EX_TOPMOST vExStyle !
     0 Create
     AutoCreate
     WinSpyPos XY?
     IF WinSpyPos XY@ SetPos
        width height SetSize
     ELSE width height Center THEN


     0 50 123 handle @ SetTimer DROP
     S" nnCron WinSpy" 2DUP ?BYE-IF-EXIST SetText
\ *      ['] OnKey onKeyDown !
\ *      ['] OnCopy but_copy OnClick !
     ['] OnHKChange ht OnChange !
;

;CLASS

WinSpyDialog POINTER wsp
: WinSpy
    WinSpyDialog NEW TO wsp
    wsp Create
    wsp Show
    wsp Run
    wsp GetPos WinSpyPos XY! save-tm-ini
    wsp Delete
    BYE
;


