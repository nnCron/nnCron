\ taskinfo.f
REQUIRE TABLE ~nn/lib/db/table.f
REQUIRE Crc32Buf ~nn/lib/crc32.f

0 CONSTANT TI-NAME
1 CONSTANT TI-CRC32
2 CONSTANT TI-CREATION-TIME
3 CONSTANT TI-WRITE-TIME
4 CONSTANT TI-EXECUTION-TIME
5 CONSTANT TI-FLAG-SUCCESS
6 CONSTANT TI-FLAG-EXIST

7 CONSTANT TI-FIELDS

: taskinfo.txt S" %NNCRON-HOME-DIR%\etc\taskinfo.txt" EVAL-SUBST ;
taskinfo.txt TI-FIELDS TABLE OBJECT: tiTable

2VARIABLE tiERR-MSG
VARIABLE tiERR
: STRUE S" 1" ;
: SFALSE S" 0" ;

: ?tiERR ( ior a u -- )
    tiERR-MSG 2! ?DUP
    IF tiERR ! S" %tiERR-MSG 2@% %taskinfo.txt% ERROR # %tiERR @%"
        EVAL-SUBST CRON-LOG THEN ;

USER ti-name-is-set
: ?set-ti-name ti-name-is-set @ 0= IF taskinfo.txt tiTable setFileName ti-name-is-set ON THEN ;
: tiREAD
    ?set-ti-name
    tiTable READ S" READ" ?tiERR
    [NONAME
        SFALSE TI-FLAG-EXIST tiTable FPUT
    NONAME] tiTable FOR-ALL
;
: tiWRITE
    ?set-ti-name
    [NONAME
        TI-FLAG-EXIST tiTable FGET SFALSE COMPARE 0=
    NONAME] tiTable DELETE-WHERE
    tiTable ?WRITE S" WRITE" ?tiERR
;

USER <TimeCRC32>
: TimeCRC320! CUR-TASK-NAME Crc32BufFirst <TimeCRC32> ! ;
: TimeCRC32+ ( a -- )
    <TimeCRC32> @ SWAP @ ?DUP
    IF
        COUNT Crc32Buf <TimeCRC32> !
    ELSE DROP THEN
;

: TimeCRC32 ( -- a u)
\ works with CUR-NODE
    TimeCRC320!
    CUR-NODE CRON-TIME-LIST
    BEGIN ( DUP . CR) @ ?DUP WHILE
      TO CUR-TIME
      CUR-TIME CRON-MIN TimeCRC32+
      CUR-TIME CRON-HOUR TimeCRC32+
      CUR-TIME CRON-DAY TimeCRC32+
      CUR-TIME CRON-WDAY TimeCRC32+
      CUR-TIME CRON-MON TimeCRC32+
      CUR-TIME CRON-YEAR TimeCRC32+
      CUR-TIME
    REPEAT
    BASE @ HEX <TimeCRC32> @ 0 <# #S #> ROT BASE !
;

: renewTI ( task-address -- )
    { \ crc32 -- }
    TO CUR-NODE
    TimeCRC32 HERE 1+ DUP CUR-NODE CRON-CRC32 ! TO crc32
        S", 0 C,
\    DBG( CUR-TASK-NAME TYPE ."  crc32=" crc32 ASCIIZ> TYPE CR )
\    2DROP EXIT
    crc32 [NONAME ASCIIZ> TI-CRC32 tiTable RFIND NONAME] CATCH
    ?DUP IF S" %CUR-TASK-NAME%: RFIND" EVAL-SUBST ?tiERR DROP TRUE THEN
    IF
        STRUE TI-FLAG-EXIST tiTable FPUT
    ELSE
        tiTable RNEW DUP S" ADD RECORD" ?tiERR 0=
        IF
            CUR-TASK-NAME TI-NAME tiTable FPUT
            crc32 ASCIIZ> TI-CRC32 tiTable FPUT
            FT-CUR FT>DD.MM.YYYY/hh:mm:ss TI-CREATION-TIME tiTable FPUT
            STRUE TI-FLAG-EXIST tiTable FPUT
            SFALSE TI-FLAG-SUCCESS tiTable FPUT
        THEN
    THEN
;

: tiBegin&Find ( -- ? )
    tiTable seize
    [NONAME CUR-NODE CRON-CRC32 @ ASCIIZ> TI-CRC32 tiTable rfind NONAME] CATCH
    ?DUP IF S" %CUR-TASK-NAME%: rfind" EVAL-SUBST ?tiERR FALSE THEN
;

: tiEnd
    tiTable release
;


: tiGetField { field -- a u t= | -- f=}
    tiBegin&Find
    IF
        field tiTable fget
        ?DUP
        IF
            EVAL-SUBST TRUE
        ELSE
            DROP FALSE
        THEN
    ELSE
        FALSE
    THEN
    tiEnd
;

: TASK-X-TIME
    tiGetField
    IF
        SDD.MM.YYYY/hh:mm:ss YMDHMS>FT TRUE
    ELSE
        FALSE
    THEN
;

: TASK-CREATION-TIME (  -- d t= | -- f=)
    TI-CREATION-TIME TASK-X-TIME
;

: TASK-EXECUTION-TIME (  -- d t= | -- f=)
    TI-EXECUTION-TIME TASK-X-TIME
;


WARNING @ WARNING 0!
: BeforeCrontabLoading
    DBG( ." ****************** tiTable READ ************************" CR )
    tiREAD
    BeforeCrontabLoading
;

: AfterCrontabLoading
    DBG( ." ****************** tiTable WRITE ************************" CR )
    tiWRITE
    AfterCrontabLoading
;
: SAVE
    tiTable clear
    SAVE
;

WARNING !