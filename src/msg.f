CLASS: TimeDialog <SUPER FrameWindow

110 VALUE width
50  VALUE height
    var vTimeOut
    var vText

    Static OBJ text
        :init a v 5 5 pos width 10 - height 40 - size ;

:NONAME { hwnd msg event time -- }
    vTimeOut @ 0=
    IF BYE
    ELSE
        vTimeOut @ S>D <# #S vText @ ASCIIZ> PLACES #>
        text SetText
    THEN
    -1 vTimeOut +!
; WNDPROC: TimeOutProc

M: Create 
     WS_EX_TOPMOST vExStyle !
     0 Create
     AutoCreate
     vTimeOut @ 
     IF ['] TimeOutProc 1000 123 handle @ SetTimer DROP THEN

     width height Center
     ProgName COUNT SetText
;

M: Text
    S>ZALLOC vText !
;

;CLASS

TimeDialog POINTER tmsg

: TimeMsg
    2DUP MsgBox
    2>R
    TimeDialog NEW TO tmsg
    tmsg vTimeOut !
    tmsg Create
    2R> tmsg Text
    tmsg Show
    tmsg Run
    tmsg Delete
;

: MAIN
10 S" hello - " TimeMsg ;

' MAIN TO <MAIN>

