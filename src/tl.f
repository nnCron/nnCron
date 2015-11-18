\ TASK LIST
REQUIRE GLOBAL ~nn/lib/globalloc.f

10000 VALUE CompleteTaskTimeout
0 VALUE FORCE-STOP
0 VALUE #TASK
VARIABLE TASK-LIST
VARIABLE tlObj
0 VALUE #THA    \ Количество Thread's Handles в массиве

: ADD-TASK ( handle_of_thread -- )
    tlObj GET
\    [ DEBUG? ] [IF] ." TL@ADD-TASK: " .TIME SPACE DUP . CR [THEN]
    DUP TASK-LIST InList? 0=
    IF
        TASK-LIST GLOBAL AddNode LOCAL
        #TASK 1+ TO #TASK
    ELSE
    [ DEBUG? ] [IF] ." TL@ADD-TASK: already exist" CR [THEN]
        DROP
    THEN
    tlObj RELEASE
;

: REMOVE-TASK ( handle_of_thread -- )
\    [ DEBUG? ] [IF] ." TL@REMOVE-TASK: " .TIME SPACE DUP . [THEN]
    DUP CloseHandle 
\    [ DEBUG? ] [IF] DUP . CR [THEN]    
    DROP
    TASK-LIST GLOBAL DelNode LOCAL
    #TASK 1- TO #TASK
;

: ADD-THA ( ListNode --)
    NodeValue PAD #THA CELLS + !
    #THA 1+ TO #THA
;

\ Создание массива Handles
: ENUM-ALL-TASKS ( -- Num)
    0 TO #THA
    ['] ADD-THA TASK-LIST DoList
    #THA
;

: ADD-THA-INACTIVE ( Node --)
    DUP NodeValue 
\    [ DEBUG? ] [IF] ." TL@INACTIVE?: " DUP . [THEN]
    >R 0 SP@ R> GetExitCodeThread
\    [ DEBUG? ] [IF] DUP . OVER . STILL_ACTIVE . CR [THEN]
    IF STILL_ACTIVE <>
        IF DUP ADD-THA THEN
    ELSE
        DROP
    THEN
    DROP
;
    
: DoTHA ( cfa --)
    #THA 0
    ?DO
        PAD I CELLS + @ OVER EXECUTE
    LOOP
    DROP
;

VARIABLE isWATA?  \ is WAIT-AND-TERMINATE-ALL?

: CLOSE-ALL-INACTIVE
    isWATA? @ 0= IF tlObj GET THEN
    0 TO #THA
    ['] ADD-THA-INACTIVE TASK-LIST DoList
    ['] REMOVE-TASK DoTHA
    isWATA? @ 0= IF tlObj RELEASE THEN
;

: STOP-AND-CLOSE 
    [ DEBUG? ] [IF] ." TL@STOP: " .TIME SPACE DUP . [THEN]    
    DUP STOP CloseHandle ERR
    [ DEBUG? ] [IF] DUP . CR [THEN]        
    DROP ;

: STOP-ALL  ['] STOP-AND-CLOSE DoTHA ;

\ Ожидание завершения всех заданий в течении заданного времени.
\ Если время истекло, то завершение всех задач
: WAIT-AND-TERMINATE-ALL
    tlObj GET
    isWATA? ON
    #TASK
    IF
        ENUM-ALL-TASKS
        IF
            FORCE-STOP IF 100 ELSE CompleteTaskTimeout THEN
            TRUE PAD #THA WaitForMultipleObjects DROP
            CLOSE-ALL-INACTIVE
            ENUM-ALL-TASKS IF STOP-ALL THEN
        THEN
        TASK-LIST GLOBAL FreeList LOCAL
    THEN
    0 TO #TASK
    TASK-LIST 0!
    FALSE TO FORCE-STOP
    isWATA? OFF
    tlObj RELEASE
;

: CompleteTaskTimeout: 
    get-number
    ?DUP IF TO CompleteTaskTimeout THEN ; IMMEDIATE


WARNING @ WARNING 0!
: BeforeCrontabLoading
    WAIT-AND-TERMINATE-ALL
    BeforeCrontabLoading
;

: BeforeStop
    TRUE TO FORCE-STOP
    WAIT-AND-TERMINATE-ALL
    BeforeStop
;

WARNING !

