REQUIRE Control ~nn/lib/win/control.f
REQUIRE RichEdit ~nn/lib/win/controls/richedit.f
REQUIRE RES! ~nn/lib/res.f
REQUIRE <TIB ~nn/lib/tib.f
REQUIRE ON ~nn/lib/onoff.f
REQUIRE get-number ~nn/lib/getstr.f
REQUIRE POPUPMENU ~nn/lib/win/menu.f
REQUIRE CommPos?  ini.f
REQUIRE FILE ~nn/lib/subst1.f

: PUSH-WINDOW ( hwnd -- prev-hwnd)
    DUP SetActiveWindow >R
    DUP SetFocus DROP
    DUP SetForegroundWindow DROP
        BringWindowToTop DROP
    R>
;

CLASS: SplashClass <SUPER WinClass

CONSTR: init
     init
     S" nnCron Splash Class" DROP lpszClassName !
     style @ CS_SAVEBITS OR style !     
;
     
;CLASS

SplashClass POINTER pSplashClass

CLASS: SplashDialog <SUPER FrameWindow

110 VALUE width
50  VALUE height
13 CONSTANT but_h
37 CONSTANT but_w
    var vLines
    var vLen
    var vSplash
    var vTimeOut
    var vCurWin
    var vBkColor
    var vText
    var vMaxLen
    var vHeight
    var vWidth
    var vNL

CONSTR: init
    init
    WS_BORDER WS_POPUP OR vStyle !
    WS_EX_TOPMOST WS_EX_TOOLWINDOW OR vExStyle !    
;    

Font POINTER CurFont

DESTR: free
    vClass @ TO pSplashClass
    pSplashClass hbrBackground @ DeleteObject DROP
    CurFont Delete
    free
;

:NONAME { hwnd msg event time -- }
   BYE
\ TRUE hwnd HANDLE>OBJ ->CLASS  SplashDialog vClose !
; WNDPROC: TimeOutProc

W: WM_NCHITTEST  HTCAPTION ;

W: WM_CREATE
    CommColor? 0= IF 0 THEN handle @ GetDC DUP >R SetTextColor DROP    
    CommColorBg? 0= IF vBkColor @ THEN R@ SetBkColor DROP
    Font NEW TO CurFont
    CommFont? 0= IF S" MS Sans Serif" THEN DROP CurFont lpszFace !
    CommFontSize? 0= IF 16 THEN CurFont height !
    CurFont Create
    CurFont handle @ R@ SelectObject DROP
    RDROP
    0
;

VM: Type S" nnCron Splash Class" ;

: NextLine ( -- a u ? ) 
    10 SKIP 13 PARSE DUP ?DUP 0= 
    IF EndOfChunk 0= THEN ;

: Center?  CommSize? IF 2DROP TRUE ELSE FALSE THEN ;
VARIABLE y
VM: OnPaint
\   GetRect SP@ pSplashClass hbrBackground @ SWAP dc FillRect . GetLastError . CR
\   2DROP 2DROP
   Center? IF TA_CENTER dc SetTextAlign DROP THEN
   vText @ ASCIIZ>
   <TIB
        0 y !
        BEGIN NextLine WHILE
            SWAP  2 y @     CommFontSize? 0= IF 8 ELSE 2/ THEN * +  
            Center? IF vWidth @ 2/ ELSE 4 THEN
            SWAP ToPixels SWAP dc TextOutA DROP 
            y 1+!
        REPEAT
        2DROP
   TIB>
;

\ 101 CONSTANT MI_ABOUT
102 CONSTANT MI_CLOSE
        
\ MM: MI_ABOUT S" Splash by Nicholas Nemtsev" ShowMessage ;

MM: MI_CLOSE BYE ;
 
VM: CreatePopup
   POPUPMENU
\     S" About" MI_ABOUT MENUITEM
     S" Close" MI_CLOSE MENUITEM
   END-MENU
;

W: WM_NCRBUTTONDOWN WM_CONTEXTMENU SELF WM: ;

M: BringBack  vCurWin @ PUSH-WINDOW DROP  ;
\ WINAPI: GetTextExtentPoint32 GDI32.DLL
: CalcSize ( -- w h)
   vMaxLen 0!
   vNL 0!
   vHeight 0!
   vText @ ASCIIZ>
   <TIB
        BEGIN NextLine WHILE
           2>R 0 0 SP@ 2R> SWAP handle @ GetDC GetTextExtentPoint32A
           IF 
              DUP vMaxLen @ > 
              IF vMaxLen ! ELSE DROP THEN
              DUP vHeight @ > 
              IF vHeight ! ELSE DROP THEN 
           ELSE 2DROP THEN
           vNL 1+! 
        REPEAT
        2DROP
   TIB>
   vHeight @ vNL @ * vHeight !
   vMaxLen @ vHeight @  FromPixels 
   5 + vHeight !
   10 + vWidth !
   vWidth @ vHeight @ 
;
M: SET-SIZE ( w h -- )
    CommSize?
    IF 2SWAP 2DROP FromPixels 2DUP vHeight ! vWidth ! THEN
    SetSize ;

M: Create 
    GetForegroundWindow vCurWin !
    SplashClass NEW TO pSplashClass
    0 ( 0xEE 0xE8 0xAA rgb) CommColorBg? 0= IF COLOR_INFOBK GetSysColor THEN DUP vBkColor !
        BS_SOLID SP@ CreateBrushIndirect  pSplashClass hbrBackground !
    2DROP DROP

    pSplashClass Register DROP

    pSplashClass SELF vClass !
    0 Create
    AutoCreate
    vTimeOut @ 
    IF ['] TimeOutProc vTimeOut @ 1000 * 123 handle @ SetTimer DROP THEN

    CalcSize CommPos?
    IF SetPos SET-SIZE
    ELSE 
        2DUP ToPixels GetDesktopSize 
            ROT  - 30 - 0 MAX >R
            SWAP - 30 - 0 MAX R> SetPos
\        0 0 SP@ GetCursorPos DROP SWAP SetPos
        SET-SIZE
        \ Center 
   THEN

    S" nnCron HINT window" SetText
;

M: MoveToHome { \ xt yt x0 y0 hy hx nstep yrest xrest -- }
    CommPos? 0=
    IF
        GetPos TO y0 TO x0
        vWidth @ vHeight @ ToPixels DROP GetDesktopSize DROP SWAP - 30 - 0 MAX 30 
        TO yt TO xt
        20 TO nstep
        xt x0 - nstep / TO hx
        yt y0 - nstep / TO hy
        nstep 1+ 1 DO x0 I hx * + y0 I hy * + SetPos 10 PAUSE LOOP
    xt yt 
    THEN
    SetPos
;

M: Flip { \ dc rgn -- }
    handle @ UpdateWindow DROP
    handle @ GetDC TO dc
    GetWindowSize SWAP 0 0 CreateRectRgn TO rgn 
    rgn dc SelectObject DROP
    4 0 DO rgn dc InvertRgn DROP 100 PAUSE LOOP
    rgn DeleteObject DROP
    dc handle @ ReleaseDC DROP
;

M: Text ( a u --) 
   S>ZALLOC vText ! 
;

;CLASS

SplashDialog POINTER msg


: (TimeSplash) ( time a u --)
    2>R
    SplashDialog NEW TO msg
    msg vTimeOut !
    2R> msg Text
    msg Create
    msg Show 
    msg BringBack    
    msg Flip
    msg MoveToHome
    msg Run
    msg Delete
;

: GetText ( -- a u )
    BL SKIP >IN @ >R
    NextWord S" FILE:" COMPARE 0=
    IF BL SKIP 1 PARSE 2DUP + 0 SWAP C! 2DUP FILE
        2SWAP DELETE-FILE DROP
    ELSE
        R@ >IN !
        1 PARSE
    THEN
    RDROP
;
: Hint 0 GetText (TimeSplash)  BYE ;

\ Message 123456789012345678901234567890\12345678901234567890
\ Message dkfsdhfsj

: TimeHint get-number GetText (TimeSplash) BYE ;

\ Hint FILE: nncron1.ini
