REQUIRE OpenDialog ~nn/lib/win/filedialogs.f
REQUIRE ISEARCH ~nn/lib/wcmatch.f

OpenDialog POINTER OpenDlg

FILTER: AllFilter
    NAME" All files (*.*)"      EXT" *.*"
;FILTER


: ChoosePath ( a1 u1 -- a u)
    OpenDialog NEW TO OpenDlg
    AllFilter OpenDlg SetFilter
    OpenDlg FileName!
    331 RES DROP OpenDlg lpstrTitle !
    OFN_PATHMUSTEXIST OFN_HIDEREADONLY OR 
    ( OFN_ALLOWMULTISELECT OR) OFN_EXPLORER OR
    OpenDlg Flags !
    OpenDlg Execute
    IF
\        OpenDlg lpstrFile @ 1024 DUMP CR
\        OpenDlg nFileOffset W@ .
        OpenDlg FileName        \ 2DUP TYPE CR

        2DUP ModuleDirName      \ 2DUP TYPE CR
        ISEARCH NIP NIP
        IF >R ModuleDirName NIP >R R@ + R> R> SWAP - THEN
        DUP >R S>ZALLOC R>
    ELSE
        S" "
    THEN
    OpenDlg SELF DELETE
;
