\ Add task. Actions
: act_w tab_w 5 cols - ;
    ComboBox OBJ cmb_action
        :init a 1 col 1 row pos  tab_w 2 cols - row_h actions * size 1 tab+ tabstop ;
    Static OBJ st_app
            :init a  1 col 3 row pos  15 cols row_h size 1 tab+ 190 RES text ;

    Edit OBJ ed_app
            :init a  2 col 4 row pos   act_w row_h size 1 tab+ tabstop ;

    Edit OBJ ed_purge
            :init a  2 col 4 row pos  act_w row_h size 1 tab+ tabstop ;

    Button OBJ but_app
            :init a  act_w 3 cols + 4 row pos  1 cols row_h size  S" ..." text 1 tab+
                tabstop ;

    Static OBJ st_scr
        :init a  3 1 15 1 ps 1 tab+ 199 RES text ;

    Edit OBJ ed_scr
        :init a  \  4 1 16 10 ps
                  1 col 4 row pos  tab_w 2 cols - row_h 10 * size
        1 tab+
            ES_MULTILINE WS_TABSTOP OR ES_WANTRETURN OR
            WS_VSCROLL OR ES_AUTOVSCROLL OR ES_AUTOHSCROLL OR vStyle !  ;

    CheckBox OBJ cb_sync
            :init a  2 col 6 row pos  7 cols row_h size 194 RES text
                1 tab+ tabstop ;

    CheckBox OBJ cb_tout
        :init a 2 col 6 row pos  6 cols row_h size  196 RES text 1 tab+ ;
    Edit OBJ ed_tout
        :init a 8 col 6 row pos  2 cols row_h size  1 tab+ tabstop ;

    Static OBJ st_dur
            :init a  1 col 3 row 1+ pos  6 cols row_h size 1 tab+ 197 RES text ;
    Edit OBJ ed_dur
            :init a  5 col 3 row pos  2 cols row_h size 1 tab+ tabstop ;

    Static OBJ st_freq
            :init a  8 col 3 row pos  3 cols row_h size 1 tab+ 198 RES text ;
    Edit OBJ ed_freq
            :init a  11 col 3 row pos  2 cols row_h size 1 tab+ tabstop ;


    M: BeepTest
        cmb_action Current
        3 =
        IF  ed_app GetText ?DUP
            IF PLAY-SOUND ELSE DROP THEN
        ELSE
            ed_dur GetText S>NUM
            ed_freq GetText S>NUM BEEP
        THEN
    ;

    Button OBJ but_test
        :init a 3 17 3 1 ps 209 RES text tabstop 1 tab+
            ['] BeepTest OnClick ! ;

    Static OBJ st_pars
            :init a 5 1 14 1 ps  191 RES text 1 tab+ ;
    Edit   OBJ ed_pars
            :init a 2 col 6 row pos  act_w row_h size tabstop 1 tab+ ;

    Edit   OBJ ed_purge_days
            :init a 2 col 6 row pos  2 cols row_h size  tabstop 1 tab+ ;

    Static OBJ st_dir
            :init a 1 col 7 row pos  14 cols row_h size  192 RES text 1 tab+ ;

    Edit   OBJ ed_dir
            :init a 2 col 8 row pos  act_w row_h size  tabstop 1 tab+ ;

    Static OBJ st_open
            :init a 1 col 10 row 1+ pos  3 cols row_h size   300 RES text 1 tab+ ;

    ComboBox OBJ cmb_open
            :init a 4 col 10 row pos  4 cols row_h 4 * size tabstop 1 tab+ ;


    Static OBJ st_prior
            :init a 9 col 10 row 1+ pos  3 cols row_h size   310 RES text 1 tab+ ;

    ComboBox OBJ cmb_prior
        :init a  12 col  10 row pos  4 cols row_h 5 * size tabstop 1 tab+ ;

    CheckBox OBJ cb_query
            :init a 12 1 8 1 ps
                320 RES text 1 tab+ tabstop ;

    CheckBox OBJ cb_as_svc
            :init a 12 9 7 1 ps
                329 RES text 1 tab+ tabstop ;


    CheckBox OBJ cb_wait
            :init a 14 1 8 1 ps
               321 RES text 1 tab+ tabstop ;

    Static OBJ st_ras_conn
        :init a  3 1 15 1 ps   340 RES text 1 tab+ ;
    ComboBox OBJ cmb_ras_conn
        :init a  4 2 16 5 ps 1 tab+ tabstop ;
    Static OBJ st_ras_user
        :init a  6 1 5 1 ps 1 tab+ 341 RES text ;
    Edit OBJ ed_ras_user
        :init a  6 6 4 1 ps 1 tab+ ;
    Static OBJ st_ras_password
        :init a  6 11 3 1 ps  1 tab+ 342 RES text ;
    Edit OBJ ed_ras_password
        :init a  6 14 4 1 ps 1 tab+ WS_TABSTOP ES_PASSWORD OR vStyle ! ;

    Static OBJ st_ras_attempts
        :init a  8 1 5 1 ps 1 tab+ 344 RES text ;
    Edit OBJ ed_ras_attempts
        :init a  8 6 4 1 ps 1 tab+ ;
    Static OBJ st_ras_pause
        :init a  8 11 3 1 ps  1 tab+ 345 RES text ;
    Edit OBJ ed_ras_pause
        :init a  8 14 4 1 ps 1 tab+ ;
    Static OBJ st_ras_domain
        :init a  10 1 3 1 ps 1 tab+ 343 RES text ;
    Edit OBJ ed_ras_domain
        :init a  10 4 4 1 ps 1 tab+ ;

    Static OBJ st_win_title
        :init a 1 tab+  3 1 4 1 ps 322 RES text ;
    Edit OBJ ed_win_title
        :init a 1 tab+  3 4 act_w 10 / 1 ps ;
    Static OBJ st_win_button
        :init a 1 tab+  5 1 4 1 ps 323 RES text ;
    Edit OBJ ed_win_button
        :init a 1 tab+  5 4 act_w 10 / 1 ps ;

    Static OBJ st_clipboard
        :init a 1 tab+  3 1 3 1 ps 324 RES text ;
    Edit OBJ ed_clipboard
        :init a 1 tab+  3 3 act_w 10 / 1 ps
            \ ES_MULTILINE ES_WANTRETURN OR WS_TABSTOP OR vStyle !
             ;

    CheckBox OBJ cb_power
        :init a 1 tab+  3 1 10 1 ps 325 RES text ;

\ -- action --
: HideAllact
    st_app ?Hide ed_app ?Hide
    st_pars ?Hide ed_pars ?Hide
    st_dir ?Hide ed_dir ?Hide
    but_app ?Hide
    but_test ?Hide
    st_scr ?Hide ed_scr ?Hide
    st_open ?Hide cmb_open ?Hide
    st_prior ?Hide cmb_prior ?Hide
    cb_query ?Hide
    cb_as_svc ?Hide
    cb_sync ?Hide
    cb_wait ?Hide
    cb_tout ?Hide ed_tout ?Hide
    st_dur ?Hide ed_dur ?Hide
    st_freq ?Hide ed_freq ?Hide
    but_test ?Hide
    st_ras_conn ?Hide  cmb_ras_conn ?Hide
    st_ras_user ?Hide  ed_ras_user ?Hide
    st_ras_password ?Hide ed_ras_password ?Hide
    st_ras_domain ?Hide  ed_ras_domain ?Hide
    st_ras_attempts ?Hide ed_ras_attempts ?Hide
    st_ras_pause ?Hide ed_ras_pause ?Hide
    st_win_title ?Hide ed_win_title ?Hide
    st_win_button ?Hide ed_win_button ?Hide
    st_clipboard ?Hide    ed_clipboard ?Hide
    cb_power ?Hide
    ed_purge ?Hide
    ed_purge_days ?Hide
\    cb_profile ?Hide
;

: SetApp
    st_app Show ed_app Show
    190 RES st_app SetText
    st_pars Show ed_pars Show
    191 RES st_pars SetText
    st_dir Show ed_dir Show
    but_app Show
    st_open Show cmb_open Show
    st_prior Show cmb_prior Show
    cb_query Show
    cb_as_svc Show
    cb_wait Show
\    cb_asuser GetCheck IF cb_profile Show THEN
;

: SetScr    st_scr Show  ed_scr Show ;

M: onTimout  cb_tout GetCheck IF ed_tout Enable ELSE ed_tout Disable THEN ;
: SetMsg
    st_app Show ed_app Show
    195 RES st_app SetText
    cb_tout Show ed_tout Show
    onTimout
;

: SetSound
    st_app Show ed_app Show
    193 RES st_app SetText
    but_app Show
    cb_sync Show
    14 col 6 row but_test set_pos
    but_test Show
;

: SetBeep
     st_dur Show  ed_dur Show
     st_freq Show ed_freq Show
     14 col 3 row but_test set_pos
     but_test Show
;

var ras_not_first

M: onRasConn
    PAD cmb_ras_conn GetCurrent RasGetCred 0=
    IF
        >R
        R@ RASCR.szUserName ASCIIZ> ed_ras_user SetText
        R@ RASCR.szPassword ASCIIZ> ed_ras_password SetText
        R> FREE DROP
    ELSE DROP THEN
;
: ras-fill
    ras_not_first @ 0=
    IF
        RasGetEntries ?DUP
        IF OVER >R
            /RASEN * OVER + SWAP
            ?DO I RASEN.szEntryName ASCIIZ> cmb_ras_conn Add /RASEN +LOOP
            R> FREE DROP
        ELSE DROP THEN
        TRUE ras_not_first !
    THEN
;
: SetDial
    st_ras_conn  Show  cmb_ras_conn Show
    st_ras_user   Show ed_ras_user Show
    st_ras_password  Show ed_ras_password Show
\    st_ras_domain  Show  ed_ras_domain Show
    st_ras_attempts  Show ed_ras_attempts Show
    st_ras_pause Show ed_ras_pause Show

    ras-fill
;

: SetHangup
    st_ras_conn  Show  cmb_ras_conn Show
    ras-fill
;

: SetWin
    322 RES st_win_title SetText
    st_win_title Show ed_win_title Show ;
: SetShowW SetWin ;
: SetHideW SetWin ;
: SetCloseW SetWin ;
: SetTermW SetWin ;

: SetClickButton
    SetWin
    st_win_button Show ed_win_button Show
;
: SetInsCB
    st_clipboard Show    ed_clipboard Show
;
: SetShutdown
    cb_power Show
;

: SetReboot
;

: SetPurge
    st_app Show ed_purge Show
    327 RES st_app SetText
    st_pars Show ed_purge_days Show
    328 RES st_pars SetText
    ed_purge SetFocus
;

: SetKill
    SetWin
    339 RES st_win_title SetText
;

OpenDialog POINTER OpenDlg

FILTER: AppFilter
    NAME" Programs"             EXT" *.exe;*.com;*.bat;*.cmd"
    NAME" Text files"           EXT" *.txt"
    NAME" HTML files"           EXT" *.htm;*.html;*.xml"
    NAME" MS Office files"      EXT" *.doc;*.xls;*.mdb;*.mde;*.dot"
    NAME" Music files"          EXT" *.wav;*.mp3"
    NAME" All files (*.*)"      EXT" *.*"
;FILTER

FILTER: WavFilter
    NAME" WAV files"            EXT" *.wav"
    NAME" All files (*.*)"      EXT" *.*"
;FILTER

FILTER: AllFilter
    NAME" All files (*.*)"      EXT" *.*"
;FILTER


: SetAppFilter
    cmb_action Current
    CASE
     0 OF AppFilter ENDOF
     3 OF WavFilter ENDOF
        AllFilter SWAP
    ENDCASE
    OpenDlg SetFilter
;

M: SetAppPath ( --)
    OpenDialog NEW TO OpenDlg
    SetAppFilter
    330 RES DROP OpenDlg lpstrTitle !
    OFN_PATHMUSTEXIST OFN_HIDEREADONLY OR  OpenDlg Flags !
    OpenDlg Execute
    IF
        OpenDlg FileName ed_app SetText
        ed_dir GetText NIP 0=
        IF
            OpenDlg FileName PAD FILE>DIR
            ed_dir SetText
        THEN
        ed_pars SetFocus
    THEN
    OpenDlg SELF DELETE
;

CREATE (set_actions) ' SetApp , ' SetScr , ' SetMsg , ' SetSound ,
        ' SetBeep , ' SetDial , ' SetHangup ,
        ' SetShowW , ' SetHideW , ' SetCloseW , ' SetTermW , ' SetClickButton ,
        ' SetInsCB , ' SetShutdown , ' SetReboot , ' SetPurge , ' SetKill ,
        ' NOOP , ' NOOP ,  ' NOOP ,  ' NOOP ,  ' NOOP ,  ' NOOP ,

M: SetAction
    HideAllact
\    S" " ed_app SetText
\    S" " ed_pars SetText
\    S" " ed_dir SetText
    (set_actions) cmb_action Current CELLS + @ EXECUTE ;


: test-dir-path
    ed_dir GetText ?DUP
    IF EVAL-SUBST EXIST? 0= IF ed_dir GetText 336 ERR-MSG-STR FALSE vCanExit ! THEN
    ELSE DROP THEN ;

\ : yy 2DUP TYPE CR ;
: ExpandPath { a u -- path u1 }
    a u 
    BEGIN S"  " SEARCH WHILE
      OVER a - a SWAP 
\      2DUP S>TEMP MsgBox
      WHICH
\      2DUP MsgBox
      ?DUP IF PAD ZPLACE PAD +ZPLACE PAD ASCIIZ> EXIT ELSE DROP THEN
      1- SWAP 1+ SWAP
    REPEAT
    2DROP
    a u WHICH
;

: test-app-path
    ed_app GetText ?DUP
    IF
        ExpandPath ?DUP
        IF ed_app SetText
        ELSE DROP 
\            ed_app GetText 
\            337 ERR-MSG-STR FALSE vCanExit ! 
        THEN
    ELSE DROP THEN ;

: test-path ( a u -- )
    2DUP EXIST? 0= IF 337  ERR-MSG-STR FALSE vCanExit ! ELSE 2DROP THEN ;

: GenApp
    test-app-path
    test-dir-path
    ed_dir GetText ?DUP
    IF S" StartIn: " adv+ "<>" advnl+ ELSE DROP THEN
    cmb_open Current
    CASE
        0 OF S" ShowNormal" ENDOF
        1 OF S" ShowMaximized" ENDOF
        2 OF S" ShowMinimized" ENDOF
        3 OF S" SWHide" ENDOF
    ENDCASE
    adv+ S"    " adv+
    cmb_prior Current
    CASE
        0 OF S" NormalPriority" ENDOF
        1 OF S" HighPriority" ENDOF
        2 OF S" RealtimePriority" ENDOF
        3 OF S" IdlePriority" ENDOF
    ENDCASE
    advl+
    cb_as_svc GetCheck IF S" AsService" advl+ THEN
\    cb_profile GetCheck IF S" LoadProfile" advl+ THEN
    cb_query GetCheck IF S" Q" adv+ THEN
    S" START-APP" adv+
    cb_wait GetCheck IF S" W" adv+ THEN
    S" : " adv+
    ed_app GetText adv+
    ed_pars GetText ?DUP
        IF S"  " adv+ adv+ ELSE DROP THEN
    advnl+
;

: GenMsg
    cb_tout GetCheck ed_tout GetText NIP 0= 0= AND
    IF
        S" TMSG: " adv+
        ed_app GetText "<>"
        ed_tout GetText advl+
    ELSE
        S" MSG: "  adv+
        ed_app GetText "<>" advnl+
    THEN ;

: GenSound
    ed_app GetText test-path
    S" PLAY-SOUND" adv+
    cb_sync GetCheck  IF S" W" adv+ THEN
    S" : " adv+
    ed_app GetText "<>" advnl+
;

: GenBeep
    S" BEEP: " adv+
    ed_dur  GetText adv+ S"  " adv+
    ed_freq GetText advl+ ;

: GenDial
    ed_ras_user GetText ?DUP IF S" RASUser: " adv+ "<>" advnl+ ELSE DROP THEN
    ed_ras_password GetText ?DUP IF S" RASSecPassword: " adv+ EncP "<>" advnl+ ELSE DROP THEN
    S" DIAL: " adv+ PAD cmb_ras_conn GetCurrent "<>"
    ed_ras_attempts GetText adv+ S"  " adv+
    ed_ras_pause GetText advl+
;

: GenHangup
    PAD cmb_ras_conn GetCurrent DUP
    IF S" HANGUP: " adv+ "<>" ELSE 2DROP S" HANGUP" adv+ THEN advnl+ ;

: win-title+  ed_win_title GetText "<>" ;
: GenShowW   S" WIN-SHOW: " adv+ win-title+ advnl+  ;
: GenHideW   S" WIN-HIDE: " adv+ win-title+ advnl+  ;
: GenCloseW  S" WIN-CLOSE: " adv+ win-title+ advnl+  ;
: GenTermW   S" WIN-TERMINATE: " adv+ win-title+ advnl+  ;
: GenClickButton
       S" WIN-CLICK: " adv+ win-title+
       ed_win_button GetText "<>" advnl+  ;
: GenInsCB S" CLIPBOARD: " adv+ ed_clipboard GetText "<>" advnl+ ;
: GenShutdown
    cb_power GetCheck IF S" POWEROFF" ELSE S" SHUTDOWN" THEN  advl+ ;
: GenReboot S" REBOOT" advl+ ;

: GenScr  ed_scr GetText advl+ ;

: GenPurge S" PURGE-OLD: " adv+ ed_purge GetText "<>"
    ed_purge_days GetText advl+ ;

: GenKill   S" KILL: " adv+ win-title+ advnl+  ;

CREATE (GenAct) ' GenApp , ' GenScr , ' GenMsg , ' GenSound ,
        ' GenBeep , ' GenDial , ' GenHangup ,
        ' GenShowW , ' GenHideW , ' GenCloseW , ' GenTermW , ' GenClickButton ,
        ' GenInsCB , ' GenShutdown , ' GenReboot , ' GenPurge , ' GenKill ,
        ' NOOP , ' NOOP ,  ' NOOP ,  ' NOOP ,  ' NOOP ,  ' NOOP ,

: GenAction
    S" Action:" advl+
    (GenAct) cmb_action Current CELLS + @ EXECUTE
;

