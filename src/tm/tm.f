\ cron
CREATE ProgName C" nnCron" ",
: DefCrontab S" nncron.tab" ;

: WINAPI: >IN @ >R
    BL WORD FIND NIP
    0= IF R> >IN ! ['] WINAPI: CATCH
          IF SOURCE TYPE CR THEN
       ELSE RDROP BL WORD DROP THEN
;

REQUIRE EVAL-SUBST ~nn/lib/subst1.f

\ : tm.out S" %NNCRON-HOME-DIR%\tm.out" EVAL-SUBST ;
: tm.out S" tm.out" EVAL-SUBST ;
0 VALUE CRON-OUT
WARNING @ WARNING 0!
REQUIRE EXIST? ~nn/lib/find.f
: BYE
    ." BYE..." CR
    tm.out
    CRON-OUT CLOSE-FILE DROP
    S" nodeltmout" EXIST? 0= IF DELETE-FILE DROP ELSE 2DROP THEN
    0 HALT
;
WARNING !
S" locals.f" INCLUDED
S" ~nn/lib/qdebug.f" INCLUDED
S" ~nn/lib/win/net/userlist.f" INCLUDED
S" ~nn/lib/wcmatch.f" INCLUDED
S" ~nn/lib/re.f" INCLUDED
S" ~nn/lib/time-vars.f" INCLUDED
S" ~nn/lib/protect/cipher.f" INCLUDED
S" ~nn/lib/winver.f" INCLUDED
S" ~nn/lib/folders.f" INCLUDED
S" ~nn/lib/getstr.f" INCLUDED

VARIABLE I'mService 
: -svc  I'mService ON ;

S" ../vars.f" INCLUDED
S" ../homedir.f" INCLUDED
S" secondcopy.f" INCLUDED
S" err_msg.f" INCLUDED
S" reload.f" INCLUDED
S" ini.f"     INCLUDED
S" message.f" INCLUDED
S" hint.f" INCLUDED
S" WinSpy.f" INCLUDED
S" query.f" INCLUDED
S" restart.f" INCLUDED
S" choosefile.f" INCLUDED
S" options3.f" INCLUDED
S" sound.f"   INCLUDED
S" addtask.f" INCLUDED
S" reminder-show.f" INCLUDED
S" build.f" INCLUDED
S" about.f" INCLUDED
S" xussr.f" INCLUDED
S" console.f" INCLUDED
S" tasklist.f" INCLUDED

DEBUG?
[IF]
ICONS: ..\ico\nncron32x32-16-2.ico ..\ico\nncron16x16-16-deb.ico
[ELSE]
ICONS: ..\ico\nncron32x32-16-2.ico ..\ico\nncron16x16-16-3.ico
[THEN]

: MAIN
\    S" AddTask %DefCrontab%"  EVAL-SUBST  EVALUATE
    TaskList
    BYE
;

' MAIN TO <MAIN>
TRUE TO ?GUI
0 MAINX !
' BYE ' QUIT JMP

DEBUG? [IF] BUILD! [ELSE] BUILD++ [THEN]

S" tm.exe" SAVE
\ .( GetDialogBaseUnits=) GetDialogBaseUnits 0x1000 /MOD . . CR
\ EditTask nncron.tab purge-cron-log
BYE
