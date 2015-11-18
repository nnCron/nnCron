\ ===============  Hash string display wordset  ===============
  DECIMAL

\ Array of digits 0123456789abcdef
: digit$  ( -- adr )  S" 0123456789ABCDEF"  DROP  ;

: intdigits ( -- )  0 PAD  ! ;
: savedigit ( n -- )  PAD  C@  1+  DUP  PAD  C!  PAD  +  C!  ;
: bytedigits ( n1 -- )
  DUP 4 RSHIFT digit$ + C@ savedigit 15 AND digit$ + C@ savedigit
;

  W C@ [IF] \ little ENDIAN
: celldigits ( a1 -- )  DUP 3 + DO I C@ bytedigits  -1 +LOOP ;
  [ELSE]    \ big ENDIAN
: celldigits ( a1 -- )  DUP 4 + SWAP DO I C@ bytedigits LOOP ;
  [THEN]

: SHAstring ( -- adr count )  \ Return counted SHA-256 string array
  intdigits  [ SHAval 7 CELLS + ]L
  8 0 DO  DUP  celldigits  CELL-  LOOP  DROP  PAD  COUNT
;

\ Display SHA-256 hash value in hex ( A B C D E F G H )
: HASH. CR  SHAstring  TYPE  SPACE  ;

: QuoteString ( adr cnt --)  [CHAR] " EMIT  TYPE  [CHAR] " EMIT ;


