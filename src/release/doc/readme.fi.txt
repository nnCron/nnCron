                                 nnCron
                                 ~~~~~~

nnCron on vahva ohjelmoitava suoritin, muistutin ja
automaatiopalikka eli lyhyesti turbo-windows-cron. Se on
ohjelmoitavissa omalla (Forth- yhteensopivalla) skriptikielellä,
tukee myös VBScript/JScript:iä sekä vahvoja korvauslausekkeita
(regular expressions). Sen toimintoja voi laajentaa
plugin-palikoilla.

nnCron osaa lukea Unix crontab tiedostoformaattia. Tämä
tekstitiedosto hallinnoi sen toimintoja. Vaihtoehtoisesti voi myös
käyttää graaffista käyttöliittymää tapahtumien
lisäämiseen/poistoon/muokkaamiseen.

Perus cron toimintojen (ajallinen komentojen suoritus, muistutus ja
dokumenttien avaus), nnCron osaa myös:
- käynnistää ohjemia palveluina,
- käynnistää komennot eri käyttäjinä,
- sammuuttaa/talvehtia tietokone tai nukuttaa tietokone määrättyyn
  kellonaikaan,
- "herättää" tietokone tiettyyn aikaan suorittamaan komento
- näyttää/piilottaa/sulkea/pienentää/suurentaan sekä piilottaa
  ikkunoita alapalkkiin järjestelmäkaukaloon,
- luo tiedotus-ikkunaan viestiin tai kijoittaa lokitiedostoon,
- toimii välimuistin, tiedostojen sekä rekisterin kanssa,
- emuloi/jäljittelee näppäin sekä hiiri toimintoja,
- aloittaa/katkaista modeemi-yhteydet,
- soittaa eri pituusia ja taajuuksia tietokoneen omalla
  kovaäinsellä,
- soittaa audio tiedostoja,
- tarkistaa järjestelmän kellon,
- määrittelee eri prosessi-prioriteetejä,
- keskeyttää ohjelmia ja prosesseja,
- käynnistyä itsestään uudelleen tarvittaessa.
- seurata tiedostoja, lippuja, ikkunointa, prosesseja, hiiren
  liikkeitä, jouto-aikaa, näppäin oikoteitä, Internet yhteysiä,
  levykkeiden ja romppujen lisäystä/poistoja, lähiverkkoyhteyksiä
  (ping), levyjen käyttöastetta, jne...

nnCron on luotettava, helppokäyttöinen vähän-muistia käyttävä
sovellus. Se on nopea ja tarjoaa runsaasti hyödyllisiä
ominaisuuksia joita edelleenkehitellään yhteistyössä nnCron
käyttäjien kanssa.

---------------------------------------
Rekisteröinti
---------------------------------------
nnCron jakelu on toteutettu shareware periaatteella: Sen voi
imuroida/asentaa/ kokeilla 30 päivää, jonka jälkeen se on
rekisteröitävä jos sitä haluaa edelleen käyttää.

Registeröinti maksaa US$25:
    http://www.nncron.ru/register.shtml
Rekisteröinnin jälkeen sinulle lähetetään sähköpostilla
avain-tiedosto. Laita tämä tiedosto nnCron hakemistoon ja käynnistä
nnCron uudelleen.

Jokainen joka suostuu kääntämään kolme tiedostoa uudelle kielelle
(omalle äidinkielelle) myönnetään ilmainen lisenssi. Lisätietoja:
http://www.nncron.ru/translation.shtml

Oppilaitosalennuksia voi tiedustella ohjelmoitsijalta: 
nemtsev@nncron.ru

---------------------------------------
Laitteistovaatimukset, asennus ja poisto: nnCron
---------------------------------------
  - IBM PC yhteensopiva tietokone
  - Intel Pentium processori tai parempi
  - Windows 95/98/ME/NT/2000/XP

Aloita nnCron asennus tuplakilkkaamalla asennustiedosto. Asennuksen
yhteydessä on määriteltävä asennuskansio. Ohjelman poistaan
hallintapaneelin "Lisää/Poista ohjelmia" ikoonista.
asennushakemistossa on tiedosto 'nncron.ini' jossa on kaikki ohjeman
asetukset.

---------------------------------------
nnCron käynnistys/lopetus
---------------------------------------

Helpoin tapa käsin käynnistää nnCron on 'startnncron.bat' ohjelmalla
asennushakemistosta. Tiedosto pysäytetään 'stopnncron.bat'
komennolla tai klikkaamalla oikealla hiirellä nnCron ikonia ja
valitsemalla 'Exit' eli 'Lopetus' valikosta.

Asennuksen yhteydessä nnCron ohjelmarymään luodaan myös oikopolut
näille bat-tiedostoille 'Start' eli 'Aloitus' painikkeseen.  You can
find shortcuts to above mentioned bat-files in nnCron program group,
located in Windows 'Start menu'.

---------------------------------------
nnCron dokumentit ja käyttäjätuki
---------------------------------------

Täydellinen enlanninkielinen windows-helppi tiedosto ('help.chm')
luodaan asennuksen yhteydessä. Tästä tiedostosta löytyy nopeasti
apua ja esimerrkeijä käytöstä.

Lisäksi, jos helppi tiedosto ei riitä, kannattaa liittyä
postituslistaan (nncron-subscribe@nncron.ru).
josta voi hakea/kysyä lisäneuvoja (Englanninkielinen lista).
Virallinen sähköpostituki toimii osoitteessa support@nncron.ru
Ohjelmoitsijalle voi myös antaa palautetta tai lähettää virheraportteja
osoitteeseen nemtsev@nncron.ru

---------------------------------------
Linkkejä:
---------------------------------------

nnCron kotisivu:
    http://www.nncron.ru/
nnCron dokumentit:
    http://www.nncron.ru/download/help.zip (English language)
    http://www.nncron.ru/download/help_ru.zip (Russian language)
    http://www.nncron.ru/download/faq.zip (English language)
    http://www.nncron.ru/download/faq_ru.zip (Russian language)

nnCron dokumentit verkossa:
    http://www.nncron.ru/help/help.htm (English language)
    http://www.nncron.ru/help/help_ru.htm (Russian language)

---------------------------------------
Copyrights/Tekijänoikeudet:
---------------------------------------
Copyright (C) 2000-2002 nnSoft. E-mail: nemtsev@nncron.ru
    http://www.nncron.ru/
SP-Forth 3.75 Copyright (C) 1992-2000 A.Cherezov 
    http://www.forth.org.ru/
RegExp 4.0 (C) Cail Lomecb <ruiv@uic.nnov.ru> 
    http://www.uic.nnov.ru/~ruiv/
