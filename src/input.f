\ $Id: input.f,v 1.3 2005/06/09 11:50:29 nncron38 Exp $
\ Author: Nicholas Nemtsev
\ Creation time: 2005-06-02 13:18

REQUIRE Control ~nn/lib/win/control.f
REQUIRE RichEdit ~nn/lib/win/controls/richedit.f
REQUIRE RES! ~nn/lib/res.f
REQUIRE <TIB ~nn/lib/tib.f
REQUIRE ON ~nn/lib/onoff.f
REQUIRE get-number ~nn/lib/getstr.f

CLASS: InputDialog <SUPER FrameWindow

150 VALUE width
70  VALUE height
13 CONSTANT but_h
37 CONSTANT but_w
    var vLines
    var vLen
    var vSplash
    var vTimeOut
    var vCurWin
    var vExitCode
    var vExitText
    var vTimeCount

    Edit OBJ ed_text
        :init a v 5 22 pos width 13 - 10 size 
        ;

    M: Close DUP vExitCode ! 
        DUP 0= IF ed_text GetText S>ZALLOC vExitText ! THEN
        Close ;

    Static OBJ st_text
        :init a v 5 5 pos width 13 - 15 size ;

    M: onOk 0 Close ;
    Button OBJ but_ok
        :init a v 30 40 pos but_w but_h size
            200 RES text ['] onOk OnClick !
            WS_TABSTOP BS_DEFPUSHBUTTON OR vStyle ! ;

    M: onCancel 1 Close ;
    Button OBJ but_cancel
        :init a v 80 40 pos but_w but_h size
            201 RES text ['] onCancel OnClick !
            WS_TABSTOP vStyle ! ;
            
M: but-pos
     width but_w - 2 / height but_h 2 * - 3 - but_w but_h but_ok Move
;

:NONAME { time event msg hwnd -- }
    2 hwnd HANDLE>OBJ => Close
; WNDPROC: TimeOutProc

: processKeyDown
    wparam @
    CASE
    VK_RETURN OF  
        ed_text isActive but_ok isActive OR IF 0 Close TRUE ELSE FALSE THEN 
        ENDOF
    VK_ESCAPE OF  1 Close TRUE  ENDOF
        123 hwnd @ KillTimer DROP
        FALSE SWAP
    ENDCASE
;

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
     IF  ['] TimeOutProc vTimeOut @ 1000 * 123 handle @ SetTimer DROP THEN

\     0 1 EM_AUTOURLDETECT ed_text handle @ SendMessageA DROP
\     ENM_LINK 0 EM_SETEVENTMASK ed_text handle @ SendMessageA DROP

     width height Center
     S" nnCron" SetText
     ed_text SetFocus
    ['] processKeyDown onKeyDown !     
;
M: Text ( a u a u a u -- )
    ed_text SetText 0 -1 ed_text SetSel
    st_text SetText
    SetText
;

VM: OnExit 
    \ 1 Close 
    1 vExitCode !
    vExitText 0!
;
;CLASS


WITH InputDialog
: (InputText) { caption u1 text u2 default u3 timeout \ inp-msg -- a u 0/1/2 }
    InputDialog NEW TO inp-msg
    timeout inp-msg => vTimeOut !
    inp-msg => Create
    caption u1 text u2 default u3 inp-msg => Text
    inp-msg => Show
    inp-msg => Run
    inp-msg => vExitText @ ?DUP IF ASCIIZ> THEN
    inp-msg => vExitCode @
    inp-msg => Delete
;
ENDWITH

: WIN-INPUT-TEXT (InputText) ;

: WIN-INPUT-TEXT: eval-string, eval-string, eval-string, number, POSTPONE WIN-INPUT-TEXT ; IMMEDIATE
\ : TimeMessage get-number BL SKIP 1 PARSE (TimeMessage) BYE ;


