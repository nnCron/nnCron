REQUIRE EXIST? ~nn/lib/find.f
REQUIRE StartApp ~nn/lib/process.f

2002 CONSTANT TAB_RELOAD


: RELOAD
    0
    S" nncrond.exe" EXIST?
    IF S" nncrond.exe -reload" ELSE S" nncron.exe -reload"  THEN
    StartApp DROP
;