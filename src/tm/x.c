#include <windows.h>
#include <ras.h>
#include <raserror.h>
#include <malloc.h>
#include <stdio.h>

LRESULT MsgPhbkDlgInit()
{
    LPRASENTRYNAME lpRasEntry;
    LPRASENTRYNAME lpTemp;
    DWORD cbBuf;
    DWORD cEntry;
    DWORD dwRet;
    UINT  ndx;
    char  szMessage[256];

    cbBuf = sizeof(RASENTRYNAME);
    if ((lpRasEntry = ( LPRASENTRYNAME ) GlobalAlloc(GPTR, (UINT)cbBuf)) != NULL ) 
    {
        lpRasEntry->dwSize = sizeof(RASENTRYNAME);
        dwRet = RasEnumEntries( NULL, NULL, lpRasEntry, &cbBuf, &cEntry );
        if ( dwRet == ERROR_BUFFER_TOO_SMALL )
        {
            if ((lpTemp = ( LPRASENTRYNAME ) GlobalAlloc(GPTR, (UINT)cbBuf )) != NULL )
            {
                lpRasEntry = lpTemp;
                dwRet = RasEnumEntries( NULL, NULL, lpRasEntry, &cbBuf, &cEntry );
            }
            else
            {
                dwRet = ERROR_NOT_ENOUGH_MEMORY;
            }
        }
        else if ( dwRet != 0 ) // other error
        {
            if ( RasGetErrorString( (UINT)dwRet, szMessage, 256 ) != 0 )
                wsprintf( (LPSTR)szMessage, "Undefined RasEnumEntries Error." );

            MessageBox(NULL, (LPSTR)szMessage, "Ras", MB_OK | MB_ICONSTOP );
        }

        if ( dwRet == 0 )  // No errors
        {
            for ( ndx = 0; ndx < cEntry; ndx++ ) 
                printf("%s\n", (LPCSTR) lpRasEntry[ndx].szEntryName);
            if ( ndx > 0 ) // at least one item was added
            {
            }
        }

        GlobalFree( (HANDLE)lpRasEntry );
    } 
}

void main(){
    MsgPhbkDlgInit();
    printf("%d\n", sizeof(RASENTRYNAME));
}

