
: ?CronINI CronINI CUR-OR-HOME-FILE? DROP ;

: -ini? ?save-def-ini BYE ;

0 VALUE ini-txt
0 VALUE ini-chg?
( 
: NewINI-PRE
\    SOURCE TYPE CR
    ini-txt ASCIIZ> BL WORD COUNT SEARCH NIP NIP 0=
    IF  \ LT LTL @ ini-txt +ZPLACE
        SOURCE ini-txt +ZPLACE
        LT LTL @ ini-txt +ZPLACE
        TRUE TO ini-chg? THEN
    1 WORD DROP
;
)

: SREAD-LINE ( a u -- a1 u1 a2 u2 ?)
    DUP
    IF
        2DUP CRLF SEARCH 0=
        IF 2DROP 2DUP + 0 2SWAP
        ELSE 
            2DUP 2>R NIP - 2R> 2 /STRING 2SWAP
        THEN
        TRUE
    ELSE 2DUP FALSE THEN
;

: AddNewINI
    FALSE TO ini-chg?
    ?CronINI FSIZE D>S 10240 + DUP ALLOCATE THROW TO ini-txt
    ini-txt SWAP ?CronINI FREAD + 0!
    ini-txt ASCIIZ> + 2- W@ LT W@ <> 
    IF LT LTL @ ini-txt +ZPLACE THEN
    default-ini ASCIIZ>
    BEGIN SREAD-LINE WHILE
        ?DUP
        IF
            OVER C@ [CHAR] \ <>
            IF
              <TIB
                  ini-txt ASCIIZ> 
                  NextWord 2DUP S" INCLUDE" COMPARE 0=
                  IF 2DROP get-string ISEARCH
                  ELSE SEARCH THEN
                  NIP NIP 0=
                  IF
\                     SOURCE S>ZALLOC DUP ASCIIZ> MsgBox FREE DROP
                     SOURCE ini-txt +ZPLACE
                     CRLF ini-txt +ZPLACE
                     TRUE TO ini-chg?
                  THEN
                  1 WORD DROP
              TIB>
            ELSE 2DROP THEN
        ELSE
          DROP
        THEN
    REPEAT
    2DROP 2DROP
    ini-chg? IF ini-txt ASCIIZ> ?CronINI FWRITE THEN
    ini-txt FREE THROW
;

( 
: AddNewINI
    FALSE TO ini-chg?
    CronINI FSIZE D>S 10240 + DUP ALLOCATE THROW TO ini-txt
    ini-txt SWAP CronINI FREAD + 0!
    ini-txt ASCIIZ> + 2- W@ LT W@ <> 
    IF LT LTL @ ini-txt +ZPLACE THEN
    ['] <PRE> BEHAVIOR >R
    ['] NewINI-PRE TO <PRE>
    S" txt\new.ini" ['] INCLUDED CATCH R> TO <PRE>
        IF 2DROP THEN
    ini-chg? IF ini-txt ASCIIZ> CronINI FWRITE THEN
    ini-txt FREE THROW
;
)

\ : new.ini S" txt\new.ini" ;

: CronDir PAD 256 GetCurrentDirectoryA PAD SWAP ;

: MOV-OR-DEL ( a1 u1 a2 u2 -- )
\    2DUP MsgBox
\    2DUP FILE MsgBox
\    CronDir MsgBox
    2DUP EXIST?
    IF \ S" exist" MsgBox
        2DROP DELETE-FILE DROP 
    ELSE
        \ S" not exist" MsgBox
        FMOVE THEN ;

: FirstCopy
    SET-DIR
    ?save-def-ini
\    S" txt\nncron.tab" nncron.tab    MOV-OR-DEL
    S" txt\deleted.tab" deleted.tab  MOV-OR-DEL
    S" HKEY_LOCAL_MACHINE\Software\NNemtsev" ['] REG-DELETE-KEY CATCH IF 2DROP THEN
\    S" txt\nncron.ini" CronINI       MOV-OR-DEL
\    new.ini EXIST?
\    IF  
        AddNewINI 
\        new.ini DELETE-FILE DROP
\    THEN
    S" txt" DROP RemoveDirectoryA DROP
    taskinfo.txt EXIST? 0= IF S" " taskinfo.txt FWRITE THEN
;

0 VALUE Silent?
: -q TRUE TO Silent? ;
: ?MsgBox Silent? IF 2DROP ELSE MsgBox THEN ;
: -?dir nnCronHomeDir @ 
	IF 
		S" -dir %QUOTE%%nnCronHomeDir @AZ%%QUOTE%" EVAL-SUBST 
	ELSE S" " THEN ;
: -ns-string S"  -ns %-?dir%" EVAL-SUBST ;
: -app-for-all AppForAllUsers ON -ns ;
: -app-for-user AppForCurUser ON -ns ;

: -install  vOperations ON vInstall ON Outfile OFF ;

: -no-pars S" " ;

: DoInstall
     FirstCopy
     INIT-CRON
     WinNT?
     IF 
\       ['] -ns-string TO svc95par
        ['] -no-pars TO svc95par
        AppForAllUsers @ 
        IF
            ['] rgRun2 TO rgRun
            HKEY_LOCAL_MACHINE TO HKEY_INSTALL            
            ServiceName InstallService95 0= 
        ELSE
        AppForCurUser @
        IF
            ['] rgRun2 TO rgRun
            HKEY_CURRENT_USER TO HKEY_INSTALL
            ServiceName InstallService95 0= 
        ELSE
            ServiceName doCreateService
        THEN THEN
     ELSE 
        ['] rgRun1 TO rgRun
        HKEY_LOCAL_MACHINE TO HKEY_INSTALL            
        ServiceName InstallService95 0= 
     THEN
     IF
        S" nnCron service installed." 
        \ MB_OK MB_SERVICE_NOTIFICATION + ServiceName DROP 
        \ S" Service installed." DROP 0 MessageBoxA DROP
     ELSE
        S" Service installation error # %GetLastError N>S%" EVAL-SUBST
     THEN
     ?MsgBox
     1000 PAUSE BYE
;

: -remove  vOperations ON vRemove ON Outfile OFF ;

: DoRemove
     INIT-CRON
     WinNT?
     IF
        AppForAllUsers @ 
        IF
            ['] rgRun2 TO rgRun
            HKEY_LOCAL_MACHINE TO HKEY_INSTALL            
            ServiceName UninstallService95 0= 
        ELSE
        AppForCurUser @
        IF
            ['] rgRun2 TO rgRun
            HKEY_CURRENT_USER TO HKEY_INSTALL
            ServiceName UninstallService95 0= 
        ELSE
            ServiceName doDeleteService
        THEN THEN
     ELSE 
        ['] rgRun1 TO rgRun
        HKEY_LOCAL_MACHINE TO HKEY_INSTALL            
        ServiceName UninstallService95 0= 
     THEN
     IF
        S" nnCron service uninstalled." ?MsgBox
        \ MB_OK MB_SERVICE_NOTIFICATION + ServiceName DROP
        \ S" Service uninstalled." 
        \ DROP 0 MessageBoxA DROP
     THEN
     1000 PAUSE BYE
;

: -uninstall vOperations ON vUninstall ON Outfile OFF ;
: DoUninstall
    0
    S" %SystemRoot%\UnGins.exe %QUOTE%%ModuleDirName%install.log%QUOTE%" 
    EVAL-SUBST StartApp DROP 

    SET-DIR
\    CronINI DELETE-FILE DROP
\    deleted.tab DELETE-FILE DROP
\    nncron.tab DELETE-FILE DROP
    BYE 
;

: -install95 
     FirstCopy
     INIT-CRON
     ServiceName InstallService95 0= 
     IF S" Service 95 installed." ?MsgBox THEN
     1000 PAUSE BYE
;
: -remove95
     ServiceName UninstallService95 0= 
     IF S" Service 95 uninstalled." ?MsgBox THEN
     1000 PAUSE BYE
;
