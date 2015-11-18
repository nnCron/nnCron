\ $Id: menu.f,v 1.3 2004/11/15 20:46:05 nncron38 Exp $
\ Author: Nicholas Nemtsev
\ Creation time: 2004-11-15 

VARIABLE TRAY-MENU-LIST
VARIABLE itemId
VARIABLE defaultId
VARIABLE selectedItemId
VARIABLE hmenu

CLASS: MenuItem
    var vId
    var vName
    var vAct
    var vPar
    M: ?set ( a u v ) >R ?DUP IF S>ZALLOC ELSE DROP 0 THEN R> ! ; 
    CONSTR: init ( id aname u1 aact u2 apar u3 ? -- )
        vPar ?set
        vAct ?set
        vName ?set
        vId !  ;
    DESTR: free
        vPar @ ?FREE
        vAct @ ?FREE
        vName @ ?FREE
    ;

;CLASS

XMLPARSER: TrayMenuXML
    : menu 
        200 itemId !
        TRAY-MENU-LIST 0! 
        POPUPMENU 
        defaultId 0!
        ;
    : /menu END-MENU hmenu ! ;
    : item
        S" name" tAtt itemId @ MENUITEM
        FALSE S" default" tAttYes? IF itemId @ defaultId ! THEN
        itemId @ S" name" tAtt S" action" tAtt S" par" tAtt MenuItem NEW
        TRAY-MENU-LIST AddNode
        itemId 1+!
    ;
    : separator/ MENUSEPARATOR ;
    : popup  S" name" tAtt S>ZALLOC POPUP   ;
    : /popup DUP ASCIIZ> END-POPUP FREE DROP ;
;XMLPARSER

: START-MENU-ITEM ( id -- )
    selectedItemId !
    [NONAME
        NodeValue >R
        WITH MenuItem
        R@ => vId @  selectedItemId @ =
        IF
            R@ => vAct @ ?DUP 
                IF ASCIIZ>  ." action=" 2DUP TYPE CR 
                   R@ => vPar @AZ ." par=" 2DUP TYPE CR
                   ACTION DROP \ пока неясно, что делать
                THEN
            DoListEXIT
        THEN
        ENDWITH
        RDROP
    NONAME]
    TRAY-MENU-LIST DoList 
;

: get-menu ( -- h ior)
    hmenu 0!
    S" get-menu" S" " ['] TrayMenuXML REQUEST-AND-PARSE 
    hmenu @ SWAP
;

: CalcMenuYX ( -- y x)
    0 0 SP@ GetCursorPos DROP
;
\ : MakePopup
\     S" <?xml" SEARCH IF
\     ( S" menu.xml" FILE) ['] TrayMenuXML JenXPARSE
\     ELSE 2DROP THEN
\ ;

