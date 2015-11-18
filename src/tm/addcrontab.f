REQUIRE InputString input.f

: AddCrontab ( a u -- a1 u1 )
\    470 RES  \ Заголовок
\    471 RES  \ Подсказка 
\    InputString
\    InputPath
    ChoosePath
;

: AddPlugin ( a u -- a1 u1 )
\    472 RES  \ Заголовок
\    473 RES  \ Подсказка 
\    InputPath
    ChoosePath
;
