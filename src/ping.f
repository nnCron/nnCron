\ MARKER P

\ S" ~nn/lib/wincon.f" INCLUDED
S" ~nn/lib/sock.f" INCLUDED
\ S" win32.f" INCLUDED
DECIMAL

USER-VALUE PING-RETRY

8 CONSTANT ICMP_ECHO
0 CONSTANT ICMP_ECHOREPLY 
 
8 CONSTANT ICMP_MIN     \  minimum 8 byte icmp packet (just header) 
 
                         \ /* The IP header */ 
0                        \ typedef struct iphdr { 
4 -- IP.h_len&version    \ unsigned int h_len:4;   // length of the header 
                         \ unsigned int version:4; // Version of IP 
1 -- IP.tos              \ unsigned char tos;      // Type of service 
2 -- IP.total_len        \ unsigned short total_len; // total length of the packet 
2 -- IP.ident            \ unsigned short ident; // unique identifier 
2 -- IP.frag_and_flags   \ unsigned short frag_and_flags; // flags 
1 -- IP.ttl              \ unsigned char  ttl;  
1 -- IP.proto            \ unsigned char proto; // protocol (TCP, UDP etc) 
2 -- IP.checksum         \ unsigned short checksum;       // IP checksum 
 
4 -- IP.sourceIP         \ unsigned int sourceIP; 
4 -- IP.destIP           \ unsigned int destIP; 
CONSTANT /IpHeader
: IP.h_len@ IP.h_len&version @ 0xF AND ;
: IP.h_version@ IP.h_len&version @ 4 RSHIFT 0xF AND ;
 
\ ICMP header 
 
0                       \ typedef struct _ihdr { 
1 -- ICMP.i_type        \  BYTE i_type; 
1 -- ICMP.i_code        \ BYTE i_code; /* type sub code */ 
2 -- ICMP.i_cksum       \ USHORT i_cksum; 
2 -- ICMP.i_id          \ USHORT i_id; 
2 -- ICMP.i_seq         \ USHORT i_seq; 
\  /* This is not the std header, but we reserve space for time */ 
8 -- ICMP.timestamp     \ ULONG timestamp; 
CONSTANT /IcmpHeader
 
0xFFFF  CONSTANT STATUS_FAILED
32      CONSTANT DEF_PACKET_SIZE
1024    CONSTANT MAX_PACKET
 
: xmalloc ( size -- ptr) HEAP_ZERO_MEMORY GetProcessHeap HeapAlloc ;
: xfree   ( ptr -- res)  0 GetProcessHeap HeapFree ;
 
\ void fill_icmp_data(char * icmp_data, int datasize){
\  IcmpHeader *icmp_hdr;
\  char *datapart;

: fill_icmp_data ( ptr size -- )
  SWAP >R           \ icmp_hdr = (IcmpHeader*)icmp_data;
  R@ ICMP_MIN ERASE
  ICMP_ECHO R@ ICMP.i_type C!          \ icmp_hdr->i_type = ICMP_ECHO;
  GetCurrentProcessId R@ ICMP.i_id W!
        \ icmp_hdr->i_id = (USHORT)GetCurrentProcessId();
  R> /IcmpHeader + 
  SWAP /IcmpHeader - 0 MAX [CHAR] E FILL
                        \  datapart = icmp_data + sizeof(IcmpHeader);
                        \  // Place some junk in the buffer.
                        \  memset(datapart,'E', datasize - sizeof(IcmpHeader));
;

\ USHORT checksum(USHORT *buffer, int size) {
\  unsigned long cksum=0;
: checksum ( buf size -- cksum)
    0 >R
    BEGIN DUP 1 > WHILE     \  while(size >1) {
       OVER W@ R> + >R      \    cksum+=*buffer++; size -=sizeof(USHORT); }
       2- SWAP 2+ SWAP
    REPEAT
    IF C@ R> + >R         \  if(size ) cksum += *(UCHAR*)buffer;
    ELSE DROP THEN
    R>                              \  cksum = (cksum >> 16) + (cksum & 0xffff);
    DUP 16 RSHIFT SWAP 0xFFFF AND +
    DUP 16 RSHIFT +                 \  cksum += (cksum >>16);
                                    \  return (USHORT)(~cksum);
    0xFFFF XOR
    0xFFFF AND
;

USER-VALUE iphdr
USER-VALUE icmphdr
USER-VALUE iphdrlen
USER-VALUE sockRaw     \  SOCKET sockRaw; 
USER-CREATE ping-dest /sockaddr_in  USER-ALLOT    \  struct sockaddr_in dest,from; 
USER-CREATE ping-from /sockaddr_in  USER-ALLOT
USER-CREATE ping-host-name 2 CELLS USER-ALLOT

USER-VALUE ping-datasize \ int bread,datasize; 
USER ping-fromlen \  int fromlen = sizeof(from); 

USER-VALUE ping-dest-ip    \  char *dest_ip; 
USER-VALUE ping-icmp-data  \  char *icmp_data; 
USER-VALUE ping-recvbuf    \  char *recvbuf; 
USER-VALUE ping-addr   \  unsigned int addr=0; 
USER-VALUE ping-seq-no \  USHORT seq_no = 0; 
USER ping-cnt

\ The response is an IP packet. We must decode the IP header to locate
\ the ICMP data
\ void decode_resp(char *buf, int bytes,struct sockaddr_in *from) {
\   IpHeader *iphdr;
\   IcmpHeader *icmphdr;
\   unsigned short iphdrlen;
: decode_resp ( buf len -- ?)
    SWAP TO iphdr   \ iphdr = (IpHeader *)buf;
    iphdr IP.h_len@ 4 * TO iphdrlen
        \ iphdrlen = iphdr->h_len * 4 ; // number of 32-bit words *4 = bytes
    iphdrlen ICMP_MIN + < IF FALSE EXIT THEN
        \ if (bytes  < iphdrlen + ICMP_MIN) 
        \   printf("Too few bytes from %s\n",inet_ntoa(from->sin_addr));

    iphdr iphdrlen + TO icmphdr \ icmphdr = (IcmpHeader*)(buf + iphdrlen);
    icmphdr ICMP.i_type C@ ICMP_ECHOREPLY <>
    icmphdr ICMP.i_id W@ GetCurrentProcessId <> OR
    IF FALSE EXIT THEN
            \ if (icmphdr->i_type != ICMP_ECHOREPLY) {
            \   fprintf(stderr,"non-echo type %d recvd\n",icmphdr->i_type);
            \   return; }
            \ if (icmphdr->i_id != (USHORT)GetCurrentProcessId()) {
            \   fprintf(stderr,"someone else's packet!\n");
            \   return ; }
    TRUE
        \ printf("%d bytes from %s:",bytes, inet_ntoa(from->sin_addr));
        \ printf(" icmp_seq = %d. ",icmphdr->i_seq);
        \ printf(" time: %d ms ",GetTickCount()-icmphdr->timestamp);
        \ printf("\n");
;

: ping-free
    sockRaw CloseSocket DROP 
    ping-icmp-data xfree DROP
    ping-recvbuf xfree DROP ;

\ int main(int argc, char **argv){ 

USER-VALUE SOCK-RESULT

: ping-err
    WSAGetLastError TO SOCK-RESULT
    DEBUG?
    IF  S" Ping error # %SOCK-RESULT N>S%" CRON-LOG THEN
;
: ?SOCK-ERROR IF ping-err SOCK-RESULT THROW THEN ;
: sock-type  WinNT? IF SOCK_RAW ELSE SOCK_DGRAM THEN ;
: ping ( S" hostname" -- cnt-of-ok)

  ping-host-name 2!    
  IPPROTO_ICMP sock-type AF_INET socket TO sockRaw
  sockRaw INVALID_SOCKET = ?SOCK-ERROR
  1000 sockRaw SetSocketTimeout SOCKET_ERROR = ?SOCK-ERROR
  ping-dest /sockaddr_in ERASE
  ping-host-name 2@ GetHostIP DUP
  IF ping-err
     sockRaw CloseSocket DROP
     THROW
  THEN DROP TO ping-addr
  [ DEBUG? ] [IF] ." PING: " ping-addr NtoA TYPE CR [THEN]

  ping-addr ping-dest sin_addr !
  AF_INET ping-dest sin_family W!
  ping-dest sin_addr @ inet_ntoa TO ping-dest-ip
 
  DEF_PACKET_SIZE /IcmpHeader + TO ping-datasize
  MAX_PACKET xmalloc TO ping-icmp-data
  MAX_PACKET xmalloc TO ping-recvbuf
  ping-recvbuf 0= IF ping-err sockRaw CloseSocket DROP WSAGetLastError THROW THEN  
  ping-icmp-data MAX_PACKET ERASE
  ping-icmp-data ping-datasize fill_icmp_data

  ping-cnt 0!

  PING-RETRY 0
  ?DO  [ DEBUG? ] [IF] ." PING: Retry " I . CR [THEN]
    0 ping-icmp-data ICMP.i_cksum W!
        \ ((IcmpHeader*)icmp_data)->i_cksum = 0; 
    GetTickCount ping-icmp-data ICMP.timestamp !
        \ ((IcmpHeader*)icmp_data)->timestamp = GetTickCount(); 
    ping-seq-no ping-icmp-data ICMP.i_seq W!
    ping-seq-no 1+ TO ping-seq-no
        \ ((IcmpHeader*)icmp_data)->i_seq = seq_no++; 
    ping-icmp-data ping-datasize checksum ping-icmp-data ICMP.i_cksum W!
        \ ((IcmpHeader*)icmp_data)->i_cksum = checksum((USHORT*)icmp_data,datasize); 
    [ DEBUG? ] [IF] ." PING: send" CR [THEN]
    /sockaddr_in ping-dest 0 ping-datasize ping-icmp-data sockRaw sendto
        \  bwrote = sendto(sockRaw,icmp_data,datasize,0,(struct sockaddr*)&dest, 
        \               sizeof(dest)); 
    SOCKET_ERROR =
    IF
        WSAGetLastError WSAETIMEDOUT <>
        IF
            [ DEBUG? ] [IF] ." PING: send error " WSAGetLastError . CR [THEN]
            ping-err
            ping-free
            UNLOOP FALSE EXIT
        THEN
        [ DEBUG? ] [IF] ." PING: send timeout" CR [THEN]
    ELSE
        [ DEBUG? ] [IF] ." PING: receive..." CR [THEN]
        /sockaddr_in ping-fromlen !
        ping-fromlen ping-from 0 MAX_PACKET ping-recvbuf sockRaw recvfrom
        [ DEBUG? ] [IF] ." PING: receive OK" CR [THEN]
        \ bread = recvfrom(sockRaw,recvbuf,MAX_PACKET,0,(struct sockaddr*)&from, 
        \                                             &fromlen); 
        DUP SOCKET_ERROR =
        IF  DROP
            WSAGetLastError WSAETIMEDOUT <>
            IF
                [ DEBUG? ] [IF] ." PING: receive error " WSAGetLastError . CR [THEN]
                ping-err
                ping-free
                UNLOOP FALSE EXIT
            THEN
            [ DEBUG? ] [IF] ." PING: receive timeout" CR [THEN]
        ELSE 
            [ DEBUG? ] [IF] ." PING: decode responce" [THEN]                
            ping-recvbuf SWAP decode_resp
            [ DEBUG? ] [IF] DUP 0= IF ."  not" THEN ."  OK" CR [THEN] 
            IF
                ping-cnt 1+!
            THEN
        THEN
    THEN 
    [ DEBUG? ] [IF] ." PING: wait" CR [THEN]
    1000 PAUSE
  LOOP
  ping-free
\  sockRaw CloseSocket DROP
  ping-cnt @
;
 

: WSOCK32.DLL? ( -- ?)
  S" WSOCK32.DLL" DROP LoadLibraryA ?DUP 0=
  IF FALSE EXIT THEN \ ABORT" Library not found"
  CLOSE-FILE DROP
  TRUE
;

: (PING) ( addr u cnt -- ?)
    TO PING-RETRY
    WSOCK32.DLL? 0=
    IF  S" Error: WSOCK32.DLL not found." CRON-LOG 
       2DROP 0 EXIT
    THEN
    SocketsStartup THROW
    ping 
    SocketsCleanup THROW
;

: PING ['] (PING) CATCH
    [ DEBUG? ] [IF] DUP ." Ping error # " . CR [THEN]
    IF 2DROP DROP 0 THEN ;

(
: T
    SocketsStartup THROW
    S" mailsrv" GetHostIP THROW NtoA TYPE CR
    SocketsCleanup THROW
;

PING 192.168.0.201
PING MAILSRV
) 