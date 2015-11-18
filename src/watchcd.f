HEX
    0x8000 CONSTANT DBT_DEVICEARRIVAL
    0x8004 CONSTANT DBT_DEVICEREMOVECOMPLETE
    2    CONSTANT DBT_DEVTYP_VOLUME
    1    CONSTANT DBTF_MEDIA
    0x07035700 CONSTANT WatchCDTag
DECIMAL

VARIABLE WatchCDCnt

WARNING @ WARNING 0!
: BeforeCrontabLoading
    BeforeCrontabLoading
    WatchCDCnt 0!
;
WARNING !

: NextWatchCD ( -- #)  WatchCDCnt DUP @ SWAP 1+! ;

: WATCH-CD-START ( -- handle)
    NextWatchCD DROP
\    Event
    0
;

: WATCH-CD-RULE ( -- ?)
    CUR-WATCH
;
: (WATCH-CD) ( Event -- )
    >R
    POSTPONE WATCH:
\      get-string EVAL-SUBST DROP C@ 0xDF AND [CHAR] A -
\      R> OR WatchCDTag OR       WATCH-NODE WATCH-PAR !
    R> WatchCDTag OR       WATCH-NODE WATCH-PAR !
    get-string EVAL-SUBST DROP C@ DUP [CHAR] * <>
    IF 0xDF AND THEN \ это в верхний регистр
        WATCH-NODE WATCH-PAR1 !
    
    ['] WATCH-CD-RULE WATCH-NODE WATCH-RULE !    
    POSTPONE WATCH-CD-START
    POSTPONE END-WATCH
;

: WatchDriveInsert: 0    (WATCH-CD) ; IMMEDIATE
: WatchDrive:       0    (WATCH-CD) ; IMMEDIATE
: WatchDriveRemove: 0x80 (WATCH-CD) ; IMMEDIATE

                            \ typedef struct _DEV_BROADCAST_HDR {
0 
1 CELLS -- dbcv_size        \   ULONG dbch_size; 
1 CELLS -- dbcv_devicetype  \   ULONG dbch_devicetype; 
1 CELLS -- dbcv_reserved    \   ULONG dbch_reserved                            
1 CELLS -- dbcv_unitmask    \   ULONG dbcv_unitmask; 
2       -- dbcv_flags       \   USHORT dbcv_flags; 
DROP

: WDrGetDriveLetter ( mask -- letter)
   [CHAR] A SWAP
   26 0 
   DO 
       DUP 1 AND 
       IF NIP [CHAR] A I + SWAP LEAVE 
       ELSE 1 RSHIFT THEN 
   LOOP
   DROP
;
\ 0 VALUE data
\ 0 VALUE typ
\ 0 VALUE w

: DRIVE-LETTER vTask ?DUP IF vtWATCH @ ?DUP IF WATCH-PAR2 1 ELSE S" " THEN ELSE S" " THEN ;

:NONAME  { w -- }
   w WATCH-PAR1 @ DUP [CHAR] * = SWAP ew-par1 @ = OR
   IF
       ew-par1 @ ( letter) w WATCH-PAR2 !
       w qWS Put
   THEN
;
: StartCDWatchByType ( letter typ -- )
    SWAP ew-par1 ! WatchCDTag LITERAL ENUM-AW-BY-TAG ;


: SetWatchCDEvent { data typ \ w letter -- }
\    WatchCDCnt @ 0= IF EXIT THEN
    data dbcv_devicetype @ DBT_DEVTYP_VOLUME =
    IF
\       data dbcv_flags W@ DBTF_MEDIA AND
\       IF
           data dbcv_unitmask @ WDrGetDriveLetter TO letter
           [ DEBUG? ] [IF] ." DriveEvent: " letter EMIT CR [THEN]
\             letter [CHAR] A - typ OR WatchCDTag StartWatchByTypeTag
           letter typ StartCDWatchByType
           \ SetWatchEvent
\       THEN
    THEN
;    

WARNING @ WARNING 0!
: BeforeStop
    BeforeStop
;
WARNING !