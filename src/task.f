\ words for task and task list processing
: TASK-ACTIVE? ( task -- )  @ ACTIVE? ;
: TASK-ACTIVATE { task -- }
    task TASK-ACTIVE? 0=
    IF
        task @ CF-ACTIVE SET-CRON-FLAG
        ['] (open-watch) task @ ENUM-WATCHES
    THEN
;
: TASK-DEACTIVATE { task -- }
    task TASK-ACTIVE?
    IF
        task @ CF-ACTIVE CLR-CRON-FLAG
        ['] (close-watch) task @ ENUM-WATCHES
    THEN
;
