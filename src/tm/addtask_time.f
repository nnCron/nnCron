: c1st 1 col ;
: c2nd 8 col ;
: c3rd 15 col ;
: tw 7 cols ;
    RadioButton OBJ rb_once
        :init a v  c1st 1 row pos  tw row_h size  120 RES text
            WS_GROUP WS_TABSTOP OR vStyle !  0 tab+ ;
    RadioButton OBJ rb_minutely
        :init a v  c2nd 1 row pos  tw row_h size  121 RES text  0 tab+  ;
    RadioButton OBJ rb_hourly
        :init a v  c3rd 1 row pos  tw row_h size  122 RES text  0 tab+ ;
    RadioButton OBJ rb_daily
        :init a v  c1st 2 row pos  tw row_h size  123 RES text  0 tab+ ;
    RadioButton OBJ rb_weekly
        :init a v  c2nd 2 row pos  tw row_h size  124 RES text  0 tab+ ;
    RadioButton OBJ rb_monthly
        :init a v  c3rd 2 row pos tw row_h size  125 RES text  0 tab+ ;
    RadioButton OBJ rb_annually
        :init a v  c1st 3 row pos  tw row_h size  126 RES text  0 tab+ ;
    RadioButton OBJ rb_event
        :init a v  c2nd 3 row pos  tw row_h size  127 RES text  0 tab+ ;
    RadioButton OBJ rb_cron_tim
        :init a v  c3rd 3 row pos tw row_h size  128 RES text  0 tab+ ;

    Static OBJ st_cron_tim
        :init a  5 1 22 1 ps   <YearField> IF 183 ELSE 185 THEN RES text 0 tab+ ;
    Edit OBJ ed_cron_tim
        :init a  6 1 20 2 ps   0 tab+
            ES_MULTILINE ES_AUTOVSCROLL OR ES_AUTOHSCROLL OR WS_VSCROLL OR
            WS_TABSTOP OR ES_WANTRETURN OR vStyle ! ;

    Static OBJ st_start_time
        :init a    1 col 5 row 1+ pos  2 cols row_h size  130 RES text  0 tab+ ;
    TimePicker OBJ tm_start_time
        :init a    3 col 5 row pos  3 cols row_h size
            tabstop  0 tab+ ;

    Static OBJ st_start_time_post
        :init a    7 col 5 row 1+ pos  2 cols row_h size  130 RES text  0 tab+ ;

    Static OBJ st_start_date
        :init a    7 col 5 row 1+ pos  2 cols row_h size  131 RES text  0 tab+ ;

    DatePicker OBJ tm_start_date
        :init a    10 col 5 row pos  7 cols row_h size
            tabstop  0 tab+ ;

    Static OBJ st_minutes
        :init a   1 col 5 row 1+ pos  2 cols row_h size  136 RES text  0 tab+ ;
    Edit OBJ ed_minutes
        :init a   3 col 5 row pos   3 cols 2/ row_h size  tabstop  0 tab+ ;
    Static OBJ st_minutes_post
        :init a   5 col 5 row 1+ pos  5 cols row_h size  135 RES text  0 tab+ ;

    Static OBJ st_minute_step
        :init a   1 col 5 row 1+ pos  3 cols row_h size  132 RES text  0 tab+ ;
    ComboBox OBJ cmb_minute_step
        :init a   4 col 9 10 */ 5 row pos  2 cols row_h 10 * size 0 tab+
            tabstop 0 tab+ ;
    Static OBJ st_minute_step_post
        :init a   6 col 5 row 1+ pos  2 cols row_h size  139 RES text  0 tab+ ;

    ComboBox OBJ cmb_weekdays
        :init a   10 cols 5 row pos  6 cols row_h 7 * size 0 tab+ tabstop ;


    ComboBox OBJ cmb_hour_step
        :init a 10 col 5 row pos  2 cols row_h 10 * size tabstop 0 tab+ ;
    Static OBJ st_hour_step_post
        :init a 12 col 5 row 1+ pos  2 cols row_h size 0 tab+ 138 RES text ;


    Edit OBJ ed_hours
        :init a   2 col 5 row pos   2 cols row_h size
            tabstop  0 tab+ ;

    Edit OBJ ed_days
        :init a   10 col 5 row pos   3 cols 2/ row_h size  tabstop  0 tab+ ;
    Static OBJ st_days_post
        :init a   12 col 5 row 1+ pos   4 cols row_h size  0 tab+ 134 RES text ;

    Static OBJ st_events
        :init a   1 col 5 row 1+ pos  2 cols row_h size 0 tab+ 158 RES text ;
    ComboBox OBJ cmb_events
        :init a   3 col 5 row pos  10 cols row_h events * size 0 tab+ tabstop ;

    Static OBJ st_event_par
        :init a   1 col 7 row 1+ pos  6 cols row_h size 0 tab+ ;

    Edit OBJ ed_event_par
        :init a   7 col 7 row pos  13 cols row_h size 0 tab+ tabstop ;

    Button OBJ but_event
        :init a   20 col 7 row pos  1 cols row_h size  0 tab+ tabstop
            S" ..." text ;

    WeekDays POINTER wd
    M: on_weekdays
        WeekDays NEW TO wd
        this wd Create
        week_days @ wd SetWeekDays
        wd ShowModal DROP
        wd Run
        wd GetWeekDays week_days !
        wd SELF DELETE
    ;

    Button OBJ but_weekdays
        :init a   7 col 5 row 1- pos  6 cols but_h size   137 RES text
            ['] on_weekdays OnClick !
             tabstop this 0 tab+ ;

    CheckBox OBJ cb_active
        :init a v  1 col 9 row pos  12 cols row_h size  142 RES text
            tabstop this 0 tab+ ;

    CheckBox OBJ cb_missed
        :init a v  1 col 10 row 1+ pos  9 cols 5 + row_h size  143 RES text  0 tab+ ;

    Edit OBJ ed_missed
        :init a v  3 col 7 - 2 + 11 row 1+ pos  2 cols row_h size 0 tab+ ;

    Static OBJ st_missed
        :init a v  5 col 5 - 11 row 2+ pos  3 cols 2 + row_h size 144 RES text 0 tab+ ;


    CheckBox OBJ cb_del
        :init a v  14 col 9 row pos  10 cols row_h size  141 RES text
            tabstop this 0 tab+ ;

    CheckBox OBJ cb_log
        :init a v  14 col 10 row pos 9 cols row_h size  140 RES text
            tabstop this 0 tab+ ;


M: OnCbMissed
    cb_missed GetCheck
    IF
        ed_missed Enable
    ELSE
        ed_missed Disable
    THEN
;

FILTER: AllFilter
    NAME" All files (*.*)"      EXT" *.*"
;FILTER

OpenDialog POINTER OpenDlg1
M: on_but_event
    OpenDialog NEW TO OpenDlg1
    AllFilter OpenDlg1 SetFilter
    331 RES DROP OpenDlg1 lpstrTitle !
    OFN_PATHMUSTEXIST OFN_HIDEREADONLY OR  OpenDlg1 Flags !
    OpenDlg1 Execute
    IF
        OpenDlg1 FileName ed_event_par SetText
        ed_event_par SetFocus
    THEN
    OpenDlg1 SELF DELETE
;

: TimeType
    rb_once GetCheck IF 1 EXIT THEN
    rb_minutely GetCheck IF 2 EXIT THEN
    rb_hourly GetCheck IF 3 EXIT THEN
    rb_daily GetCheck IF 4 EXIT THEN
    rb_weekly GetCheck IF 5 EXIT THEN
    rb_monthly GetCheck IF 6 EXIT THEN
    rb_annually GetCheck IF 7 EXIT THEN
    rb_event GetCheck IF 8 EXIT THEN
    rb_cron_tim GetCheck IF 9 EXIT THEN
    10
;

: on_startup ;
: show_event_par
    TimeType 8 =
    IF
        st_event_par Show
        ed_event_par Show
        cmb_events Current 2 =
        IF but_event Show
        ELSE but_event Hide THEN
    ELSE
        st_event_par Hide
        ed_event_par Hide
        but_event Hide
    THEN
;

: on_dir
    show_event_par
    180 RES st_event_par SetText
;
: on_file
    show_event_par
    181 RES st_event_par SetText
;
: on_conn ;
: on_disconn ;
: on_clip
    show_event_par
    182 RES st_event_par SetText
;
: on_win
    show_event_par
    184 RES st_event_par SetText
    ed_event_par GetText NIP 0=
    IF S" *" ed_event_par SetText THEN
;
: on_drv
    show_event_par
    186 RES st_event_par SetText
;

: on_proc
    show_event_par
    187 RES st_event_par SetText
;

: on_hotkey
    show_event_par
    188 RES st_event_par SetText
;

: on_logoff ;
: on_shutdown ;

: on_logonUser
    show_event_par
    189 RES st_event_par SetText
;
: on_logoffUser on_logonUser ;

CREATE (events) ' on_startup , ' on_dir , ' on_file , ' on_conn ,
        ' on_disconn ,  ' on_clip ,
        ' on_win , ' on_win , ' on_win , ' on_win ,
        ' on_drv , ' on_drv ,  ' on_proc , ' on_proc ,
        ' on_logoff , ' on_shutdown , ' on_hotkey ,
        ' on_logonUser , ' on_logoffUser ,
M: SetEvent
    st_event_par Hide
    ed_event_par Hide
    but_event Hide
    (events) cmb_events Current CELLS + @ EXECUTE
;

M: HideAlltm
    st_start_time Hide tm_start_time Hide
    st_start_date Hide tm_start_date Hide
    st_minutes Hide ed_minutes Hide st_minutes_post Hide
    st_start_time_post Hide
    cmb_weekdays Hide
    ed_hours Hide
    ed_days Hide
    st_days_post Hide
\    cb_del Disable
    but_weekdays Hide
    st_events Hide       cmb_events Hide
    st_event_par Hide    ed_event_par Hide  but_event Hide
    st_minute_step Hide  cmb_minute_step Hide    st_minute_step_post Hide
    cmb_hour_step Hide   st_hour_step_post Hide
    st_cron_tim Hide ed_cron_tim Hide
\    cb_missed Hide
;

: SetTime1 \ once
    st_start_time Show tm_start_time Show
    st_start_date Show tm_start_date Show
    cb_del Enable
    S" d' 'MMMM' 'yyy" tm_start_date SetFormat
    cb_missed Enable
    OnCbMissed
;

: SetTime2 \ minutely
    st_minute_step Show    cmb_minute_step Show    st_minute_step_post Show
    cb_del Disable
    cb_missed Enable
    OnCbMissed
;

: SetTime3 \ hourly
    st_minutes Show ed_minutes Show st_minutes_post Show
    cmb_hour_step Show st_hour_step_post Show
    cb_del Disable
    cb_missed Enable
    OnCbMissed
;

: SetTime4 \ daily
    st_start_time Show tm_start_time Show
    but_weekdays Show
    cb_del Disable
    cb_missed Enable
    OnCbMissed
;
: SetTime5 \ weekly
    st_start_time Show tm_start_time Show
    st_start_time_post Show
    132 RES st_start_time_post SetText
    cmb_weekdays Show
    cb_del Disable
    cb_missed Enable
    OnCbMissed
;
: SetTime6 \ monthly
    st_start_time Show tm_start_time Show
    st_start_time_post Show
    133 RES st_start_time_post SetText
    ed_days Show
    st_days_post Show
    cb_del Disable
    cb_missed Enable
    OnCbMissed
;
: SetTime7 \ annually
    st_start_time Show tm_start_time Show
    st_start_date Show tm_start_date Show
    S" d' 'MMMM'" tm_start_date SetFormat
    cb_del Disable
    cb_missed Enable
    OnCbMissed
;


: SetTime8 \ event
    st_events Show
    cmb_events Show
    SetEvent
    cb_del Disable
    cb_missed Disable
    ed_missed Disable
;

: SetTime9
    st_cron_tim Show ed_cron_tim Show
    cb_missed Enable
;

: SetTime0 ;

CREATE (SetTimeType) ' NOOP , ' SetTime1 ,  ' SetTime2 ,  ' SetTime3 ,
    ' SetTime4 ,  ' SetTime5 ,   ' SetTime6 ,   ' SetTime7 , ' SetTime8 ,
    ' SetTime9 ,  ' SetTime0 ,

M: SetTimeType
    HideAlltm
\    cb_del Disable
    (SetTimeType) TimeType CELLS + @ EXECUTE
;

WITH Edit
: test_num_change { lo hi ed -- }
    num_chg @ IF EXIT THEN   TRUE num_chg !
    ed => GetText ?DUP
    IF
        ed => GetPos >R
        0 0 2SWAP >NUMBER 2DROP D>S
        lo MAX hi MIN S>D <# #S #> ed => SetText
        R> ed => SetPos
    ELSE
        DROP
    THEN
    num_chg 0!
;

ENDWITH

M: on_minutes_change  0 59 ed_minutes SELF test_num_change ;
M: on_hours_change 0 23 ed_hours SELF test_num_change ;
M: on_days_change 1 31 ed_days SELF test_num_change ;



CREATE min_steps C" 1 2 3 4 5 6 1012152030" ",
CREATE hour_steps C" 1 2 3 4 6 8 12" ",

CREATE tm_buf 256 ALLOT

: tme S" Time: " tm_buf +PLACE ;
: tmnl LT LTL @ tm_buf +PLACE ;
: tml+ ( a u --) tme tm_buf +PLACE tmnl ;
: tme+ tm_buf +PLACE tm_buf +PLACE0 ;

: 2>tme SWAP S>D <#  BL HOLD #S BL HOLD 2DROP S>D #S #> tme+ ;
: m&h  tm_start_time Get DROP 2>tme ;
: d&m  tm_start_date Get DROP ROT DROP 2>tme ;
: year <YearField> IF tm_start_date Get 2DROP DROP S>D <# #S #> tme+ THEN ;
: *year <YearField> IF S"  *" tme+ THEN ;

: wdays
    week_days @ 127 = week_days @ 0= OR
                      IF S" *"   ELSE
    week_days @ 63  = IF S" 1-6" ELSE
    week_days @ 31  = IF S" 1-5" ELSE
        <#
            week_days @
            1 7 DO DUP 64 AND
                   IF  I S>D #S 2DROP
                      DUP 63 AND IF [CHAR] ,  HOLD THEN
                   THEN
                   1 LSHIFT
                -1 +LOOP
           0
        #> THEN THEN THEN
    tme+
;

: GenOnce tme m&h d&m S" * " tme+ year ;
: GenMinutely
    cmb_minute_step Current
    IF
        tme
        S" *" tme+
        cmb_minute_step Current ?DUP
        IF
            S" /" tme+
            2* min_steps + 1+
            2 tme+
        THEN
        S"  * * * *" tme+
        *year
    THEN ;

: GenHourly tme
    ed_minutes GetText tme+  S"  *" tme+
    cmb_hour_step Current ?DUP
    IF
        S" /" tme+
        2* hour_steps + 1+ 2 tme+
    THEN
    S"  * * *" tme+
    *year
    ;

: GenDaily tme m&h S" * * " tme+ wdays *year ;
: GenWeekly tme m&h S" * * " tme+
    cmb_weekdays Current 1+ S>D <# #S #> tme+
    *year
    ;

: GenMonthly tme m&h ed_days GetText tme+ S"  * *" tme+ *year ;
: GenAnnualy tme m&h d&m S" *" tme+ *year ;

: EvStartup tme S" START-TIME" tme+ ;
CREATE (qt) 1 C, CHAR " C, 0 C,
: evp (qt) COUNT tme+ ed_event_par GetText tme+ (qt) COUNT tme+
    ed_event_par GetText NIP 0=
    IF 332 ERR-MSG THEN
;
: EvDir S" WatchDir: " tme+ evp ;
: EvFile S" WatchFile: " tme+ evp ;
: EvConn S" WatchConnect" tme+ ;
: EvDisconn S" WatchDisconnect" tme+ ;
: EvClipboard S" WatchClipboard: " tme+ evp ;
: EvWinCr  S" WatchWinCreate: " tme+ evp ;
: EvWinAc  S" WatchWinActivate: " tme+ evp ;
: EvWinDe  S" WatchWinDestroy: " tme+ evp ;
: EvWindow S" WatchWindow: " tme+ evp ;
: EvDrvIns S" WatchDriveInsert: " tme+ evp ;
: EvDrvRm  S" WatchDriveRemove: " tme+ evp ;
: EvProc   S" WatchProc: " tme+ evp ;
: EvProcStop  S" WatchProcStop: " tme+ evp ;
: EvLogoff S" WatchLogoff" tme+ ;
: EvShutdown S" WatchShutdown" tme+ ;
: EvHotKey  S" WatchHotKey: " tme+ evp ;
: EvLogonU S" WatchLogon: " tme+ evp ;
: EvLogoffU S" WatchLogoff: " tme+ evp ;

CREATE (GenEvent) ' EvStartup , ' EvDir , ' EvFile , ' EvConn , ' EvDisconn ,
                ' EvClipboard ,
                ' EvWinCr , ' EvWinAc , ' EvWinDe , ' EvWindow ,
                ' EvDrvIns , ' EvDrvRm , ' EvProc ,  ' EvProcStop ,
                ' EvLogoff , ' EvShutdown , ' EvHotKey ,
                ' EvLogonU , ' EvLogoffU ,

: GenEvent
    tm_buf 0!
    (GenEvent) cmb_events Current CELLS + @ EXECUTE
;

: GenCron
    ed_cron_tim LineCount 0
    ?DO
        PAD 1024 I ed_cron_tim GetLine ?DUP
        IF tml+
        ELSE DROP THEN
    LOOP
    tm_buf C@ ?DUP IF 2- tm_buf C! THEN
;

CREATE (GenTime) ' NOOP , ' GenOnce , ' GenMinutely , ' GenHourly ,
    ' GenDaily , ' GenWeekly , ' GenMonthly , ' GenAnnualy , ' GenEvent ,
    ' GenCron ,

