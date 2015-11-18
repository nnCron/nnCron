REQUIRE Control ~nn/lib/win/control.f
REQUIRE RES ~nn/lib/res.f
\ REQUIRE OpenDialog ~nn/lib/win/filedialogs.f
\ REQUIRE ISEARCH ~nn/lib/isearch.f

CLASS: InputDialog <SUPER FrameWindow
200 CONSTANT width
70 CONSTANT height
13 CONSTANT but_h
37 CONSTANT but_w
: but_col ( # -- col ) but_w 5 + * width 1st-col + SWAP - 5 - ;
: but_row height but_h 2* - 5 - ;
: button  WITH Control but_col but_row pos but_w but_h size tabstop ENDWITH ;

    var vResult
    var vIsPath

    Static OBJ st_text
        :init a v  0 1 10 1 ps ;
    Edit OBJ ed_text
        :init a v  1 1 17 1 ps tabstop ;

    Button OBJ but_path
        :init a 1 18 1 1 ps tabstop S" ..." text ;

    M: onOk TRUE vResult ! 0 Close ;
    Button OBJ but_ok
        :init a v 2 button 200 RES text ['] onOk OnClick ! ;
    M: onCancel FALSE vResult ! 0 Close ;
    Button OBJ but_cancel
        :init a v 1 button 201 RES text ['] onCancel OnClick ! ;

M: Create
    0 TO 1st-row 0 TO 1st-col    
    0 Create
    width height Center
    AutoCreate
\    vIsPath @ IF but_path Show THEN
    ed_text SetFocus
\    ['] SetPath but_path OnClick !
;
M: GetString  ed_text GetText ;
M: SetString  ed_text SetText ;

M: SetPrompt st_text SetText ;

;CLASS

InputDialog POINTER inpw

: (InputString) ( a1 u1 a2 u2 a3 u3 -- a4 u4 )
    InputDialog NEW TO inpw
\    inpw vIsPath !
    inpw Create

    inpw SetPrompt
    inpw SetText    
    inpw SetString

    inpw ShowModal DROP
    inpw Run
    inpw GetString PAD ZPLACE
    inpw vResult @
    inpw SELF DELETE
    IF PAD ASCIIZ> ELSE S" " THEN
;

: InputString ( a1 u1 a2 u2 a3 u3 -- a4 u4 )  (InputString) ;   

\ : InputPath TRUE (InputString) ;   

\ S" xxxx" S" yyyy" S" zzzz" InputPath TYPE CR BYE