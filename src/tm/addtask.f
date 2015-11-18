(
: WINAPI: >IN @ >R
    BL WORD FIND NIP
    0= IF R> >IN ! ['] WINAPI: CATCH DROP
       ELSE RDROP BL WORD DROP THEN
;
)

VARIABLE DontBYE
: ?BYE DontBYE @ 0= IF BYE THEN ;

REQUIRE { ~nn/lib/locals.f
REQUIRE BEEP ~nn/lib/beep.f
REQUIRE Control     ~nn/lib/win/control.f
REQUIRE TabControl  ~nn/lib/win/controls/tab.f
REQUIRE ComboBox ~nn/lib/win/controls/combobox.f
REQUIRE RES ~nn/lib/res.f
REQUIRE OpenDialog ~nn/lib/win/filedialogs.f
REQUIRE FILE>DIR ~nn/lib/filename.f
REQUIRE DateTimePicker ~nn/lib/win/controls/DateTimePicker.f
REQUIRE CASE lib/ext/case.f
REQUIRE AddNode ~nn/lib/list.f
REQUIRE ENV ~nn/lib/set.f
REQUIRE WinNT? ~nn/lib/winver.f
REQUIRE RasGetEnties ~nn/lib/ras_entries.f
REQUIRE ERR-MSG err_msg.f
REQUIRE get-string ~nn/lib/getstr.f
REQUIRE <TIB ~nn/lib/tib.f
REQUIRE >EOF ~nemnick\lib\eof.f
REQUIRE JMP ~nn/lib/jmp.f
REQUIRE USERNAME ~nn/lib/win/sec/username.f
REQUIRE WHICH ~nn/lib/which.f
REQUIRE S>NUM ~nn/lib/s2num.f
REQUIRE ShellStart ~nn/lib/shellstart.f
REQUIRE isShift? ~nn/lib/win/sys/keystate.f

\ S" lib/ext/dis486.f" INCLUDED

\ REQUIRE Shedule sched.f
REQUIRE gethostname ~nn/lib/sock.f

REQUIRE WeekDays weekdays.f

17 CONSTANT actions
 9 CONSTANT conds
 3 CONSTANT TAB-ADV
19 CONSTANT events

CLASS: AddTaskDialog <SUPER FrameWindow
    var week_days
    var adv_buf
    var is-edit
    var crontab
    var taskname
    var is-adv
    var vCanExit
    var vUserName

USER tab1
: tab+ ( index -- )  this SWAP tab1 @ ->CLASS TabControl AddEl ;

\ * 192 CONSTANT width
\ * 228 CONSTANT height

\ 270 CONSTANT width
250 CONSTANT width
\ 228 CONSTANT height
258 CONSTANT height

row_h 3 * 2 / CONSTANT tab_row
4 CONSTANT tab_col
: set-rc
    tab_row TO 1st-row
    tab_col TO 1st-col ;

width tab_col 3 * - CONSTANT tab_w
height tab_row tab_col 2 * + - 25 - CONSTANT tab_h
13 CONSTANT but_h
37 CONSTANT but_w
: but_col ( # -- col ) but_w 5 + * tab_w tab_col + SWAP - 5 + ;
: but_row tab_row tab_h + tab_col + ;


\ ---- Header -------------------------------

    Static OBJ st_task_name
        :init a v  0 col 2 pos  50 row_h size 110 RES text ;
    Edit OBJ ed_task_name
        :init a v  5 col 2 pos  6 cols row_h size  ;

    Static OBJ st_crontab
        :init a v  width 10 cols -  3 pos  3 cols row_h size  112 RES text ;
    ComboBox OBJ cmb_crontab
        :init a v  width 7 cols - 2 pos  6 cols row_h 4 * size tabstop ;

\        tab_w 2 cols - row_h actions * size

    var task_name_chg
    var num_chg

    M: on_task_name_change
        task_name_chg @ IF EXIT THEN
        ed_task_name GetText 2DUP 2>R
        OVER + SWAP
        ?DO I C@ BL =
            IF [CHAR] _ I C! TRUE task_name_chg ! THEN
        LOOP
        2R>
        task_name_chg @
        IF
            ed_task_name GetPos >R
            PAD 256 ERASE  PAD SWAP CMOVE  PAD ASCIIZ>
            ed_task_name SetText
            R> ed_task_name SetPos
        ELSE
            2DROP
        THEN
        task_name_chg 0!
    ;


    TabControl OBJ tab
        :init a v  tab_col tab_row pos  tab_w tab_h size
            this tab1 !
            vStyle @ WS_TABSTOP OR vStyle !
            ;

\ --- advanced -------
    Static OBJ st_adv
        :init a 1 col 1 row pos  15 cols row_h size 3 tab+ 400 RES text ;
    Edit OBJ ed_adv
        :init a 1 col 2 row pos  tab_w 2 cols - tab_h row_h 4 * - size 3 tab+
            ES_MULTILINE ES_AUTOVSCROLL OR ES_AUTOHSCROLL OR WS_VSCROLL OR
            WS_TABSTOP OR ES_WANTRETURN OR vStyle !
        ;

\ ----- time -----------
S" addtask_time.f" INCLUDED
\ ------ flags -------

    GroupBox OBJ user_grp
        :init a v 10 12 row 5 + pos width 23 - 70 size
            0 tab+ ;

    CheckBox OBJ cb_aslogged
        :init a v  1 col 13 row pos  15 cols row_h size  159 RES text
            tabstop this 0 tab+ ;


    CheckBox OBJ cb_asuser
        :init a v  1 col 14 row pos  5 cols row_h size  150 RES text
            tabstop this 0 tab+ ;

: cust 10 col ;
: wust 5 cols ;
: cued 15 col ;
: wued 8 cols ;

    Static OBJ st_user_name
        :init a v  cust 14 row 1+ pos  wust row_h size 151 RES text
              this 0 tab+ ;

\    Edit OBJ ed_user_name
\        :init a v  9 col 11 row pos  7 cols row_h size
\            tabstop this 0 tab+ ;

    ComboBoxEdit OBJ cmb_users
        :init a v  cued 14 row pos  wued row_h 5 * size
            tabstop this 0 tab+ ;


    Static OBJ st_password
        :init a v  cust 15 row 1+ pos  wust row_h size 152 RES text
              this 0 tab+ ;

    Edit OBJ ed_password
        :init a v  cued 15 row pos  wued row_h size
            WS_TABSTOP ES_PASSWORD OR vStyle !
            this 0 tab+ ;

    Static OBJ st_domain
        :init a v  cust 16 row 1+ pos  wust row_h size 153 RES text
              this 0 tab+ ;

    Edit OBJ ed_domain
        :init a v  cued 16 row pos  wued row_h size
            tabstop this 0 tab+ ;

    Static OBJ st_logon_type
        :init a v  cust 17 row 1+ pos  wust row_h size 154 RES text
              this 0 tab+ ;

    ComboBox OBJ cmb_logon_type
        :init a v  cued 17 row pos  wued row_h 5 * size
            tabstop this 0 tab+ ;

    CheckBox OBJ cb_profile
            :init a v
                17 1 7 1 ps
\                11 col 12 row pos  5 cols row_h size
                480 RES text 0 tab+ tabstop ;

USER <user-buf> 100 USER-ALLOT
M: GetUser ( -- a u)
\    <user-buf> cmb_users GetCurrent
\    <user-buf>
    cmb_users GetText
;

2010 CONSTANT NN_TEST_LOGON

: n-az ( n -- a )  PAD SWAP 0 ?DO ASCIIZ> + 1+ LOOP ;

M: logon_test
    S" nnCron control window" DROP 0 FindWindowA
    ?DUP
    IF
        >R
        GetUser PAD ZPLACE
        ed_password  GetText 1 n-az ZPLACE
        ed_domain  GetText 2 n-az ZPLACE
        PAD
        3 n-az PAD -
        cmb_logon_type Current
        CASE
          0 OF LOGON32_LOGON_INTERACTIVE ENDOF
          1 OF LOGON32_LOGON_BATCH ENDOF
          2 OF LOGON32_LOGON_NETWORK ENDOF
          LOGON32_LOGON_INTERACTIVE SWAP
        ENDCASE
        SP@
        NN_TEST_LOGON WM_COPYDATA R> SendMessageA ?DUP
        IF
          SetLastError DROP
          vCanExit 0!
          GetLastError TO IO-ERR
          600 ERR-MSG
        ELSE
          601 RES MsgBox
        THEN
        2DROP DROP
     ELSE
        605 ERR-MSG
     THEN
(
  0 SP@
  LOGON32_PROVIDER_DEFAULT
  cmb_logon_type Current
  CASE
    0 OF LOGON32_LOGON_INTERACTIVE ENDOF
    1 OF LOGON32_LOGON_BATCH ENDOF
    2 OF LOGON32_LOGON_NETWORK ENDOF
    LOGON32_LOGON_INTERACTIVE SWAP
  ENDCASE
  ed_password  GetText DROP
  ed_domain  GetText DROP

\  ed_user_name GetText DROP
\  PAD cmb_users GetCurrent  DROP
  GetUser DROP
  LogonUserA 0=
  IF DROP
    vCanExit 0!
    GetLastError TO IO-ERR
    600 ERR-MSG
  ELSE
    CLOSE-FILE DROP
    601 RES MsgBox
  THEN
)
;
    Button OBJ but_logon_test
        :init a v cued 18 row 2 + pos wued 10 size 602 RES text
            ['] logon_test OnClick !
            tabstop this 0 tab+ ;



M: SetUserName ( a u -- )
    vUserName @ ?DUP IF FREE DROP THEN
    S>ZALLOC vUserName !
;
M: cmb_users_change
\    PAD cmb_users GetCurrent ed_user_name SetText
    GetUser SetUserName
;

\ ------ Action -----------------

S" addtask_com.f" INCLUDED
S" addtask_act.f" INCLUDED
S" addtask_cond.f" INCLUDED
S" addtask_make.f" INCLUDED

\ ----- common buttons ----------

    Button OBJ ok_button
        :init a v  but_w but_h size  2 but_col but_row pos
                200 RES text  tabstop  ;


    : sav-tm-ini GetPos AddTaskPos XY! save-tm-ini ;

    M: onCancel sav-tm-ini TRUE vClose ! ( 0 ModalResult!) ;
    Button OBJ cancel_button
        :init a v  but_w but_h size  1 but_col but_row pos tabstop
                201 RES text  ['] onCancel OnClick ! ;
(
    Button OBJ help_button
        :init a v but_w but_h size  3 but_col but_row pos tabstop
                203 RES text ['] open-help OnClick ! ;
)
    Button OBJ del_button
        :init a  but_w but_h size  3 but_col but_row pos tabstop
                202 RES text ;


(
    M: onTest 5 cmb_minute_step Current! ;
    Button OBJ test_button
        :init a v but_w but_h size  4 but_col but_row pos
                S" test" text  ['] onTest OnClick ! ;
)

\ ===================================


: add_user ( node -- )
    NodeValue DUP ASCIIZ> cmb_users Add
    FREE DROP
;

M: set_cmb_users
    vUserName @ ?DUP
    IF
        ASCIIZ> cmb_users GetIndex DUP CB_ERR <>
        IF cmb_users Current! ELSE DROP
           vUserName @ ASCIIZ> cmb_users SetText
        THEN
    THEN
;

M: set-user-list { \ list -- }
\    S" ok" MsgBox
    ed_domain GetText ?DUP 
    IF 
        USER-LIST TO list
        list
        IF
            cmb_users Clear
            ['] add_user AT list DoList
            AT list FreeList
        THEN
        set_cmb_users
    ELSE DROP THEN
;

M: SetAsUser
    cb_asuser GetCheck WinNT? AND
    IF
        set-user-list
        st_user_name Enable cmb_users Enable \ ed_user_name Enable
        st_password Enable ed_password Enable
        st_domain Enable ed_domain Enable
        st_logon_type Enable cmb_logon_type Enable
        but_logon_test Enable
\        is-edit @ 0= IF WinXP? IF cb_profile Checked THEN THEN
    ELSE
        st_user_name Disable cmb_users Disable \ ed_user_name Disable
        st_password Disable ed_password Disable
        st_domain Disable ed_domain Disable
        st_logon_type Disable cmb_logon_type Disable
        but_logon_test Disable
    THEN

    cb_asuser GetCheck cb_aslogged GetCheck OR WinNT? AND
    IF
        cb_profile Enable
    ELSE
        cb_profile Disable
    THEN
;


M: SetAdv   MakeTaskText ed_adv SetText ;

M: SetCond
    onCondChange
;
0 [IF]
CLASS: TabTest <SUPER FrameWindow
    Edit OBJ ed1
        :init a v 2 2 10 2 ps ;
M: Create ( owner -- )
    WS_CHILD vStyle !
    Create
    30 30 100 100 Move
    AutoCreate
    S" xaxaxax" ed1 SetText
;
;CLASS

TabTest POINTER w1
M: SetTest
    TabTest NEW TO w1
    this w1 Create
    w1 Show
;

[THEN]

CREATE (tab-select)  ' SetTimeType , ' SetAction ,
    ' SetCond ,  ' SetAdv ,  \ ' SetTest ,

M: TabSelect (tab-select) tab Current CELLS + @ EXECUTE  TRUE ;

S" addtask_inp.f" INCLUDED
S" addtask_rw.f" INCLUDED

M: BeforeTabSelect tab Current TAB-ADV = IF adv-parse is-adv @ ELSE 0 THEN ;

: CreateTab
    4 0 DO 101 I + RES I tab Insert LOOP
\    S" testttt" 4 tab Insert
    ['] TabSelect tab OnSelChange !
    ['] BeforeTabSelect tab OnSelChanging !
;

: S>AZ ( a u -- a1 u1)
    PAD OVER 1+ ERASE
    PAD SWAP >R R@ CMOVE
    PAD R>
;

M: onOk
    ed_task_name GetText NIP 0=
    IF
        335 ERR-MSG
    ELSE
        sav-tm-ini
        TRUE vCanExit !
        tab Current TAB-ADV <> IF SetAdv THEN
        vCanExit @
        IF
           cmb_crontab Current CB_ERR <>
           IF
               PAD cmb_crontab GetCurrent
           ELSE DefCrontab THEN
           write-task
        THEN
        vCanExit @  IF  1 ModalResult!  THEN
    THEN
;

M: onDelete
    ed_task_name GetText NIP 0=
    IF
        335 ERR-MSG
    ELSE
        sav-tm-ini
        crontab @ ?DUP IF ASCIIZ> delete-task THEN ?BYE
    THEN ;

VARIABLE max_crontab
: add-crontab
    NodeValue ASCIIZ> EVAL-SUBST
    DUP max_crontab @ > IF DUP max_crontab ! THEN
    cmb_crontab Add ;
: fill-crontab
    max_crontab 0!
    ['] add-crontab CRONTAB-LIST DoList
\    10 GetDialogBaseUnits 0xFFFF AND FromPixels . . CR
    max_crontab @ 6 * cmb_crontab SetDropWidth
;

(
: W: WM_CHAR
    BASE @ HEX
    wparam @ . BASE !
    TRUE
;
)

: processKeyDown
    wparam @
    CASE
    VK_F1  OF open-help TRUE ENDOF
    VK_TAB OF
(
             isControl?
             IF
               tab Current DUP TAB-ADV = IF DROP 0 ELSE 1+ THEN
               DUP TAB-ADV = IF SetAdv THEN
               BeforeTabSelect
               tab Current!
               TabSelect
               TRUE
             ELSE
)
               ed_scr isActive
               IF isShift? IF cmb_action SetFocus ELSE ok_button SetFocus THEN ELSE
               ed_adv isActive
               IF isShift? IF tab SetFocus ELSE ok_button SetFocus THEN ELSE
               ed_cron_tim isActive
               IF isShift? IF rb_cron_tim SetFocus ELSE cb_log SetFocus THEN ELSE
               FALSE THEN THEN THEN
\             THEN
           ENDOF
        FALSE SWAP
    ENDCASE
;


Font POINTER CurFont
M: Create
    0 Create
    is-edit @ IF 111 ELSE 100 THEN RES SetText
    AddTaskPos XY?
    IF AddTaskPos XY@ SetPos
       width height SetSize
    ELSE width height Center THEN
    AutoCreate
    CreateTab
    ['] on_task_name_change ed_task_name OnChange !
    ed_task_name SetFocus
    rb_once Checked
    SetTimeType
    S" HH':'mm" tm_start_time SetFormat
    ['] SetTimeType rb_once OnClick !
    ['] SetTimeType rb_minutely OnClick !
    ['] SetTimeType rb_hourly OnClick !
    ['] SetTimeType rb_daily OnClick !
    ['] SetTimeType rb_weekly OnClick !
    ['] SetTimeType rb_monthly OnClick !
    ['] SetTimeType rb_annually OnClick !
    ['] SetTimeType rb_event OnClick !
    ['] SetTimeType rb_cron_tim OnClick !

    events 0 DO 500 I + RES cmb_events Add LOOP
    0 cmb_events Current!
    SetEvent
    ['] SetEvent cmb_events OnSelChange !


    min_steps COUNT OVER + SWAP DO I 2 S>AZ cmb_minute_step Add 2 +LOOP
    0 cmb_minute_step Current!
    hour_steps COUNT OVER + SWAP DO I 2  S>AZ cmb_hour_step Add 2 +LOOP
    0 cmb_hour_step Current!
    7 0 DO I 160 + RES cmb_weekdays Add LOOP
    0 cmb_weekdays Current!

    cb_log Checked
    SetAsUser
    OnCbMissed
    S" USERNAME" ENV SetUserName
    S" COMPUTERNAME" ENV ed_domain SetText
    3 0 DO  155 I + RES cmb_logon_type Add LOOP
    0 cmb_logon_type Current!
    ['] SetAsUser cb_asuser OnClick !
    ['] SetAsUser cb_aslogged OnClick !
    S" 0" ed_minutes SetText  2 ed_minutes SetLimit
        ['] on_minutes_change ed_minutes OnChange !
    S" 1" ed_days SetText 2 ed_days SetLimit
        ['] on_days_change ed_days OnChange !
    127 week_days !

    ['] OnCbMissed cb_missed OnClick !

    actions 0 DO 210 I + RES cmb_action Add LOOP
    0 cmb_action Current!
    ['] SetAction cmb_action OnSelChange !
    4 0 DO 301 I + RES cmb_open Add LOOP
        0 cmb_open Current!
    4 0 DO 311 I + RES cmb_prior Add LOOP
        0 cmb_prior Current!
    ['] SetAppPath but_app OnClick !
    255 ed_app SetLimit
    255 ed_dir SetLimit
    ['] on_but_event but_event OnClick !
    S" 1000" ed_dur SetText
    S" 1000" ed_freq SetText

    conds 0 DO 260 I + RES cmb_cond Add LOOP
    0 cmb_cond Current!
    ['] onCondChange cmb_cond OnSelChange !
\    ['] on_cond_clr but_cond_clr OnClick !
    10240 ALLOCATE THROW adv_buf !
    ['] onTimout cb_tout OnClick !
    ['] onRasConn cmb_ras_conn OnSelChange !
    S" 1" ed_ras_attempts SetText
    S" 1" ed_ras_pause SetText
    S" 7" ed_purge_days SetText
    S" TMP" ENV
    ?DUP IF PAD PLACE S" \*.*" PAD +PLACE PAD +PLACE0
            PAD COUNT ed_purge SetText
         ELSE DROP THEN
    Font NEW TO CurFont
    S" Courier" DROP CurFont lpszFace !
    16 CurFont height !
    CurFont Create
    CurFont handle @ ed_adv SetFont
    CurFont handle @ ed_scr SetFont
    CurFont handle @ st_cron_tim SetFont
    CurFont handle @ ed_cron_tim SetFont
    ['] onOk ok_button OnClick !
    is-edit @ IF del_button Show THEN
    ['] onDelete del_button OnClick !
    cb_active Checked
\    32 SP@ 1 EM_SETTABSTOPS ed_adv handle @ SendMessageA 2DROP
\    0 0 EM_SETTABSTOPS ed_adv handle @ SendMessageA DUP . DROP
    fill-crontab
    ['] cmb_users_change cmb_users OnSelChange !
\    ['] set-user-list ed_domain OnChange !
    ['] set-user-list ed_domain OnLeave !
    15 ed_scr TabStops
    15 ed_adv TabStops
\    NACCELS @ ACCELS CreateAcceleratorTableA DUP . CR vAccel !
    ['] processKeyDown onKeyDown !
;

M: SetCrontab   ( a u -- )
    OVER NNCRON-HOME-DIR\ SWAP OVER PATH-COMPARE 0=
    IF NNCRON-HOME-DIR\ NIP /STRING THEN
    S>ZALLOC crontab !
    crontab @ ASCIIZ> 2DUP cmb_crontab GetIndex
    CB_ERR = IF 2DUP cmb_crontab Add THEN
    cmb_crontab GetIndex  cmb_crontab Current!
;

M: ReadTask ( a u a1 u1 -- )
    S>ZALLOC taskname !
    SetCrontab
    crontab @ ASCIIZ> taskname @ ASCIIZ> read-task
    adv-parse
    SetTimeType
    is-adv @ IF 3 tab Current! tab SelTab THEN
    SetAsUser
;

M: SetDefs
    DEF-OPEN-MODE cmb_open Current!
    DEF-PRIORITY cmb_prior Current!
;

;CLASS

: READED-TASKNAME
    WITH AddTaskDialog
    readed-task-name
    ENDWITH
;

AddTaskDialog POINTER w


: AddTask
\    TM-INI
    WITH AddTaskDialog set-rc ENDWITH
    AddTaskDialog NEW TO w
    w Create
    get-string w SetCrontab
    w SetDefs
    w ShowModal DROP
    w Run
    w SELF DELETE
    ?BYE
;

: NewTask AddTask ;

: EditTask
\    TM-INI
    WITH AddTaskDialog set-rc ENDWITH
    AddTaskDialog NEW TO w
    TRUE w is-edit !
    w Create
    get-string NextWord w ReadTask
    w Show
    w Run
    w SELF DELETE
    ?BYE
;

