REQUIRE EXIST? ~nn/lib/find.f
REQUIRE StartApp ~nn/lib/process.f
CREATE sti /STARTUPINFO ALLOT sti /STARTUPINFO ERASE

: bat-pars
    I'mService @ 
    IF
        S" " 
    ELSE 
        S"  -dir '%NNCRON-HOME-DIR%' " EVAL-SUBST
    THEN
;

: RunBAT { a u \ buf -- ? }
    1024 ALLOCATE THROW TO buf
    S" %ComSpec% /c " EVAL-SUBST
    buf ZPLACE
    a u buf +ZPLACE
    bat-pars ?DUP IF buf +ZPLACE ELSE DROP THEN
\    buf ASCIIZ> Query DROP
\    ModuleDirName 1- S>ZALLOC APP-Dir !
    SW_HIDE sti wShowWindow W!
    sti buf ASCIIZ> 
[ DEBUG? ] [IF]  2DUP TYPE CR [THEN]
    StartAppWait
[ DEBUG? ] [IF]  . CR [THEN]
    buf FREE DROP
;

: RestartNNCRON
    S" %QUOTE%%ModuleDirName%stopnncron.bat%QUOTE%" EVAL-SUBST RunBAT DROP
    3000 PAUSE
    S" %QUOTE%%ModuleDirName%startnncron.bat%QUOTE%" EVAL-SUBST RunBAT DROP
;
