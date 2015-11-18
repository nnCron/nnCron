
VARIABLE H-REG
0 VALUE R-DATE
: MAKE-R-P ( addr u -- a)
    S" HKEY_LOCAL_MACHINE\SOFTWARE\nnSoft\" PAD1 ZPLACE
    PAD1 +ZPLACE
    S" \@" PAD1 +ZPLACE
    PAD1 ;

: DateDays@ Year@ 12 * Mon@ 1- + 31 * Day@ + ;

: DATE-VALUE ( -- addr len)
    GET-CUR-TIME
    DateDays@ S>D
    <#  0 HOLD #S #> 1-
;

: ADD-R-D ( S" progname" --)
    BASE @ >R DECIMAL
    MAKE-R-P >R
    PAD R@ ASCIIZ> ['] GET-REG CATCH
    IF 2DROP DROP
        R@ ASCIIZ> DATE-VALUE REG-SZ
    ELSE
        PAD ASCIIZ>
        0 0 2SWAP >NUMBER 2DROP D>S TO R-DATE
    THEN
    RDROP
    R> BASE !
;

0 [IF] \ old
: ADD-R-D1 ( S" ProgName" --)
    BASE @ >R DECIMAL
    MAKE-R-P >R
    256 SP@ PAD R@ HKEY_LOCAL_MACHINE RegQueryValueA ERROR_SUCCESS - OVER 2 < OR
    IF \ Not found
        \ ." Reg Key Not found" CR
        DROP
        H-REG R@ HKEY_LOCAL_MACHINE RegCreateKeyA ERROR_SUCCESS =
        IF
            H-REG @ RegCloseKey DROP
            DATE-VALUE SWAP REG_SZ R@ HKEY_LOCAL_MACHINE RegSetValueA DROP
            DateDays@ TO R-DATE
        THEN
    ELSE
        PAD SWAP
        0 0 2SWAP >NUMBER 2DROP D>S TO R-DATE
    THEN
    RDROP
    R> BASE !
;
[THEN]
