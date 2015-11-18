REQUIRE { ~nn/lib/locals.f
REQUIRE .S lib/ext/tools.f

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

: LOGGEDUSERCOUNT { \ entriesread totalentries resumehandle -- status }
    0 TO resumehandle
    AT resumehandle
    AT totalentries 
    AT entriesread 
    16
    PAD
    0 0
    NetWkstaUserEnum DROP
    totalentries
;
t1.f
t1.f
