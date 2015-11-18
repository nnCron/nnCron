S" ~nn/lib/base64.f" INCLUDED

: EncP ( a u -- a1 u1)
    5 TO 64offset
    PAD base64 2DUP + 0!
    0 TO 64offset
;

: DecP ( a u -- a1 u1)
    5 TO 64offset
    PAD debase64 2DUP + 0!
    0 TO 64offset
;
