                                 nnCron
                                 ~~~~~~

nnCron yra paþangus galingas planuotojas, priminëjas, skriptø
árankis ir automatizatorius. nnCron turi savo (suderinamà su Forth)
skriptø kalbà, leidþia naudoti VBScript/JScript, taip pat paprastuosius
reiðkinius ir gali bûti iðplëstas intarpais.

nnCron supranta cron lentelës formatà (Unix) ir yra valdomas
lengvai redaguojamais crontab failais. Taèiau tiems, kas teikia
pirmenybæ GVS aplinkai, programa turi grafinæ sàsajà, kuria galima
ðalinti, pridëti, redaguoti uþduotis, nustatyti priminimus, keisti
programos nustatymus.

Be tradiciniø planuotojo ypatybiø (programø paleidimas, priminimø rodymas
ir dokumentø nurodytu laiku atidarymas),
nnCron taip pat gali:
  - vykdyti bet kurià programà kaip servisà;
  - vykdyti uþduotis kito naudotojo paskyroje;
  - valdyti ir ið naujo vykdyti praleistas uþduotis ir priminimus
  - iðjungti ar iðsaugoti (hibernate) kompiuterá, arba uþmigdyti nurodytu laiku;
  - "priþadinti" kompiuterá uþduoties vykdymui;
  - rodyti/slëpti/uþdaryti/naikinti/sutraukti/iðskleisti langus bei slëpti nurodytus
    langus sisteminëje juostoje;
  - rodyti praneðimus ekrane ir iðsaugoti juos á registro failà;
  - dirbti su iðkarpø krepðeliu, failais, sistemos registru;
  - emuliuoti klaviatûros ávedimà ir pelës aktyvumà;
  - skambinti ir nutraukti ryðá;
  - naudoti sistemos garsiakalbá nurodyto ilgio ir daþnio pypsëjimams;
  - groti garso failus;
  - sinchronizuoti sistemos laikà;
  - procesui priskirti nurodytà prioritetà;
  - nutraukti bet kurá vykdomà procesà;
  - automatiðkai persikrauti po kritiniø klaidø.
  - stebëti failus, parametrus, langus, procesus, pelës aktyvumà,
    budëjimo periodus, sparèiuosius klaviðus, prisijungimà/atsijungimà nuo Interneto,
    disko ádëjimà á diskasuká, kito kompiuterio buvimà tinkle (ping), 
    laisvos vietos diske kieká ir t. t.

nnCron yra labai patikima, maþa ir lengvai naudojama programa. Ji veikia
liepsnojanèiai greitai ir siûlo daugybæ naudingø ypatybiø, iðvystytø
kartu su kitais nnCron naudotojais.

---------------------------------------
Registracija
---------------------------------------
nnCron yra platinamas kaip sàlyginai nemokama programa: jûs galite atsisiøsti
nemokamai ir vertinti jà 30 dienø. Jei nusprendþiate toliau naudoti nnCron
po 30 dienø vertinimo laikotarpio, turëtumëte jà uþregistruoti.

Jûs galite uþregistruoti nnCron tik uþ $25:
    http://www.nncron.ru/register.shtml
Po registracijos jûs gausite savo nuosavà rakto failà elektroniniu paðtu.
Ákelkite já á nnCron katalogà ir perkraukite nnCron.

Jûs galite gauti nemokamà nnCron registracijà iðversdami nnCron kalbos failus
á jûsø gimtàjà kalbà ir palaikydami juos naujais. Detalesnæ informacijà rasite
http://www.nncron.ru/translation.shtml

Praðau susisiekti su autoriumi dël mokomøjø nuolaidø: nemtsev@nncron.ru

---------------------------------------
Sisteminiai reikalavimai, nnCron diegimas/ðalinimas
---------------------------------------
  - IBM PC ar suderinamas
  - Intel Pentium procesorius ar geresnis
  - Windows 95/98/ME/NT/2000/XP

Norëdami paleisti nnCron diegimà, dukart spustelëkite kairiuoju pelës
klaviðu ant platinamo failo. Diegimo metu bus papraðyta parinkti
diegimo katalogà.
Norëdami paðalinti nnCron, naudokite 'Add or remove programs' esantá 'Control Panel'.
nnCron laiko savo nustatymus 'nncron.ini' faile.

---------------------------------------
nnCron paleidimas ir stabdymas
---------------------------------------
Patogiausias bûdas rankiniu bûdu paleisti nnCron servisà yra paleisti
'startnncron.bat' esantá nnCron pradþios kataloge. Norëdami iðjungti
nnCron, paleiskite 'stopnncron.bat' arba spauskite ant 'Iðeiti' meniu
punkto nnCron meniu (pasiekiamo paspaudus deðiná pelës klaviðà ant
nnCron piktogramos sisteminëje juostoje).

Nuorodas á anksèiau nurodytus bat failus rasite nnCron programos grupëje,
esanèioje Windows 'Start menu'.

---------------------------------------
nnCron dokumentacija, naudotojø palaikymas
---------------------------------------
Visa nnCron dokumentacija anglø kalba ('help.chm') yra platinama nnCron
platinimo faile. nnCron dokumentacija rusø kalba yra pasiekiama kaip
atskiras nemokamas atsisiuntimas. Á bet kokius klausimus ar problemas,
galinèias kilti naudojant nnCron, atsakymo ieðkoti rekomenduojama
nnCron dokumentacijoje, platinamoje kartu su nnCron.

Jei iðkilo klausimø dël nnCron naudojimo ir negalite rasti atsakymø
dokumentacijoje, praðome apsilankyti mûsø forumuose
(http://www.nncron.ru/forums/) ar prenumeruoti (bei klausti klausimø)
nnCron elektroninæ konferencijà. Oficiali konferencijos kalba yra anglø.
Norëdami uþsiprenumeruoti, siøskite el. laiðkà á
nncron-subscribe@nncron.ru.
nnCron palaikymo el. paðtas: support@nncron.ru
Nesivarþykite ir siøskite komentarus ir klaidø praneðimus nnCron autoriui:
nemtsev@nncron.ru

---------------------------------------
Nuorodos
---------------------------------------
nnCron pradinis puslapis:
    http://www.nncron.ru/
nnCron dokumentacija:
    http://www.nncron.ru/download/help.zip (anglø kalba)
    http://www.nncron.ru/download/help_ru.zip (rusø kalba)
    http://www.nncron.ru/download/faq.zip (anglø kalba)
    http://www.nncron.ru/download/faq_ru.zip (rusø kalba)
nnCron dokumentacija Internete:
    http://www.nncron.ru/help/help.htm (anglø kalba)
    http://www.nncron.ru/help/help_ru.htm (rusø kalba)
nnCron forumai:
http://wwww.nncron.ru/forums/
nnCron vertimai:
    http://www.nncron.ru/translation.shtml

---------------------------------------
Autorinës teisës
---------------------------------------
Copyright (C) 2000-2002 nnSoft. E-mail: nemtsev@nncron.ru
    http://www.nncron.ru/
SP-Forth 3.75 Copyright (C) 1992-2000 A.Cherezov 
    http://www.forth.org.ru/
RegExp 4.0 (C) Cail Lomecb <ruiv@uic.nnov.ru> 
    http://www.uic.nnov.ru/~ruiv/
