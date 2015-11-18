\ REQUIRE WSAStartup ~nn/lib/sock.f
REQUIRE Socket ~nn/lib/net/socket.f
\ S" ~nn/lib/sock.f" INCLUDED
WINAPI: IcmpCreateFile ICMP.DLL
WINAPI: IcmpCloseHandle ICMP.DLL
WINAPI: IcmpSendEcho ICMP.DLL
\ WINAPI: WSAStartup      WSOCK32.DLL
\ WINAPI: WSAGetLastError WSOCK32.DLL

\ WINAPI: inet_addr       WSOCK32.DLL
\ WINAPI: gethostbyname   WSOCK32.DLL

\ : SocketsStartup ( -- ior )
\   HERE 257 WSAStartup
\ ;

\ : GetHostIP ( addr u -- IP ior )
\   OVER inet_addr DUP -1 <> IF NIP NIP 0 EXIT ELSE DROP THEN
\   DROP gethostbyname DUP IF 3 CELLS + @ @ @ 0
\                          ELSE WSAGetLastError THEN
\ ;

\    icmp_echo_reply = packed record
\         Address : u_long;            // Адрес отвечающего
\         Status : u_long;             // IP_STATUS (см. ниже)
\         RTTime : u_long;             // Время между эхо-запросом и эхо-ответом 
\                          // в миллисекундах
\         DataSize : u_short;              // Размер возвращенных данных
\         Reserved : u_short;              // Зарезервировано
\         Data : Pointer;          // Указатель на возвращенные данные
\         Options : ip_option_information; // Информация из заголовка IP
\     end;

\ IP_STATUS_BASE 11000
\ IP_SUCCESS 0
\ IP_BUF_TOO_SMALL 11001
\ IP_DEST_NET_UNREACHABLE 11002
\ IP_DEST_HOST_UNREACHABLE 11003
\ IP_DEST_PROT_UNREACHABLE 11004
\ IP_DEST_PORT_UNREACHABLE 11005
\ IP_NO_RESOURCES 11006
\ IP_BAD_OPTION 11007
\ IP_HW_ERROR 11008
\ IP_PACKET_TOO_BIG 11009
\ IP_REQ_TIMED_OUT 11010
\ IP_BAD_REQ 11011
\ IP_BAD_ROUTE 11012
\ IP_TTL_EXPIRED_TRANSIT 11013
\ IP_TTL_EXPIRED_REASSEM 11014
\ IP_PARAM_PROBLEM 11015
\ IP_SOURCE_QUENCH 11016
\ IP_OPTION_TOO_BIG 11017
\ IP_BAD_DESTINATION 11018
\ IP_ADDR_DELETED 11019
\ IP_SPEC_MTU_CHANGE 11020
\ IP_MTU_CHANGE 11021
\ IP_UNLOAD 11022
\ IP_GENERAL_FAILURE 11050
\ MAX_IP_STATUS IP_GENERAL_FAILURE
\ IP_PENDING 11255


0
1 -- ipTtl \ u_char Ttl;        /* Time To Live (used for traceroute) */
1 -- ipTos \    u_char Tos;     /* Type Of Service (usually 0) */
1 -- ipFlags \    u_char Flags;     /* IP header flags (usually 0) */
1 -- ipOptionsSize \    u_char OptionsSize; /* Size of options data (usually 0, max 40) */
1 -- ipOptionsData \    u_char FAR *OptionsData;   /* Options data buffer */
CONSTANT /IPINFO \ } IPINFO, *PIPINFO, FAR *LPIPINFO;

0
1 CELLS -- icmpAddress \     u_long Address;    /* source address *.
1 CELLS -- icmpStatus \     u_long Status;  /* IP status value (see below) */
1 CELLS -- icmpRTTime \     u_long RTTime;  /* Round Trip Time in milliseconds */
2       -- icmpDataSize \     u_short DataSize;     /* reply data size */
2       -- icmpReserved \     u_short Reserved;     /* */
1 CELLS -- icmpData \     void FAR *Data;   /* reply data buffer */
/IPINFO -- icmpOptions \     struct ip_option_information Options; /* reply options */
CONSTANT /ICMPECHO \ } ICMPECHO, *PICMPECHO, FAR *LPICMPECHO;

8096 VALUE PING-BUF-LEN
5000 VALUE PING-TIMEOUT
32   VALUE PING-LEN
USER-VALUE PING-RETRY
USER-VALUE PING-RES
10   VALUE PING-NREPLY
64   VALUE PING-TTL
0    VALUE PING-TOS
\ : sock-start  sock-init 0= IF SocketsStartup THROW TRUE TO sock-init THEN ;
    
: ping ( a u -- ?)
    { \ ip h ipi req echo -- ?}
    GetHostIP 
[ DEBUG? ] [IF] ." GetHostIP=" DUP . CR [THEN]
    THROW 
[ DEBUG? ] [IF] ." IP=" DUP HEX . DECIMAL CR [THEN]
    TO ip
    IcmpCreateFile DUP INVALID_HANDLE_VALUE =
[ DEBUG? ] [IF] ." IcmpCreateFile=" DUP . CR [THEN]
    IF DROP 
        GetLastError 
[ DEBUG? ] [IF] ." Error=" DUP . CR [THEN]
        THROW 
    THEN
    TO h
    /IPINFO TEMP-ALLOC TO ipi
    /ICMPECHO PING-BUF-LEN + TEMP-ALLOC TO echo
    PING-BUF-LEN TEMP-ALLOC TO req
    PING-TTL ipi ipTtl C!
    PING-TTL ipi ipTos C!
    
    PING-LEN 0 DO I 32 + req I + C! LOOP
    
    -1 TO PING-RES
    PING-RETRY 1 MAX 0
    DO
       PING-TIMEOUT PING-BUF-LEN echo
       ipi
       PING-LEN  req
       ip  h IcmpSendEcho
[ DEBUG? ] [IF] ." IcmpSendEcho=" DUP . CR [THEN]
       IF 
          echo icmpStatus @ DUP TO PING-RES 0=
[ DEBUG? ] [IF] ." PING-RES=" PING-RES . echo icmpRTTime @ . CR [THEN]
          IF
              h IcmpCloseHandle DROP
              UNLOOP
              TRUE EXIT 
          THEN
       THEN
    LOOP
    h IcmpCloseHandle DROP
    FALSE 
;

\ : WSOCK32.DLL? ( -- ?)
\  S" WSOCK32.DLL" DROP LoadLibraryA ?DUP 0=
\  IF FALSE EXIT THEN \ ABORT" Library not found"
\  CLOSE-FILE DROP
\  TRUE
\ ;

\ VARIABLE pingINIT?

: (PING) ( addr u cnt -- ?)
    TO PING-RETRY
\    WSOCK32.DLL? 0=
\    IF  S" Error: WSOCK32.DLL not found." CRON-LOG 
\       2DROP 0 EXIT
\    THEN
\    sock-start    
     WITH Socket
         ( pingINIT? @ 0= IF) ?INIT ( TRUE pingINIT? ! THEN)
         ['] ping CATCH
         ?CLEAN
     ENDWITH
     THROW
;

: PING ['] (PING) CATCH ?DUP
    IF [ DEBUG? ] [IF] ." Ping error # " DUP . CR [THEN] 2DROP 2DROP 0 THEN ;

