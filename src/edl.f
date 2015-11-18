\ Line editor for

\
WARNING @  0 WARNING !
DECIMAL 2 9 THRU DECIMAL
WARNING !

FORTH DEFINITIONS
: ED [COMPILE] EDITOR [ EDITOR ] L [ FORTH ] ;
: EDIT  EDITOR ESCR ! 0 CUR ! [ FORTH ] ED  ;

10 LOAD   -- Auto-EDIT





( Line Editor for FORTH-83                          07/Apr/97 )
VOCABULARY EDITOR IMMEDIATE
EDITOR DEFINITIONS
DECIMAL 64 CONSTANT S/L
VARIABLE ESCR  VARIABLE CUR   VARIABLE SP-C
VARIABLE B-I S/L ALLOT   VARIABLE B-S S/L ALLOT
VARIABLE SSCR    -- Search. Last screen.
: stack SP@ SP-C ! ;  : AL S/L * ;
: #ARG SP@ SP-C @ SWAP - 2 / 0 MAX ;
: BADR ESCR @ BLOCK ;
: UPDATE " ( " COUNT BADR SWAP CMOVE  BADR 50 + 14 BLANK
     DATE $DATE COUNT BADR 52 + SWAP CMOVE
     BADR S/L OVER + SWAP DO I C@ C" ) = IF BL I C! THEN LOOP
     C" ) BADR 62 + C! UPDATE ;
: WIPE BADR B/BUF BLANK UPDATE ;

( T L W N B K $ ^                                    07/04/97 )
: CUR! 0 MAX B/BUF 1- MIN CUR ! ;    : CUR+! CUR @ + CUR! ;
: ROW CUR @ S/L / ; : COL CUR @ S/L MOD ; : C- S/L COL - ;
: B- B/BUF CUR @ - ; : inv-arg ." argument???" stack ;
: CA BADR CUR @ + ;  : LA CA COL - ;
: LDEF #ARG IF AL CUR! THEN ; : 1DEF #ARG 0= IF 1 THEN ;
: T LDEF CR ROW 2 .R 2 SPACES LA COL TYPE 95 EMIT
    CA C- TYPE stack ;
: L ESCR @ LIST T ; : Q [COMPILE] FORTH ;
: W FLUSH Q ; : NB ESCR +! STACK ;
: N 1DEF NB ; : B 1DEF NEGATE NB ;
: K LDEF CA C- BLANK UPDATE stack ;
: $ LDEF LA S/L -TRAILING COL - CUR+! DROP stack ;
: ^ LDEF COL NEGATE CUR+! stack ;
: getw ( Adr) 1 WORD 1+ C@  IF HERE SWAP $MOVE ELSE DROP THEN ;
: M 1DEF CUR+! T ;
( I P DC X SPREAD                                    07/04/97 )
: last-a BADR [ S/L 15 * ] LITERAL + ;
: I ( I) LDEF B-I getw B-I COUNT C- MIN >R CA DUP R@ +
    C- R@ - CMOVE> CA R@ CMOVE R> CUR+! UPDATE T ;
: P K cur @ 0= if bl ca c! then I ;
: DC 1DEF DUP 0<
   IF COL NEGATE MAX DUP CUR+! ABS ELSE C- MIN THEN
   ?DUP IF DUP CA + CA C- CMOVE
           LA S/L + OVER - SWAP BLANK UPDATE THEN T ;
: X LDEF LA S/L -TRAILING
    ?DUP IF DUP B-I C! B-I 1+ SWAP CMOVE THEN
    15 ROW - AL LA DUP S/L + SWAP ROT CMOVE
    last-a S/L BLANK UPDATE stack ;
: SPREAD 1DEF 16 ROW - SWAP OVER MIN AL  SWAP AL
    OVER - ?DUP IF >R LA OVER OVER + R> CMOVE> THEN
    LA SWAP BLANK UPDATE stack ;
( U C A F                                            07/04/97 )
: U LDEF 1 SPREAD ^ P C- M ;
: C LDEF CA C- -TRAILING DUP B-I C!
    B-I 1+ SWAP CMOVE K T ;
: A LDEF 16 ROW
    DO CR [ FORTH ] I [ EDITOR ] 2 .R 2 SPACES
       QUERY 1 WORD 1+ C@ 0=
       IF LEAVE
       ELSE LA S/L BLANK  HERE COUNT C- MIN LA
            SWAP CMOVE UPDATE C- CUR+! THEN
    LOOP stack ;
: MATCH 3 PICK >R -MATCH
    IF DROP 0 1024 ELSE -1 SWAP R@ - THEN RDROP ;
: (F) CA SWAP B-S COUNT MATCH OVER IF CUR+! ELSE DROP THEN ;
: not-found B-S COUNT TYPE ."   - not found." ;
: F LDEF B-S getw B- (F) IF T ELSE not-found THEN ;
( S E R TILL                                         07/04/97 )
: S ( EndBlock --)
   B-S getw
   #ARG 0= IF SSCR @ ?DUP 0= IF ESCR @ THEN THEN
   DUP ESCR @ - DUP 0<
   IF 2DROP inv-arg
   ELSE SWAP SSCR ! ESCR @ CUR @ ROT
     BEGIN B- (F) IF DROP DROP DROP T EXIT THEN
           1 ESCR +! 0 CUR ! 1 - DUP 0<
     UNTIL DROP CUR! ESCR ! not-found stack
   THEN ;
: E B-S C@ NEGATE DC ;
: R E I ;
: TILL LDEF B-S getw CA C- B-S COUNT MATCH
    SWAP IF DC ELSE not-found THEN stack ;

( D G M                                              07/04/97 )
: D LDEF B-S getw C- (F) IF E ELSE not-found THEN stack ;
: EXCH B-I PAD S/L CMOVE B-S B-I S/L CMOVE
    PAD B-S S/L CMOVE stack ;
: G ( [[NLines] BegLine] Block --)
  #ARG
  IF #ARG 1 =   IF 16 0 ROT ELSE
     #ARG 2 =   IF 1 ROT ROT THEN THEN
     BLOCK SWAP 0 MAX 15 MIN AL  +
     SWAP 16 MIN AL  SWAP OVER PAD SWAP CMOVE
     LA last-a S/L + OVER - ROT MIN PAD ROT ROT CMOVE
     UPDATE
  THEN T ;
FORTH DEFINITIONS


( IB UPC                                            07/Apr/97 )
EDITOR DEFINITIONS

: #BLOCKS FBLK SIZE B/BUF UM/MOD NIP ;

: IB ( # ->)  ( Insert Blocks)  FLUSH
   1DEF    #BLOCKS ESCR @ -  ( # Cnt)
   DUP 0> IF ESCR @ 2 PICK OVER + ROT COPY
          ELSE DROP THEN
   ESCR @ SWAP 0 ?DO WIPE 1 N LOOP ESCR ! 0 T ;

: UPC ( # ->) 1DEF DUP DUP >R 0< IF DUP CUR+! NEGATE THEN
          B- 1- MIN CA OVER UPPER
          R> 0< IF DROP T ELSE M THEN ;


( DB RDB                                            07/Apr/97 )
CREATE SAVB  B/BUF ALLOT   SAVB B/BUF BLANK

: DB ( # ->)  ( Delete Blocks)  FLUSH
    BADR SAVB B/BUF CMOVE  ( Saving of current block)
    1DEF #BLOCKS ESCR @ - TUCK MIN DUP 0>
    IF TUCK - ESCR @ 2 PICK OVER + SWAP ROT COPY
       B/BUF UM* DNEGATE FBLK SEEK-END
       0 0 FBLK WRITE DROP ELSE 2DROP THEN 0 T ;

: RDB ( ->)   ( Restore Deleted Block)
   1 IB   SAVB BADR B/BUF CMOVE UPDATE 0 T ;
FORTH DEFINITIONS



( auto-edit                                         08/Apr/97 )
EDITOR DEFINITIONS
DECIMAL
    : AUTO-EDIT
        ." Block # " blk @ . ." Line # " >IN @ 64 / DUP . CR
        BLK @ .LINE CR ;
  --     ." Press any key to edit, <Esc> - cancel ..."
  --   KEY 27 - IF BLK @ EDIT >IN @ CUR! T S0 @ SP! QUIT THEN ;

    ' auto-edit show-block !

FORTH DEFINITIONS




( Help for editor)
A ( [#] --)      Добавлять текст
B ( --)          Перейти к редактированию пред. блока
C ( [#] --)      Удалить в буф. вставок остаток строки
D ( [#] [S] --)  Удалить S
E ( --)          Удалить текст, найденный командами F или S
F ( [#] [S] --)  Найти S в текущем блоке
G ( [[N] #] B--) Скопировать часть или весь блок B, начиная
                 с # строки, всего N строк
I ( [#] [S] --)  Вставить S
K ( [#] --)      Удалить остаток строки
L ( [#] --)      Выполнить команду LIST для тек. блока
M ( --)          Поменять содержимое буферов вставки и поиска
N ( --)          Перейти к редактированию след. блока
P ( [#] [S] --)  Поместить S, заменив им остаток строки
Q ( --)          Выход в контекст FORTHа
( Test EDITOR                                        07/04/97 )

: UPDATE " ( " COUNT BADR SWAP CMOVE  BADR 50 + 14 BLANK
     DATE $DATE COUNT BADR 53 + SWAP CMOVE
     BADR S/L OVER + SWAP DO I C@ C" ) = IF BL I C! THEN LOOP
     C" ) BADR 62 + C! UPDATE ;










