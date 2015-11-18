REQUIRE FILE ~nn/lib/subst1.f
REQUIRE base64 ~nn/lib/base64.f
REQUIRE get-string ~nn/lib/getstr.f
REQUIRE @AZ ~nn/lib/az.f
REQUIRE FWRITE ~nn/lib/file.f
REQUIRE RANDOM ~nn/lib/ran4.f

VARIABLE inpFILE
VARIABLE outFILE
VARIABLE hi
VARIABLE ho
VARIABLE direction direction ON

: -e direction ON ; 
: -d direction OFF ;
: -i get-string S>ZALLOC inpFILE ! ;
: -o get-string S>ZALLOC outFILE ! ;

VARIABLE ibuf
VARIABLE obuf
: START-SEQ ( a u -- )
    0 ROT ROT OVER + SWAP
    DO I C@ + LOOP
    DUP 2DUP .S START-SEQUENCE
;
63 CONSTANT BLK-LEN
: encode-file ( a u a2 u2 -- )
    2DUP START-SEQ
    BLK-LEN ALLOCATE THROW ibuf !
    BLK-LEN 2* ALLOCATE THROW obuf !
    2SWAP R/O OPEN-FILE-SHARED THROW hi !
    2DUP DELETE-FILE DROP
    W/O CREATE-FILE-SHARED THROW ho !
    BEGIN ibuf @ BLK-LEN hi @ READ-FILE THROW ?DUP WHILE
        64 RANDOM TO 64offset
        ibuf @ SWAP obuf @ base64 ho @ WRITE-LINE THROW
    REPEAT
    hi @ CLOSE-FILE DROP
    ho @ CLOSE-FILE DROP
    ibuf @ FREE DROP
    obuf @ FREE DROP
;

: decode-file ( a u a2 u2 -- )
    2OVER START-SEQ
    BLK-LEN 2* ALLOCATE THROW ibuf !
    BLK-LEN 2* ALLOCATE THROW obuf !
    2SWAP R/O OPEN-FILE-SHARED THROW hi !
    2DUP DELETE-FILE DROP
    W/O CREATE-FILE-SHARED THROW ho !
    BEGIN ibuf @ BLK-LEN 2* hi @ READ-LINE THROW WHILE
        64 RANDOM TO 64offset
        ibuf @ SWAP obuf @ debase64 ho @ WRITE-FILE THROW
    REPEAT
    DROP
    hi @ CLOSE-FILE DROP
    ho @ CLOSE-FILE DROP
    ibuf @ FREE DROP
    obuf @ FREE DROP
;

: main
    inpFILE @AZ
    outFILE @AZ
    direction @ 
    IF
        encode-file
    ELSE
        decode-file
    THEN
\	inpFILE @AZ FILE DUP 3 * ALLOCATE THROW buf !
\	buf @ base64 outFILE @AZ FWRITE
	BYE
;

' main TO <MAIN>
0 MAINX !
\ FALSE TO SPF-INIT?


S" b64.exe" SAVE BYE
