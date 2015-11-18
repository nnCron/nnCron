REQUIRE Control ~nn/lib/win/control.f
REQUIRE RichEdit ~nn/lib/win/controls/richedit.f
REQUIRE RES! ~nn/lib/res.f
REQUIRE <TIB ~nn/lib/tib.f
REQUIRE ON ~nn/lib/onoff.f
REQUIRE get-number ~nn/lib/getstr.f

CLASS: MessageDialog <SUPER FrameWindow

110 VALUE width
50  VALUE height
13 CONSTANT but_h
37 CONSTANT but_w
    var vLines
    var vLen
    var vSplash
    var vTimeOut
    var vCurWin

    M: onURL
        lparam 5 CELLS + @ WM_LBUTTONDOWN =
        IF
            ." LB " HEX
            lparam 8 CELLS + @ .
            lparam 9 CELLS + @ .
            CR DECIMAL
\            0 Z" sladalskld" Z" sladalskld" 0 MessageBoxA DROP
        THEN
    ;
    Edit OBJ ed_text
        :init a v 5 5 pos width 10 - height 40 - size
           \ ['] onURL vOnUrl !
            ES_MULTILINE ES_READONLY OR ES_CENTER OR vStyle ! ;

    M: onOk 0 Close ;
    Button OBJ but_ok
        :init a v but_w 2 / 50 pos but_w but_h size
            200 RES text ['] onOk OnClick !
            WS_TABSTOP BS_DEFPUSHBUTTON OR vStyle ! ;

M: but-pos
     width but_w - 2 / height but_h 2 * - 3 - but_w but_h but_ok Move
;

Font POINTER CurFont

:NONAME { hwnd msg event time -- }
    BYE
; WNDPROC: TimeOutProc

M: Create
     GetForegroundWindow vCurWin !
     WS_EX_TOPMOST vExStyle !
\     vSplash @ IF WS_CAPTION -1 XOR vStyle @ AND WS_DLGFRAME OR vStyle !
\         WS_EX_TOOLWINDOW vExStyle @ OR vExStyle !
\         ES_CENTER -1 XOR ed_text vStyle @ AND ed_text vStyle !
\     THEN
     0 Create
     AutoCreate
     vTimeOut @
     IF ['] TimeOutProc vTimeOut @ 1000 * 123 handle @ SetTimer DROP THEN

\     0 1 EM_AUTOURLDETECT ed_text handle @ SendMessageA DROP
\     ENM_LINK 0 EM_SETEVENTMASK ed_text handle @ SendMessageA DROP

     width height Center
     ProgName COUNT SetText
     but_ok SetFocus
     but-pos
    Font NEW TO CurFont
    S" Courier" DROP CurFont lpszFace !
    16 CurFont height !
    CurFont Create
    CurFont handle @ ed_text SetFont
;


M: Text ( a u --)
    EVAL-SUBST
    <TIB
    10240 ALLOCATE IF DROP TIB> EXIT THEN >R
    R@ 0!

    vLines 0! vLen 0!
(
    BEGIN [CHAR] \ PARSE ?DUP WHILE
        DUP vLen @ > IF DUP vLen ! THEN
        R@ +ZPLACE
        LT LTL @ R@ +ZPLACE
        vLines 1+!
    REPEAT
)
    BEGIN 13 PARSE DUP 0<> EndOfChunk 0= OR WHILE
        DUP vLen @ > IF DUP vLen ! THEN
        2DUP TYPE CR
        R@ +ZPLACE
        LT LTL @ R@ +ZPLACE
        vLines 1+!
        10 SKIP
    REPEAT
    2DROP

    R@ ASCIIZ> ed_text SetText
    R> FREE DROP
    TIB>
    vLines @ 0= IF EXIT THEN
    vLen @ 23 > IF vLen @ 5 * 10 + TO width THEN
    vLines @ 1- 9 *  50 + TO height
    width height Center
    5 5 width 13 - height 40 -
    ed_text Move
    but-pos
;

;CLASS

MessageDialog POINTER msg
: (Message)
    2>R
    MessageDialog NEW TO msg
    msg Create
    2R> msg Text
    msg Show
    msg Run
    msg Delete
;

: (TimeMessage)
    2>R
    MessageDialog NEW TO msg
    msg vTimeOut !
    msg Create
    2R> msg Text
    msg Show
    msg Run
    msg Delete
;

: Message BL SKIP 1 PARSE (Message)  BYE ;

\ Message 123456789012345678901234567890\12345678901234567890
\ Message dkfsdhfsj

: TimeMessage get-number BL SKIP 1 PARSE (TimeMessage) BYE ;

\ TimeMessage 5 xxxxxxxxxxxxxx\xxxxxxxxxxxxxxxxxx\xxxxxxxx