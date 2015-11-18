\ $Id: tasklist.f,v 1.2 2009/12/03 14:45:10 nncron38 Exp $
\ Author: Nicholas Nemtsev
\ Creation time: 2009-12-02 09:05

REQUIRE ListView ~nn/lib/win/controls/listview.f
CLASS: TaskListDialog <SUPER FrameWindow

325 VALUE width
200 VALUE height
13 CONSTANT but_h
37 CONSTANT but_w
: but_col ( # -- col ) but_w 5 + * width 1st-col + SWAP - 5 - ;
: but_row height but_h 2* - 5 - ;
: button  WITH Control but_col but_row pos but_w but_h size tabstop ENDWITH ;

    Static OBJ st_crontab
        :init a v 0 1 4 1 ps 800 RES text ;
    ComboBox OBJ cmb_crontab
        :init a v 0 4 10 4 ps tabstop  ;
    
\     M: onAddCrontab ;
\     Button OBJ but_add_crontab
\         :init a v 14 col 5 + 0 row pos 10 10 size S" +" text tabstop
\             ['] onAddCrontab OnClick ! ;

    ListView OBJ lv_tasks
       :init a v  1 col 2 row pos 250 150 size tabstop
            LVS_EX_GRIDLINES LVS_EX_FULLROWSELECT OR v_ex_style ! ;

0 VALUE nrow
    : LOAD-CRONTAB ( a u )
        { \ fh -- }
        SP@ >R
        0 TO nrow
        R/O OPEN-FILE-SHARED 0=
        IF
            TO fh
            BEGIN PAD 512 fh READ-LINE THROW WHILE
                DUP 3 >
                IF
                    PAD SWAP <TIB
                        NextWord 2DUP S" #(" COMPARE 0=
                        IF 2DROP
                            0 S"   " nrow lv_tasks InsertItem 
                            NextWord
                            nrow 1 2SWAP lv_tasks SetItem
                            nrow 1+ TO nrow
                        ELSE
                        S" NoActive" COMPARE 0=
                        IF
                            nrow 1- 0 S" --" lv_tasks SetItem
                        THEN THEN
                    TIB>
                ELSE
                    DROP 
                THEN
            REPEAT
            2DROP
\            lv_tasks
            fh CLOSE-FILE DROP
        ELSE
            DROP
        THEN
        R> SP!
    ;
    M: ReloadCrontab
        SP@ >R
        lv_tasks GetSelectionMark >R    \ запоминаем текущую позицию
        lv_tasks ClearAll
        PAD cmb_crontab GetCurrent LOAD-CRONTAB
        R> lv_tasks SetSelectionMark
        R> SP!
    ;
    M: onNewTask
        SP@ >R
        PAD cmb_crontab GetCurrent S" NewTask %1 esPICKS%" EVAL-SUBST 
        EVALUATE
        ReloadCrontab
        R> SP!
    ;
    Button OBJ but_new_task
        :init a v 26 col 5 + 2 row pos 50 10 size 14 RES text tabstop
            ['] onNewTask OnClick ! ;
    
    M: onEditTask
        SP@ >R
        lv_tasks GetSelectionMark 1 lv_tasks GetItem 2DUP TYPE CR
        PAD cmb_crontab GetCurrent S>TEMP 
        S" EditTask %1 esPICKS% %3 esPICKS%" EVAL-SUBST 
        EVALUATE
        ReloadCrontab 
        R> SP!
    ;
    Button OBJ but_edit_task
        :init a v 26 col 5 + 3 row 5 + pos 50 10 size 13 RES text tabstop
            ['] onEditTask OnClick ! ;
M: Create
    0 TO 1st-row 0 TO 1st-col    
    0 Create
    AutoCreate
    450 RES SetText
    OptionsPos XY? 
    IF OptionsPos XY@ SetPos 
       width height SetSize
    ELSE width height Center THEN 
\    ['] add-crontab CRONTAB-LIST DoList
    
    \ lv_tasks ClearAll
    lv_tasks ReportStyle
    S" *"         20  0 lv_tasks InsertColumn
    110 RES ( Task name) 263 1 lv_tasks InsertColumn
    801 RES ( Next time) 100 2 lv_tasks InsertColumn
    802 RES ( Last time) 100 3 lv_tasks InsertColumn
    
    [NONAME
        NodeValue ASCIIZ> cmb_crontab Add
    NONAME] CRONTAB-LIST DoList
    0 cmb_crontab Current!
   
    ReloadCrontab
    ['] ReloadCrontab cmb_crontab OnSelChange !
;

;CLASS

TaskListDialog POINTER tl
: TaskList
    DontBYE ON
    TaskListDialog NEW TO tl
    tl Create
    tl Show
    tl Run
    tl SELF DELETE
    BYE
;
