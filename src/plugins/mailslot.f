REQUIRE CLASS: ~nn/class/class.f
REQUIRE { ~nn/lib/locals.f
REQUIRE EveryoneAcl ~nn/lib/security/everyone.f

S" mailslot.spf" INCLUDED

MailSlot POINTER mslot

: test
    MailSlot NEW TO mslot
    S" \\.\mailslot\messngr" mslot Create
    BEGIN 1 WHILE
      mslot Read
      IF
        mslot Get DUMP CR
      THEN
      1000 PAUSE
\      ." msg:" mslot Get TYPE CR
    REPEAT
;

test