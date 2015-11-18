\ MARKER WC
.( Loadin WINCON extension...)
ALSO FORTH DEFINITIONS
DECIMAL

WINAPI: FindWin32Constant plugins/WINCON.DLL
WINAPI: EnumWin32Constants plugins/WINCON.DLL

\ BOOL APIENTRY FindWin32Constant(char *addr, int len, int *value)
\ typedef int (WINAPI *ENUMPROC)(char*, int, int);
\ int APIENTRY EnumWin32Constants(char *addr, int len, ENUMPROC callback)


: ?WIN-CONST-SLITERAL ( addr u --)
    2>R 0 SP@ 2R> SWAP FindWin32Constant
    0=  IF DROP -321 THROW THEN
    [COMPILE] LITERAL
;

: ?WIN-CONST-LITERAL ( c-addr --)  COUNT ?WIN-CONST-SLITERAL ;

: NOTFOUND
    2DUP 2>R ['] ?WIN-CONST-SLITERAL CATCH
    IF 2DROP 2R> ?SLITERAL
    ELSE
        2R> 2DROP
    THEN ;

10 VALUE WCONST-BASE

: ?SPACES DUP 0 > 0= IF DROP 1 THEN SPACES ;

: (WIN-SHOW-CONST) ( Value Len Addr -- ?)
    WCONST-BASE BASE !
    OVER TYPE 40 SWAP - ?SPACES
    . CR
    KEY? IF KEY BL =
            IF KEY BL =
            ELSE FALSE THEN
         ELSE TRUE THEN       
;

' (WIN-SHOW-CONST) WNDPROC: WIN-SHOW-CONST

: WCONSTS
    ['] WIN-SHOW-CONST BL WORD COUNT SWAP EnumWin32Constants DROP ;


PREVIOUS DEFINITIONS

.( Ok.) CR
\ WCONSTS MB_

( \ TEST1
INFINITE . CR
SW_HIDE . CR
SW_MINIMIZE . CR
SW_MAXIMIZE . CR

: XX ." SW_MINIMIZE is " SW_MINIMIZE . CR ;
XX
)
( \ TEST2
VARIABLE CONST-VALUE
: T CONST-VALUE BL WORD COUNT SWAP FindWin32Constant
    IF ." is " CONST-VALUE @ . ELSE ." Not found" THEN CR ;
)