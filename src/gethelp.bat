@echo off
set ZIPFILE=help.zip
set HELPFILE=help.chm
echo %HOME%
nnbackup ver -i %HOME%\src\cron\release\doc -o %HOME%\src\cron\backup\readme -n 10 -pc
nnbackup ver -i %HOME%\src\cron\tm\res -o %HOME%\src\cron\tm\backup\res  -n 10 -pc
pushd %HOME%\src\cron\release\doc
call wget -e continue=off -N http://www.nncron.ru/translation/nncron/readme.txt
call wget -e continue=off -N http://www.nncron.ru/translation/nncron/readme.br.txt
call wget -e continue=off -N http://www.nncron.ru/translation/nncron/readme.by.txt
call wget -e continue=off -N http://www.nncron.ru/translation/nncron/readme.chs.txt
call wget -e continue=off -N http://www.nncron.ru/translation/nncron/readme.cz.txt
call wget -e continue=off -N http://www.nncron.ru/translation/nncron/readme.de.txt
call wget -e continue=off -N http://www.nncron.ru/translation/nncron/readme.es.txt
call wget -e continue=off -N http://www.nncron.ru/translation/nncron/readme.fi.txt
call wget -e continue=off -N http://www.nncron.ru/translation/nncron/readme.fr.txt
call wget -e continue=off -N http://www.nncron.ru/translation/nncron/readme.hu.txt
call wget -e continue=off -N http://www.nncron.ru/translation/nncron/readme.lt.txt
call wget -e continue=off -N http://www.nncron.ru/translation/nncron/readme.pt.txt
call wget -e continue=off -N http://www.nncron.ru/translation/nncron/readme.rus.txt
call wget -e continue=off -N http://www.nncron.ru/translation/nncron/readme.it.txt
call wget -e continue=off -N http://www.nncron.ru/translation/nncron/readme.nl.txt
call wget -e continue=off -N http://www.nncron.ru/translation/nncron/readme.pl.txt
call wget -e continue=off -N http://www.nncron.ru/translation/nncron/readme.ro.txt
call wget -e continue=off -N http://www.nncron.ru/translation/nncron/readme.srb-lat.txt
call wget -e continue=off -N http://www.nncron.ru/translation/nncron/readme.ua.txt

popd

pushd %HOME%\src\cron\release\txt
call wget -e continue=off -N http://www.nncron.ru/translation/nncron/license.txt
call wget -e continue=off -N http://www.nncron.ru/translation/nncron/license.rus
del license.rus.txt
ren license.rus license.rus.txt
popd


pushd %HOME%\src\cron\release\res
call wget -e continue=off -N http://www.nncron.ru/translation/nncron/Belarussian.txt
call wget -e continue=off -N http://www.nncron.ru/translation/nncron/Chinese(Simplified).txt
call wget -e continue=off -N http://www.nncron.ru/translation/nncron/Czech.txt
call wget -e continue=off -N http://www.nncron.ru/translation/nncron/Dutch.txt
rem call wget -e continue=off -N http://www.nncron.ru/translation/nncron/English.txt
call wget -e continue=off -N http://www.nncron.ru/translation/nncron/Finnish.txt
call wget -e continue=off -N http://www.nncron.ru/translation/nncron/French.txt
call wget -e continue=off -N http://www.nncron.ru/translation/nncron/German.txt
call wget -e continue=off -N http://www.nncron.ru/translation/nncron/Hungarian.txt
call wget -e continue=off -N http://www.nncron.ru/translation/nncron/Italian.txt
call wget -e continue=off -N http://www.nncron.ru/translation/nncron/Lithuanian.txt
call wget -e continue=off -N http://www.nncron.ru/translation/nncron/Portuguese.txt
call wget -e continue=off -N http://www.nncron.ru/translation/nncron/Portuguese-BR.txt
rem call wget -e continue=off -N http://www.nncron.ru/translation/nncron/Russian.txt
call wget -e continue=off -N http://www.nncron.ru/translation/nncron/Polish.txt
call wget -e continue=off -N http://www.nncron.ru/translation/nncron/Spanish.txt
call wget -e continue=off -N http://www.nncron.ru/translation/nncron/Romanian.txt
call wget -e continue=off -N http://www.nncron.ru/translation/nncron/Serbian-Latin.txt
call wget -e continue=off -N http://www.nncron.ru/translation/nncron/Ukrainian.txt


popd

pushd %HOME%\src\help
call wget -e continue=off -N http://www.nncron.ru/download/%ZIPFILE%
if exist %ZIPFILE% goto unzip_help
echo ERROR: file %ZIPFILE% not exists
goto exit
:no_get_help
:unzip_help
cd
echo unzipping %HELPFILE%
del %HELPFILE%
unzip -o %ZIPFILE%
copy %HELPFILE% %HOME%\src\cron\release\doc
:exit
popd