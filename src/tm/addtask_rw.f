\ Read/Write crontab
REQUIRE MAKE-BAK ~nn/lib/bak.f
REQUIRE DELETE-TASK delete_task.f

0 VALUE FTAB

VARIABLE <crontab-name> 0 , 
: crontab-name <crontab-name> @ ?DUP IF ASCIIZ> ELSE S" " THEN ;

VARIABLE <readed-task-name> 
: readed-task-name <readed-task-name> @ ?DUP IF ASCIIZ> ELSE S" " THEN ;

: find-task ( a u  -- ?)
   <readed-task-name> 0!
   BEGIN PAD 512 FTAB READ-LINE THROW WHILE
     DUP 3 >
     IF 
       PAD SWAP <TIB
       NextWord S" #(" COMPARE 0=
       IF
         NextWord  \ 2DUP TYPE ." =="
         2OVER  \ 2DUP TYPE SPACE
         COMPARE 0=
         \ DUP . CR
         IF TIB> S>ZALLOC <readed-task-name> ! TRUE EXIT THEN
       THEN
       TIB>
     ELSE
       DROP
     THEN
   REPEAT
   2DROP
   FALSE
;

: is-end-task PAD 2 S" )#" COMPARE 0= ;
: read-task-body ( -- )
    BEGIN PAD 512 FTAB READ-LINE THROW WHILE
        is-end-task IF DROP EXIT THEN
        PAD SWAP advl+
    REPEAT
;

: read-task1 ( a u -- )
    adv-clr 2DUP find-task
    IF ed_task_name SetText read-task-body
    ELSE 2DROP THEN
    adv_buf @ ASCIIZ> del-last-crlf ed_adv SetText
;

: read-task ( a-crontab u-crontab a-task u-task -- )
    2SWAP  S>ZALLOC <crontab-name> !
    crontab-name R/O OPEN-FILE-SHARED THROW  TO FTAB ( handle)
    read-task1
    FTAB CLOSE-FILE DROP   0 TO FTAB
;

0 [IF]
: LAST-CR? (  -- ? )
    { \ fsize -- }
    FTAB FILE-SIZE THROW D>S TO fsize
    fsize 0= IF FALSE EXIT THEN
    fsize 4 >
    IF
        fsize 4 - S>D FTAB REPOSITION-FILE THROW
        0 SP@ 4 FTAB READ-FILE THROW DROP
        LT W@  DUP 16 LSHIFT OR =
    ELSE FALSE THEN
;
[THEN]

: isCR? ( a u -- ?)
    LTL @ <
    IF DROP FALSE 
    ELSE LTL @ LT OVER COMPARE 0= THEN ;

: isEndCR? ( a u -- ?)
    DUP 1 > 
    IF + LTL @ - LTL @ isCR?
    ELSE 2DROP FALSE THEN
;
: TABCR S" " FTAB WRITE-LINE THROW ;
: write-task-text
    S" #( " FTAB WRITE-FILE THROW
            ed_task_name GetText FTAB WRITE-LINE THROW
    ed_adv GetText 2DUP FTAB WRITE-FILE THROW
    isEndCR? 0= IF TABCR THEN
    S" )#" FTAB WRITE-LINE THROW
    TABCR
;

: write-to-end (  -- )
    \    FTAB LAST-CR? 0= IF S" " FTAB WRITE-LINE DROP THEN
    FTAB ?FCR
    write-task-text
;

: xx . SP@ . SP@ 3 CELLS OVER + SWAP DO I @ . CELL +LOOP CR ;

: ?CREATE-FILE ( a u --)
    2DUP EXIST? IF 2DROP EXIT THEN
    R/W CREATE-FILE THROW CLOSE-FILE DROP    
;
0 [IF]
: (write-task) ( a-crontab u-crontab -- )
    S>ZALLOC <crontab-name> !
    crontab-name ?CREATE-FILE
    <readed-task-name> @ 
    IF crontab @ ASCIIZ> readed-task-name FALSE DELETE-TASK THEN
    crontab-name R/W OPEN-FILE-SHARED THROW TO FTAB
    FTAB >EOF
    FTAB write-to-end
    FTAB CLOSE-FILE DROP 0 TO FTAB
    RELOAD
;
[THEN]

: add-to-end
    crontab-name R/W OPEN-FILE-SHARED THROW TO FTAB
    FTAB >EOF
    FTAB write-to-end
    FTAB CLOSE-FILE DROP 0 TO FTAB
;

0 VALUE tab-buf
: outcr CRON-OUT WRITE-FILE DROP CR ;
: (write-task) ( a-crontab u-crontab -- )
    S>ZALLOC <crontab-name> !
    crontab-name ?CREATE-FILE
    <readed-task-name> @
    IF \ crontab @ ASCIIZ> readed-task-name FALSE DELETE-TASK 
        crontab @ ASCIIZ> R/W OPEN-FILE-SHARED THROW TO FTAB
        FTAB FILE-SIZE THROW D>S DUP CELL+
            ALLOCATE THROW TO tab-buf
        tab-buf SWAP 2DUP FTAB READ-FILE THROW DROP 
\        FILE
        S" /(.*?)(\#\(\s+?%READED-TASKNAME QUOTE-RE%\s+.*?\)\#)(.*)/s" EVAL-SUBST RE-MATCH
        IF
            0. FTAB REPOSITION-FILE THROW 
            $1 2DUP FTAB WRITE-FILE DROP
               LTL @ - isEndCR? 0= IF TABCR THEN
            write-task-text
            $3  \ 2DUP TYPE CR
            BEGIN 
               DUP IF 2DUP isCR? THEN 
            WHILE
                LTL @ /STRING
            REPEAT
            FTAB WRITE-FILE DROP
            FTAB FILE-POSITION THROW FTAB RESIZE-FILE THROW
            FTAB CLOSE-FILE DROP
        ELSE
            FTAB CLOSE-FILE DROP
            add-to-end
        THEN
        tab-buf FREE DROP
    ELSE
        add-to-end
    THEN
    RELOAD
;


: write-task
    0 TO FTAB
    ['] (write-task) CATCH ?DUP
    IF  TO IO-ERR
\        ." Write error #" . CR
        FALSE vCanExit !
        338 ERR-MSG
        FTAB ?DUP IF FTAB CLOSE-FILE DROP THEN
    THEN ;

: delete-task ( crontab-name u -- )
    readed-task-name TRUE DELETE-TASK
    RELOAD
;
