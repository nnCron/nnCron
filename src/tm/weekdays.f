REQUIRE Control ~nn/lib/win/control.f

CLASS: WeekDays <SUPER FrameWindow
10 CONSTANT row_h
10 CONSTANT col_w

13 CONSTANT but_h
37 CONSTANT but_w

: row ( # -- row ) row_h *  ;
: col ( # -- col ) col_w *  ;
: cols ( # -- cols) col_w * ;

    CheckBox OBJ cb_mon
        :init a v   1 col 1 row pos  5 cols row_h size  160 RES text tabstop ;
    CheckBox OBJ cb_tue
        :init a v   1 col 2 row pos  5 cols row_h size  161 RES text tabstop ;
    CheckBox OBJ cb_wed
        :init a v   1 col 3 row pos  5 cols row_h size  162 RES text tabstop ;
    CheckBox OBJ cb_thu
        :init a v   1 col 4 row pos  5 cols row_h size  163 RES text tabstop ;
    CheckBox OBJ cb_fri
        :init a v   1 col 5 row pos  5 cols row_h size  164 RES text tabstop ;
    CheckBox OBJ cb_sat
        :init a v   1 col 6 row pos  5 cols row_h size  165 RES text tabstop ;
    CheckBox OBJ cb_sun
        :init a v   1 col 7 row pos  5 cols row_h size  166 RES text tabstop ;

    M: onOk 7 Close ;

    Button OBJ but_ok
        :init a v   2 col 9 row pos  but_w but_h size  200 RES text tabstop
            ['] onOk OnClick !
        ;

M: Create ( parent --)
    Create
    167 RES SetText
    75 120 Center
    AutoCreate
    cb_mon Checked      cb_tue Checked      cb_wed Checked
    cb_thu Checked      cb_fri Checked      cb_sat Checked
    cb_sun Checked
;
M: SetWeekDays ( n --)
    DUP 1 AND 0= IF cb_mon Unchecked THEN
    DUP 2 AND 0= IF cb_tue Unchecked THEN
    DUP 4 AND 0= IF cb_wed Unchecked THEN
    DUP 8 AND 0= IF cb_thu Unchecked THEN
    DUP 16 AND 0= IF cb_fri Unchecked THEN
    DUP 32 AND 0= IF cb_sat Unchecked THEN
        64 AND 0= IF cb_sun Unchecked THEN
;

M: GetWeekDays ( -- n)
    0
    cb_mon GetCheck IF 1 OR THEN
    cb_tue GetCheck IF 2 OR THEN
    cb_wed GetCheck IF 4 OR THEN
    cb_thu GetCheck IF 8 OR THEN
    cb_fri GetCheck IF 16 OR THEN
    cb_sat GetCheck IF 32 OR THEN
    cb_sun GetCheck IF 64 OR THEN
;
;CLASS