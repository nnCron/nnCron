REQUIRE PrivOn ~nn/lib/win/sec/priv.f
REQUIRE WinNT? ~nn/lib/winver.f
\ Shutdown
: (SHUTDOWN) ( flags -- )
    WinNT? IF
              S" SeShutdownPrivilege" ['] PrivOn CATCH
              IF 2DROP FALSE THEN
              [ DEBUG? ] [IF] ." SeShutdownPrivilege RESULT " DUP . CR [THEN]
              0= IF  S" Set Shutdown privelege error" CRON-LOG THEN
           THEN
     0 SWAP ExitWindowsEx DROP
;
: (FORCE-SHUTDOWN) EWX_FORCE OR (SHUTDOWN) ;
: SHUTDOWN  EWX_SHUTDOWN (SHUTDOWN) ;
: REBOOT    EWX_REBOOT   (SHUTDOWN) ;
: LOGOFF    EWX_LOGOFF   (SHUTDOWN) ;
: POWEROFF  EWX_SHUTDOWN EWX_POWEROFF OR (SHUTDOWN) ;

: FORCE-SHUTDOWN  EWX_SHUTDOWN (FORCE-SHUTDOWN) ;
: FORCE-REBOOT    EWX_REBOOT   (FORCE-SHUTDOWN) ;
: FORCE-LOGOFF    EWX_LOGOFF   (FORCE-SHUTDOWN) ;
: FORCE-POWEROFF  EWX_SHUTDOWN EWX_POWEROFF OR (FORCE-SHUTDOWN) ;
