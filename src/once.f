
MODULE: ONCE-MODULE
: once.txt S" %NNCRON-HOME-DIR%\etc\once.txt" EVAL-SUBST ;

USER-VALUE fonce
VARIABLE foncesem

: OPEN-ONCE  once.txt R/W OPEN/CREATE-FILE THROW TO fonce ;
: CLOSE-ONCE fonce CLOSE-FILE DROP ;


\ New version
VARIABLE once-list
VARIABLE once-update
VARIABLE once-time 0 ,
USER once-node
USER once-xt

: write-once-line
    NodeValue ASCIIZ>
    ?DUP
    IF
        OVER C@ [CHAR] ! <>
        IF
\            DEPTH .
            2DUP <TIB NextWord TIB>
            SFIND DUP 0= IF NIP THEN NIP
\            DUP . DEPTH . CR
        ELSE
          TRUE
        THEN
        IF fonce WRITE-LINE DROP ELSE 2DROP THEN
    ELSE DROP THEN
;
: free-item NodeValue FREE DROP ;

EXPORT
: READ-ONCE
\    GLOBAL
\    ['] free-item  once-list DoList
\    once-list FreeList
\    LOCAL
    once-list 0!
    OPEN-ONCE
    BEGIN PAD 500 fonce READ-LINE THROW WHILE
        PAD SWAP \ 2DUP TYPE CR
        GLOBAL S>ZALLOC once-list AppendNode LOCAL
    REPEAT
    DROP
    CLOSE-ONCE ;

: WRITE-ONCE
    once-update @
    IF
        once.txt DELETE-FILE DROP
        OPEN-ONCE
        0 0 fonce RESIZE-FILE DROP
        ['] write-once-line once-list DoList
        CLOSE-ONCE
        once-update OFF
    THEN ;

: (FIND-ONCE) ( xt \  -- ? )
    once-xt !
    once-node 0!
    once-list
    BEGIN @ ?DUP WHILE
        DUP NodeValue ASCIIZ> once-xt @ EXECUTE
        IF once-node ! TRUE EXIT THEN
    REPEAT
    FALSE
;

: FIND-ONCE foncesem GET (FIND-ONCE) foncesem RELEASE ;

: UPDATE-ONCE { a u xt -- }
    foncesem GET
    xt (FIND-ONCE)
    a u EVAL-SUBST \ 2DUP ." UPDATE-ONCE: " TYPE CR
    GLOBAL
    S>ZALLOC SWAP
    IF
        once-node @ NodeValue FREE DROP
        once-node @ CELL+ !
    ELSE
        once-list AppendNode
    THEN
    once-update ON
    LOCAL
\    WRITE-ONCE
    foncesem RELEASE
;

\ * [ELSE]
\ * : FIND-ONCE { xt \ f found offs -- ? }
\ *     BEGIN
\ *         fonce FILE-POSITION THROW D>S TO offs
\ *         PAD 500 fonce READ-LINE THROW
\ *     WHILE
\ *         ?DUP
\ *         IF
\ *             PAD SWAP xt EXECUTE
\ *             IF
\ *                 offs S>D fonce REPOSITION-FILE THROW
\ *                 TRUE EXIT
\ *             THEN
\ *         THEN
\ *     REPEAT
\ *     DROP
\ *     FALSE
\ * ;

\ * : WRITE-ONCE { a u xt -- }
\ *     OPEN-ONCE
\ *     xt FIND-ONCE DROP
\ *     a u fonce WRITE-LINE THROW
\ *     CLOSE-ONCE
\ * ;
\ * [THEN]


;MODULE

WARNING @ WARNING 0!
: SAVE
    {{ ONCE-MODULE
        foncesem 0!
    }} SAVE ;
WARNING !
