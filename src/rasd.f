S" ~nemnick\lib\lh.f" INCLUDED

S" ~nn/lib/wincon.f" INCLUDED
S" LIB\EXT\CORE-EXT1.F" INCLUDED
S" LIB\EXT\JMP.F" LH-INCLUDED
S" ~nn/lib/EOF.F" INCLUDED
S" LIB\ext\tools.f" INCLUDED
S" LIB\EXT\CASE.F" INCLUDED
S" ~nn/lib/globalloc.f" INCLUDED

: WINAPI: >IN @ >R
    BL WORD FIND NIP 
    0= IF R> >IN ! WINAPI: 
       ELSE RDROP BL WORD DROP THEN
;
\ : INCLUDED 2DUP TYPE ." ..." INCLUDED ." ok" CR ;

S" ~nemnick\lib\qdebug.f" INCLUDED
S" ~nemnick\lib\ras.f" INCLUDED
S" ~nemnick\lib\ras_entries.f" INCLUDED

: TEST
    S" asuvdk" RASUser
    S" 09sov11asu99" RASPassword
    S" 160043" RASPhone
    S" PSC" ?DIAL . CR
    ." Ras error " RASError . CR
;

: TEST2
    S" PSC" RasGetCred ?DUP IF ." Error # " . CR BYE THEN
    >R
    R@ RASCR.szUserName ASCIIZ> TYPE CR
    R@ RASCR.szPassword ASCIIZ> TYPE CR
    R@ RASCR.szDomain ASCIIZ> TYPE CR
    R> DROP
;
: MAIN
\    TEST
    TEST2
;

' MAIN TO <MAIN>
0 MAINX !
S" rasd.exe" SAVE 
S" \\mailsrv\e$\bin\rasd.exe" SAVE
BYE
