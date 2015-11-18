WINAPI: PlaySound winmm.dll

: PLAY-SOUND ( a u -- )
    DROP
    SND_SYNC SND_FILENAME OR SND_NODEFAULT OR SWAP
    0 SWAP
    PlaySound 
\    [ DEBUG? ] [IF] DUP 0= IF ." Sound error" THEN [THEN] 
    DROP
;
