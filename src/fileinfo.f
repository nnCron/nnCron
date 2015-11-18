\ taskinfo.f
REQUIRE TABLE ~nn/lib/db/table.f
REQUIRE Crc32Buf ~nn/lib/crc32.f

0
tf FI-NAME
tf FI-CREATION-TIME
tf FI-WRITE-TIME
tf FI-SIZE
tf FI-CRC32
tf FI-MD5
tf FI-FLAG-EXIST

CONSTANT FI-FIELDS

: fileinfo.txt S" %NNCRON-HOME-DIR%\etc\fileinfo.txt" EVAL-SUBST ;
fileinfo.txt FI-FIELDS TABLE OBJECT: fiTable

2VARIABLE fiERR-MSG
VARIABLE fiERR

: ?fiERR ( ior a u -- )
    fiERR-MSG 2! ?DUP
    IF DUP 2 <>
        IF fiERR ! S" %fiERR-MSG 2@% %fileinfo.txt% ERROR # %fiERR @%"
            EVAL-SUBST CRON-LOG
        ELSE DROP THEN
    THEN ;

USER fi-name-is-set
: ?set-fi-name fi-name-is-set @ 0= IF fileinfo.txt fiTable setFileName fi-name-is-set ON THEN ;

: fiREAD
    ?set-fi-name
    fiTable READ S" READ" ?fiERR
    [NONAME
        SFALSE FI-FLAG-EXIST fiTable FPUT
    NONAME] fiTable FOR-ALL
;

: fiWRITE
    ?set-fi-name
    [NONAME
        FI-FLAG-EXIST fiTable FGET SFALSE COMPARE 0=
    NONAME] fiTable DELETE-WHERE
    fiTable ?WRITE S" WRITE" ?fiERR
;

WARNING @ WARNING 0!
: BeforeCrontabLoading
    fiREAD
    BeforeCrontabLoading
;

: SAVE
    fiTable clear
    SAVE
;

WARNING !