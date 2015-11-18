REQUIRE FrameWindow ~nn/lib/win/framewindow.f
REQUIRE Control ~nn/lib/win/control.f
REQUIRE get-string ~nn/lib/getstr.f
REQUIRE S>ZALLOC ~nn/lib/az.f
REQUIRE RichEdit ~nn/lib/win/controls/richedit.f
REQUIRE EVAL-SUBST ~nn/lib/subst1.f
REQUIRE FWTIME ~nn/lib/file.f

CLASS: ViewDialog <SUPER FrameWindow
    var vFileName
    dvar vFileTime
    var vContinuous

200 VALUE width
200 VALUE height

RichEdit OBJ ed
    :init a v 0 0 pos width height size 
        [ ES_MULTILINE ES_WANTRETURN OR WS_VSCROLL OR ( ES_READONLY OR) ] LITERAL vStyle ! ;


W: WM_SIZE { \ w h -- }
    lparam @ LOWORD TO w 
    lparam @ HIWORD TO h
    w h ed SetSizePixels
;
M: UpdateText
    S" " ed SetText
    vFileName @ ASCIIZ> 2DUP FILE ed SetText
    FWTIME vFileTime 2!
;

M: ed_length
    ed handle @ GetWindowTextLengthA    \ DUP . 
    0 0 EM_GETLINECOUNT ed SendMessage  - \ DUP .
;

W: WM_TIMER 
    vFileName @ ASCIIZ> FWTIME vFileTime 2@ DNEGATE D+ OR
    IF 
       vContinuous @ 
        UpdateText
       DUP 
       vContinuous ! 
       IF 
         ed SetFocus
         ed_length DUP EM_SETSEL ed SendMessage DROP
\         0 0 EM_SCROLLCARET ed SendMessage DROP
       THEN
    THEN
\    0 SB_LINEDOWN EM_SCROLL ed SendMessage DROP
;

Font POINTER CurFont

M: OnSelChange lparam 
    @ 3 CELLS + @ ( pos )               ."  sel=" DUP .
    ed_length < 0= vContinuous !
;

M: Create
    [ WS_THICKFRAME WS_MAXIMIZEBOX OR ] LITERAL vStyle @ OR vStyle !
    WS_EX_CLIENTEDGE  vExStyle @ OR vExStyle !
    0 Create
    AutoCreate
    width height SetSize
    Font NEW TO CurFont
    S" Courier" DROP CurFont lpszFace !
    16 CurFont height !
    CurFont Create
    CurFont handle @ ed SetFont
    0 5000 0 handle @ SetTimer DROP
    ['] OnSelChange ed vOnSelChange !
    ENM_SELCHANGE ENM_SCROLL OR 0 EM_SETEVENTMASK ed SendMessage DROP
    ed SetFocus
;

M: set_text
   2DUP SetText
   S>ZALLOC vFileName !
   UpdateText
;

;CLASS

ViewDialog POINTER view
: View
    ViewDialog NEW TO view
    view Create
    get-string view set_text
    view Show
    view Run
    view SELF DELETE
    BYE
;

View ..\nncron.out
\ View E:\opt\JRun4old\servers\fyb\zmod.xml