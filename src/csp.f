
WARNING @ WARNING 0!
USER CSP
WARNING !
USER-CREATE CSP-NAME 2 CELLS USER-ALLOT
USER-VALUE CSP-DIFF
USER-VALUE CSP-THID

: CSP!  SP@ CSP ! ;
: CSP? ( S" Name" --)
    CSP-NAME 2!
    SP@ CSP @ - DUP TO CSP-DIFF DUP >R
    IF  CSP @ SP!
\        GetCurrentThreadId TO CSP-THID
        CSP-DIFF 0<
        IF \ S" %CSP-NAME 2@%. Stack has garbage (%CSP-DIFF ABS%)"
           \ CRON-LOG
           -1 10007 ?LOG-ERROR
        ELSE
           \ S" %CSP-NAME 2@%. Stack is destroyed (%CSP-DIFF%)"
           \ CRON-LOG
           -1 10008 ?LOG-ERROR
        THEN
    THEN
    R> TO CSP-DIFF
;