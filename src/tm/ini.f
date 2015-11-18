\ Windows ini parameters

REQUIRE get-number ~nn/lib/getstr.f
REQUIRE >NAME ~nn/lib/to-name.f
REQUIRE HOLDS lib/ext/string.f
REQUIRE DoList ~nn/lib/list.f
REQUIRE EXIST? ~nn/lib/find.f
REQUIRE GetDesktopSize ~nn/lib/win/window.f
CREATE CommPos  -1 , -1 ,
CREATE CommSize -1 , -1 ,
VARIABLE CommColorBg -1 CommColorBg !
VARIABLE CommColorFont -1 CommColorFont !
VARIABLE CommFontSize
CREATE CommFont 256 ALLOT CommFont 0!

CREATE AddTaskPos HERE  0 ,    -1 , -1 ,
CREATE OptionsPos HERE  SWAP , -1 , -1 , 
CREATE WinSpyPos  HERE  SWAP , -1 , -1 ,

VARIABLE INI-LIST INI-LIST !

: XY! ( x y a -- ) CELL+ 2! ;

: XY@ ( a -- x y) CELL+ 2@ ;

: XY? ( a -- ?) CELL+ @ -1 <> ;

: GETXY { \ mx my x y -- }
    GetDesktopSize TO my TO mx 
    get-number TO x  get-number TO y
    x -1 MAX mx 40 - MIN
    y -1 MAX my 40 - MIN
;

: AddTaskPos: GETXY AddTaskPos XY! ;
: OptionsPos: GETXY OptionsPos XY! ;
: WinSpyPos:  GETXY WinSpyPos XY! ;

: tm.ini S" tm.ini" ;
0 VALUE hINI

: WRINI ( a u -- ) hINI WRITE-FILE THROW ;

: WRITE-PAR ( node -- )
    >R
    R@ NodeValue -1 <>
    IF
        <#  R@ XY@ S>D DUP >R DABS #S R> SIGN BL HOLD 2DROP
            S>D  DUP >R DABS #S R> SIGN S" : " HOLDS
            R@ CFL - >NAME COUNT HOLDS #>
        hINI WRITE-LINE THROW 
    THEN
    RDROP
;

: (save-tm-ini)
    tm.ini DELETE-FILE DROP
    tm.ini R/W CREATE-FILE THROW TO hINI
    ['] WRITE-PAR INI-LIST DoList
    hINI FILE-POSITION THROW OR 0=
        hINI CLOSE-FILE DROP
    IF \ пустой
        tm.ini DELETE-FILE DROP
    THEN
;

: save-tm-ini ['] (save-tm-ini) CATCH DROP ;
: load-tm-ini
    tm.ini EXIST?
    IF
        tm.ini ['] INCLUDED CATCH 
            IF 2DROP SOURCE-ID CLOSE-FILE DROP
               tm.ini DELETE-FILE DROP 
               0 S" Delete tm.ini file" DROP DUP 0 MessageBoxA DROP
            THEN
    THEN
;

: -pos get-number get-number CommPos 2! ;
: -size get-number get-number CommSize 2! ;
: -bgcolor get-number CommColorBg ! ;
: -color get-number CommColorFont ! ;
: -font get-string CommFont ZPLACE ;
: -fontsize get-number CommFontSize ! ;

: CommPos? ( -- x y true | -- false)
    CommPos @ -1 = 
    IF FALSE ELSE CommPos 2@ TRUE THEN ;
: CommSize? ( -- w h true | -- false)
    CommSize @ -1 = 
    IF FALSE ELSE CommSize 2@ TRUE THEN ;
: CommColor? ( -- n true | -- false ) CommColorFont @ 0< 0= IF CommColorFont @ TRUE ELSE FALSE THEN ;
: CommColorBg? ( -- n true | -- false ) CommColorBg @ 0< 0= IF CommColorBg @ TRUE ELSE FALSE THEN ;
: CommFont? ( -- a u true | -- false ) CommFont C@ IF CommFont ASCIIZ> TRUE ELSE FALSE THEN ;
: CommFontSize? ( -- n true | -- false ) CommFontSize @ ?DUP IF TRUE ELSE FALSE THEN ;
