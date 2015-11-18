WINAPI: RasDialA               RASAPI32.DLL
WINAPI: RasHangUpA             RASAPI32.DLL
WINAPI: RasEnumConnectionsA    RASAPI32.DLL
WINAPI: RasGetErrorStringA     RASAPI32.DLL

 0
  4 -- dwSize
257 -- szEntryName
129 -- szPhoneNumber
129 -- szCallbackNumber
257 -- szUserName
257 -- szPassword
 19 -- szDomain
CONSTANT /RASDIALPARAMS
\ CREATE RASDIALPARAMS /RASDIALPARAMS ALLOT
0 VALUE RDP     \ RasDialParameters

  0
  4 -- RASCONN.dwSize
  4 -- RASCONN.hrasconn
257 -- RASCONN.szEntryName
\ CONSTANT /RASCONN
412 CONSTANT /RASCONN

(  0
  4 -- RASCONNSTATUS.dwSize
  4 -- RASCONNSTATUS.rasconnstate
  4 -- RASCONNSTATUS.dwError
257 -- RASCONNSTATUS.szDeviceType
257 -- RASCONNSTATUS.szDeviceName
\ CONSTANT /RASCONNSTATUS
160 CONSTANT /RASCONNSTATUS
)


USER SAVE-SP
USER lpcConnections
USER lpcb
USER-CREATE CONN-NAME 2 CELLS USER-ALLOT
VARIABLE HRASCONN

: MyConnection? ( addr u -- ?)
    CONN-NAME 2@ ?DUP
    IF ICOMPARE 0=
    ELSE DROP 2DROP TRUE THEN ;

: SONLINE? ( addr u -- ?)
  CONN-NAME 2!  
  SP@ SAVE-SP ! \ против глюков RasEnumConnections
  10000 lpcb ! lpcConnections 0!
  lpcConnections lpcb 10000 ALLOCATE THROW >R
  R@ /RASCONN ERASE
  /RASCONN R@ !
  R@ RasEnumConnectionsA 0=
  lpcConnections @ 0 > AND
  IF ( соединение установлено, проверить нужное ли)
    SAVE-SP @ SP!
    R@ lpcConnections @ /RASCONN * +  R@
    ?DO
      I RASCONN.szEntryName ASCIIZ> MyConnection?
      IF
        I RASCONN.hrasconn @ HRASCONN !
        UNLOOP R> FREE DROP TRUE EXIT
      THEN
    /RASCONN +LOOP
    DROP
  ELSE
    SAVE-SP @ SP!
  THEN
  FALSE
  R> FREE THROW
;

: ?ALLOC-RDP
    RDP 0=
    IF
        /RASDIALPARAMS ALLOCATE THROW
        TO RDP
        RDP /RASDIALPARAMS ERASE
        /RASDIALPARAMS RDP dwSize !
    THEN
;


0 VALUE RASError

: RASUser ( addr u --)   ?ALLOC-RDP  RDP szUserName ZPLACE ;
: RASPassword            ?ALLOC-RDP  RDP szPassword ZPLACE ;
: RASDomain              ?ALLOC-RDP  RDP szDomain ZPLACE ;
: RASEntry               ?ALLOC-RDP  RDP szEntryName ZPLACE ;
: RASPhone               ?ALLOC-RDP  RDP szPhoneNumber ZPLACE ;

: ?DIAL ( addr u -- ?)
    ?ALLOC-RDP
    RDP szEntryName ZPLACE
    HRASCONN 0!
    HRASCONN 0 0 RDP 0 0 RasDialA
    DUP TO RASError
    0=
;

: DIAL ?DIAL DROP ;

: #DIAL ( u1 addr2 u2 -- )
    ROT 0
    ?DO
        2DUP ?DIAL
        IF UNLOOP 2DROP EXIT THEN
    LOOP
    2DROP
;    

: SHANGUP ( addr u -- )
    SONLINE?
    IF
        HRASCONN @ RasHangUpA TO RASError
    THEN
;

