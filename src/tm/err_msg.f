REQUIRE WinErrorMessage ~nn/lib/message.f
REQUIRE RES ~nn/lib/res.f
REQUIRE EVAL-SUBST ~nn/lib/subst1.f

0 VALUE IO-ERR

: MsgBox ( a u -- )
    DROP 0 
    S" nnCron" DROP ROT
    0 MessageBoxA DROP 
;

: IO-ERR-TXT ( - a u )  IO-ERR WinErrorMessage ;

: NNCronErr S" nnCron. Error message"  ;
: ERR-MSG ( # -- )
    MB_ICONEXCLAMATION MB_OK OR
    SWAP RES EVAL-SUBST DROP NNCronErr DROP SWAP
    0 MessageBoxA DROP ;

: ERR-MSG-STR ( a u # --)
    RES EVAL-SUBST PAD ZPLACE LT LTL @ PAD +ZPLACE
    EVAL-SUBST PAD +ZPLACE 
    MB_ICONEXCLAMATION MB_OK OR
    NNCronErr DROP PAD 0 MessageBoxA DROP ;
