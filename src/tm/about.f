REQUIRE EVAL-SUBST ~nn/lib/subst1.f
REQUIRE xUR? ~nn/lib/regkey.f

CEZ: toReg S" %crlf%%crlf%to register nnCron go to%crlf%%777 RES%" EVAL-SUBST ;CEZ
CEZ: REG-PAGE
    kfil EXIST?
    IF
        ProgName COUNT RKL
        IF
            xUR? 
            IF S" %crlf%%crlf%%FNCUO%" EVAL-SUBST 
            ELSE 
               S" %crlf%%crlf%Registered to %QUOTE%%UNm @ ASCIIZ>%%QUOTE%" EVAL-SUBST
            THEN
\            2DUP TYPE CR
        ELSE
            toReg
        THEN
    ELSE
        toReg
    THEN
;CEZ

VARIABLE <SVC-BUILD>

: SVC-BUILD
    <SVC-BUILD> @ ?DUP
    IF
        ASCIIZ>
    ELSE
        #BUILD-CRON
    THEN ;

: CronDir PAD 256  GetCurrentDirectoryA PAD SWAP
\    2DUP OVER + SWAP
\    ?DO I C@ [CHAR] \ =
\        IF [CHAR] / I C! THEN
\    LOOP
;

: shell32.dll S" shell32.dll" ;
: comctl32.dll S" comctl32.dll" ;

: progVer S" Task scheduler by nnSoft%crlf%%crlf%nncron.exe v %SVC-BUILD%%crlf%tm.exe v %SVERSION%"
    EVAL-SUBST ;
: info S" Directory: %CronDir%%crlf%%WinVersionString%%crlf%%shell32.dll% %shell32.dll DllGetVersion VerM.M.B%"
    EVAL-SUBST ;
: About
    <SVC-BUILD> 0!
    BL SKIP 1 PARSE ?DUP IF S>ZALLOC <SVC-BUILD> ! ELSE DROP THEN
\    S" Task scheduler by nnSoft\ \nncron.exe v %SVC-BUILD%\tm.exe v %SVERSION%\Directory: %CronDir%\%WinVersionString%\%shell32.dll% %shell32.dll DllGetVersion VerM.M.B%\ \mailto:nemtsev@nncron.ru\http://www.nncron.ru/%REG-PAGE%"
    S" %progVer%%crlf%%info%%crlf%%crlf%mailto:nemtsev@nncron.ru%crlf%http://www.nncron.ru/%REG-PAGE%"
    EVAL-SUBST
\    MsgBox
\    2DUP TYPE CR
    (Message)
    BYE
;
