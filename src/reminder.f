\ : \2CRLF ( a u -- a1 u1 )
\     <TIB
\     PAD 0!
\     BEGIN [CHAR] \ PARSE ?DUP WHILE
\         PAD +ZPLACE
\         LT LTL @ PAD +ZPLACE
\     REPEAT
\     TIB>
\     PAD ASCIIZ>
\ ;

: REMINDER { a u \ buf -- }
    BEGIN ExplorerExist 0= WHILE 1000 PAUSE REPEAT
    C" REMINDER-SOUND" FIND IF CATCH THEN DROP 
    1024 ALLOCATE THROW TO buf
    TMName EXIST?
    IF
        tm.exe exe-buf PLACE
        S"  Reminder " exe-buf +PLACE
        place-crontab S"  " exe-buf +PLACE
        exe-buf COUNT buf ZPLACE
        CRON-NEED-DELETE? IF S" once " ELSE S" * " THEN buf +ZPLACE
        a u buf +ZPLACE
        0 buf ASCIIZ> GUIStartApp
    ELSE ( \2CRLF) MsgBox THEN
    buf FREE DROP
;

: REMINDER: eval-string, POSTPONE REMINDER ; IMMEDIATE

