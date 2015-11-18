REQUIRE Control     ~nn/lib/win/control.f
REQUIRE ComboBox ~nn/lib/win/controls/combobox.f
REQUIRE RES ~nn/lib/res.f
REQUIRE PLACE lib\ext\string.f
REQUIRE JMP ~nn/lib/jmp.f
REQUIRE get-string ~nn/lib/getstr.f
REQUIRE StartApp ~nn/lib/process.f
REQUIRE FOR-FILES ~nn/lib/for-files3.f
REQUIRE <EOF> ~nn/lib/eof.f
REQUIRE ICOMPARE agents/pop3rules/wcmatch.f
REQUIRE CASE lib/ext/case.f
REQUIRE AddCrontab addcrontab.f
REQUIRE MAKE-BAK ~nn/lib/bak.f
REQUIRE EVAL-SUBST ~nn/lib/subst1.f

TRUE VALUE <YearField>

: NNCronIni S" nncron.ini" ;

VARIABLE Editor
0 VALUE DEF-OPEN-MODE
0 VALUE DEF-PRIORITY
VARIABLE CRONTAB-LIST
0 VALUE LOG-FILE
0 VALUE LOG-TIME-FORMAT
0 VALUE LANGUAGE
0 VALUE UPDATE?
: UPDATE TRUE TO UPDATE? ;

CREATE exe-buf 256 ALLOT
: edit-file ( a u -- )
    Editor @ DUP IF ASCIIZ> EXIST? THEN
    IF
        Editor @ ASCIIZ> exe-buf ZPLACE TRUE
    ELSE
        exe-buf S" ." DROP S" doc\readme.txt" +ModuleDirName DROP
        FindExecutableA 32 >
    THEN
    IF  S"  " exe-buf +ZPLACE
        exe-buf +ZPLACE
        0 exe-buf ASCIIZ> StartApp DROP
    ELSE
        2DROP
        0 Z" nnCron." Z" You have not default text editor." 0
        MessageBoxA DROP
    THEN
;

CLASS: OptionsDialog <SUPER FrameWindow

150 VALUE width
200 VALUE height
13 CONSTANT but_h
37 CONSTANT but_w
: but_col ( # -- col ) but_w 5 + * width 1st-col + SWAP - 5 - ;
: but_row height but_h 2* - 5 - ;
: button  WITH Control but_col but_row pos but_w but_h size tabstop ENDWITH ;

\    Static OBJ st_crontab
\        :init a v 0 1 4 1 ps  451 RES text ;
\    Edit OBJ ed_crontab
\        :init a v 0 5 5 1 ps tabstop ;
    Static OBJ st_crontabl
        :init a v 0 1 10 1 ps  453 RES text ;
    
    ListBox OBJ lb_crontabl
        :init a v 1 1 9 4 ps  tabstop ;

    M: onEdit
        lb_crontabl Current -1 <>
        IF
            PAD lb_crontabl Current lb_crontabl Get
            AddCrontab ?DUP
            IF lb_crontabl Current DUP lb_crontabl Delete DROP
               lb_crontabl Insert
               UPDATE
            ELSE DROP THEN 
        THEN
    ;
    Button OBJ but_edit
        :init a v 11 col 1 row pos 30 10 size 461 RES text tabstop
            ['] onEdit OnClick ! ;
    M: onAdd 
        S" " AddCrontab ?DUP
        IF lb_crontabl Add UPDATE
        ELSE DROP THEN ;
    Button OBJ but_add
        :init a v 11 col 2 row pos 30 10 size 452 RES text tabstop
            ['] onAdd OnClick ! ;
    M: onDel lb_crontabl Current DUP -1 <>
        IF lb_crontabl Delete DROP UPDATE ELSE DROP THEN ;
    Button OBJ but_del
        :init a v 11 col 3 row pos 30 10 size 454 RES text tabstop
            ['] onDel OnClick !  ;
    M: upd UPDATE ;    
    Static OBJ st_log
        :init a v 5 1 4 1 ps 455 RES text ;
    Edit OBJ ed_log
        :init a v 5 5 9 1 ps tabstop ['] upd OnChange ! ;
    Static OBJ st_log_time
        :init a v 7 1 4 1 ps 456 RES text ;
    Edit OBJ ed_log_time
        :init a v 7 5 9 1 ps tabstop ['] upd OnChange ! ;

    Static OBJ st_open
        :init a v 9 1 9 1 ps 458 RES text ;
    ComboBox OBJ cmb_open
        :init a v 9 10 4 4 ps tabstop ['] upd OnSelChange ! ;

    Static OBJ st_prior
        :init a v 11 1 9 1 ps 459 RES text ;
    ComboBox OBJ cmb_prior
        :init a v 11 10 4 4 ps tabstop ['] upd OnSelChange ! ;

    Static OBJ st_lang
        :init a v 13 1 3 1 ps 460 RES text ;
    ComboBox OBJ cmb_lang
        :init a v 13 10 4 4 ps tabstop ['] upd OnSelChange ! ;

    VECT SAVE-INI
    : sav-tm-ini  GetPos OptionsPos XY! save-tm-ini ;
    M: onIni sav-tm-ini
        UPDATE? IF SAVE-INI THEN NNCronIni edit-file BYE ;
    Button OBJ but_ini
        :init a v 3 button  NNCronIni text ['] onIni OnClick ! ;
    M: onOk  sav-tm-ini
        UPDATE? IF SAVE-INI THEN BYE ;
    Button OBJ but_ok
        :init a v 2 button 200 RES text ['] onOk OnClick ! ;
    M: onCancel sav-tm-ini BYE ;
    Button OBJ but_cancel
        :init a v 1 button 201 RES text ['] onCancel OnClick ! ;

0 VALUE WID-OPT
0 VALUE BUF
0 VALUE FINI
0 VALUE CRONTAB-EXIST
0 VALUE CUR-INI-NODE

VARIABLE INI-LIST
0
1 CELLS -- ini-xt
1 CELLS -- ini-buf
CONSTANT /INI-NODE
CREATE <qt> CHAR " C, 
: qt <qt> 1 ;
: INIWR FINI WRITE-FILE DROP ;
: "INIWR" qt INIWR INIWR qt INIWR ;     \ "
: INICR LT LTL @ INIWR ;

: CR+ PAD ZPLACE LT LTL @ PAD +ZPLACE PAD ASCIIZ> ;
: BUF+ ( a u -- )
    CR+
    BUF 0= IF S>ZALLOC TO BUF EXIT THEN
    BUF ASCIIZ> NIP OVER + 1+ ALLOCATE THROW >R
    BUF ASCIIZ> R@ ZPLACE  R@ +ZPLACE
    BUF FREE DROP
    R> TO BUF ;


: INI-WR-BUF ( -- ) CUR-INI-NODE ini-buf @ ASCIIZ> INIWR ;
: BUF2LIST
    BUF ?DUP
    IF /INI-NODE ALLOCATE THROW >R
        R@ ini-buf !
        ['] INI-WR-BUF R@ ini-xt !
        R> INI-LIST AppendNode
        0 TO BUF
    THEN
;

: ADD-OPT ( xt -- )
    /INI-NODE ALLOCATE THROW >R
    R@ ini-xt !
    0 R@ ini-buf !
    R> INI-LIST AppendNode ;
: CRONTAB+ ( a u -- )  S>ZALLOC CRONTAB-LIST AppendNode ;

: OMODE-WR
    S" DefaultOpenMode: " INIWR
    cmb_open Current
    CASE
        0 OF S" ShowNormal" ENDOF
        1 OF S" ShowMaximized" ENDOF
        2 OF S" ShowMinimized" ENDOF
        3 OF S" SWHide" ENDOF
    ENDCASE
    INIWR INICR
;

: PRIOR-WR
    S" DefaultPriority: " INIWR
    cmb_prior Current
    CASE
        0 OF S" NormalPriority" ENDOF
        1 OF S" HighPriority" ENDOF
        2 OF S" RealtimePriority" ENDOF
        3 OF S" IdlePriority" ENDOF
    ENDCASE
    INIWR INICR
;
: CRONTAB-WR
    lb_crontabl Length 0
    ?DO
        S" Crontab: " INIWR
        PAD I lb_crontabl Get "INIWR" INICR
    LOOP
;

: LOG-WR S" Cronlog: " INIWR ed_log GetText "INIWR" INICR ;
: LOG-TIME-WR S" LogTimeFormat: " INIWR ed_log_time GetText "INIWR" INICR ;
: LANG-WR S" Language: " INIWR PAD cmb_lang GetCurrent INIWR INICR ;
( 
: set-lang
    S" res\" PAD PLACE
    NextWord 2DUP S>ZALLOC TO LANGUAGE
        PAD +PLACE
    S" .txt" PAD +PLACE
    PAD COUNT RES!
;
)

: INI-ERROR
    ." Task Maker: Loading ini-file error. Line # "
        CURSTR @ .  CR ;

: EXEC-NEXT 
    NextWord WID-OPT SEARCH-WORDLIST 
    IF
        BUF2LIST
        CATCH IF INI-ERROR THEN
    ELSE
        SOURCE BUF+
        1 PARSE 2DROP
    THEN
;

: SET-OMODE TO DEF-OPEN-MODE ;
: SET-PRIOR TO DEF-PRIORITY ;

VOCABULARY OPTIONS
ALSO OPTIONS DEFINITIONS
CONTEXT @ TO WID-OPT
: ShowNormal    0 SET-OMODE ;
: ShowMaximized 1 SET-OMODE ;
: ShowMinimized 2 SET-OMODE ;
: SWHide        3 SET-OMODE ;

: NormalPriority   0 SET-PRIOR ;
: HighPriority     1 SET-PRIOR ;
: RealtimePriority 2 SET-PRIOR ;
: IdlePriority     3 SET-PRIOR ;

: DefaultOpenMode: EXEC-NEXT ['] OMODE-WR ADD-OPT ;
: DefaultPriority: EXEC-NEXT ['] PRIOR-WR ADD-OPT ;
: Crontab: CRONTAB-EXIST 0=
    IF ['] CRONTAB-WR ADD-OPT TRUE TO CRONTAB-EXIST THEN
    get-string CRONTAB+ ;
: Cronlog: get-string S>ZALLOC TO LOG-FILE ['] LOG-WR ADD-OPT ;
: LogTimeFormat: get-string S>ZALLOC TO LOG-TIME-FORMAT
        ['] LOG-TIME-WR ADD-OPT ;
: Language: set-lang ['] LANG-WR ADD-OPT ;
: YearField NextWord S" ON" COMPARE 0=
    TO <YearField> ;
: BackupPath: get-string S>ZALLOC BACKUP-PATH ! ;
: Editor: get-string S>ZALLOC Editor ! ;

PREVIOUS DEFINITIONS

: PRE-INI   EXEC-NEXT   1 PARSE 2DROP ;
: >file
    tm.out R/W CREATE-FILE-SHARED
    IF DROP  ELSE DUP TO CRON-OUT TO H-STDOUT THEN
;

: load-ini
    POSTPONE [
    ['] PRE-INI TO <PRE>
    NNCronIni ['] INCLUDED CATCH
    IF 2DROP THEN
    BUF2LIST
    ['] NOOP TO <PRE>
;

: TM-INI
    >file
    load-ini
    load-tm-ini
    S" nnCron. Task Maker V %SVERSION%" EVAL-SUBST TYPE CR
    S" Copyright (C) 2001-%YYYY% nnSoft. Email: nemtsev@nncron.ru" EVAL-SUBST TYPE CR
;

' TM-INI ' SPF-INI JMP

: SAVE-NODE ( node --)
    NodeValue DUP TO CUR-INI-NODE
    ini-xt @ EXECUTE ;

: (SAVE-INI)
    463 RES Query 0= IF EXIT THEN
    NNCronIni MAKE-BAK
    NNCronIni R/W CREATE-FILE THROW TO FINI
    ['] SAVE-NODE INI-LIST DoList
    FINI CLOSE-FILE DROP
    469 RES Query 
    IF 
        RestartNNCRON
    ELSE
        462 RES (Message)
    THEN
;

' (SAVE-INI) TO SAVE-INI
: add-crontab  NodeValue ASCIIZ> lb_crontabl Add ;
0 VALUE CUR-LANG
0 VALUE num
: fill-langs 
    0 TO CUR-LANG
    0 TO num
    S" res/*.txt" FOR-FILES
        FOUND-FILENAME 4 - 2DUP LANGUAGE ASCIIZ> ICOMPARE 0=
        IF num TO CUR-LANG THEN
        2DUP + 0 SWAP C!
        cmb_lang Add
        num 1+ TO num
    ;FOR-FILES
    CUR-LANG cmb_lang Current!
;

M: Create
    0 TO 1st-row 0 TO 1st-col    
    0 Create
    AutoCreate
    450 RES SetText
    OptionsPos XY? 
    IF OptionsPos XY@ SetPos 
       width height SetSize
    ELSE width height Center THEN 
    ['] add-crontab CRONTAB-LIST DoList
    LOG-FILE ?DUP IF ASCIIZ> ed_log SetText THEN
    LOG-TIME-FORMAT ?DUP IF ASCIIZ> ed_log_time SetText THEN
    4 0 DO 301 I + RES cmb_open Add LOOP
        DEF-OPEN-MODE cmb_open Current!
    4 0 DO 311 I + RES cmb_prior Add LOOP
        DEF-PRIORITY cmb_prior Current!
    fill-langs
    FALSE TO UPDATE?
;

;CLASS

OptionsDialog POINTER opt
: Options
    OptionsDialog NEW TO opt
    opt Create
    opt Show
    opt Run
    opt SELF DELETE
    BYE
;

\ SPF-INI Options
