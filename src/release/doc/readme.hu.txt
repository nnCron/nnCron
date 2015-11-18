                                 nnCron
                                 ~~~~~~

Az nncron egy fejlett, nagy tudású feladatütemezõ, emlékeztetõ,
automatizáló és szkript-támogatással rendelkezõ eszköz. Egy saját
(Forth-kompatibilis) beépített szkriptnyelvvel rendelkezik, ezenkívül
lehetõvé teszi a VBScript/JScript használatát, csakúgy mint a reguláris
kifejezésekét, valamint tovább bõvíthetõ pluginok használatával.

Az nncron a standard cron táblaformátumot használja (Unix), és könnyen
szerkeszthetõ szöveges crontab file-okkal vezérelhetõ. A grafikus felületet
elõnyben részesítõk számára tartalmaz egy grafikus shell-t, amely
lehetõséget ad feladatok hozzáadására, szerkesztésére, törlésére és
futtatására, valamint emlékeztetõk hozzáadására, a program beállítására.

A szokványos ütemezõ és naptári funkciók mellett (programindítás,
emlékeztetõ üzenetek megjelenítése és dokumentumok megnyitása megadott
idõpontban) az nncron sok más hasznos képességgel is rendelkezik:

  - képes programokat rendszerszolgáltatásként futtatni
  - megadott felhasználó nevében futtatni taszkokat
  - kezelni és újraindítani elmulasztott taszkokat és emlékeztetõket
  - leállítani és hibernálni a számítógépet, vagy "alvó" üzemmódba 
    helyezni megadott idõpontban
  - "felébreszteni" a gépet egy feladat elvégzése céljából
  - megjeleníteni, elrejteni, bezárni, kilõni, kicsinyíteni, nagyítani
    megadott ablakokat a tálcára és ikonként az óra mellé
  - üzenetek megjelenítésére a képernyõn és ezeket naplófájlban rögzíteni
  - kezeli a vágólapot, fájlokat és a regisztrációs adatbázist
  - képes emulálni billentyûzetrõl és egérrõl érkezõ aktivitást
  - tárcsáz és vonalat bont
  - hangjelzéseket tud adni a rendszer hangszórón keresztül, ennek
    frekvenciáját és hosszát tetszés szerint megadhatjuk
  - hangfájlokat tud lejátszani
  - a rendszeridõt szinkronizálja
  - megadott szintû prioritásokat képes rendelni folyamatokhoz
  - bármely folyamatot képes "kilõni"
  - automatikusan úrjaindít végzetes hibák esetén
  - képes file-ok, állapotjelzõk, ablakok, folyamatok, egéraktivitások
    nyomonkövetésére, billentyûzet figyelésre, üresjárati idõtartamok
    figyelésére, billenytûzetparancsokra, lemezcsatolásra, hosztok 
    figyelésére a hálózatban (ping), szabad hely figyelésére a lemezen,
    stb. stb.

Az nncron megbízható, kicsi és könnyen használható alkalmazás. Bámulatos
gyorsasággal fut, és hasznos szolgáltatások sokaságát nyújtja, amelyeket
más nncron felhasználókkal szoros együttmûködésben fejlesztettek ki.

---------------------------------------
Regisztráció
---------------------------------------
Az nncron terjesztése shareware programként történik: ingyenesen
letöltheted és kibróbálhatod 30 napig. Ha úgy döntesz, hogy szeretnéd a 30
napos idõszak után is használni, akkor regisztrálnod kell.

Az nncron regisztrálása csak 25 dollár:
    http://www.nncron.ru/register.shtml
A regisztráció után kapsz majd egy e-mail-t, amely tartalmazza a saját
kulcsodat.
Ezt kell elhelyezned az nncron könyvtárában, majd újraindítani az nncron-t.

Ingyenes a regisztráció, ha lefordítod az nncron nyelvi fájlokat
a saját nyelvedre, és folyamatosan karban tartod õket. A részletekért
látogass el a http://www.nncron.ru/translation.shtml oldalra.

Oktatási kedvezmény esetén kérlek, vedd fel a kapcsolatot a szerzõvel :
nemtsev@nncron.ru

-------------------------------------------------------
Rendszerszükséglet, installálás/eltávolítás
--------------------------------------------------------
  - IBM PC vagy kopmatibilis
  - Intel Pentium processzor vagy nagyobb
  - Windows 95/98/ME/NT/2000/XP

Az nncron installációjához kattints duplán az egér bal gombjával a
disztribúció fájlján. Az installálás folyamán meg kell majd adnod a
telepítés célmappáját.  Eltávolításához használd a "Programok hozzáadása és
eltávolítása" ikont a Vezérlõpultban.
A program beállításai megmaradnak az "nncron.ini" fájlban.

---------------------------------------
Az nnCron indítása és leállítása
---------------------------------------
Az nnCron szolgáltatás manuális elindításának legmegfelelõbb módja a
'startnncron.bat' állomány futtatása a feltelepített program könyvtárában.
A memóriából történõ eltávolításhoz a 'stopnncron.bat' kell futtatnunk,
vagy az 'Exit' menüpontot is válaszhatjuk az nncron kontext menüjében
(elérhetõ az óra melleti nnCron ikonon jobb gombbal kattintva).

A fent említett bat-fájlokra mutató parancsikon az nnCron programcsoportban
található, a Windows 'Start menüjében'.

---------------------------------------
nnCron dokumentáció, felhasználó támogatás
---------------------------------------
A teljes angol nyelvû nnCron dokumentáció ('help.chm') megtalálható az
nnCron disztribúcióban. Az nnCron orosz nyelvû dokumentációja külön,
ingyenesen letölthetõ.  Erõsen ajánlott az nnCron dokumentáció
áttanulmányozása annak érdekében, hogy a felmerülõ kérdésekre és
problémákra gyors válaszokat és megoldásokat találjunk.

Ha kérdése van az nnCron használatával kapcsolatban, és a válasz nem
található meg a dokumentációban, kérem iratkozzon fel (és tegye fel
kérdését) az angol nyelvû nnCron levelezõ listára. A feliratkozáshoz
küldjön egy levelet a következõ címre:
nncron-subscribe@nncron.ru. 

Az nnCron támogatási e-mail címe: support@nncron.ru

A szoftverrel kapcsolatos véleményét és a hibajelenségeket elküldheti a
szerzõ címére: nemtsev@nncron.ru


---------------------------------------
Linkek
---------------------------------------
nnCron honlap:
    http://www.nncron.ru/
nnCron dokumentáció:
    http://www.nncron.ru/download/help.zip (English language)
    http://www.nncron.ru/download/help_ru.zip (Russian language)
    http://www.nncron.ru/download/faq.zip (English language)
    http://www.nncron.ru/download/faq_ru.zip (Russian language)
nnCron online dokumentáció:
    http://www.nncron.ru/help/help.htm (English language)
    http://www.nncron.ru/help/help_ru.htm (Russian language)
nnCron fordítások:
    http://www.nncron.ru/translation.shtml

---------------------------------------
Copyrights
---------------------------------------
Copyright (C) 2000-2002 nnSoft. E-mail: nemtsev@nncron.ru
    http://www.nncron.ru/
SP-Forth 3.75 Copyright (C) 1992-2000 A.Cherezov 
    http://www.forth.org.ru/
RegExp 4.0 (C) Cail Lomecb <ruiv@uic.nnov.ru> 
    http://www.uic.nnov.ru/~ruiv/
