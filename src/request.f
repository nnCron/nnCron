\ $Id: request.f,v 1.3 2004/11/16 21:29:59 nncron38 Exp $

REQUIRE JenXPARSE ~nn/lib/xml/jenx.f
REQUIRE STRING-FROM-FILE: ~nn/lib/fstring.f

STRING-FROM-FILE: tray/menu.xml tray\menu.xml
STRING-FROM-FILE: tray/options.xml tray\options.xml

USER REQUEST-SESSIONID

USER menu-item-buf
: menu-item-buf-init 
    menu-item-buf @ 0= IF 256 V$CREATE menu-item-buf ! THEN
    menu-item-buf @ V$0!
;

: menu-item-buf+ menu-item-buf @ V$+! ;
: "attrib" 
    menu-item-buf+ S" =" menu-item-buf+
    QUOTE menu-item-buf+ menu-item-buf+ QUOTE menu-item-buf+ 
    S"  " menu-item-buf+ ;

: ?"attrib" 2 PICK IF "attrib" ELSE 2DROP 2DROP THEN ;
: <item> ( S" par" S" act" S" name" -- )
    S" <item " menu-item-buf+ 
    S" name" ?"attrib"
    S" action" ?"attrib"
    S" par" ?"attrib"
    S" />" menu-item-buf+
    CRLF menu-item-buf+
;

: crontab-menu-item { crontab-item \ tab-name menu-id -- }
    crontab-item NodeValue TAB-FILENAME @ TO tab-name
    tab-name COUNT EVAL-SUBST EXIST?
    IF
        tab-name COUNT EVAL-SUBST 
        S" ses-edit-crontab"
        2OVER
            S" Crontab: " PAD PLACE PAD +PLACE PAD +PLACE0
            PAD COUNT <item>
    THEN
;

: edit-crontab-menu-items  
    menu-item-buf-init 
    ['] crontab-menu-item TAB-LIST DoList
    menu-item-buf @ V$@
;
: task-menu-item { cron-node act u \ menu-id -- ? }
    cron-node CRON-NAME @ COUNT CLASSIC? 0=
\ *     only-crontab ?DUP IF COUNT 2DUP TYPE SPACE cron-node CRON-FILENAME @ COUNT 2DUP TYPE CR COMPARE 0= AND THEN
    IF
        cron-node azTaskName act u 2OVER <item>
        TRUE
    ELSE
        FALSE
    THEN
;

: task-menu-items { action u-action list \ cnt --  }
    0 TO cnt
    list
    BEGIN @ ?DUP WHILE
        DUP CRON-NAME @ 1+ C@
        IF
            DUP action u-action task-menu-item
            IF
                cnt 1+ TO cnt
                cnt #menu-lines > OVER @ 0= 0= AND
                  IF S" <popup name='more...'>" menu-item-buf+ 
                    CRLF menu-item-buf+
                    action u-action ROT RECURSE 
                    S" </popup>" menu-item-buf+ 
                    CRLF menu-item-buf+
                    EXIT 
                  THEN
            THEN
        THEN
    REPEAT
;
 
: edit-task-menu-items 
    menu-item-buf-init 
    S" ses-edit-task" CRON-LIST task-menu-items
    menu-item-buf @ V$@
;
: start-task-menu-items  
    menu-item-buf-init 
    S" ses-start-task" CRON-LIST task-menu-items  
    menu-item-buf @ V$@ ;

: find-task ( a u -- xt/0 )
    OVER 3 S" -- " COMPARE 0=
    IF 3 /STRING THEN
    SFIND 0= IF 2DROP 0 THEN
;
: ses! REQUEST-SESSIONID @ GUI-APP-SESSION! ;
MODULE: ENABLED-REQUESTS
: get-menu tray/menu.xml EVAL-SUBST TYPE CR ;
: get-options tray/options.xml EVAL-SUBST TYPE CR ;
: exit-cron EXIT-CRON ;
: ses-about ses! about ;
: ses-winspy ses! winspy ;
: reload-crontab reload-crontab ;
: ses-options ses! options ;
: ses-help ses! open-help ;
: ses-console ses! START-CONSOLE ;
: ses-show-log ses! show-log ;
: ses-add-task ses! add-new-task ;
: ses-add-reminder ses! add-reminder ;
: disable-cron DISABLE-CRON set-icon ;
: enable-cron ENABLE-CRON set-icon ;
: ses-buy ses! buy ;
: ses-start-task find-task ?DUP IF EXECUTE LAUNCH THEN ;
: ses-edit-task ses! find-task ?DUP IF EXECUTE @ edit-task-action THEN ; 
: ses-edit-crontab ses! edit-file ;
;MODULE


XMLPARSER: requestXML
    : sessionid -cBuff ;
    : /sessionid cBuff@ S>NUM REQUEST-SESSIONID ! ; 
    : request -cBuff -1 REQUEST-SESSIONID ! ;
    : /request C" BYE" FEX ;
    : action
        S" option" tAtt 2DUP TYPE CR
        ?DUP 0= IF DROP THEN
        S" name" tAtt 2DUP TYPE CR
        ALSO ENABLED-REQUESTS CONTEXT @ PREVIOUS
        SEARCH-WORDLIST IF  EXECUTE ELSE 2DROP THEN
    ;
;XMLPARSER

: <?xml
    JenXINIT
    ONLY FORTH
    ALSO requestXML 
    ['] <?xml CATCH DROP
    PREVIOUS
    JenXFREE
;

