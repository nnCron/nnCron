REQUIRE avlNode ~nn/lib/utils/avltree.f

MODULE: TCREATE-MODULE

0 VALUE last_tc_node
VARIABLE
CLASS: tcNode <SUPER avlNode
    var vLen
    var vString
    var vFlags
    dvar vTime
CONSTR: init
    this TO last_tc_node
    ASCIIZ> vLen ! vString ! init ;
DESTR: free vString @ ?FREE ;

VM: toString vString @ vLen @ ;
VM: Compare ( n1 -- n2 )  ASCIIZ> toString ICOMPARE ;
;CLASS

CLASS: tcList <SUPER avlTree
    CONSTR: init tcNode init ;
    M: Insert ( a u -- ) S>ZALLOC Insert ;
;CLASS

;MODULE
