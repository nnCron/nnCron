WINAPI: MessageBoxA USER32.DLL
WINAPI: GetWindowTextA USER32.DLL
WINAPI: EnumWindows USER32.DLL
WINAPI: EnumThreadWindows USER32.DLL
WINAPI: EnumChildWindows USER32.DLL
\ WINAPI: Beep KERNEL32.DLL
WINAPI: GetTickCount KERNEL32.DLL
WINAPI: GetCurrentThreadId KERNEL32.DLL
WINAPI: GetCurrentProcessId KERNEL32.DLL
WINAPI: SetCurrentDirectoryA KERNEL32.DLL
WINAPI: WaitForMultipleObjects KERNEL32.DLL
WINAPI: ExitWindowsEx USER32.DLL
WINAPI: LogonUserA ADVAPI32.DLL
WINAPI: SetConsoleCtrlHandler KERNEL32.DLL
WINAPI: GetNamedSecurityInfoA ADVAPI32.DLL
WINAPI: GetExitCodeThread KERNEL32.DLL
\ BOOL GetExitCodeThread(
\   HANDLE hThread,      // handle to the thread
\   LPDWORD lpExitCode   // address to receive termination status
\ );
 
WINAPI: GetWindowRect USER32.DLL
WINAPI: GetCursorPos USER32.DLL
WINAPI: GetFocus USER32.DLL
WINAPI: SetFocus USER32.DLL
WINAPI: SetCursorPos USER32.DLL
WINAPI: SendMessageA USER32.DLL
WINAPI: PostMessageA USER32.DLL
WINAPI: ShowWindow USER32.DLL
WINAPI: GetClassNameA USER32.DLL
WINAPI: GetWindowThreadProcessId USER32.DLL
WINAPI: OpenProcess KERNEL32.DLL
WINAPI: TerminateProcess KERNEL32.DLL
WINAPI: SetActiveWindow  USER32.DLL
WINAPI: AttachThreadInput USER32.DLL
WINAPI: DestroyWindow USER32.DLL
WINAPI: ImpersonateLoggedOnUser ADVAPI32.DLL
WINAPI: GetUserNameA ADVAPI32.DLL
WINAPI: SetForegroundWindow USER32.DLL
WINAPI: BringWindowToTop USER32.DLL
\ WINAPI: OpenWindowStationA USER32.DLL
\ HWINSTA OpenWindowStation(
\  LPTSTR lpszWinSta,           // window station name
\  BOOL fInherit,               // inheritance option
\  ACCESS_MASK dwDesiredAccess);  // handle access

\ : BEEP ( Duration-ms Freq-Hz --) Beep DROP ;

WINAPI: GlobalAlloc KERNEL32.DLL
WINAPI: GlobalFree KERNEL32.DLL
: GLOBAL-ALLOCATE ( bytes -- address ior)
    GPTR GlobalAlloc DUP 0= IF GetLastError ELSE 0 THEN ;
: GLOBAL-FREE ( address - ior) GlobalFree ;