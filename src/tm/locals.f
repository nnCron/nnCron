\ $Id: locals.f,v 1.1 2005/06/20 13:26:37 nncron38 Exp $
\ Author: Nicholas Nemtsev
\ Creation time: 2005-05-12 22:11

REQUIRE JMP ~nn/lib/jmp.f

10000 VALUE WL_SIZE2

: TEMP-WORDLIST2 ( -- wid )
\ создаст временный словарь (в виртуальной памяти)
  IMAGE-SIZE WL_SIZE2 -
  IMAGE-BEGIN + 
  ( WL_SIZE ALLOCATE THROW) DUP >R WL_SIZE2 ERASE
  -1      R@ ! \ не присоединяем к VOC-LIST, заодно признак временности словаря
  R@      R@ 5 CELLS + !
  VERSION R@ 6 CELLS + !
  R@ 8 CELLS + DUP CELL- !
  R> CELL+
;
: FREE-WORDLIST2 ( wid -- )
  DROP
;

ALSO vocLocalsSupport DEFINITIONS

: LocalsStartup2
  TEMP-WORDLIST2 widLocals !
  GET-CURRENT uPrevCurrent !
  ALSO vocLocalsSupport
  ALSO widLocals @ CONTEXT ! DEFINITIONS
  uLocalsCnt 0!
  uLocalsUCnt 0!
  uAddDepth 0!
  [ PREVIOUS ]
;
ALSO vocLocalsSupport
: LocalsCleanup2
  PREVIOUS PREVIOUS
  widLocals @ FREE-WORDLIST2
  [ PREVIOUS ]
;

ALSO vocLocalsSupport

' LocalsStartup2 ' LocalsStartup JMP
' LocalsCleanup2 ' LocalsCleanup JMP

PREVIOUS DEFINITIONS

