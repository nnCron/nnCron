REQUIRE { ~nn/lib/locals.f
REQUIRE Control     ~nn/lib/win/control.f
REQUIRE ComboBox ~nn/lib/win/controls/combobox.f
REQUIRE RES ~nn/lib/res.f
REQUIRE HOLDS lib/EXT/string.f
REQUIRE <TIB ~nn/lib/tib.f
REQUIRE GET-CUR-TIME ~nemnick\lib\time.f
REQUIRE CASE lib/ext/case.f
REQUIRE ADD-REMINDER reminder-add.f

37 CONSTANT REM-MAX-LEN

CLASS: ReminderDialog <SUPER FrameWindow

200 VALUE width
120 VALUE height
13 CONSTANT but_h
37 CONSTANT but_w

    Edit OBJ ed_text
        :init a v 0 1 width col_w / 2 - 5 ps
            ES_MULTILINE ES_READONLY OR WS_VSCROLL OR vStyle ! ;

    CheckBox OBJ cb_again
        :init a v 6 1 7 1 ps tabstop 413 RES text ;

    Edit OBJ ed_period
        :init a v 6 9 1 1 ps tabstop ;

    ComboBox OBJ cmb_period_type
        :init a v 6 11 3 10 ps tabstop ;

    CheckBox OBJ cb_missed
        :init a v 8 1 12 1 ps tabstop 423 RES text ;

    Edit OBJ ed_missed
        :init a v 8 13 2 1 ps  tabstop ;

M: OnCbMissed
    cb_missed GetCheck
    IF
        ed_missed Enable
    ELSE
        ed_missed Disable
    THEN
;


    Static OBJ st_missed
        :init a v
            15 col 3 + 8 row 1+ pos 3 cols 5 + row_h size
            \ 8 16 3 1 ps
        144 RES text tabstop ;

    var vPeriod
    var vMin   var vHour
    var vDay   var vMon
    var vYear  var vOnce
    : add-mon ( n --)
        vMon @ + 1- 12 /MOD vYear +! 1+ vMon ! ;
    : add-day ( n --)
        vDay @ +
        BEGIN  vYear @ vMon @ MonLength 2DUP > WHILE
           - 1 add-mon
        REPEAT
        DROP vDay ! ;
    : add-hour ( n -- )
        vHour @ + 24 /MOD SWAP vHour !
        ?DUP IF add-day THEN  ;
    : add-min ( n --)
        vMin @ +  60 /MOD SWAP vMin !
        ?DUP  IF add-hour THEN ;

    : CALC-TIME ( -- min hour day mon)
        GET-CUR-TIME
        ed_period GetText 0 0 2SWAP >NUMBER 2DROP D>S vPeriod !
        Min@ vMin !  Hour@ vHour !  Day@ vDay !  Mon@ vMon !
        Year@ vYear !
        cmb_period_type Current
        CASE
          0 OF vPeriod @ add-min  ENDOF
          1 OF vPeriod @ add-hour  ENDOF
          2 OF vPeriod @ add-day ENDOF
          3 OF vPeriod @ add-mon ENDOF
        ENDCASE
        vMin @ vHour @ vDay @ vMon @ vYear @
    ;

    M: onOk
        SP@ S0 !
        cb_again GetCheck
        IF
            cb_missed GetCheck missed !
            ed_text GetText TRUE CALC-TIME ADD-REMINDER
        THEN
        BYE
    ;
    Button OBJ but_ok
        :init a v 15 col 6 row pos but_w but_h size 412 RES text
            WS_TABSTOP BS_DEFPUSHBUTTON  OR vStyle !
            ['] onOk OnClick !  ;


: processKeyDown
    wparam @
    CASE
    VK_F1 OF open-help TRUE ENDOF
    VK_TAB OF GetFocus ed_text handle @ =
              IF 
                  cb_again vVisible C@ 0<> 
                  IF
                      cb_again SetFocus
                  ELSE
                      but_ok SetFocus
                  THEN
                  TRUE 
              ELSE FALSE THEN ENDOF
    VK_RETURN OF onOk TRUE ENDOF
        FALSE SWAP
    ENDCASE
;

VM: OnPaint
;

: AddPeriods
\ *     S" minutes" cmb_period_type Add
\ *     S" hours" cmb_period_type Add
\ *     S" days" cmb_period_type Add
\ *     S" months" cmb_period_type Add
\ *     S" year" cmb_period_type Add
    175 170 DO I RES cmb_period_type Add LOOP
    0 cmb_period_type Current!
    S" 1" ed_period SetText
;

M: onAgain
    cb_again GetCheck
    IF
        ed_period Enable
        cmb_period_type Enable
        cb_missed Enable
        OnCbMissed
        414 RES
    ELSE
        ed_period Disable
        cmb_period_type Disable
        cb_missed Disable
        ed_missed Disable
        415 RES
    THEN
    but_ok SetText
;
\ W: WM_CHAR    S" Hello" ShowMessage ;

Font POINTER CurFont
M: Create
    WS_EX_TOPMOST vExStyle !
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

    but_ok SetFocus
    cb_missed Checked
    ['] OnCbMissed cb_missed OnClick !

    OnCbMissed
    onAgain
    
    ['] processKeyDown onKeyDown !    
;


M: SetRemText ( a u --)
\      ." ***> " 2DUP TYPE CR
    EVAL-SUBST \ ed_text SetText EXIT
\      ." +++> " 2DUP TYPE CR
    <TIB
    10240 ALLOCATE IF DROP 2DROP EXIT THEN >R
    R@ 0!
    BEGIN 
        13 PARSE 
\          ." ---> " 2DUP TYPE CR
        BEGIN DUP REM-MAX-LEN > WHILE
            OVER REM-MAX-LEN R@ +ZPLACE
            REM-MAX-LEN /STRING
            LT LTL @ R@ +ZPLACE
        REPEAT
        R@ +ZPLACE
        LT LTL @ R@ +ZPLACE
\          SOURCE >IN @ /STRING ." Rest1:" TYPE CR
        10 SKIP
\          SOURCE >IN @ /STRING ." Rest2:" TYPE CR
        EndOfChunk
    UNTIL
    R@ ASCIIZ> 
\    ." ===> " 2DUP TYPE CR
    ed_text SetText
    R> FREE DROP
    TIB>
\      S" OKKKK" MsgBox
;

M: SetOnce ( ? -- )
    DUP vOnce !
    0=
    IF cb_again Hide ed_period Hide cmb_period_type Hide cb_missed Hide
       ed_missed Hide
       st_missed Hide
       width height 20 - Center
    THEN ;

;CLASS

ReminderDialog POINTER rm

: Reminder
\    TM-INI
    0 TO 1st-row
    0 TO 1st-col

    GET-CUR-TIME
    ReminderDialog NEW TO rm
    rm Create
    get-string SET-CRONTAB
    NextWord DROP C@ [CHAR] o = rm SetOnce
    BL SKIP 1 PARSE rm SetRemText
    rm Show
    rm Run
    rm SELF DELETE
    BYE
;


\ S" res\russian.txt" RES!
\ Reminder once reminder.tab Hello my dear friends\I can't without you.\ \Bye.
