REQUIRE { ~nemnick/lib/locals.f
REQUIRE Control     ~nemnick/lib/win/control.f
REQUIRE ComboBox ~nemnick/lib/win/controls/combobox.f
REQUIRE RES ~nn/lib/res.f
REQUIRE HOLDS lib\EXT\string.f 
REQUIRE <TIB ~nemnick/lib/tib.f
REQUIRE GET-CUR-TIME ~nemnick\lib\time.f 
REQUIRE CASE lib/ext/case.f
REQUIRE ADD-REMINDER reminder-add.f


CLASS: ReminderDialog <SUPER FrameWindow

200 VALUE width
100 VALUE height
13 CONSTANT but_h
37 CONSTANT but_w

    Edit OBJ ed_text
        :init a v 0 1 width col_w / 2 - 5 ps
            ES_MULTILINE ES_READONLY OR vStyle ! ;

    CheckBox OBJ cb_again
        :init a v 6 1 7 1 ps tabstop 413 RES text ;

    Edit OBJ ed_period
        :init a v 6 9 1 1 ps tabstop ;

    ComboBox OBJ cmb_period_type
        :init a v 6 11 3 10 ps tabstop ;

    0 VALUE period

    : CALC-TIME ( -- min hour day mon)
        ed_period GetText 0 0 2SWAP >NUMBER 2DROP TO period
        cmb_period_type Current
        CASE
          0 OF Min@ period + 60 /MOD ?DUP
                IF ( add-hour)
                ELSE Hour@ Day@ Mon@ THEN ENDOF
          1 OF Min@ 
               Hour@ period + 24 /MOD ?DUP
                IF 
                ELSE Day@ Mon@ THEN ENDOF
          2 OF Min@ Hour@
               Day@ period + Year@ Mon@ MonLength /MOD ?DUP
                IF
                ELSE Mon@ THEN ENDOF
          3 OF Min@ Hour@ Day@
               Mon@ period + 13 MOD ?DUP 0= IF 1 THEN ENDOF
          4 OF Min@ Hour@ Day@ Mon@ ENDOF
        ENDCASE
    ;

    M: onOk
        cb_again GetCheck
        IF
            ed_text GetText CALC-TIME ADD-REMINDER
        THEN
        BYE
    ;
    Button OBJ but_ok
        :init a v 15 col 6 row pos but_w but_h size 412 RES text
            WS_TABSTOP BS_DEFPUSHBUTTON  OR vStyle !
            ['] onOk OnClick !  ;
    

            
VM: OnPaint
;

: AddPeriods
    S" minutes" cmb_period_type Add
    S" hours" cmb_period_type Add
    S" days" cmb_period_type Add
    S" months" cmb_period_type Add
    S" year" cmb_period_type Add
    0 cmb_period_type Current!
    S" 1" ed_period SetText
;

M: onAgain
    cb_again GetCheck
    IF
        ed_period Enable
        cmb_period_type Enable
        414 RES 
    ELSE
        ed_period Disable
        cmb_period_type Disable
        415 RES 
    THEN
    but_ok SetText
;
\ W: WM_CHAR    S" Hello" ShowMessage ;

Font POINTER CurFont
M: Create
    0 Create
    width height Center
    410 RES SetText
    AutoCreate

    Font NEW TO CurFont
    S" Courier" DROP CurFont lpszFace !
    16 CurFont height !
    CurFont Create
    CurFont handle @ ed_text SetFont

    AddPeriods
    ['] onAgain cb_again OnClick ! 
    onAgain
    but_ok SetFocus
;


M: SetRemText ( a u --)
    <TIB
    10240 ALLOCATE IF DROP 2DROP EXIT THEN >R
    R@ 0!
    BEGIN [CHAR] \ PARSE ?DUP WHILE
        R@ +ZPLACE
        LT LTL @ R@ +ZPLACE
    REPEAT
    R@ ASCIIZ> ed_text SetText
    R> FREE DROP
    TIB>
;

;CLASS

ReminderDialog POINTER rm

: Reminder
    0 TO 1st-row
    0 TO 1st-col

    GET-CUR-TIME
    ReminderDialog NEW TO rm
    rm Create
    1 PARSE rm SetRemText
    rm Show
    rm Run
    rm SELF DELETE
    BYE
;

\ S" res\russian.txt" RES!
\ Reminder Hello my dear friends\I can't without you.\ \Bye.
