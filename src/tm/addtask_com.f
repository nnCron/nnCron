REQUIRE ZPLACE ~nn/lib/az.f

: adv-clr adv_buf @ 0! ;
: adv+ ( a u --)  adv_buf @ +ZPLACE ;
: advnl+ LT LTL @ adv+ ;
: advl+ ( a u --) adv+ advnl+ ;
: advq+ (qt) COUNT adv+ ;
: "<>" ( a u --) advq+ adv+ advq+ S"  " adv+ ;

: adv. adv_buf @ ASCIIZ> ." <" TYPE ." >" CR ;