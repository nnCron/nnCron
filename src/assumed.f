USER-VALUE a.Y
USER-VALUE a.M
USER-VALUE a.D
USER-VALUE a.W
USER-VALUE a.h
USER-VALUE a.m

: test-a.Y CUR-TIME CRON-T-YEAR a.Y + MIN-YEAR - C@ ;
: test-a.M CUR-TIME CRON-T-MON a.M  + 1- C@ ;
: test-a.D CUR-TIME CRON-T-DAY a.D  + 1- C@ ;
: test-a.W CUR-TIME CRON-T-WDAY a.W + 1- C@ ;
: test-a.h CUR-TIME CRON-T-HOUR a.h +    C@ ;
: test-a.m CUR-TIME CRON-T-MIN a.m  +    C@ ;

: test-assumed-time ( -- ?)
    test-a.m 0= IF FALSE EXIT THEN
    test-a.h 0= IF FALSE EXIT THEN
    test-a.D 0= IF FALSE EXIT THEN
    test-a.M 0= IF FALSE EXIT THEN
    test-a.W 0= IF FALSE EXIT THEN
    test-a.Y 0= IF FALSE EXIT THEN
    TRUE
;

: ASSUMED-NEXT-1TIME ( -- d t= | -- f=)

    Year@ Mon@ Day@ Hour@ Min@ 1 MINUTE+ TO a.m TO a.h TO a.D TO a.M TO a.Y
    a.Y a.M a.D WEEK-DAY TO a.W

\ *     CUR-TASK-NAME TYPE SPACE GetTickCount DUP . >R
\ *     GetTickCount R> - . CR

    BEGIN
        test-a.Y
        IF
            BEGIN
                test-a.M
                IF
                    BEGIN
                        test-a.D test-a.W AND
                        IF
                            BEGIN
                                test-a.h
                                IF
                                    BEGIN
                                        test-a.m
                                        IF
\                                          DBG( CR a.Y . a.M . a.D . a.h . a.m . CR )
                                          a.Y a.M a.D a.h a.m 0 ['] YMDHMS>FT CATCH
                                          IF 2DROP 2DROP 2DROP FALSE ELSE TRUE THEN
                                          EXIT
                                        THEN
                                        a.m 1+ TO a.m
                                        a.m 59 >
                                    UNTIL
                                THEN
                                0 TO a.m
                                a.h 1+ TO a.h
                                a.h 23 >
                            UNTIL
                        THEN
                        0 TO a.h 0 TO a.m
                        a.D 1+ TO a.D
                        a.W 1+ DUP 8 = IF DROP 1 THEN TO a.W
                        a.D a.Y a.M MonLength >
                    UNTIL
                THEN
                1 TO a.D 0 TO a.h 0 TO a.m
                a.M 1+ TO a.M
                a.M 12 >
            UNTIL

        THEN
        1 TO a.M 1 TO a.D 0 TO a.h 0 TO a.m
        a.Y 1+ TO a.Y
        a.Y MAX-YEAR >
    UNTIL
    FALSE
;


: ASSUMED-PREV-1TIME ( -- d t= | -- f=)
    DBG( ." ASSUMED-PREV-1TIME begin" CR )
    Year@ Mon@ Day@ Hour@ Min@ -1 MINUTE+ TO a.m TO a.h TO a.D TO a.M TO a.Y
    a.Y a.M a.D WEEK-DAY TO a.W

\ *     CUR-TASK-NAME TYPE SPACE GetTickCount DUP . >R
\ *     GetTickCount R> - . CR

    BEGIN
        test-a.Y
        IF
            BEGIN
                test-a.M
                IF
                    BEGIN
                        test-a.D test-a.W AND
                        IF
                            BEGIN
                                test-a.h
                                IF
                                    BEGIN
                                        test-a.m
                                        IF
\                                          DBG( CR a.Y . a.M . a.D . a.h . a.m . CR )
                                          a.Y a.M a.D a.h a.m 0 ['] YMDHMS>FT CATCH
                                          IF 2DROP 2DROP 2DROP FALSE ELSE TRUE THEN
                                          EXIT
                                        THEN
                                        a.m 1- TO a.m
                                        a.m 0<
                                    UNTIL
                                THEN
                                59 TO a.m
                                a.h 1- TO a.h
                                a.h 0<
                            UNTIL
                        THEN
                        23 TO a.h 59 TO a.m
                        a.D 1- TO a.D
                        a.W 1- DUP 0 = IF DROP 7 THEN TO a.W
                        a.D 1 <
                    UNTIL
                THEN
                a.M 1- 0= IF 31 ELSE a.Y a.M 1- MonLength THEN TO a.D
                23 TO a.h 59 TO a.m
                a.M 1- TO a.M
                a.M 1 <
            UNTIL
        THEN
        12 TO a.M 31 TO a.D 23 TO a.h 59 TO a.m
        a.Y 1- TO a.Y
        a.Y MIN-YEAR <
    UNTIL
    FALSE
    DBG( ." ASSUMED-PREV-1TIME end " DUP . CR )
;

: ASSUMED-NEXT-TIME { \ n1 n2 flag -- d t= | -- f= }
    FALSE TO flag
    0xFFFFFFFF TO n1
    0x7FFFFFFF TO n2
    CUR-NODE CRON-TIME-LIST
    BEGIN ( DUP . CR) @ ?DUP WHILE
      TO CUR-TIME
      ASSUMED-NEXT-1TIME
      IF
          2DUP n1 n2 D< IF TO n2 TO n1 ELSE 2DROP THEN
          TRUE TO flag
      THEN
      CUR-TIME
    REPEAT
    flag IF n1 n2 TRUE ELSE FALSE THEN
;

: ASSUMED-PREV-TIME { \ n1 n2 flag -- d t= | -- f= }
    FALSE TO flag
    0 TO n1
    0 TO n2
    CUR-NODE CRON-TIME-LIST
    BEGIN @ ?DUP WHILE
      TO CUR-TIME
      ASSUMED-PREV-1TIME
      IF
          2DUP n1 n2 D< 0= IF TO n2 TO n1 ELSE 2DROP THEN
          TRUE TO flag
      THEN
      CUR-TIME
    REPEAT
    flag IF n1 n2 TRUE ELSE FALSE THEN
    TDBG( ." ASSUMED-PREV-TIME=" DUP IF >R 2DUP FT>DD.MM.YYYY/hh:mm:ss TYPE R> ELSE ." false" THEN )
;

: test-prev&next
    CUR-TASK-NAME TYPE SPACE
    GetTickCount >R
    ." next=" ASSUMED-NEXT-TIME IF FT>DD.MM.YYYY/hh:mm:ss TYPE ELSE ." no" THEN SPACE
    ." prev=" ASSUMED-PREV-TIME IF FT>DD.MM.YYYY/hh:mm:ss TYPE ELSE ." no" THEN SPACE
    GetTickCount R> - . CR
;


: ASSUMED-PREV-2TIME ( -- d2 t= | -- f=)
    DBG( ." ASSUMED-PREV-2TIME begin" CR )
    { \ pY pM pD ph pm --  } 
\ отсчёт идёт от предыдущего вызова ASSUMED-PREV-1TIME
    \ Year@ Mon@ Day@ Hour@ Min@ -1 MINUTE+ TO a.m TO a.h TO a.D TO a.M TO a.Y
    a.Y a.M a.D WEEK-DAY TO a.W

\ *     CUR-TASK-NAME TYPE SPACE GetTickCount DUP . >R
\ *     GetTickCount R> - . CR

    BEGIN
        test-a.Y
        IF
            a.Y TO pY
            BEGIN
                test-a.M
                IF
                    a.M TO pM
                    BEGIN
                        test-a.D test-a.W AND
                        IF
                            a.D TO pD
                            BEGIN
                                test-a.h
                                IF
                                    a.h TO ph
                                    BEGIN
                                        test-a.m 0=
                                        IF
\                                          DBG( CR a.Y . a.M . a.D . a.h . a.m . CR )
                                          pY pM pD ph pm 0 ['] YMDHMS>FT CATCH
                                          IF 2DROP 2DROP 2DROP FALSE ELSE TRUE THEN
                                          EXIT
                                        ELSE
                                            a.m TO pm
                                        THEN
                                        a.m 1- TO a.m
                                        a.m 0<
                                    UNTIL
                                ELSE
                                    pY pM pD ph pm 0 ['] YMDHMS>FT CATCH
                                    IF 2DROP 2DROP 2DROP FALSE ELSE TRUE THEN
                                    EXIT
                                THEN
                                59 TO a.m
                                a.h 1- TO a.h
                                a.h 0<
                            UNTIL
                        ELSE
                            pY pM pD ph pm 0 ['] YMDHMS>FT CATCH
                            IF 2DROP 2DROP 2DROP FALSE ELSE TRUE THEN
                            EXIT
                        THEN
                        23 TO a.h 59 TO a.m
                        a.D 1- TO a.D
                        a.W 1- DUP 0 = IF DROP 7 THEN TO a.W
                        a.D 1 <
                    UNTIL
                ELSE
                    pY pM pD ph pm 0 ['] YMDHMS>FT CATCH
                    IF 2DROP 2DROP 2DROP FALSE ELSE TRUE THEN
                    EXIT
                THEN
                a.M 1- 0= IF 31 ELSE a.Y a.M 1- MonLength THEN TO a.D
                23 TO a.h 59 TO a.m
                a.M 1- TO a.M
                a.M 1 <
            UNTIL
        ELSE
            pY pM pD ph pm 0 ['] YMDHMS>FT CATCH
            IF 2DROP 2DROP 2DROP FALSE ELSE TRUE THEN
            EXIT
        THEN
        12 TO a.M 31 TO a.D 23 TO a.h 59 TO a.m
        a.Y 1- TO a.Y
        a.Y MIN-YEAR <
    UNTIL
    
    pY pM pD ph pm 0 ['] YMDHMS>FT CATCH
    IF 2DROP 2DROP 2DROP FALSE ELSE TRUE THEN
    
    DBG( ." ASSUMED-PREV-2TIME end " DUP . CR )
;


: ASSUMED-PREV-TIME2 { \ n1 n2 n12 n22 flag -- d2 d1 t= | -- f= }
\ n1 n2 - время правой границы интервала (d1)
\ n12 n22 - время левой границы интервала (d2)
    FALSE TO flag
    0 TO n1
    0 TO n2
   
    CUR-NODE CRON-TIME-LIST
    BEGIN @ ?DUP WHILE
      TO CUR-TIME
      ASSUMED-PREV-1TIME
      IF
          2DUP n1 n2 D< 0= 
          IF TO n2 TO n1 
             ASSUMED-PREV-2TIME 0=
             IF
                 n1 n2
             THEN
             TO n22 TO n12
          ELSE 2DROP THEN
          TRUE TO flag
      THEN
      CUR-TIME
    REPEAT
    flag IF n12 n22 n1 n2 TRUE ELSE FALSE THEN
    TDBG( ." ASSUMED-PREV-TIME2=" DUP IF >R 2DUP FT>DD.MM.YYYY/hh:mm:ss TYPE SPACE 2OVER FT>DD.MM.YYYY/hh:mm:ss TYPE R> ELSE ." false" THEN )
;
