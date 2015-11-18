\ $Id: request.f,v 1.4 2004/11/17 10:20:23 nncron38 Exp $
\ Author: Nicholas Nemtsev
\ Creation time: 2004-11-15 

STRING-FROM-FILE: request.xml request.xml

XMLPARSER: replyXML
;XMLPARSER

: REQUEST ( a1 u1 a2 u2 -- a3 u3 ior)
    ." enter=" .S CR
    request.xml  EVAL-SUBST 2DUP TYPE CR Request
    DUP 0= IF >R 2DUP TYPE CR R> ELSE ." REQUEST ERROR # " DUP . THEN
    ." exit=" .S CR
    ;

: REQUEST-AND-PARSE ( a1 u1 a2 u2 xtwid -- ior )
    >R
    REQUEST ?DUP 0=
    IF
        R@ JenXPARSE 0
    ELSE
        >R 2DROP R>
    THEN
    RDROP
;
    
: ACTION { a1 u1 a2 u2 -- ior } 
    a1 u1 a2 u2 ['] replyXML REQUEST-AND-PARSE  
    a1 u1 S" exit-cron" COMPARE 0= IF C" BYE" FEX THEN
;

