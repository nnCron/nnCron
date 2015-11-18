: CRON-LOG TYPE CR ;
FALSE VALUE DEBUG?
ping.f

:NONAME . S" localhost" 3 PING . CR ; TASK: tp

: test 10 0 DO I tp START CLOSE-FILE DROP LOOP ;

test
