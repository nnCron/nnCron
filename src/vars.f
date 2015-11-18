VARIABLE vOperations
VARIABLE vInstall       \ установка сервиса
VARIABLE vRemove        \ удаление сервиса
VARIABLE vUninstall     \ полное удаление из системы
VARIABLE Outfile        \ если OFF, то nncron.out не создаётся

<EOF>
\ WINAPI: SHGetSpecialFolderPath SHELL32.DLL
\ WINSHELLAPI HRESULT WINAPI SHGetSpecialFolderPath(
\    HWND hwndOwner,
\    LPTSTR lpszPath,
\    int nFolder,
\    BOOL fCreate
\ );  

: LoadLibrary ( a u -- h)
    DROP DUP GetModuleHandleA ?DUP 0=
    IF LoadLibraryA
    ELSE NIP THEN ;

: SHGetSpecialFolderPath
    .S
    S" shell32.dll" LoadLibrary ?DUP
    IF
        ." DLL handle is " DUP . CR
\        [ HEX ] 0AF [ DECIMAL ]
        52
        
         SWAP GetProcAddress 
        ." Proc address is " DUP . CR
        ?DUP IF API-CALL ELSE 2DROP 2DROP CR ." SHGetSpecialFolderPath not found." CR THEN
        CR ." Error code " GetLastError . CR
    ELSE
        2DROP 2DROP
        CR ." shell32.dll not loaded" CR
        GetLastError . CR
    THEN
    .S
;

\ WINAPI: SHGetSpecialFolderLocation shell32.dll
\ WINSHELLAPI HRESULT WINAPI SHGetSpecialFolderLocation(
\    HWND hwndOwner,
\    int nFolder,
\    LPITEMIDLIST *ppidl
\ );  



: get-spec-folder ( folder-id -- a u )
    0 SWAP PAD 0 SHGetSpecialFolderPath NOERROR =
    IF PAD ASCIIZ> ELSE PAD 0 THEN
;
\ _vFolder_AppData    Contains path to the application data folder.
: APP-DATA CSIDL_APPDATA get-spec-folder ;

\ _vFolder_CommonDesktop  Contains path to the all users desktop folder.
: COMMON-DESKTOP CSIDL_COMMON_DESKTOPDIRECTORY get-spec-folder ;

\ _vFolder_CommonPrograms Contains path to the all users start menu programs folder.
\ _vFolder_CommonStartMenu    Contains path to the all users start menu folder.
\ _vFolder_Cookies    Contains path to the cookies folder.
\ _vFolder_Desktop    Contains path to the desktop folder.
\ _vFolder_Favourites Contains path to the favourites folder.
\ _vFolder_Personal   Contains path to the personal folder.
\ _vFolder_Programs   Contains path to the start menu programs folder.
\ _vFolder_Recent Contains path to the recent files folder.
\ _vFolder_SendTo Contains path to the "send to" folder.
\ _vFolder_StartMenu  Contains path to the start menu folder.
\ _vFolder_Startup    Contains path to the start menu start up folder.
\ _vFolder_Templates  Contains path to the templates folder.
\ _vFolder_Windows    Contains path to the windows folder.
\ _vFolder_System Contains path to the system folder.
\ _vFolder_Temp   Contains path to the temporary folder.
