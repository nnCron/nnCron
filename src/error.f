REQUIRE WinErrorMessage ~nn/lib/message.f
REQUIRE RES ~nn/lib/res.f
REQUIRE QUEUE ~nn/lib/utils/queue.f

VARIABLE ShowErrorMsg
VARIABLE ShowErrorTime 30 ShowErrorTime !
USER LOG-IOR
VECT LOG-ERR-PREF
:NONAME S" " ; TO LOG-ERR-PREF

VARIABLE Log2StdOut

\ : TYPE2 CRON-OUT WRITE-FILE DROP ;
\ : CR2 LT LTL @ TYPE2 ;
\ : SPACE2 BL SP@ 1 TYPE2 DROP ;
VARIABLE log-name-tested
VARIABLE log-name-at-home
VARIABLE log-name-buffer
VARIABLE log-name-prefix-len
: log-name-convert ( a u -- a1 u1)
    EVAL-SUBST
    log-name-tested @ 0= 
    IF
        2DUP S" :" SEARCH NIP NIP 0= DUP log-name-at-home !
        IF 
            DUP 100 + ( add 100 for reserve)
            NNCRON-HOME-DIR
            DUP 1+ log-name-prefix-len !
            ROT OVER + 1+ ALLOCATE THROW log-name-buffer !
            log-name-buffer @ ZPLACE
            S" /" log-name-buffer @ +ZPLACE
        THEN
        log-name-tested ON
    THEN
    log-name-at-home @ 
    IF
        DUP >R
        log-name-buffer @ log-name-prefix-len @ + ZPLACE
        log-name-buffer @ log-name-prefix-len @ R> +
    THEN
;

WARNING @ WARNING 0!
: SAVE log-name-tested OFF SAVE ;
WARNING !
: CRON-LOG  ( a u --)
\    GET-CUR-TIME
    EVAL-SUBST \ 2DUP MsgBox
    Log2StdOut @
    IF
       SAVE-HOLD
       CRONLOG-TIME-FORMAT COUNT EVAL-SUBST TYPE
       SPACE 2DUP TYPE CR
       REST-HOLD
    THEN
    cron.log log-name-convert
    LOG
;


: WIN-ERR-STR LOG-IOR @ WinErrorMessage
    ?DUP 0=
    IF DROP
       LOG-IOR @ -1 <>
       IF S" Error # %LOG-IOR @%" EVAL-SUBST
       ELSE HERE 0 THEN
    THEN ;

: ?LOG-SERROR { ior a u \ buf -- }
    ior ?DUP
    IF LOG-IOR ! 0 TO buf
       LOG-ERR-PREF ?DUP
       IF DUP u + 2 CELLS + ALLOCATE 0=
          IF TO buf
             buf ZPLACE
             S" : " buf +ZPLACE
             a u buf +ZPLACE
             buf ASCIIZ>
          ELSE DROP a u THEN
       ELSE DROP a u THEN
       EVAL-SUBST
       ShowErrorMsg @ IF 2DUP ShowErrorTime @ TimeErrMsgBox THEN
       CRON-LOG
       buf ?DUP IF FREE DROP THEN
    THEN
;

: ?LOG-ERROR ( ior #msg -- ) RES ?LOG-SERROR ;


DEBUG? 
[IF]
: time-elapsed \ [ # -- ] 
    S>D
    GetTickCount runfile-time @ - S>D
    <#
       #S 2DROP
       S" : runfile time elapsed: " HOLDS
       #S
    #>
    CRON-LOG
;
[THEN]


