~NEMNICK\LIB\TIME.F

: PARSE-INTERVAL ( addr u -- first last period)
    2DUP S" /" SEARCH
    IF 1- SWAP 1+ SWAP
        SH:M>Min
    ELSE 1 THEN
    >R
    2DUP S" -" SEARCH
    IF
        1- SWAP 1+ SWAP
        SH:M>Min >R
        SH:M>Min R>
    ELSE
        2DROP
        SH:M>Min DUP
    THEN
    R>
;


: 0..24 1440 MOD ;

: INTERVAL ( TIME first-time-in-min last-time-in-min period-in-min -- ? )
    >R
    1440 ROT - >R
    R@ + 0..24
    SWAP R> + 0..24 TUCK
    < 0= SWAP R> MOD 0= AND
;

: T INTERVAL IF ." TRUE" ELSE ." FALSE" THEN CR ;

10 10 20 1 T .( need TRUE) CR
20 10 20 1 T .( need TRUE) CR
21 10 20 1 T .( need FALSE) CR
9 10 20 1 T  .( need FALSE) CR
1000 10 20 1 T  .( need FALSE) CR

50 1400 100 1 T .( need TRUE) CR
1439 1400 100 1 T .( need TRUE) CR
1000 1400 500 1 T  .( need FALSE) CR

