REQUIRE Control ~nn/lib/win/control.f
REQUIRE DateTimePicker ~nn/lib/win/controls/DateTimePicker.f
REQUIRE ComboBox ~nn/lib/win/controls/combobox.f
REQUIRE FrameWindow ~nn/lib/win/framewindow.f
REQUIRE RES ~nn/lib/res.f
REQUIRE PLACE lib/ext/string.f


CLASS: ScheduleDialog <SUPER FrameWindow
180 CONSTANT width
200 CONSTANT height
10 CONSTANT col1
80 CONSTANT col2
150 CONSTANT col3
8  CONSTANT hs
5  CONSTANT row1
15 CONSTANT row2
30 CONSTANT row3
40 CONSTANT row4

    Static OBJ stSched
        :init  auto  visible  col1 row1 pos   40 hs size   40 RES text ;
    Static OBJ stTime
        :init  auto  visible  col2 row1 pos   40 hs size   41 RES text ;
    ComboBox OBJ cbType
        :init  auto  visible  col1 row2 pos   60 60 size
            WS_TABSTOP vStyle !  ;
    TimePicker OBJ time
        :init  auto  visible  col2 row2 pos   30 10 size
            WS_TABSTOP vStyle !  ;
    DatePicker OBJ date
        :init  auto visible ;
    GroupBox OBJ wd_frame
        :init  auto visible col1 row3 pos  50 85 size  50 RES text  ;
    CheckBox OBJ chkMon
        :init  auto visible col1 5 + row4 pos   30 10 size 51 RES text 
            WS_TABSTOP vStyle !  ;
    CheckBox OBJ chkTue
        :init  auto visible col1 5 + row4 10 + pos   40 10 size 52 RES text 
            WS_TABSTOP vStyle !  ;
    CheckBox OBJ chkWed
        :init  auto visible col1 5 + row4 20 + pos   40 10 size 53 RES text
            WS_TABSTOP vStyle !  ;
    CheckBox OBJ chkThu
        :init  auto visible col1 5 + row4 30 + pos   40 10 size 54 RES text
            WS_TABSTOP vStyle !  ;
    CheckBox OBJ chkFri
        :init  auto visible col1 5 + row4 40 + pos   40 10 size 55 RES text
            WS_TABSTOP vStyle !  ;
    CheckBox OBJ chkSat
        :init  auto visible col1 5 + row4 50 + pos   40 10 size 56 RES text
            WS_TABSTOP vStyle !  ;
    CheckBox OBJ chkSun
        :init  auto visible col1 5 + row4 60 + pos   40 10 size 57 RES text
            WS_TABSTOP vStyle !  ;
               


    M: OkClick 0 Close ;
    M: CancelClick BYE ;

    Button OBJ butOk
        :init  auto  visible 
                width 100 - height 30 - pos
                40 11 size  101 RES text
                ['] OkClick OnClick !
                WS_TABSTOP BS_DEFPUSHBUTTON OR vStyle !
                ;
    Button OBJ butCancel
        :init  auto  visible
                width 50 - height 30 - pos
                40 11 size  102 RES text
                ['] CancelClick OnClick !
                WS_TABSTOP vStyle !
                ;

M: set_frame_text
    256 ALLOCATE THROW >R
    50 RES R@ PLACE
    S"  " R@ +PLACE
    R@ COUNT + cbType GetCurrent NIP  \ ShowMessage
    R@ COUNT ROT + wd_frame SetText
    R> FREE THROW
;

M: cbTypeChange
    
;

M: init-sched-type
    30 RES cbType Add    31 RES cbType Add
    32 RES cbType Add    33 RES cbType Add
    34 RES cbType Add    36 RES cbType Add
    37 RES cbType Add    0 cbType Current!
    ['] cbTypeChange cbType vOnSelChange !
    cbTypeChange
;

M: Create
    WS_OVERLAPPED WS_SYSMENU OR WS_CAPTION OR  WS_MINIMIZEBOX OR
       vStyle !
    0 Create
    width height Center
    10 RES SetText

    AutoCreate

    1 chkMon SetCheck
    1 chkTue SetCheck
    1 chkWed SetCheck
    1 chkThu SetCheck
    1 chkFri SetCheck

    init-sched-type
    S" HH':'mm" time SetFormat
    cbType SetFocus
;

;CLASS

ScheduleDialog POINTER schdlg

: Schedule
    ScheduleDialog NEW TO schdlg
    schdlg Create
    schdlg Show
    schdlg Run
    schdlg SELF DELETE
    DROP
;

\ Schedule