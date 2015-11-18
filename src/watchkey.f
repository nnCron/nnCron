\ WatchHotKey
VARIABLE HotKeyId
0x9DEC2900 CONSTANT HotKeyTag
VARIABLE <HKL>
: HKL
    <HKL> @ ?DUP 0=
    IF KLF_NOTELLSHELL S" 00000409" DROP LoadKeyboardLayoutA DUP
        <HKL> !
    THEN
    [ DEBUG? ] [IF] ." HKL=" DUP . GetLastError . CR [THEN]
;

REQUIRE VK-SPEC-WID ~nn/lib/win/windows/vk.f

: get-hot-key { a u \ mod vk -- mod vk }
    0 TO mod 0 TO vk
    a u
    BEGIN DUP 0<> vk 0= AND WHILE
      OVER C@ >R 1- SWAP 1+ SWAP R>
      CASE
        [CHAR] ^ OF MOD_CONTROL mod OR TO mod ENDOF
        [CHAR] @ OF MOD_ALT mod OR TO mod ENDOF
        [CHAR] + OF MOD_SHIFT mod OR TO mod ENDOF
        [CHAR] $ OF MOD_WIN mod OR TO mod ENDOF
        [CHAR] { OF
                ( a u )
\ *                 2DUP 1- VK-SPEC-WID SEARCH-WORDLIST
\ *                 IF EXECUTE
\ *                 ELSE OVER C@ CharLowerA HKL SWAP VkKeyScanExA THEN
\ *                 TO vk
\ *                 DROP 0
                POSTPONE [
                2>R GET-ORDER 2R> ONLY VK-SPEC-KEYS
                2DUP S" }" SEARCH
                IF NIP ELSE DROP 0 THEN
                >R 2DUP R> - ['] EVALUATE CATCH
                IF 2DROP OVER C@ CharLowerA HKL SWAP VkKeyScanExA THEN
                TO vk 2DROP
                SET-ORDER
                0 0
            ENDOF
        [CHAR] ( OF DUP 0= ( конец строки?)
                    IF [CHAR] ( HKL VkKeyScanExA TO vk
                    ELSE
                        \ ничего не делаем. просто пропускаем.
                    THEN
            ENDOF
        DUP CharLowerA HKL SWAP VkKeyScanExA TO vk
      ENDCASE
    REPEAT
    2DROP
    mod vk
\    MOD_ALT MOD_CONTROL OR VK_F12
;

\ * : (get-same-hk) { w -- }
\ *     w WATCH-PAR @ 0xFFFFFF00 AND HotKeyTag =
\ *     IF
\ *     THEN
\ * ;

: get-same-hk { w \ w2 id -- id }
\ Ищет, а нет уже такого хоткея? Если есть возвращает id+HotKeyTag, иначе 0
    0 TO id
    CRON-LIST
    BEGIN @ ?DUP WHILE
        DUP ACTIVE?  OVER CRON-WATCH @ 0<> AND
        IF
           DUP CRON-WATCH
           BEGIN @ ?DUP WHILE
             DUP TO w2
             w2 WATCH-PAR @ 0xFFFFFF00 AND HotKeyTag =
             w2 WATCH-PAR @ 0xFF AND 0<>           AND
             w WATCH-PAR1 @ w2 WATCH-PAR1 @ = AND
             w WATCH-PAR2 @ w2 WATCH-PAR2 @ = AND
             IF
                w2 WATCH-PAR @ TO id
             THEN
           REPEAT
        THEN
    REPEAT
    id
;

\ * : WATCH-HK-START ( -- h )
\ *     Event
\ * ;

: WATCH-HK-XT-IF-RULE-FALSE
\    DBG( ." WATCH-HK-XT-IF-RULE-FALSE" CR )
    [NONAME
    WATCH-PAR-T HotKeyTag =
    IF
\ hotkey off
        CUR-WATCH 0 NN_UNREG_HOT_KEY1 CtrlWnd @ SendMessageA DROP
\ sendkey
\        CUR-WATCH WATCH-PAR3 @ COUNT SEND-KEYS
        \ 0 GetKeyboardLayout TO HKBLT
\        VK_LCONTROL GetKeyState ." 1:" HEX U. CR
        0x4090409 TO HKBLT
        CUR-WATCH WATCH-PAR3 @ COUNT send_keys
\        VK_LCONTROL GetKeyState ." 2:" U. DECIMAL CR

\ hotkey on
        CUR-WATCH 0 NN_REG_HOT_KEY1 CtrlWnd @ SendMessageA DROP
    THEN
    NONAME] CATCH DROP
;

: WatchHotKey:
    get-string 2DUP s,
    POSTPONE WATCH:
    WATCH-NODE WATCH-PAR3 ! ( keystring)
    get-hot-key
                  WATCH-NODE WATCH-PAR1 !  ( vk)
                  WATCH-NODE WATCH-PAR2 !  ( mod)
    HotKeyTag WATCH-NODE WATCH-PAR !
    ['] WATCH-HK-XT-IF-RULE-FALSE WATCH-NODE WATCH-XT-IF-RULE-FALSE !
\    POSTPONE Event
    POSTPONE 0
    POSTPONE END-WATCH
; IMMEDIATE

: SetHotKeyEvent ( hot-key-id -- ) HotKeyTag StartWatchByTypeTag ;

:NONAME { w \ id w2 -- }
\    [ DEBUG? ] [IF] w WATCH-PAR @ HEX U. DECIMAL CR [THEN]
    w WATCH-PAR @ 0xFFFFFF00 AND HotKeyTag =
    IF
        w WATCH-PAR1 @
        w WATCH-PAR2 @
        HotKeyId @ 1+ DUP HotKeyId !
        ew-par1 @ RegisterHotKey w WATCH-PAR1 @ -1 <> AND
        IF
           [ DEBUG? ] [IF] w WATCH-CRON-NODE @ CRON-NAME @ COUNT TYPE SPACE
                               ." Set hot-key. Id=" HotKeyId @  .
                               w WATCH-PAR1 @ .
                               w WATCH-PAR2 @ . CR [THEN]
           HotKeyId @ HotKeyTag OR w WATCH-PAR !
        ELSE
            -1 HotKeyId +!
            CRON-LIST
            BEGIN @ ?DUP WHILE
                DUP ACTIVE?  OVER CRON-WATCH @ 0<> AND
                IF
                   DUP CRON-WATCH
                   BEGIN @ ?DUP WHILE
                     DUP TO w2
                     w2 WATCH-PAR @ 0xFFFFFF00 AND HotKeyTag =
                     w2 WATCH-PAR @ 0xFF AND 0<>           AND
                     w WATCH-PAR1 @ w2 WATCH-PAR1 @ = AND
                     w WATCH-PAR2 @ w2 WATCH-PAR2 @ = AND
                     IF
                        w2 WATCH-PAR @ w WATCH-PAR !
                     THEN
                   REPEAT
                THEN
            REPEAT
           w WATCH-PAR @ 0xFF AND 0=
           IF
             S" RegisterHotKey ERROR # %GetLastError%: " w WATCH-CRON-NODE @ LOG-NODE
           THEN
        THEN
    THEN
;

: UnregisterHotKeys ( hwnd -- )
    HotKeyId @ 1+ 1 ?DO I OVER UnregisterHotKey DROP LOOP
    DROP
;

: RegisterHotKeys ( hwnd -- )
\    10000 PAUSE
    DUP UnregisterHotKeys
    ew-par1 !
    HotKeyId 0!
    LITERAL ENUM-ACTIVE-WATCH ;

(
:NONAME { w -- }
    w WATCH-PAR @ 0xFFFFFF00 AND HotKeyTag =
    IF
        w WATCH-PAR @ 0xFF AND ew-par1 @ UnregisterHotKey DROP
    THEN
;
)
