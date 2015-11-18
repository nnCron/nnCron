\ version 3

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
REQUIRE EncP ../sec.f

REQUIRE OptionsPos ini.f

REQUIRE TreeView ~nn/lib/win/controls/treeview.f

TRUE VALUE <YearField>

VARIABLE ini-filename

: CronINI ini-filename @ COUNT CUR-OR-HOME-OR-NNCRON-FILE? DROP ;
: az, HERE get-string S", 0 C, ; \ "
: -ini az, ini-filename ! ;

-ini nncron.ini

0 VALUE EDITOR
0 VALUE HELP-FILE
0 VALUE DEF-OPEN-MODE
0 VALUE DEF-PRIORITY
VARIABLE CRONTAB-LIST
0 VALUE LOG-FILE
0 VALUE LOG-TIME-FORMAT
0 VALUE LANGUAGE
0 VALUE UPDATE?
0 VALUE SYS-TRAY
0 VALUE ADMIN-ONLY
0 VALUE SHOW-ERROR
0 VALUE itEXIT
0 VALUE itOPTIONS
0 VALUE itCONSOLE
0 VALUE itRELOAD
0 VALUE OPEN-CONSOLE

0 VALUE vRunAsDefaultUser
0 VALUE vDefaultUser
0 VALUE vDefaultPassword
0 VALUE vDefaultDomain
0 VALUE vDefaultLoadProfile

0 VALUE vGUIAsUser
0 VALUE vGUIUser
0 VALUE vGUIPassword
0 VALUE vGUIDomain
0 VALUE vGUILoadProfile

0 VALUE vGuard

0 VALUE vTrayIconDoubleClick
0 VALUE vTrayIconRightButton

VARIABLE PLUGIN-LIST

: UnP 2DUP S" %" SEARCH NIP NIP 0= IF DecP THEN ;
: EnP 2DUP S" %" SEARCH NIP NIP 0= IF EncP THEN ;

: UPDATE TRUE TO UPDATE? ;

CREATE exe-buf 256 ALLOT

5 VALUE #OPTS

: edit-file ( a u -- )
    EDITOR DUP IF ASCIIZ> EXIST? THEN
    IF
        EDITOR ASCIIZ> exe-buf ZPLACE TRUE
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

: open-help
    HELP-FILE
    IF
        SW_SHOW 0  0
        HELP-FILE  S" open" DROP 0
        ShellExecuteA DROP
    THEN
;

CLASS: OptionsDialog <SUPER FrameWindow

( 225) 240 VALUE width
( 181) 250 VALUE height
13 CONSTANT but_h
37 CONSTANT but_w
: but_col ( # -- col ) but_w 5 + * width 1st-col + SWAP - 5 - ;
: but_row height but_h 2* - 5 - ;
: button  WITH Control but_col but_row pos but_w but_h size tabstop ENDWITH ;

CLASS: OptionFrame <SUPER FrameWindow
M: Create ( parent )
   WS_CHILD  WS_BORDER OR vStyle !
   WS_EX_CLIENTEDGE WS_EX_WINDOWEDGE OR vExStyle !
   140 20 pos  298 273 size
   Create
;

;CLASS

VARIABLE fwc-list   \ Frame window controls list
VARIABLE cur-frame

: sw ( # -- )
    2 CELLS ALLOCATE THROW >R
    this R@ !
    R@ CELL+ !
    R> fwc-list AddNode ;

: show-frame
    NodeValue >R
    R@ CELL+ @ cur-frame @ =
    IF R@ @ => Show THEN
    RDROP
;

: hide-frame
    NodeValue >R
    R@ CELL+ @ cur-frame @ =
    IF R@ @ => Hide THEN
    RDROP
;


M: FrameShow ( # -- ) cur-frame ! ['] show-frame fwc-list DoList ;
M: FrameHide ( # -- ) cur-frame ! ['] hide-frame fwc-list DoList ;

\    Static OBJ st_crontab
\        :init a v 0 1 4 1 ps  451 RES text ;
\    Edit OBJ ed_crontab
\        :init a v 0 5 5 1 ps tabstop ;

    TreeView OBJ tree_opts
        :init a v 5 5 pos 63 ( 142) height 39 - size  tabstop
            TVS_HASLINES TVS_LINESATROOT  OR
            WS_TABSTOP OR
\            TVS_HASBUTTONS OR
            vStyle ! ;

    GroupBox OBJ grp1
        :init a v 70 2 pos width 80 - ( 145) height 36 - size 700 RES text ;

: c1 8 ;
: w1 6 ;
: c2 13 ;
: w2 9 ;
    Static OBJ st_crontabl
        :init 0 sw a v 0 8 10 1 ps  453 RES text ;

    ListBox OBJ lb_crontabl
        :init 0 sw a v 1 8 9 4 ps  tabstop ;


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
        :init 0 sw a v 18 col 1 row pos 30 9 size 461 RES text tabstop
            ['] onEdit OnClick ! ;
    M: onAdd
        S" " AddCrontab ?DUP
        IF lb_crontabl Add UPDATE
        ELSE DROP THEN ;
    Button OBJ but_add
        :init 0 sw a v 18 col 2 row pos 30 9 size 452 RES text tabstop
            ['] onAdd OnClick ! ;
    M: onDel lb_crontabl Current DUP -1 <>
        IF lb_crontabl Delete DROP UPDATE ELSE DROP THEN ;
    Button OBJ but_del
        :init 0 sw a v 18 col 3 row pos 30 9 size 454 RES text tabstop
            ['] onDel OnClick !  ;
    M: upd UPDATE ;

VARIABLE <rw>
: rw <rw> @ POSTPONE LITERAL ; IMMEDIATE
: rw++ <rw> 1+! ;
: rw+ <rw> @ POSTPONE LITERAL rw++ ; IMMEDIATE
: rw! <rw> ! ;

    4 rw!
    Static OBJ st_log
        :init 0 sw a v rw c1 w1 1 ps 455 RES text ;
    Edit OBJ ed_log
        :init 0 sw a v rw+ c2 w2 1 ps tabstop ['] upd OnChange ! ;
    Static OBJ st_log_time
        :init 0 sw a v rw c1 w1 1 ps 456 RES text ;
    Edit OBJ ed_log_time
        :init 0 sw a v rw+ c2 w2 1 ps tabstop ['] upd OnChange ! ;

    Static OBJ st_editor
        :init 0 sw a v rw c1 w1 1 ps 720 RES text ;
    Edit OBJ ed_editor
        :init 0 sw a v rw+ c2 w2 1 ps tabstop ['] upd OnChange ! ;

    Static OBJ st_backup
        :init 0 sw a v rw c1 w1 1 ps 722 RES text ;
    Edit OBJ ed_backup
        :init 0 sw a v rw+ c2 w2 1 ps tabstop ['] upd OnChange ! ;

    Static OBJ st_helpfile
        :init 0 sw a v rw c1 w1 1 ps  474 RES text ;
    Edit OBJ ed_helpfile
        :init 0 sw a v rw+ c2 w2 1 ps tabstop ['] upd OnChange ! ;

    Static OBJ st_open
        :init 0 sw a v rw 8 9 1 ps 458 RES text ;
    ComboBox OBJ cmb_open
        :init 0 sw a v rw+ 18 4 4 ps tabstop ['] upd OnSelChange ! ;

    Static OBJ st_prior
        :init 0 sw a v rw 8 9 1 ps 459 RES text ;
    ComboBox OBJ cmb_prior
        :init 0 sw a v rw+ 18 4 4 ps tabstop ['] upd OnSelChange ! ;

    Static OBJ st_lang
        :init 0 sw a v rw 8 9 1 ps 460 RES text ;
    ComboBox OBJ cmb_lang
        :init 0 sw a v rw+ 18 4 4 ps tabstop ['] upd OnSelChange ! ;

    CheckBox OBJ cb_showerror
        :init 0 sw a v rw+ 8 10 1 ps 481 RES text tabstop ['] upd OnClick ! ;

    CheckBox OBJ cb_year
        :init 0 sw a v rw 8 5 1 ps 721 RES text tabstop ['] upd OnClick ! ;

    CheckBox OBJ cb_guard
        :init 0 sw a v rw 13 7 1 ps 729 RES text tabstop ['] upd OnClick ! ;


\ ---------------------------- Interface ----------------------------

    CheckBox OBJ cb_systray
        :init 1 sw a 0 8 6 1 ps 723 RES text tabstop ['] upd OnClick ! ;

    CheckBox OBJ cb_adminonly
        :init 1 sw a 0 15 7 1 ps 750 RES text tabstop ['] upd OnClick ! ;

    GroupBox OBJ grp_menu
        :init 1 sw a 80 70 pos 100 58 size 724 RES text  ;

    CheckBox OBJ cb_options
        :init 1 sw a 7 9 8 1 ps 725 RES text tabstop ['] upd OnClick ! ;

    CheckBox OBJ cb_exit
        :init 1 sw a 8 9 8 1 ps 726 RES text tabstop ['] upd OnClick ! ;

    CheckBox OBJ cb_console
        :init 1 sw a 9 9 8 1 ps 727 RES text tabstop ['] upd OnClick ! ;

    CheckBox OBJ cb_reload
        :init 1 sw a 10 9 8 1 ps 23 RES text tabstop ['] upd OnClick ! ;


    CheckBox OBJ cb_start_console
        :init 1 sw a 13 8 10 1 ps 728 RES text tabstop ['] upd OnClick ! ;


    Static OBJ st_tray_db
        :init 1 sw a 2 8 9 1 ps  482 RES text ;
    ComboBoxEdit OBJ cmb_tray_db
        :init 1 sw a  2 17 5 8 ps tabstop 
            ['] upd OnSelChange !
            ['] upd OnEditChange !
        ;
        
    Static OBJ st_tray_rb
        :init 1 sw a 4 8 9 1 ps  483 RES text ;
    ComboBoxEdit OBJ cmb_tray_rb
        :init 1 sw a  4 17 5 8 ps tabstop
            ['] upd OnSelChange ! 
            ['] upd OnEditChange !
        ;
        
        

\ ------------------------------ AUTHORIZATION ----------------------

    CheckBox OBJ cb_dasuser
        :init 2 sw a 0 8 13 1 ps 730 RES text tabstop ['] upd OnClick ! ;

    Static OBJ st_duser
        :init 2 sw a 1 9 4 1 ps 732 RES text  ;
    Edit OBJ ed_duser
        :init 2 sw a 1 13 6 1 ps  tabstop ['] upd OnChange ! ;

    Static OBJ st_dpass
        :init 2 sw a 2 9 4 1 ps 733 RES text  ;
    Edit OBJ ed_dpass
        :init 2 sw a 2 13 6 1 ps  WS_TABSTOP ES_PASSWORD OR vStyle ! ['] upd OnChange ! ;

    Static OBJ st_ddomain
        :init 2 sw a 3 9 4 1 ps 734 RES text  ;
    Edit OBJ ed_ddomain
        :init 2 sw a 3 13 6 1 ps  tabstop ['] upd OnChange ! ;

    CheckBox OBJ cb_dloadprofile
        :init 2 sw a 4 9 12 1 ps 731 RES text tabstop ['] upd OnClick ! ;


    CheckBox OBJ cb_gasuser
        :init 2 sw a 6 8 12 1 ps 735 RES text tabstop ['] upd OnClick ! ;

    Static OBJ st_guser
        :init 2 sw a 7 9 4 1 ps 732 RES text  ;
    Edit OBJ ed_guser
        :init 2 sw a 7 13 6 1 ps  tabstop ['] upd OnChange ! ;

    Static OBJ st_gpass
        :init 2 sw a 8 9 4 1 ps 733 RES text  ;
    Edit OBJ ed_gpass
        :init 2 sw a 8 13 6 1 ps  WS_TABSTOP ES_PASSWORD OR vStyle ! ['] upd OnChange ! ;

    Static OBJ st_gdomain
        :init 2 sw a 9 9 4 1 ps 734 RES text  ;
    Edit OBJ ed_gdomain
        :init 2 sw a 9 13 6 1 ps  tabstop ['] upd OnChange ! ;

    CheckBox OBJ cb_gloadprofile
        :init 2 sw a 10 9 12 1 ps 731 RES text tabstop ['] upd OnClick ! ;


\ ----------------------------- Plugins -----------------------------

    Static OBJ st_plugins
        :init 3 sw a 0 8 10 1 ps 740 RES text  ;
    ListBox OBJ lb_plugins
        :init 3 sw a 1 8 13 10 ps tabstop  ;

    M: onEditPl
        lb_plugins Current -1 <>
        IF
            PAD lb_plugins Current lb_plugins Get
            AddPlugin ?DUP
            IF lb_plugins Current DUP lb_plugins  Delete DROP
               lb_plugins Insert
               UPDATE
            ELSE DROP THEN
        THEN
    ;

    Button OBJ but_editpl
        :init 3 sw a  8 col 11 row pos 30 9 size 461 RES text tabstop
            ['] onEditPl OnClick ! ;
    M: onAddPl
        S" " AddPlugin ?DUP
        IF lb_plugins Add UPDATE
        ELSE DROP THEN ;
    Button OBJ but_addpl
        :init 3 sw a  12 col 11 row pos 30 9 size 452 RES text tabstop
            ['] onAddPl OnClick ! ;
    M: onDelPl lb_plugins Current DUP -1 <>
        IF lb_plugins Delete DROP UPDATE ELSE DROP THEN ;
    Button OBJ but_delpl
        :init 3 sw a  16 col 11 row pos 30 9 size 454 RES text tabstop
            ['] onDelPl OnClick !  ;

\ ----------------------------------------------------------------------

    VECT SAVE-INI
    : sav-tm-ini  GetPos OptionsPos XY! save-tm-ini ;
    M: onIni sav-tm-ini
        UPDATE? IF SAVE-INI THEN CronINI edit-file BYE ;
    Button OBJ but_ini
        :init a v 3 button  CronINI text ['] onIni OnClick ! ;
    M: onOk  sav-tm-ini
        UPDATE? IF
                    ['] SAVE-INI CATCH ?DUP
                    IF TO IO-ERR S" %CronINI%" 338 ERR-MSG-STR EXIT THEN
                THEN BYE ;
    Button OBJ but_ok
        :init a v 2 button 200 RES text ['] onOk OnClick ! ;
    M: onCancel sav-tm-ini BYE ;
    Button OBJ but_cancel
        :init a v 1 button 201 RES text ['] onCancel OnClick ! ;


    M: onTreeChange { \ iprev icur -- }
\        0 S" ok" DROP DUP 0 MessageBoxA DROP
        lparam @ 13 CELLS + @ TO iprev
        lparam @ 23 CELLS + @ TO icur
        iprev icur <>
        IF
            lparam @ 15 CELLS + @  \ hItem
            tree_opts GetItemText \ 2DUP TYPE CR
            grp1 SetText
            iprev FrameHide
            icur FrameShow
        THEN
    ;


S" options-rw.f" INCLUDED

: add-plugin NodeValue ASCIIZ> lb_plugins  Add ;
: add-crontab  NodeValue ASCIIZ> lb_crontabl Add ;


: processKeyDown
    wparam @
    CASE
    VK_F1  OF open-help TRUE ENDOF
        FALSE SWAP
    ENDCASE
;

: fill-actions { a u cmb -- }
    WITH ComboBox
        S" options"         cmb => Add
        S" add-new-task"    cmb => Add
        S" open-help"       cmb => Add
        S" add-reminder"    cmb => Add
        S" about"           cmb => Add
        S" show-log"        cmb => Add
        S" winspy"          cmb => Add
        S" START-CONSOLE"   cmb => Add
        S" reload-crontab"  cmb => Add
    ENDWITH
    a u cmb ->CLASS ComboBox GetIndex CB_ERR =
        IF a u cmb ->CLASS ComboBox Add THEN    
    a u cmb ->CLASS ComboBox GetIndex
    cmb ->CLASS ComboBox Current!
;

M: Create
\    WS_EX_CONTEXTHELP vExStyle @ OR vExStyle !
    0 TO 1st-row 0 TO 1st-col
    0 Create
    AutoCreate
    0 FrameShow
    450 RES 2DUP ?BYE-IF-EXIST SetText
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

    EDITOR ?DUP IF ASCIIZ> ed_editor SetText THEN
    HELP-FILE ?DUP IF ASCIIZ> ed_helpfile SetText THEN
    BACKUP-PATH @ ?DUP IF ASCIIZ> ed_backup SetText THEN
    <YearField> cb_year ?Check

    SYS-TRAY    cb_systray ?Check
    ADMIN-ONLY  cb_adminonly ?Check

    SHOW-ERROR  cb_showerror ?Check

    itEXIT      cb_exit ?Check
    itOPTIONS   cb_options ?Check
    itCONSOLE   cb_console ?Check
    itRELOAD    cb_reload ?Check
    OPEN-CONSOLE cb_start_console ?Check

    vRunAsDefaultUser       cb_dasuser ?Check
    vDefaultLoadProfile     cb_dloadprofile ?Check
    vDefaultUser            ?DUP IF ASCIIZ> ed_duser SetText THEN
    vDefaultPassword        ?DUP IF ASCIIZ> UnP ed_dpass SetText THEN
    vDefaultDomain          ?DUP IF ASCIIZ> ed_ddomain SetText THEN

    vGUIAsUser              cb_gasuser ?Check
    vGUILoadProfile         cb_gloadprofile ?Check
    vGUIUser                ?DUP IF ASCIIZ> ed_guser SetText THEN
    vGUIPassword            ?DUP IF ASCIIZ> UnP ed_gpass SetText THEN
    vGUIDomain              ?DUP IF ASCIIZ> ed_gdomain SetText THEN

    vGuard cb_guard ?Check

    PLUGIN-LIST @
    IF
        ['] add-plugin PLUGIN-LIST DoList
    THEN
    ['] onEditPl lb_plugins OnDoubleClick !
    ['] onEdit lb_crontabl OnDoubleClick !

    fill-langs
    
    vTrayIconDoubleClick ASCIIZ> cmb_tray_db SELF fill-actions
    vTrayIconRightButton ASCIIZ> cmb_tray_rb SELF fill-actions
    
    FALSE TO UPDATE?

    4 0 DO I 700 + RES 0 tree_opts AddTextItem LOOP

\    702 RES 0 1 tree_opts GetItem tree_opts AddTextItem
\    703 RES 0 1 tree_opts GetItem tree_opts AddTextItem
    tree_opts ExpandAll
    ['] onTreeChange tree_opts OnSelChange !
\    ['] onTVClick tree_opts OnClick !

    ['] processKeyDown onKeyDown !
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
