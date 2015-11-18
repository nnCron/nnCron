\ $Id: options.f,v 1.5 2005/10/04 15:24:19 nncron38 Exp $
\ Author: Nicholas Nemtsev
\ Creation time: 2004-11-15 

VARIABLE OPTIONS
XMLPARSER: optionsXML
    : options         
        GLOBAL
        [NONAME NodeValue DUP @ FREE DROP CELL+ @ FREE DROP NONAME] OPTIONS DoList
        OPTIONS FreePairList OPTIONS 0! 
        LOCAL
    ;

    : /options ;
    : option
        S" name" tAtt ?DUP
        IF  
            S" value" tAtt ?DUP
            IF GLOBAL S>ZALLOC ROT ROT S>ZALLOC OPTIONS SetPropZ LOCAL
            ELSE 2DROP THEN
        ELSE DROP THEN
    ;
;XMLPARSER

: OPTION DROP OPTIONS GetPropZ ?DUP IF ASCIIZ> ELSE S" " THEN ;

: get-options S" get-options" S" " ['] optionsXML REQUEST-AND-PARSE ;

: DISABLE-CRON? S" disabled" OPTION S" -1" COMPARE 0= ;
