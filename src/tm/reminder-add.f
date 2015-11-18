REQUIRE Control     ~nn/lib/win/control.f
REQUIRE ComboBox ~nn/lib/win/controls/combobox.f
REQUIRE DateTimePicker ~nn/lib/win/controls/DateTimePicker.f
REQUIRE RES ~nn/lib/res.f
REQUIRE HOLDS lib/EXT/string.f
REQUIRE <TIB ~nn/lib/tib.f
REQUIRE GET-CUR-TIME ~nn/lib/time.f
REQUIRE get-string ~nn/lib/getstr.f
REQUIRE STR-SUBST ~nn/lib/strsubst.f

REQUIRE >EOF ~nn/lib/eof.f

VARIABLE <RMNDR-FILENAME>
VARIABLE rmCanExit
VARIABLE missed
VARIABLE missed-time
: RMNDR-FILENAME <RMNDR-FILENAME> @ ASCIIZ> ;
: SET-CRONTAB  S>ZALLOC <RMNDR-FILENAME> ! ;
: NN BL HOLD S>D #S 2DROP ;
0 VALUE FTAB
: TABWR FTAB WRITE-FILE DROP ;
: TABCR LT LTL @ TABWR ;
: TAB"WR [CHAR] " SP@ 1 TABWR DROP ;

: WHITE-SPACE? ( c -- ?)
    DUP BL = OVER 13 = OR OVER 10 = OR SWAP 9 = OR 
;
: TO>TASKNAME ( a u )
    BEGIN
        OVER C@ WHITE-SPACE?
        OVER 0<> AND
    WHILE
        1- SWAP 1+ SWAP
    REPEAT
    16 MIN -TRAILING
    BEGIN DUP 1 > IF 2DUP + 2- W@ LT W@ = ELSE FALSE THEN
    WHILE  2-  REPEAT
    PAD PLACE
    PAD COUNT OVER + SWAP
    ?DO I C@ BL = I C@ 13 = OR I C@ 10 = OR  I C@ 9 = OR I C@ [CHAR] % = OR 
       I C@ [CHAR] " = OR
        IF [CHAR] _ I C! THEN LOOP
    S" _" PAD +PLACE
    GetTickCount S>D <# #S #> PAD +PLACE
    PAD COUNT
;

: t>num ( m h d m y -- n)
\    h*60 d*60*24 m*60*24*32 y*60*24*32*13
         [ 60 24 * 32 * 13 * ] LITERAL * ( y )
    SWAP [ 60 24 * 32 * ] LITERAL * +    ( m )
    SWAP [ 60 24 * ] LITERAL * +         ( d )
    SWAP 60  * +                         ( h )
    +
;

: TABCRLF S" %%crlf%%" TABWR ;
: ADD-REMINDER { a u once-flag min hour day mon year -- }
    u 0= IF EXIT THEN
    GET-CUR-TIME
    min hour day mon year t>num
    Min@ Hour@ Day@ Mon@ Year@ t>num > 0=
    IF
        rmCanExit OFF
        10013 ERR-MSG
        EXIT
    THEN
    RMNDR-FILENAME R/W OPEN-FILE-SHARED ?DUP
    IF TO IO-ERR DROP
       rmCanExit OFF
       338 ERR-MSG
       EXIT
    THEN TO FTAB
    FTAB >EOF
    FTAB ?FCR
    S" #( " TABWR
    a u TO>TASKNAME TABWR TABCR
    once-flag IF S" RunOnce" TABWR TABCR THEN
    <# <YearField> IF year NN THEN S" * " HOLDS mon NN day NN hour NN min NN
        S" Time: " HOLDS 0 0 #> TABWR TABCR
    missed @
    IF
        missed-time @
        IF
            S" RunMissed: "  TABWR
            missed-time @ ASCIIZ> TABWR
        ELSE
            S" RunMissed"  TABWR
        THEN
        TABCR
    THEN
    S" Action: " TABWR TABCR
    S"  REMINDER: " TABWR TAB"WR
    a u PERCENT S" %%PERCENT%%" STR-SUBST
        QUOTE S" %%QUOTE%%" STR-SUBST
        LT LTL @ S" %%crlf%%" STR-SUBST
    TABWR        
\      BEGIN 2DUP LT LTL @ SEARCH WHILE
\          OVER >R 2SWAP DROP R> OVER - \ ?DUP 0= IF DROP S" " THEN
\          TABWR
\          DUP 2 > IF  S" %%crlf%%" TABWR THEN
\          2- SWAP 2+ SWAP
\      REPEAT
    TABWR TAB"WR TABCR
    S" )#" TABWR TABCR
    FTAB CLOSE-FILE DROP
    RELOAD
;

\ REQUIRE RichEdit ~nn/lib/win/controls/richedit.f

CLASS: AddReminderDialog <SUPER FrameWindow

200 VALUE width
140 VALUE height
13 CONSTANT but_h
37 CONSTANT but_w



    Edit OBJ ed_text
        :init a v 0 1 width col_w / 2 - 5 ps
            WS_TABSTOP ES_MULTILINE OR ES_WANTRETURN OR WS_VSCROLL OR vStyle ! ;

    Static OBJ st_start_time
        :init a v 6 1 3 1 ps 421 RES text   ;
    TimePicker OBJ tm_start_time
        :init a v 6 3 3 1 ps tabstop ;

    Static OBJ st_start_date
        :init a v 6 7 3 1 ps 422 RES text   ;
    DatePicker OBJ tm_start_date
        :init a v 6 9 6 1 ps  tabstop ;

    CheckBox OBJ cb_missed
        :init a v 8 1 12 1 ps  tabstop 423 RES text ;

    Edit OBJ ed_missed
        :init a v
            \ 16 col 10 row pos 9 cols row_h size
            8 13 2 1 ps  tabstop ;

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
        144 RES text ;


\    CheckBox OBJ cb_once
\        :init a v 6 16 4 1 ps tabstop 120 RES text ;



    : PLACE-TIME
        tm_start_time Get DROP SWAP
        tm_start_date Get DROP SWAP ROT ;

    M: onOk
        rmCanExit ON
        ed_text GetText ( cb_once GetCheck)
        ?DUP
        IF
            cb_missed GetCheck missed !
            ed_missed GetText ?DUP
            IF
                S>ZALLOC missed-time !
            ELSE DROP THEN
            TRUE  PLACE-TIME ADD-REMINDER
        ELSE
          DROP
          603 ERR-MSG
          rmCanExit OFF
        THEN
        rmCanExit @ IF BYE THEN
    ;
    Button OBJ but_ok
        :init a v 11 col 10 row pos but_w but_h size 200 RES text
            tabstop
            WS_TABSTOP BS_DEFPUSHBUTTON  OR vStyle !
            ['] onOk OnClick !  ;

    Button OBJ but_cancel
        :init a v 15 col 10 row pos but_w but_h size 201 RES text
            tabstop ['] BYE OnClick !  ;

: processKeyDown
    wparam @
    CASE
    VK_F1 OF open-help TRUE ENDOF
    VK_TAB OF GetFocus ed_text handle @ =
              IF tm_start_time SetFocus TRUE ELSE FALSE THEN ENDOF
        FALSE SWAP
    ENDCASE
;

VM: OnPaint

;

Font POINTER CurFont
M: Create
    0 TO 1st-row 0 TO 1st-col
    0 Create
    width height Center
    420 RES SetText
    AutoCreate

    Font NEW TO CurFont
    S" Courier" DROP CurFont lpszFace !
    16 CurFont height !
    CurFont Create
    CurFont handle @ ed_text SetFont

    ed_text SetFocus

    S" HH':'mm" tm_start_time SetFormat
    S" d' 'MMMM' 'yyyy" tm_start_date SetFormat
    15 ed_text TabStops

    cb_missed Checked

    ['] OnCbMissed cb_missed OnClick !
    OnCbMissed

    ['] processKeyDown onKeyDown !
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

AddReminderDialog POINTER arm

: AddReminder
\    0 TO 1st-row 0 TO 1st-col
    GET-CUR-TIME
    AddReminderDialog NEW TO arm
    arm Create
    get-string SET-CRONTAB
    BL SKIP 1 PARSE arm SetRemText
    arm Show
    arm Run
    arm SELF DELETE
    BYE
;

: NewReminder AddReminder ;

\ S" res\russian.txt" RES!
\ AddReminder reminder.tab
