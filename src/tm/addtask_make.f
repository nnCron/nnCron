
: GenFlags
    cb_active GetCheck 0= IF S" NoActive" advl+ THEN
    cb_log GetCheck 0= IF S" NoLog" advl+ THEN
    rb_once GetState
        IF S" RunOnce" advl+
            cb_del GetCheck 0=
            IF S" NoDel" advl+ THEN
        THEN

    rb_event GetState 0=
    IF
        cb_missed GetCheck
        IF
            ed_missed GetText ?DUP
            IF
                S" RunMissed: " adv+ advl+
            ELSE
                DROP
                S" RunMissed" advl+
            THEN
        THEN
    THEN

    cb_aslogged GetCheck IF S" AsLoggedUser" advl+ THEN
    cb_profile GetCheck IF S" LoadProfile" advl+ THEN
;

: GenTime
    tm_buf 0!
    (GenTime) TimeType CELLS + @ EXECUTE
    tm_buf COUNT ?DUP IF advl+ ELSE DROP THEN
;

: GenAsUser
    cb_asuser GetCheck
    IF
\        ed_word GetText NIP 0= IF 334 ERR-MSG THEN
\        ed_user_name GetText
        GetUser
        NIP 0= IF 334 ERR-MSG THEN
        S" User: " adv+    GetUser "<>"
        ed_password GetText NIP
        IF
            S" SecPassword: " adv+  ed_password GetText
                EnP "<>"
        THEN
        ed_domain GetText NIP
        IF
            S" Domain: " adv+       ed_domain GetText "<>"
        THEN
        cmb_logon_type Current
        CASE
            0 OF S" LogonInteractive" ENDOF
            1 OF S" LogonBatch" ENDOF
            2 OF S" LogonNetwork" ENDOF
        ENDCASE
        advl+
    THEN
;

: GenRule
    cmb_cond Current ?DUP
    IF
        ed_cond GetText NIP 0= IF 333 ERR-MSG THEN
        S" Rule: " adv+
        CASE
            1 OF S" FILE-EXIST: " ENDOF
            2 OF S" WIN-EXIST: " ENDOF
            3 OF S" ONLINE: " ENDOF
            4 OF S" FILE-EMPTY: " ENDOF
            5 OF S" HOST-EXIST: " ENDOF
            6 OF S" QUERY: " ENDOF
            7 OF S" PROC-EXIST: " ENDOF
            8 OF S" POP3-CHECK: " ENDOF
        ENDCASE
        adv+
        ed_cond GetText "<>"
        cmb_cond Current 8 =
            IF ed_pop3_user GetText "<>" ed_pop3_pass GetText "<>" THEN
        cb_not GetCheck IF S" NOT"  adv+ THEN
        advnl+
    THEN
;


M: MakeTaskText ( -- a u)
    adv_buf @ 0!
    GenFlags
    GenAsUser
    GenTime
    GenRule
    GenAction
    adv_buf @ ASCIIZ> \ 2DUP TYPE
;

