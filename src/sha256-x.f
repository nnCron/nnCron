
\ REQUIRE MARKER lib/ext/core-ext.f
\ REQUIRE D2* lib/ext/double.f
VERSION 400000 <    \ NOT SPF4
[IF]
HEX
HEADER D2*
87 C, E5 C, 5A C, 58 C,  C1 C, E2 C, 01 C, C1 C,
D0 C, 01 C, 50 C, 52 C,  87 C, E5 C, C3 C, 
DECIMAL
[THEN]


: 3DROP 2DROP DROP ;

: STRING WORD COUNT HERE OVER 1+ CHARS ALLOT PLACE ;

\ : ANEW  >IN @ BL WORD FIND IF EXECUTE ELSE DROP THEN >IN ! MARKER ;

: split-at-char
  >R  2DUP  BEGIN  DUP  WHILE  OVER  C@  R@  -
            WHILE  1 /STRING  REPEAT  THEN
            R> DROP  TUCK  2>R  -  2R>
;

: DOES>MACRO
  DOES> COUNT  BEGIN [CHAR]  \ split-at-char  2>R  EVALUATE  R@
               WHILE BL WORD COUNT EVALUATE 2R>  1 /STRING REPEAT
               R> DROP   R> DROP
;


: MACRO  CREATE  IMMEDIATE  CHAR  STRING  DOES>MACRO  ;


  DECIMAL
  32 CONSTANT CELLSIZE

  VARIABLE  SHAlen
  CREATE SHAval  8 CELLS ALLOT
  CREATE SHAsh  72 CELLS ALLOT
  CREATE W      16 CELLS ALLOT
  1 W !

  HEX
CREATE  K[I]
428A2F98 , 71374491 , B5C0FBCF , E9B5DBA5 , 3956C25B , 59F111F1 , 923F82A4 , AB1C5ED5 ,
D807AA98 , 12835B01 , 243185BE , 550C7DC3 , 72BE5D74 , 80DEB1FE , 9BDC06A7 , C19BF174 ,
E49B69C1 , EFBE4786 , 0FC19DC6 , 240CA1CC , 2DE92C6F , 4A7484AA , 5CB0A9DC , 76F988DA ,
983E5152 , A831C66D , B00327C8 , BF597FC7 , C6E00BF3 , D5A79147 , 06CA6351 , 14292967 ,
27B70A85 , 2E1B2138 , 4D2C6DFC , 53380D13 , 650A7354 , 766A0ABB , 81C2C92E , 92722C85 ,
A2BFE8A1 , A81A664B , C24B8B70 , C76C51A3 , D192E819 , D6990624 , F40E3585 , 106AA070 ,
19A4C116 , 1E376C08 , 2748774C , 34B0BCB5 , 391C0CB3 , 4ED8AA4A , 5B9CCA4F , 682E6FF3 ,
748F82EE , 78A5636F , 84C87814 , 8CC70208 , 90BEFFFA , A4506CEB , BEF9A3F7 , C67178F2 ,


  DECIMAL

MACRO ]L   " ] LITERAL "

  0 VALUE H[H]

MACRO H[G]  " H[H]  [ 1 CELLS ]L  +"
MACRO H[F]  " H[H]  [ 2 CELLS ]L  +"
MACRO H[E]  " H[H]  [ 3 CELLS ]L  +"
MACRO H[D]  " H[H]  [ 4 CELLS ]L  +"
MACRO H[C]  " H[H]  [ 5 CELLS ]L  +"
MACRO H[A]  " H[H]  [ 7 CELLS ]L  +"

MACRO ror\  " DUP >R [ CELLSIZE \ TUCK - ]L LSHIFT R> LITERAL RSHIFT OR "

: SHAinit ( -)
  [ HEX ] 6A09E667 ( H0)  BB67AE85 ( H1)  3C6EF372 ( H2)  A54FF53A ( H3)
          510E527F ( H4)  9B05688C ( H5)  1F83D9AB ( H6)  5BE0CD19 ( H7)
  [ DECIMAL ]
  SHAsh  7 0 DO  TUCK  !  CELL+  LOOP  !
  SHAsh  SHAval  8 CELLS  CMOVE
  SHAsh  TO  H[H]
;

: UpDateHash ( -)
  SHAsh  SHAval  H[H]
  8 0 DO  DUP >R   @   SWAP  DUP >R  @  +  DUP
          R@  !  OVER  !  CELL+  R>  CELL+  R>  CELL+
  LOOP  3DROP
  SHAsh  TO  H[H]
;

MACRO Ch   " H[F] 2@  OVER  AND  SWAP  INVERT  H[G]  @  AND  XOR"

MACRO Maj  " H[C]  DUP >R  CELL+  2@  OVER  AND  SWAP  R@ @  AND XOR  R> 2@ AND  XOR "

: T1x  Ch  H[E] @  DUP >R  ror\ 6  R@  ror\ 11  XOR  R>  ror\ 25  XOR  +  H[H] @  +  ;

: T2  Maj  H[A] @  DUP >R  ror\ 2  R@  ror\ 13  XOR  R>  ror\ 22  XOR  +  ;

: sig0  DUP >R  ror\  7  R@  ror\ 18  XOR  R>   3 RSHIFT  XOR  ;

: sig1  DUP >R  ror\ 17  R@  ror\ 19  XOR  R>  10 RSHIFT  XOR  ;

MACRO Wi@  " DUP  @  TUCK"

MACRO Wi  " 15 PICK  15 PICK  sig0  +  7 PICK  +  2 PICK  sig1  +  DUP "

MACRO WiDROP  " 8 0 DO  2DROP 2DROP  2DROP 2DROP  LOOP"  ( W0..W63 - )

  0 VALUE Ki
: Ki+  Ki  DUP  CELL+  TO  Ki  @  + ;

MACRO subrnd  " T1x +  Ki+  ( T1)  DUP  H[D]  +!  T2  +  H[G] TO H[H]  H[A]  !"

: SHA256
  K[I]  TO  Ki
  16 0  DO  Wi@  subrnd  CELL+  LOOP  DROP
  48 0  DO  Wi   subrnd         LOOP  WiDROP
  UpDateHash
;

: setlen
  SHAlen @  DUP  [ CELLSIZE 3 - ]L  RSHIFT  [ W 56 CHARS + ]L !  ( hi)
  3 LSHIFT  [ W 60 CHARS + ]L !  ( lo)
;

: bytes><
  [ HEX ]  DUP >R  18 LSHIFT  R@  FF00 AND  8 LSHIFT  OR
  R@  FF0000 AND  8 RSHIFT  OR  R>  18 RSHIFT  OR  [ DECIMAL ]
;

: cellsreverse
  0 DO  DUP  @  bytes><  OVER !  CELL+  LOOP  DROP
;

W C@ [IF]
      MACRO endian16 "  DUP  16  cellsreverse "
      MACRO endian14 "  DUP  14  cellsreverse "
[ELSE]
      MACRO endian16 " "
      MACRO endian14 " "
[THEN]

: hashfullblocks
  DUP  -64  AND
  IF  DUP >R  6 RSHIFT
      0 DO  DUP  endian16
            SHA256  64 +
      LOOP
      R> 63 AND
  THEN
;

: hashfinal
  DUP >R  W  DUP >R  SWAP  CMOVE
  R> R@ +  128  OVER  C!
  CHAR+  55 R@ -
  R> 55 >
  IF    8 + 0  FILL
        W  endian16  SHA256
        W  56
  THEN
  0 FILL  setlen  W  endian14  SHA256
;

: SHAbuffer
  SHAinit  DUP  SHAlen !  hashfullblocks  hashfinal
;

