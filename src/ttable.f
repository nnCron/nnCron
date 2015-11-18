VECT t-table!
VECT normalize-time
: ny-normalize-time BEG-RANGE MAX END-RANGE MIN ;
: ny-t-table! ( table offset -- ) BEG-RANGE - + 1 SWAP C! ;
: y-t-table! ( table offset -- )
    DUP BEG-RANGE < OVER END-RANGE > OR 0=
    IF BEG-RANGE - + 1 SWAP C! ELSE 2DROP THEN ;
: time-table! ( table offset -- ) normalize-time t-table! ;
: t-is-y
    t-is-year ON
    ['] y-t-table!  TO t-table!
    ['] NOOP TO normalize-time ;
: t-is-ny
    t-is-year OFF
    ['] ny-t-table!  TO t-table!
    ['] ny-normalize-time TO normalize-time ;
t-is-ny

: fill-time-range { table beg end step -- }
    beg normalize-time TO beg
    end normalize-time TO end
    beg end > 0= ( <=)
    IF
        \ это случай обычный
        end 1+ beg DO
            table I t-table!
        step +LOOP
    ELSE
        \ это когда начало периода позже конца, т.е. период переходит через границу
        \ заданной величины (другой час, день и т.д.)
        END-RANGE 1+ beg ?DO
            table I t-table!
        step +LOOP

        end 1+
        BEG-RANGE END-RANGE beg - step MOD step SWAP - 1- +
        \ такие хитрые вычисления для того, чтобы шаг сохранялся и вначале шкалы
        ?DO
            table I t-table!
        step +LOOP
    THEN
;

: set-time-step ( a u -- a1 u1)
    1 TO STEP-NUM
    DUP
    IF
        OVER C@ [CHAR] / =
        IF SKIP-CHAR
        DUP
        IF TIME>NUMB ?DUP IF TO STEP-NUM THEN  THEN
        THEN
    ELSE
    THEN
;
: ?TIME>NUMB ( a u -- a1 u1 num)
    DUP >R
    TIME>NUMB
    OVER R> = IF NIP 0 SWAP THEN
;

: set-cron-time-table { ac table start-num -- }
\    EXIT
    <N-TEST
    \ table END-RANGE BEG-RANGE - 1+ 1 FILL
    1 TO STEP-NUM
    ac
    IF
        ac COUNT ?DUP
        IF
            table END-RANGE BEG-RANGE - 1+ ERASE
            OVER C@ [CHAR] ? =
            IF
                2DROP table start-num time-table!
            ELSE
                BEGIN ?DUP WHILE  ( addr # )
                  \ */step
\                  2DUP TYPE CR
                  OVER C@ [CHAR] * =
                  IF
                    SKIP-CHAR
                    set-time-step
                    table BEG-RANGE END-RANGE STEP-NUM fill-time-range
                    DROP 0 \ Завершаем разбор строки, т.к. *
                  ELSE
                      ?TIME>NUMB TO BEG-NUM
                      DUP
                      IF
                          OVER C@ [CHAR] - =
                          IF SKIP-CHAR
                            DUP
                            IF ?TIME>NUMB ELSE END-RANGE THEN TO END-NUM
                            set-time-step
                            table BEG-NUM END-NUM STEP-NUM fill-time-range
                            DUP IF OVER C@ [CHAR] , = IF SKIP-CHAR THEN THEN
                          ELSE
                          OVER C@ [CHAR] , =
                          IF
                            SKIP-CHAR
                            table BEG-NUM time-table!
                          THEN THEN
                      ELSE
                          \ Одно число, однако
                          table BEG-NUM time-table!
                      THEN
                  THEN
                REPEAT
                DROP
            THEN
\            DBG( ac COUNT TYPE SPACE ." --" END-RANGE BEG-RANGE - 1+ 0 DO table I + C@ IF ." 1" ELSE ." 0" THEN LOOP ." --" CR )
        ELSE
            DROP
        THEN
    THEN
    N-TEST>
;
