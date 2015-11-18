: RGB>BGR 256 /MOD 256 /MOD 0xFF AND SWAP 256 * + SWAP 65536 * + ;
: HINT-POS   ( x y --) 0x1000 * + <HINT-POS> ! ;
: HINT-SIZE  ( w h --) 0x1000 * + <HINT-SIZE> ! ;
: HINT-COLOR ( bg fg -- ) RGB>BGR <HINT-FONT-COLOR> ! RGB>BGR <HINT-COLOR> ! ;
: HINT-FONT ( a u n -- ) <HINT-FONT-SIZE> ! S>ZALLOC <HINT-FONT> ! ;

: #xy ( xy -- ) 0x1000 /MOD S>D #S BL HOLD 2DROP S>D #S BL HOLD 2DROP ;
: (HINT) { a u time-out wait? \ fn -- }
    TempFile S>ZALLOC TO fn
    a u fn ASCIIZ> FWRITE
    0
    <# 0 HOLD fn ASCIIZ> HOLDS S"  FILE: " HOLDS time-out S>D #S 
       S"  TimeHint " HOLDS   
       <HINT-POS>  @ ?DUP IF #xy S"  -pos " HOLDS THEN
       <HINT-SIZE> @ ?DUP IF #xy S"  -size " HOLDS THEN       
       <HINT-FONT> @ ?DUP IF ASCIIZ> [CHAR] " HOLD HOLDS [CHAR] " HOLD S"  -font " HOLDS THEN
       <HINT-FONT-SIZE> @ ?DUP IF S>D #S 2DROP S"  -fontsize " HOLDS THEN
       <HINT-FONT-COLOR> @ 0< 0=  IF <HINT-FONT-COLOR> @ S>D #S 2DROP S"  -color " HOLDS THEN
       <HINT-COLOR> @ 0< 0= IF <HINT-COLOR> @ S>D #S 2DROP S"  -bgcolor " HOLDS THEN  
       tm.exe HOLDS #>
\       2DUP TYPE CR
    APP-Dir 0!
    wait? IF StartAppWait ELSE  StartApp  THEN    
    DROP
    fn FREE DROP
;

: HINT  0 FALSE (HINT) ;
: HINTW 0 TRUE  (HINT) ;

: THINT  FALSE  (HINT) ;
: THINTW TRUE   (HINT) ;


: HINT:  eval-string, POSTPONE HINT  ; IMMEDIATE
: HINTW: eval-string, POSTPONE HINTW ; IMMEDIATE

: THINT:  eval-string, get-number POSTPONE LITERAL POSTPONE THINT  ; IMMEDIATE
: THINTW: eval-string, get-number POSTPONE LITERAL POSTPONE THINTW ; IMMEDIATE

: HINT-OFF S" nnCron HINT window" WIN-CLOSE ;

: HINT-POS: xy, POSTPONE HINT-POS ; IMMEDIATE
: HINT-SIZE: xy, POSTPONE HINT-SIZE ; IMMEDIATE
