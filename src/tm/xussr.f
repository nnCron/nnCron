REQUIRE Control ~nn/lib/win/control.f
REQUIRE RichEdit ~nn/lib/win/controls/richedit.f
REQUIRE RES! ~nn/lib/res.f
REQUIRE <TIB ~nn/lib/tib.f
REQUIRE ON ~nn/lib/onoff.f
REQUIRE get-number ~nn/lib/getstr.f
REQUIRE EVAL-SUBST ~nn/lib/subst1.f
REQUIRE WDay@ ~nn/lib/time.f
REQUIRE ICOMPARE agents/pop3rules/wcmatch.f
REQUIRE xUR? ~nn/lib/regkey.f

CEZ: xPASS GET-CUR-TIME WDay@ 159 + RES ;CEZ

CLASS: xRegDialog <SUPER FrameWindow

150 VALUE width
100  VALUE height
13 CONSTANT but_h
37 CONSTANT but_w

: header S" nnCron: %466 RES%" EVAL-SUBST ;
    Static OBJ st_user
        :init a v 0 1 12 1 ps 467 RES text ;
    Edit OBJ ed_user
        :init a v 1 1 12 1 ps ;

    Static OBJ st_pass
        :init a v 3 1 12 1 ps 468 RES text ;
    Edit OBJ ed_pass
        :init a v 4 1 12 1 ps ;

    0 VALUE h1
    : wr h1 WRITE-LINE THROW ;
    CEZ: l1 S" SP6Q1C LQ62II UN3VPF " wr
            S" UCKF9X XBWJMT MUBQZ9 1R8ETCW 1UURT2G 1Z07P40 " wr
            S" G7KKSL UCQ7TS TSO6ZY R0Z8SG WL4VP0 " wr
            S" 8XWXFO DN8ZLE DDEZW1 9PS " wr
            S" G6ACSY E7JFOG 1F " wr ;CEZ

    CEZ: (onOk)
        ed_user GetText -TRAILING xUR12?
        ed_pass GetText -TRAILING xPASS  ICOMPARE 0= AND
        IF
            kfil R/W CREATE-FILE THROW TO h1
            l1
            h1 CLOSE-FILE THROW
            0 header DROP FNCUO DROP 0 MessageBoxA DROP
            0 Close
        ELSE
            0 header DROP S" Invalid code" DROP 0 MessageBoxA DROP
            ed_pass SetFocus
        THEN
    ;CEZ

    M: onOk ['] (onOk) CATCH DROP ;

    Button OBJ but_ok
        :init a v but_w 2* 10 + 70 pos
            but_w but_h size
            200 RES text ['] onOk OnClick !
            WS_TABSTOP BS_DEFPUSHBUTTON OR vStyle ! ;
    M: onCancel 1 Close ;
    Button OBJ but_cancel
        :init a v but_w 10 - 70 pos  but_w but_h size
            201 RES text ['] onCancel OnClick !
            WS_TABSTOP vStyle ! ;

: processKeyDown
    wparam @
    CASE
    VK_RETURN OF
                onOk
                TRUE
           ENDOF
        FALSE SWAP
    ENDCASE
;

M: Create
     0 Create
     AutoCreate

     width height Center
     header  SetText
\     but_ok SetFocus
    ed_user SetFocus
    ['] processKeyDown onKeyDown !
;



;CLASS

xRegDialog POINTER reg

: xReg
    S" %ModuleDirName%res\russian.txt" EVAL-SUBST RES!
    xRegDialog NEW TO reg
    reg Create
    reg Show
    reg Run
    reg Delete
    BYE ;

\ xReg
