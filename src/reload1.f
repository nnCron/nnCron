S" ~nn/lib/lh.f" INCLUDED
S" ~nn/lib/wincon.f"  LH-INCLUDED
S" ~nn/lib/usedll.f"  INCLUDED
UseDLL KERNEL32.DLL
UseDLL USER32.DLL

REQUIRE JMP ~nn/lib/jmp.f

: ServiceName S" NNCronD" ;
: CtrlClassName S" NNCronCtrlClassD" ;

2002 CONSTANT TAB_RELOAD


WINAPI: FindWindowA USER32.DLL

: MAIN
    0 CtrlClassName DROP FindWindowA ?DUP
    IF >R
        0 0 TAB_RELOAD R> SendMessageA DROP
    THEN
    BYE
;


' MAIN TO <MAIN>
0 MAINX !
' BYE ' QUIT JMP

S" reload.exe" SAVE BYE