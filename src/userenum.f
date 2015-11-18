REQUIRE { ~nn/lib/locals.f
REQUIRE WCONSTS ~nn/lib/wincon.f

\ NET_API_STATUS NetWkstaUserEnum(
\   LPWSTR servername,    
\  DWORD level,          
\  LPBYTE *bufptr,       
\  DWORD prefmaxlen,     
\  LPDWORD entriesread,  
\  LPDWORD totalentries, 
\  LPDWORD resumehandle  
\ );
 
WINAPI: NetWkstaUserEnum NETAPI32.DLL

: UserEnum { \ entriesread totalentries resumehandle bufptr -- addr cnt }
    0 TO resumehandle
    AT resumehandle
    AT totalentries 
    AT entriesread 
    1024
    AT bufptr
    0 0
    NetWkstaUserEnum 0= IF bufptr totalentries ELSE 0 THEN
;

: WPUTS ( a -- )
    BEGIN DUP C@ ?DUP WHILE
      EMIT 2+
    REPEAT DROP
;

: TEST 
    UserEnum ?DUP
    IF
        0 DO DUP I CELLS + @ WPUTS CR LOOP DROP
    THEN
;
TEST