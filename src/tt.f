S" ~nn/LIB/TIME.F" INCLUDED

: WITHIN# ( num low high high-bound -- ?)
    >R
    2DUP > IF R@ ROT - SWAP OVER + >R + R@ MOD 0 R> THEN
    ( num low high)
    >R OVER > 0= SWAP R> > 0= AND
    RDROP
;

: WITHIN7 8 WITHIN# ;
: WITHIN24 24:00 WITHIN# ;    

: IntervalExp ( time-interval_in_minutes -- flag )
  TimeMin@ SWAP
  ?DUP
  IF MOD 0=
  ELSE DROP FALSE THEN
;

: DayOfWeek ( week_day_first week_day_last -- flag )
  WDay@ ROT ROT WITHIN7 ;

: TimeInterval ( time_first time_last -- flag )
  TimeMin@  ROT ROT WITHIN24 ;

: Time= ( TimeInMin -- flag ) TimeMin@ = ;

: TM. 60 /MOD SWAP S>D <# # # [CHAR] : HOLD 2DROP S>D # # #> TYPE SPACE ;
: TI GET-CUR-TIME
    2DUP SWAP TM. TM. TimeInterval . ;
