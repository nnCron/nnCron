\ $Id: homedir.f,v 1.12 2013/03/18 15:25:03 nncron38 Exp $
\ Author: Nicholas Nemtsev
\ Creation time: 2007-11-26 17:47

REQUIRE USERNAME ~nn/lib/win/sec/username.f
REQUIRE EXIST? ~nn/lib/find.f
REQUIRE DIR-CREATE ~nn/lib/file.f
REQUIRE get-string ~nn/lib/getstr.f
REQUIRE STR-SUBST ~nn/lib/strsubst.f
VARIABLE nnCronHomeDir

: -dir  get-string ( 2DUP EXIST? IF) EVAL-SUBST S>ZALLOC nnCronHomeDir ! ( THEN) ;

: CUR-OR-HOME-FILE? { a u -- a1 u1 ?}
    a u EXIST?
    IF a u TRUE
    ELSE
        a u S" %NNCRON-HOME-DIR%\%1 esPICKS%" EVAL-SUBST 2DUP EXIST? 
    THEN
;

: CUR-OR-HOME-OR-NNCRON-FILE? { a u -- a1 u1 ?}
    a u CUR-OR-HOME-FILE? ?DUP 0=
    IF 2DROP a u S" %ModuleDirName%\%1 esPICKS%" EVAL-SUBST 2DUP EXIST? THEN
;

\ : MsgBox1 ( S" Message" -- )
\     DROP ( DUP >R) MB_OK MB_ICONINFORMATION OR
\     MB_SYSTEMMODAL OR SWAP Z" nnCron" SWAP 0 MessageBoxA DROP
\ ;

: NNCRON-HOME-DIR
    nnCronHomeDir @ 
    IF
        nnCronHomeDir @ ASCIIZ>
    ELSE
        I'mService @ 0<> 
\        USERNAME I'mService @ 0<> IF 2DUP S" c:\tmp\uname.txt" FWRITE THEN
\        S" SYSTEM" COMPARE 0= AND
        S" portable" +ModuleDirName EXIST? OR
        vOperations @ 0= AND
        IF 
            ModuleDirName 1- 
        ELSE
           S" %FOLDER-APP-DATA%\nnCron" EVAL-SUBST
        THEN
        2DUP S>ZALLOC nnCronHomeDir !
    THEN
;

: NNCRON-HOME-DIR\ S" %NNCRON-HOME-DIR%\" EVAL-SUBST ; \ "
: ?CREATE-NNCRON-HOME-DIR-STRUCTURE ( a u --)
   2DUP EXIST? 0=
   IF
     DIR-CREATE 
   ELSE 
     2DROP
   THEN
;

: NNCRON-HOME-DIR-AS-NAME { \ buf1 buf2 buf3 -- a u }
    NNCRON-HOME-DIR 
    S" \" S" _" STR-SUBST OVER TO buf1 \ "
    S" /" S" _" STR-SUBST OVER TO buf2
    S" :" S" _" STR-SUBST OVER TO buf3
    S>TEMP
    buf1 FREE DROP
    buf2 FREE DROP
    buf3 FREE DROP
;

WARNING @ WARNING 0!
: SAVE
   nnCronHomeDir 0!
   SAVE ;
WARNING !

