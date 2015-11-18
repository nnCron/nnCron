REQUIRE SocketLine ~nn/lib/net/socketline.f
REQUIRE <ACCEPT> ~nn/lib/spf4/con_io.f
REQUIRE [NONAME ~nn/lib/noname.f
REQUIRE EVAL-SUBST ~nn/lib/subst1.f
REQUIRE GLOBAL ~nn/lib/globalloc.f
REQUIRE FIT-MASK? ~nn/lib/masks.f
REQUIRE GET ~nn/lib/mutex.f

USER LIRC-IOR
VECT LIRC-LOG
VECT LIRC-ON-CONNECT     ' NOOP TO LIRC-ON-CONNECT
VECT LIRC-ON-DISCONNECT  ' NOOP TO LIRC-ON-DISCONNECT

VARIABLE RemAllowed
VARIABLE RemDisallowed


:NONAME EVAL-SUBST TYPE CR ; TO LIRC-LOG

MODULE: LIRCFER

: ?LIRC-ERROR
    ?DUP IF LIRC-IOR ! S" lirc server error # %LIRC-IOR @%." LIRC-LOG THEN
;

Socket POINTER ss   \ server socket
SocketLine POINTER sl

: DO-LIRC ( socket -- )
    [NONAME
      SocketLine NEW TO sl
      DUP
      ->CLASS Socket vSock @   sl vSock !
      DELETE
      S" Connection is established." LIRC-LOG
      BEGIN
        S" 0000000000eab154 00 play myremote" sl WriteLine
        10000 PAUSE
      AGAIN
    NONAME] CATCH ERROR
;

:NONAME ( port -- )
    DECIMAL
    S0 @ SP! R0 @ RP!
    [NONAME
\ *     SocketLine NEW TO ts
\ *     snif vTargetHost @ ASCIIZ> ts Addr!
\ *     snif vTargetPort @ ts vPort !
\ *     ts Create
\ *     ts Connect
    Socket NEW TO ss
    ss Create
    ss vPort ! ss Bind ss Listen
    S" winlirc server is started." LIRC-LOG
    BEGIN
      ss Accept DO-LIRC
    AGAIN
    NONAME] CATCH ERROR
; TASK: WINLIRC-SERVER

EXPORT

: START-WINLIRC-SERVER ( port -- )
    WINLIRC-SERVER START  CLOSE-FILE DROP ;

;MODULE

8765 START-WINLIRC-SERVER
