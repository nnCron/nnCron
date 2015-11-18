\ $Id: connect.f,v 1.4 2004/11/18 21:08:27 nncron38 Exp $
REQUIRE get-string ~nn/lib/getstr.f
REQUIRE PLACE lib/ext/string.f
REQUIRE SocketLine ~nn/lib/net/socketline.f
REQUIRE EVAL-SUBST ~nn/lib/subst1.f
REQUIRE [NONAME ~nn/lib/noname.f
REQUIRE toOEM ~nn/lib/convert.f
REQUIRE V$CREATE ~nn/lib/vstring.f
REQUIRE WinErrorMessage ~nn/lib/message.f
REQUIRE { ~nn/lib/local.f

VARIABLE RemHost    HERE 1+ S" localhost" S", 0 C, RemHost !
VARIABLE RemPort    2002 RemPort !

VARIABLE CON-DONT-ALLOC

SocketLine POINTER sl
 
VARIABLE CON-IOR

: ?CON-ERROR ( ior -- )
    DUP CON-IOR !
    ?DUP
    IF 
[ DEBUG? ] [IF]  ." ERROR # " DUP . WinErrorMessage TYPE CR [ELSE] DROP [THEN]
    THEN
;

: Connect
    [NONAME
        SocketLine NEW TO sl
        RemPort @ sl vPort !
        RemHost @AZ sl Addr!
        sl Create
        sl Connect
    NONAME] CATCH DUP ?CON-ERROR
;

: Disconnect
    [NONAME
       sl Close
       sl SELF DELETE
    NONAME] CATCH DUP ?CON-ERROR
;
: Send ( a u -- ior ) 
    [NONAME 
        toANSI  sl WriteLine
    NONAME] CATCH DUP IF >R 2DROP R> THEN DUP ?CON-ERROR ;

0 VALUE INP-BUF
: Receive ( -- a u )
    INP-BUF ?DUP IF V$FREE THEN
    1024 V$CREATE TO INP-BUF
    INP-BUF V$0!
    [NONAME
        BEGIN
            sl ReadLine 
\ [ DEBUG? ] [IF]   2DUP TYPE CR [THEN]
CON-DONT-ALLOC @ 
            IF  TYPE CR
            ELSE
                INP-BUF V$+!
                CRLF INP-BUF V$+!
            THEN
        AGAIN    
    NONAME] CATCH DUP ?CON-ERROR
    INP-BUF V$@ ROT
; 

: Console \ hostname port ( -- )
    get-string ?DUP 
    IF S>ZALLOC RemHost !
       get-number ?DUP
       IF RemPort ! THEN
    ELSE
        SocketsStartup DROP
        256 PAD gethostname 0=
        IF PAD ASCIIZ> S>ZALLOC RemHost ! THEN
        SocketsCleanup DROP
    THEN
      [NONAME
          Connect
      NONAME] CATCH DROP
    BYE
;

: Request ( a u -- a1 u1 ior )
\    ." [" DEPTH . CR
    Connect ?DUP 0=
    IF
        Send ?DUP 0=
        IF
            Receive DUP -1002 = IF DROP 0 THEN
        ELSE
            S" " ROT
        THEN
        Disconnect DROP
    ELSE
        >R 2DROP S" " R>
    THEN
\    ." ]" DEPTH . CR
;
