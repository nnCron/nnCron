\ ONLY FORTH DEFINITIONS

0 VALUE VOC_OPTIONS
0 VALUE VOC_ACTIONS
0 VALUE VOC_RULES
0 VALUE CUR_VOC
0 VALUE cnt-rul
0 VALUE cnt-act
0 VALUE cnt-tim
0 VALUE cnt-watch
0 VALUE is-act
0 VALUE act-buf
0 VALUE tim-buf

: toOPTIONS   VOC_OPTIONS TO CUR_VOC ;
: toRULES     VOC_RULES TO CUR_VOC cb_not Unchecked ;
: toACTIONS   VOC_ACTIONS TO CUR_VOC cb_as_svc Unchecked
\              cb_profile Unchecked
              S" " ed_pars SetText ;
: isACT?      CUR_VOC VOC_ACTIONS = ;

: act++ cnt-act 1+ TO cnt-act ;
: rul++ cnt-rul 1+ TO cnt-rul ;
: tim++ cnt-tim 1+ TO cnt-tim ;

: (set_event_par) get-string ed_event_par SetText ;
: set-act cmb_action Current! ;

: any? ( a u -- a u ?) DUP IF OVER C@ [CHAR] * = ELSE FALSE THEN ;
: skip-char DUP IF 1- SWAP 1+ SWAP THEN ;
: peek-char DUP IF OVER C@ ELSE 0 THEN ;
: next-char peek-char >R skip-char R> ;
: set-time-type ( # -- )
    0 rb_once SetState
    rb_once Unchecked
    rb_minutely  Unchecked
    rb_hourly Unchecked
    rb_daily  Unchecked
    rb_monthly Unchecked
    rb_weekly Unchecked
    rb_annually  Unchecked
    rb_event Unchecked
    rb_cron_tim Unchecked
    CASE
      0 OF rb_once Checked ENDOF
      1 OF rb_minutely Checked ENDOF
      2 OF rb_hourly Checked ENDOF
      3 OF rb_daily Checked ENDOF
      4 OF rb_weekly Checked ENDOF
      5 OF rb_monthly Checked ENDOF
      6 OF rb_annually Checked ENDOF
      7 OF rb_event Checked ENDOF
      8 OF rb_cron_tim Checked ENDOF
    ENDCASE
\    SetTimeType
;
: (set_event) ( # -- ) cnt-watch 1+ TO cnt-watch cmb_events Current! 7 set-time-type ;
: >NUM ( a u - u ) 0 0 2SWAP >NUMBER 2DROP D>S ;
: NUM>S ( u -- a u ) S>D <# 0 HOLD #S #> 1- ;
: next-num ( a u -- a1 u1 u2) 0 0 2SWAP >NUMBER 2SWAP D>S ;
: set-weekday ( u -- )
    DUP 8 < OVER 0 > AND
    IF
      1- 1 SWAP LSHIFT week_days @ OR week_days !
    ELSE DROP THEN ;

0 VALUE first
: set-weekdays  ( a u  -- )
    0 week_days !
    TRUE TO first
    BEGIN
        DUP IF next-num ?DUP ELSE FALSE THEN
    WHILE
        >R
        next-char DUP
        [CHAR] , =
        IF DROP R> set-weekday ELSE
        DUP 0=
        IF DROP R>
            first IF 1- cmb_weekdays Current!
                     4 set-time-type
                  ELSE set-weekday THEN
        ELSE
        [CHAR] - =
          IF next-num ?DUP
             IF
                1+ R@ ?DO I set-weekday LOOP
             THEN
          THEN
          RDROP 2DROP EXIT
        THEN THEN
        FALSE TO first
    REPEAT
    2DROP
;
: set-ras-conn
    ras-fill
    get-string EVAL-SUBST cmb_ras_conn GetIndex DUP CB_ERR <>
    IF cmb_ras_conn Current! ELSE DROP THEN
;

: set-win-title get-string ed_win_title SetText ;

: set-rule ( # --) cmb_cond Current! ;
: set-rule-par get-string ed_cond SetText ;
\ SEE set-weekdays KEY DROP


: get-tim
    6 0 DO
        BL WORD COUNT tim-buf +ZPLACE
        I 5 <> IF S"  " tim-buf +ZPLACE THEN
    LOOP LT LTL @ tim-buf +ZPLACE ;

: test-tim ( a u -- a u )
    DUP
    IF
        2DUP S" ," SEARCH NIP NIP IF tim++ EXIT THEN
        2DUP S" -" SEARCH NIP NIP IF tim++ EXIT THEN
    THEN
;

: tm-skip ( u -- ) 0 ?DO NextWord test-tim
                         IF C@ [CHAR] * <> IF 8 set-time-type THEN
                         ELSE DROP THEN LOOP ;
0 VALUE is-del
0 VALUE is-once

: year_corr ( # -- #-1/#)
    <YearField> 0= IF 1- THEN ;

VOCABULARY OPTIONS
ALSO OPTIONS DEFINITIONS
CONTEXT @ TO VOC_OPTIONS
: Action: toACTIONS ;
: Rule:   toRULES ;
: NoLog cb_log Unchecked ;
: NoDel cb_del Unchecked TRUE TO is-del ;
: AsLoggedUser cb_aslogged Checked ;
: LoadProfile cb_profile Checked ;
: NoActive cb_active Unchecked ;
: RunOnce rb_once Checked is-del 0= IF cb_del Checked THEN
    TRUE TO is-once ;
: RunMissed cb_missed Checked ;
: RunMissed: RunMissed get-string ed_missed SetText ;
\ : OnceAHour ;
\ : OnceADay ;
\ : OnceAWeek ;
\ : OnceAMonth ;
: User:     cb_asuser Checked
\    get-string ed_user_name SetText
    get-string SetUserName
;

: Password: get-string ed_password SetText ;
: SecPassword: get-string
    UnP ed_password SetText ;
: Domain: get-string ed_domain SetText ;
: LogonInteractive 0 cmb_logon_type Current! ;
: LogonBatch       1 cmb_logon_type Current! ;
: LogonNetwork     2 cmb_logon_type Current! ;

0 VALUE min
0 VALUE hour
0 VALUE day
0 VALUE mon
0 VALUE wday
0 VALUE year
0 VALUE tt
: cron-time 8 TO tt ;

: "START-TIME" S" START-TIME" ;

: Time:
    tim++
    >IN @ >R
    NextWord "START-TIME" COMPARE 0=
    IF
        "START-TIME" tim-buf +ZPLACE LT LTL @ tim-buf +ZPLACE
        RDROP  0 (set_event)
    ELSE
        R@ >IN ! get-tim
        R> >IN !
        127 week_days !
        NextWord test-tim any?   \ minutes
        IF
           1 TO tt
           skip-char next-char [CHAR] / =
           IF
              min_steps COUNT 2SWAP SEARCH
              IF DROP min_steps 1+ - 2 / ELSE 2DROP 0 cron-time THEN
              cmb_minute_step Current!
           ELSE 2DROP THEN
           tt set-time-type
           5 year_corr tm-skip
        ELSE
           >NUM TO min
           NextWord test-tim any?    \ hours
           IF
             2 TO tt
             skip-char next-char [CHAR] / =
             IF
              hour_steps COUNT 2SWAP SEARCH
              IF DROP hour_steps 1+ - 2 / ELSE 2DROP 0 cron-time THEN
              cmb_hour_step Current!
             ELSE 2DROP THEN
             min NUM>S ed_minutes SetText
             tt set-time-type
             4 year_corr tm-skip
           ELSE
             >NUM TO hour
             hour min 0 tm_start_time Set
             NextWord test-tim any?  \ days
             IF 2DROP
                3 set-time-type \ daily
                1 tm-skip \ month
                NextWord \ week-days
                any? 0= IF set-weekdays ELSE 2DROP THEN
                1 year_corr tm-skip
             ELSE
                2DUP ed_days SetText
                >NUM TO day
                NextWord test-tim any? \ month
                IF 2DROP 5 set-time-type \ monthly
                   NextWord \ week-days
                   any? 0= IF set-weekdays ELSE 2DROP THEN
                   1 year_corr tm-skip
                ELSE
                   >NUM TO mon
                   NextWord \ week-days
                   any? 0= IF set-weekdays ELSE 2DROP THEN
                   <YearField>
                   IF
                       NextWord test-tim any? \ year
                       IF
                          2DROP 6 set-time-type \ annually
                          2000 mon day 1 tm_start_date Set
                       ELSE
                          >NUM TO year
                          0 set-time-type \ once
                          year mon day 1 tm_start_date Set
                       THEN
                   ELSE
                      is-once
                      IF
                          0 set-time-type \ once
                          year mon day 1 tm_start_date Set
                      ELSE
                          6 set-time-type \ annually
                          2000 mon day 1 tm_start_date Set
                      THEN
                   THEN
                THEN
             THEN
           THEN
        THEN
    THEN
;

: WatchDir:         1 (set_event) (set_event_par) ;
: WatchFile:        2 (set_event) (set_event_par) ;
: WatchConnect      3 (set_event) ;
: WatchDisconnect   4 (set_event) ;
: WatchClipboard:   5 (set_event) (set_event_par) ;
: WatchWinCreate:   6 (set_event) (set_event_par) ;
: WatchWinActivate: 7 (set_event) (set_event_par) ;
: WatchWinDestroy:  8 (set_event) (set_event_par) ;
: WatchWindow:      9 (set_event) (set_event_par) ;
: WatchDriveInsert: 10 (set_event) (set_event_par) ;
: WatchDriveRemove: 11 (set_event) (set_event_par) ;
: WatchProc:        12 (set_event) (set_event_par) ;
: WatchProcStop:    13 (set_event) (set_event_par) ;
: WatchLogoff       14 (set_event) ;
: WatchShutdown     15 (set_event) ;
: WatchHotKey:      16 (set_event) (set_event_par) ;
: WatchLogon:       17 (set_event) (set_event_par) ;
: WatchLogoff:      18 (set_event) (set_event_par) ;


PREVIOUS DEFINITIONS

VOCABULARY RULES
ALSO RULES DEFINITIONS
CONTEXT @ TO VOC_RULES
: Action: toACTIONS ;

: FILE-EXIST: rul++  1 set-rule set-rule-par ;
: WIN-EXIST:  rul++  2 set-rule set-rule-par ;
: ONLINE:     rul++  3 set-rule set-rule-par ;
: FILE-EMPTY: rul++  4 set-rule set-rule-par ;
: HOST-EXIST: rul++  5 set-rule set-rule-par ;
: QUERY:      rul++  6 set-rule set-rule-par ;
: PROC-EXIST: rul++  7 set-rule set-rule-par ;
: POP3-CHECK: rul++  8 set-rule set-rule-par
    get-string ed_pop3_user SetText
    get-string ed_pop3_pass SetText ;
: NOT         cb_not Checked ;

PREVIOUS DEFINITIONS

VOCABULARY ACTIONS
ALSO ACTIONS DEFINITIONS
CONTEXT @ TO VOC_ACTIONS

: START-APP: act++ BL SKIP 1 PARSE ed_app SetText
    cb_wait Unchecked cb_query Unchecked  0 set-act ;
: START-APPW: START-APP: cb_wait Checked ;
: QSTART-APP: START-APP: cb_query Checked ;
: QSTART-APPW: START-APPW: cb_query Checked ;

: StartIn: get-string ed_dir SetText ;
: ShowNormal 0 cmb_open Current! ;
: ShowMaximized 1 cmb_open Current! ;
: ShowMinimized 2 cmb_open Current! ;
: SWHide 3 cmb_open Current! ;

: NormalPriority 0 cmb_prior Current! ;
: HighPriority 1 cmb_prior Current! ;
: RealtimePriority 2 cmb_prior Current! ;
: IdlePriority 3 cmb_prior Current! ;

: AsService cb_as_svc Checked ;
: LoadProfile cb_profile Checked ;

: MSG: act++ get-string ed_app SetText 2 set-act cb_tout Unchecked ;
: TMSG: MSG: get-string ed_tout SetText cb_tout Checked ;
: PLAY-SOUND: act++ get-string ed_app SetText cb_sync Unchecked 3 set-act ;
: PLAY-SOUNDW: PLAY-SOUND: cb_sync Checked ;
: BEEP: act++ get-string ed_dur SetText get-string ed_freq SetText 4 set-act ;

: RASUser: get-string ed_ras_user SetText ;
: RASPassword: get-string ed_ras_password SetText ;
: RASSecPassword: get-string DecP ed_ras_password SetText ;
: DIAL: act++
    set-ras-conn
    get-string ed_ras_attempts SetText
    get-string ed_ras_pause SetText
    5 set-act ;
: HANGUP:   act++ set-ras-conn    6 set-act ;
: HANGUP    act++ set-ras-conn    6 set-act ;
: WIN-SHOW: act++ set-win-title   7 set-act ;
: WIN-HIDE: act++ set-win-title   8 set-act ;
: WIN-CLOSE: act++ set-win-title  9 set-act ;
: WIN-TERMINATE: act++ set-win-title   10 set-act ;
: WIN-CLICK: act++ set-win-title get-string ed_win_button SetText 11 set-act ;
: CLIPBOARD: act++ get-string ed_clipboard SetText 12 set-act ;
: SHUTDOWN act++ 13 set-act cb_power Unchecked ;
: POWEROFF SHUTDOWN cb_power Checked ;
: REBOOT act++ 14 set-act ;
: PURGE-OLD: act++ 15 set-act
    get-string ed_purge SetText
    get-string ed_purge_days SetText ;
: KILL: act++ 16 set-act set-win-title ;
PREVIOUS DEFINITIONS

: parse-line ( a u -- ?)
    <TIB STATE 0!
    BEGIN
        NextWord ?DUP
        IF
            CUR_VOC SEARCH-WORDLIST ?DUP 0=
            IF TIB> FALSE EXIT THEN
        ELSE DROP FALSE THEN
    WHILE
        EXECUTE
    REPEAT
    TIB>
    TRUE
;

: act+ ( a u -- )
    act-buf +ZPLACE LT LTL @ act-buf +ZPLACE ;

: del-last-crlf ( a u -- a u1)
    BEGIN DUP WHILE
      DUP 1 >
      IF 2DUP + 2 - W@ LT W@ =
         IF 2 - ELSE EXIT THEN
      ELSE EXIT THEN
    REPEAT
;
: adv-init
    cb_missed Unchecked
    cb_aslogged Unchecked
;
: adv-parse ( -- )
    adv-init
    FALSE TO is-del
    FALSE TO is-once
    1024 ALLOCATE THROW TO tim-buf tim-buf 0!
    0 TO cnt-rul 0 TO cnt-act 0 TO cnt-tim
    0 TO cnt-watch
    0 TO is-act
    tm_buf 0!
    FALSE is-adv !
    toOPTIONS
    act-buf 0= IF 10240 ALLOCATE THROW TO act-buf THEN
    0 act-buf !
\    ." Lines=" ed_adv LineCount . CR
    1 set-time-type
    0 cmb_minute_step Current!
\    S" 1" ed_minutes SetText
    ed_adv LineCount 0
    ?DO
        PAD 1024 I ed_adv GetLine \ 2DUP TYPE CR
        isACT? IF 2DUP act+ THEN
        parse-line 0=
        IF TRUE is-adv !
           isACT? 0= IF LEAVE THEN
        THEN
    LOOP
    is-adv @ cnt-act 1 > OR
    IF
        isACT?
        IF
            act-buf ASCIIZ> del-last-crlf ed_scr SetText
\            act-buf ASCIIZ> ed_scr SetText
            1 set-act
            is-adv 0!
        THEN
    THEN
    tim-buf ASCIIZ> ed_cron_tim SetText
    tim-buf FREE DROP
    cnt-tim 1 > IF 8 set-time-type THEN
    is-adv @ 0= IF cnt-rul 1 > cnt-watch 1 > OR is-adv ! THEN
    cb_asuser GetCheck IF set-user-list THEN
;
