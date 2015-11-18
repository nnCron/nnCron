REQUIRE set-lang ~nn/lib/res.f 
\ 0 VALUE RES-INIT
\ : set-lang
\     S" res\" PAD PLACE
\     NextWord PAD +PLACE
\     S" .txt" PAD +PLACE
\     PAD COUNT  \ 2DUP TYPE CR
\     RES!
\     TRUE TO RES-INIT
\ ;

: Language: get-string set-lang ;
: SKIP-ALL 1 PARSE 2DROP ;
: ?EXEC BL WORD FIND IF CATCH THEN DROP ;
: DefaultPriority:  ?EXEC SKIP-ALL ; IMMEDIATE
: DefaultOpenMode:  ?EXEC SKIP-ALL ; IMMEDIATE
: DefaultLogonType: ?EXEC SKIP-ALL ; IMMEDIATE



