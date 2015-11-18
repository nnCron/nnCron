
    ComboBox OBJ cmb_cond
        :init a 2 tab+ 1 4 act_w 10 / conds ps tabstop ;
    CheckBox OBJ cb_not
        :init a 2 tab+ 1 1 3 1 ps 326 RES text tabstop ;
\    Button OBJ but_cond_clr
\        :init a 2 tab+ 1 16 1 1 ps S" X" text ;

    Static OBJ st_cond
        :init a 2 tab+ 3 1 6 1 ps 280 RES text ;
    Edit OBJ ed_cond
        :init a 2 tab+ 3 7 14 1 ps tabstop ;

    Static OBJ st_pop3_user
        :init a 2 tab+ 5 1 6 1 ps 464 RES text ;
    Edit OBJ ed_pop3_user
        :init a 2 tab+ 5 7 14 1 ps tabstop ;

    Static OBJ st_pop3_pass
        :init a 2 tab+ 7 1 6 1 ps 465 RES text ;
    Edit OBJ ed_pop3_pass
        :init a 2 tab+ 7 7 14 1 ps tabstop ;


: pop3_hide
     st_pop3_user Hide
     ed_pop3_user Hide
     st_pop3_pass Hide
     ed_pop3_pass Hide
;

M: onCondChange
    cmb_cond Current ?DUP
    IF 280 + RES st_cond SetText
        st_cond Show
        ed_cond Show
        cmb_cond Current 8 =
        IF
            st_pop3_user Show
            ed_pop3_user Show
            st_pop3_pass Show
            ed_pop3_pass Show
        ELSE
            pop3_hide
        THEN
    ELSE
        st_cond Hide
        ed_cond Hide
        pop3_hide
    THEN
;

M: on_cond_clr
\    -1 cmb_cond Current!
\    280 RES st_cond SetText
    ;