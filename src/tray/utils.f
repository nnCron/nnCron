\ $Id: utils.f,v 1.2 2004/11/17 10:20:23 nncron38 Exp $
\ Author: Nicholas Nemtsev
\ Creation time: 2004-11-16 20:24

0 VALUE TRAY-OUT
: tray.out S" %ModuleDirName%tray.out" EVAL-SUBST ;

WARNING @ WARNING 0!
: BYE
    TRAY-OUT ?DUP IF CLOSE-FILE DROP THEN
    S" nodelout2" EXIST? 0=
    IF tray.out DELETE-FILE DROP THEN
    BYE
; WARNING !

: open-tray.out
    ?GUI 
    IF
        tray.out DELETE-FILE DROP 
        tray.out R/W CREATE-FILE-SHARED
        IF DROP
        ELSE
            TO TRAY-OUT
            TRAY-OUT TO H-STDOUT
            TRAY-OUT TO H-STDERR
        THEN
     THEN
;
