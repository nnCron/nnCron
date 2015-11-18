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
: "INIWR" qt INIWR INIWR qt INIWR ; \ "
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

: ?ADD-OPT { xt -- }
    INI-LIST
    BEGIN @ ?DUP WHILE
        DUP NodeValue @ xt =
        IF DROP EXIT THEN
    REPEAT
    xt ADD-OPT
;

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

VARIABLE include-written
: INCLUDE-WR
    include-written @ 0=
    IF
        lb_plugins Length 0
        ?DO
            S" INCLUDE " INIWR
            PAD I lb_plugins Get "INIWR" INICR
        LOOP
        include-written ON
    THEN
;


: LOG-WR S" Cronlog: " INIWR ed_log GetText "INIWR" INICR ;
: LOG-TIME-WR S" LogTimeFormat: " INIWR ed_log_time GetText "INIWR" INICR ;
: EDITOR-WR S" Editor: " INIWR ed_editor GetText "INIWR" INICR ;
: HELP-FILE-WR S" HelpFile: " INIWR ed_helpfile GetText "INIWR" INICR ;
: BACKUP-WR S" BackupPath: " INIWR ed_backup GetText "INIWR" INICR ;
: ONOFF-WR IF S" ON" ELSE S" OFF" THEN INIWR INICR ;
: YEAR-WR S" YearField " INIWR  cb_year GetCheck ONOFF-WR ;
: SYS-TRAY-WR S" SysTrayIcon " INIWR cb_systray GetCheck ONOFF-WR ;
: SHOW-ERROR-WR S" ShowErrorMsg " INIWR cb_showerror GetCheck ONOFF-WR ;
: ADMIN-ONLY-WR S" IconForAdminsOnly " INIWR cb_adminonly GetCheck ONOFF-WR ;
: itOPTIONS-WR S" ItemOptions " INIWR cb_options GetCheck ONOFF-WR ;
: itEXIT-WR S" ItemExit " INIWR cb_exit GetCheck ONOFF-WR ;
: itCONSOLE-WR S" ItemConsole " INIWR cb_console GetCheck ONOFF-WR ;
: itRELOAD-WR S" ItemReload " INIWR cb_reload GetCheck ONOFF-WR ;

: OPEN-CONSOLE-WR S" Console " INIWR cb_start_console GetCheck ONOFF-WR ;

: RunAsDefaultUser-WR   S" RunAsDefaultUser " INIWR cb_dasuser GetCheck ONOFF-WR ;
: DefaultLoadProfile-WR S" DefaultLoadProfile " INIWR cb_dloadprofile GetCheck ONOFF-WR ;
: DefaultUser-WR    S" DefaultUser: " INIWR ed_duser GetText "INIWR" INICR ;
: DefaultPassword-WR S" DefaultPassword: " INIWR ed_dpass GetText EnP "INIWR" INICR ;
: DefaultDomain-WR S" DefaultDomain: " INIWR ed_ddomain GetText "INIWR" INICR ;

: GUIAsUser-WR   S" GUIAsUser " INIWR cb_gasuser GetCheck ONOFF-WR ;
: GUILoadProfile-WR S" GUILoadProfile " INIWR cb_gloadprofile GetCheck ONOFF-WR ;
: GUIUser-WR    S" GUIUser: " INIWR ed_guser GetText "INIWR" INICR ;
: GUIPassword-WR S" GUIPassword: " INIWR ed_gpass GetText EnP "INIWR" INICR ;
: GUIDomain-WR S" GUIDomain: " INIWR ed_gdomain GetText "INIWR" INICR ;

: Guard-WR S" Guard " INIWR cb_guard GetCheck ONOFF-WR ;

: TrayIconDoubleClick-WR 
    S" TrayIconDoubleClick: " INIWR 
    cmb_tray_db GetText INIWR INICR ;
: TrayIconRightButton-WR 
    S" TrayIconRightButton: " INIWR 
    cmb_tray_rb GetText INIWR INICR ;



: LANG-WR S" Language: " INIWR PAD cmb_lang GetCurrent INIWR INICR ;

\ : set-lang
\     S" res\" PAD PLACE
\     NextWord 2DUP S>ZALLOC TO LANGUAGE
\         PAD +PLACE
\     S" .txt" PAD +PLACE
\     PAD COUNT RES!
\ ;

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

: getaz get-string S>ZALLOC ;

: ON? NextWord S" ON" COMPARE 0= ;

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
: Cronlog: getaz TO LOG-FILE ['] LOG-WR ADD-OPT ;
: LogTimeFormat: getaz TO LOG-TIME-FORMAT
        ['] LOG-TIME-WR ADD-OPT ;
: Language: getaz DUP TO LANGUAGE ASCIIZ> set-lang ['] LANG-WR ADD-OPT ;
: YearField ON? TO <YearField> ['] YEAR-WR ADD-OPT ;
: SysTrayIcon ON? TO SYS-TRAY ['] SYS-TRAY-WR ADD-OPT ;
: ShowErrorMsg ON? TO SHOW-ERROR ['] SHOW-ERROR-WR ADD-OPT ;
: IconForAdminsOnly ON? TO ADMIN-ONLY ['] ADMIN-ONLY-WR ADD-OPT ;
: Console ON? TO OPEN-CONSOLE ['] OPEN-CONSOLE-WR ADD-OPT ;
: ItemConsole ON? TO itCONSOLE ['] itCONSOLE-WR ADD-OPT ;
: ItemExit    ON? TO itEXIT ['] itEXIT-WR ADD-OPT ;
: ItemOptions ON? TO itOPTIONS ['] itOPTIONS-WR ADD-OPT ;
: ItemReload  ON? TO itRELOAD ['] itRELOAD-WR ADD-OPT ;

: BackupPath: getaz BACKUP-PATH ! ['] BACKUP-WR ADD-OPT ;
: Editor: getaz TO EDITOR ['] EDITOR-WR ADD-OPT ;
: HelpFile: getaz TO HELP-FILE ['] HELP-FILE-WR ADD-OPT ;

: RunAsDefaultUser      ON? TO vRunAsDefaultUser    ['] RunAsDefaultUser-WR ADD-OPT ;
: DefaultLoadProfile    ON? TO vDefaultLoadProfile  ['] DefaultLoadProfile-WR ADD-OPT ;
: DefaultUser:      getaz TO vDefaultUser           ['] DefaultUser-WR ADD-OPT ;
: DefaultPassword:  getaz TO vDefaultPassword       ['] DefaultPassword-WR ADD-OPT ;
: DefaultDomain:    getaz TO vDefaultDomain         ['] DefaultDomain-WR ADD-OPT ;

: GUIAsUser      ON? TO vGUIAsUser      ['] GUIAsUser-WR ADD-OPT ;
: GUILoadProfile ON? TO vGUILoadProfile ['] GUILoadProfile-WR ADD-OPT ;
: GUIUser:      getaz TO vGUIUser       ['] GUIUser-WR ADD-OPT ;        
: GUIPassword:  getaz TO vGUIPassword   ['] GUIPassword-WR ADD-OPT ;
: GUIDomain:    getaz TO vGUIDomain     ['] GUIDomain-WR ADD-OPT ;    

: TrayIconDoubleClick: getaz TO vTrayIconDoubleClick ['] TrayIconDoubleClick-WR ADD-OPT ;
: TrayIconRightButton: getaz TO vTrayIconRightButton ['] TrayIconRightButton-WR ADD-OPT ;


: Guard ON? TO vGuard      ['] Guard-WR ADD-OPT ;

: INCLUDE getaz PLUGIN-LIST AppendNode ['] INCLUDE-WR ADD-OPT ;

PREVIOUS DEFINITIONS

: PRE-INI   EXEC-NEXT   1 PARSE 2DROP ;
: >file
    tm.out R/W CREATE-FILE-SHARED
    IF DROP  ELSE DUP TO CRON-OUT TO H-STDOUT THEN
;

: load-ini
    CronINI EXIST? 0= IF 0 S" nncron.exe -ini?" StartAppWait DROP THEN
    POSTPONE [
    ['] PRE-INI TO <PRE>
    CronINI ['] INCLUDED CATCH ?DUP
    IF TO IO-ERR 
       S" %CronINI%" 604 ERR-MSG-STR 2DROP BYE 
    THEN
    BUF2LIST
    ['] NOOP TO <PRE>
;

: set-ini-file
  GetCommandLineA ASCIIZ>
  TIB SWAP C/L MIN DUP #TIB ! MOVE >IN 0!
  TIB C@ [CHAR] " = IF [CHAR] " ELSE BL THEN
  WORD DROP \ טלÿ ןנמדנאללû
  BEGIN get-string ?DUP WHILE
    2DUP S" -ini" COMPARE 0=
    IF -ini EXIT THEN
  REPEAT
  DROP
;

: TM-INI
    >file

\    AT-PROCESS-STARTING
\    AT-THREAD-STARTING
    set-ini-file
    load-ini
    load-tm-ini
    S" nnCron. Task Maker V %SVERSION%" EVAL-SUBST TYPE CR
    S" Copyright (C) 2001-%YYYY% nnSoft. Email: nemtsev@nncron.ru"  EVAL-SUBST TYPE CR
;

' TM-INI ' SPF-INI JMP

: SAVE-NODE ( node --)
    NodeValue DUP TO CUR-INI-NODE
    ini-xt @ EXECUTE ;

: add-absence 
    ['] CRONTAB-WR ?ADD-OPT
    ['] INCLUDE-WR ?ADD-OPT
    ['] OMODE-WR ?ADD-OPT
    ['] PRIOR-WR ?ADD-OPT
    ['] CRONTAB-WR ?ADD-OPT
    ['] LOG-WR ?ADD-OPT
    ['] LOG-TIME-WR ?ADD-OPT
    ['] LANG-WR ?ADD-OPT
    ['] YEAR-WR ?ADD-OPT
    ['] SYS-TRAY-WR ?ADD-OPT
    ['] SHOW-ERROR-WR ?ADD-OPT
    ['] ADMIN-ONLY-WR ?ADD-OPT
    ['] OPEN-CONSOLE-WR ?ADD-OPT
    ['] itCONSOLE-WR ?ADD-OPT
    ['] itEXIT-WR ?ADD-OPT
    ['] itOPTIONS-WR ?ADD-OPT
    ['] itRELOAD-WR ?ADD-OPT
    ['] BACKUP-WR ?ADD-OPT
    ['] EDITOR-WR ?ADD-OPT

    ['] RunAsDefaultUser-WR ?ADD-OPT
    ['] DefaultLoadProfile-WR ?ADD-OPT
    ['] DefaultUser-WR ?ADD-OPT
    ['] DefaultPassword-WR ?ADD-OPT
    ['] DefaultDomain-WR ?ADD-OPT

    ['] GUIAsUser-WR ?ADD-OPT
    ['] GUILoadProfile-WR ?ADD-OPT
    ['] GUIUser-WR ?ADD-OPT        
    ['] GUIPassword-WR ?ADD-OPT
    ['] GUIDomain-WR ?ADD-OPT    
    ['] Guard-WR ?ADD-OPT
    ['] INCLUDE-WR ?ADD-OPT
    
    ['] TrayIconDoubleClick-WR ?ADD-OPT
    ['] TrayIconRightButton-WR ?ADD-OPT
    
;

: (SAVE-INI)
    463 RES Query 0= IF EXIT THEN
    CronINI MAKE-BAK
    CronINI R/W CREATE-FILE-SHARED THROW TO FINI
    add-absence 
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

0 VALUE CUR-LANG
0 VALUE num
: fill-langs 
    0 TO CUR-LANG
    0 TO num
    S" %ModuleDirName%\res\*.txt" EVAL-SUBST FOR-FILES
        FOUND-FILENAME 4 - 2DUP LANGUAGE ?DUP 
        IF ASCIIZ> ICOMPARE 0= 
           IF num TO CUR-LANG THEN
        ELSE 2DROP THEN
        2DUP + 0 SWAP C!
        cmb_lang Add
        num 1+ TO num
    ;FOR-FILES
    CUR-LANG cmb_lang Current!
;
