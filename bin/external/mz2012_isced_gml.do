/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  Diese Datei: mz12_isced_gml.do
       Dateiformat: Dos\Windows
       Zeichensatz: Windows-1252
  Download: http://www.gesis.org/missy/materials/MZ/tools/isced
  Version: 29. August 2016

  Stata-Syntax zur Umsetzung der Bildungsklassifikation ISCED-1997
  mit dem Mikrozensus 2012
  ISCED-Version des German Microdata Lab, GESIS

  Version: Stata/MP 13.1/14.1 for Windows

  Siehe dazu:
  Schroedter, J. H.; Lechert, Y.; Luettinger, P. (2006): Die Umsetzung der
  Bildungsskala ISCED-1997 fuer die Volkszaehlung 1970, die Mikrozensus-
  Zusatzerhebung 1971 und die Mikrozensen 1976-2004.
  ZUMA-Methodenbericht 2006/08.
  http://www.gesis.org/fileadmin/upload/forschung/publikationen/gesis_reihen/
  gesis_methodenberichte/2006/06_08_Schroedter.pdf

  Datenbasis: Mikrozensus 2012, Scientific Use File
  siehe http://www.gesis.org/missy/metadata/MZ/2012/

  GESIS - Leibniz-Institut fuer Sozialwissenschaften
  German Microdata Lab (GML)
  http://www.gesis.org/das-institut/kompetenzzentren/fdz-german-microdata-lab
  E-Mail: gml@gesis.org

 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  Bitte beachten:
  Die Syntax mit der Zeichencodierung Windows-1252 ist auch mit aelteren Versionen
  vor Stata 14 ablauffaehig.
  Stata 14 benoetigt jedoch das Setup mit dem Zeichensatz Unicode (UTF-8).
  Diese Umsetzung kann durch die folgenden Befehle im Kommandofenster geschehen:
    * Lokale Zeichensatzcodierung, hier z. B. Windows-1252, ggf. aendern
    unicode encoding set Windows-1252
    * Umwandeln in Unicode (UTF-8) Zeichencodierung
    unicode translate "mz12_isced_gml.do", nodata

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

// version 14.1       // Stata/MP 14.1 for Windows
//
// clear
// capture log close
// set varabbrev off
// set dp comma
// set more off
//
// * Im folgenden Kommando "<DIR>" durch das lokale Arbeitsverzeichnis ersetzen
// cd <DIR>
//
// log using mz12_isced_gml.log, text replace
//
// /* Im folgenden Kommando ist "<mz2012.dta>" durch den lokalen Dateinamen zu
//    ersetzen; ggf. ohne Variablenauswahl - Datenfile ohne User-Missings */
// use EF30  /// Bevoelkerung: Haupt- oder Nebenwohnsitz
//     EF44  /// Alter
//     EF47  /// Geburtsjahr
//     EF287 /// F124 Schule: gegenwaertiger Besuch (i. d. letzten 4 Wochen)
//     EF288 /// F123 Schule: Besuch im letzten Jahr
//     EF289 /// F125 Art der besuchten Schule
//     EF290 /// F126 Art der besuchten allgemeinbildenden Schule (Klassenstufe)
//     EF309 /// F135 Allgemeiner Schulabschluss
//     EF310 /// F136 Hoechster allg. Schulabschluss
//     EF311 /// F137 Beruflicher Abschluss
//     EF312 /// F138 Hoechster berufl. Abschluss
//     EF952 /// Standardhochrechnungsfaktor Jahr (in 1000) - neuer Hochrechnungsrahmen
// using "<mz2012>", clear


/* *************************************************************************
Bildung der Variable "Allgemeinbildender Schulabschluss"

Klasse 5-10 zu Haupt-/Volksschule
Klasse 11-13 zu Fachhochschulreife/Abitur
In den Mikrozensen bis 2004 gab es zur Frage "Allgemeiner Schulabschluss
vorhanden" die Antwortkategorie "Ohne Angabe" (siehe u.a. MZ 2004: EF258=9),
die zur Bildung der Variable as=2 "ohne Angabe ob allgemeinbildender
Schulabschluss" benoetigt wurde. Zur besseren Verstaendlichkeit entfaellt diese
Kategorie ab MZ2005 und wird statt dessen bei der Frage "Hoechster Allgemeiner
Schulabschluss" erfragt (siehe u.a. MZ2006: EF310=9) und zur Kategorie as=3
"ohne Angabe zur Art des Schulabschlusses" zusammengefasst.

Ab dem Mikrozensus 2008 wird bei der Frage zum Besuch von Schule und Hochschule
in den letzten 4 Wochen auch erfragt, ob die Schule wegen Ferien oder
Uebergang in eine andere Schule/Ausbildung nicht besucht wurde
(Variable EF287=2). Diese Angabe wird im Folgenden wie ein Schulbesuch (EF287=1)
behandelt.

***************************************************************************/
recode EF310 ///
  (-7 -8 =.) /// Entfaellt, fuer Querschnittausw. nicht relevant
  (-3 -5 = 0 "[0] entf./o.A.") ///
  (6 = 1     "[1] kein AB") /// Abschluss nach hoechstens 7 Jahren Schulbesuch
  /// "[2] o.A. ob SA": ab 2005 in EF310=9 integriert
 (9 = 3      "[3] o.A. zur Art/o.A. ob SA") ///
 (1 2 = 4    "[4] HS/VS, POS 8./9. Kl., Kl. 5-10") ///
 (3 7 = 5    "[5] RS/POS 10. Kl.") ///
 (4 5 = 6    "[6] FHR/ABI, gym. Oberstufe"), generate (as)

replace as=1 if (EF309==8) // Nein/noch nicht
replace as=7 if (((EF287>=1 & EF287<=2) | EF288==1) & EF290==2) // Klassenstufe 5 bis 10
replace as=8 if (((EF287>=1 & EF287<=2) | EF288==1) & EF290==3) // Gymnasiale Oberstufe
recode as (4 7=4) (6 8=6)
label variable as "Allgemeinbildender Schulabschluss"


/***************************************************************************
Bildung der Variable "Berufsbildender Abschluss"

In den Mikrozensen bis 2004 gab es zur Frage "Beruflicher Ausbildungs-
oder Hochschul-/Fachhochschulabschluss vorhanden?" die Antwortkategorie
"Ohne Angabe" (siehe u.a. MZ2004: EF260=9), die zur Bildung der Variable
ba=2 "ohne Angabe ob beruflicher Abschluss" benoetigt wurde. Zur besseren
Verstaendlichkeit entfaellt diese Kategorie ab MZ2005 und wird statt dessen
bei der Frage "Hoechster beruflicher Ausbildungs- oder Hochschul-/
Fachhochschulabschluss" erfragt (siehe u.a. MZ2006: EF312=99) und zur
Kategorie ba=3 "ohne Angabe zur Art des beruflichen Abschlusses"
zusammengefasst.

***************************************************************************/
recode EF312 ///
  (-7 -8 = .) /// Entfaellt, fuer Querschnittsausw. nicht relevant
  (-3 -5 = 0 "[0] entf./o.A.") ///
  /// "[2] o.A. ob SA": ab 2005 in EF312=9 integriert
 (99 = 3     "[3] o.A. zur Art d. BA/o.A. ob BA") ///
 (1 2 = 4    "[4] Anlernausb./Praktikum/BVJ") ///
 (3/6 = 5    "[5] Lehrausb./Berufsfachs./Vorber.mittl.Dienst/Gesundhw. 1J.") ///
 (7/12 = 6   "[6] Gesundheitsw. 2-/3j./Meister/Technik./Fachschule/Fachak./Berufsak./Verw.FH") ///
 (13 14 = 7  "[7] FH/Hochschule/Duale HS") ///
 (15 = 8     "[8] Promotion"),generate (ba)
replace ba=1 if (EF311==8) // Nein/noch nicht
label variable ba "Beruflicher Abschluss"
label define ba 1 "[1] kein BA", add modify

/***************************************************************************
Bildung der Hilfsvariable "Gegenwaertiger Besuch berufliche Schule"

Ab dem Mikrozensus 2008 wurden die Fragen zum Schulbesuch (EF287-EF293)
modifiziert. Insbesondere wurden die ehemals drei Fragen zur Art der besuchten
allgemeinbildenden Schule, der beruflichen Schule und der (Fach-)Hochschule
ab 2008 in eine Frage (Variable EF289; MZ 2007: Variablen EF289-EF291)
zusammengefasst.
***************************************************************************/

generate ba2 = .
replace ba2 = 4 if EF289>=16 & EF289<=19 & ((EF287>=1 & EF287<=2) | EF288==1)
replace ba2 = 5 if EF289==12 | EF289==13 | EF289==14 | EF289==15 | EF289==20 ///
                   & ((EF287>=1 & EF287<=2) | EF288==1)
replace ba2 = 6 if EF289>=21 & EF289<=25 & ((EF287>=1 & EF287<=2) | EF288==1)
replace ba2 = 7 if EF289==26 | EF289==27 & ((EF287>=1 & EF287<=2) | EF288==1)
replace ba2 = 8 if EF289==28 & ((EF287>=1 & EF287<=2) | EF288==1)
label variable ba2 "Gegenwaertiger Besuch berufliche Schule" // incl. i.d. letzt. 12 Mon. (EF288)
label define ba2 4 "Berufsschule/BGJ/BVJ" ///
                 5 "berufl. Schule verm. RS/FHR, einj. SdG" ///
                 6 "Fachschule, Fach-/Berufsakademie/2-3j. SdG, Verw.FH" ///
                 7 "FH/Hochschule/UNI" ///
                 8 "Promotion"
label values ba2 ba2


/****************************************************************************
Modifikation der Variable "Berufsbildender Abschluss"

Wenn der angestrebte berufliche Abschluss hoeher ist als der gegenwaertige,
ersetzt dieser den "eigentlichen" beruflichen Abschluss.
****************************************************************************/
recode ba 1 3=4   if ba2==4 & ba2>ba
recode ba 1 3 4=5 if ba2==5 & ba2>ba
recode ba 1 3/5=6 if ba2==6 & ba2>ba
recode ba 1 3/6=7 if ba2==7 & ba2>ba
recode ba 1 3/7=8 if ba2==8 & ba2>ba

*****************************************************************************
* Kreuztabelle zur Zuordnung der ISCED-Stufen
tab as ba
*****************************************************************************


/****************************************************************************
Bildung der Variable "ISCED-1997 - GML"

Aufgrund der Streichung der Variablen 'Besuch eines Kindergartens,
einer Kindergrippe bzw. eines Kinderhorts' ab MZ2005, kann die ISCED-
Kategorie 0, die den Elementarbereich (Vorschulbereich) abbildet, nicht mehr
gebildet werden.
****************************************************************************/
generate is=99 if EF287>-7
replace is=1  if (as==1 & ba==1)
replace is=2  if ((EF287>=1 & EF287<=2 | EF288==1) & EF290==1)
replace is=3  if ((as==0 | as==1) & (ba==3 | ba==4)) | ((as==3 | as==4) ///
                  & (ba==0 | ba==1 | ba==3 | ba==4))
replace is=4  if (as==5 & (ba==1 | ba==3 | ba==4))
replace is=5  if ((as==0 | as==1 | as==3 | as==4 | as==5) & ba==5)
replace is=6  if (as==6 & (ba==1 | ba==3 | ba==4))
replace is=7  if (as==6 & ba==5)
replace is=8  if (ba==6)
replace is=9  if (ba==7)
replace is=10 if (ba==8)
label variable is "ISCED-1997 - GML"
label define is 1 "1B" /// Ohne allgemeinen Schulabschluss; ohne beruflichen Abschluss
                2 "1A" /// Schulbesuch Klassen 1-4; Personen mit Schulbesuch, in Ausbildung
                3 "2B" /// Hauptschulabschluss, Schulbesuch Klassen 5-10, ...
                4 "2A" /// Realschulabschluss, kein beruflicher Abschluss ...
                5 "3B" /// Abschluss einer Lehrausbildung ...
                6 "3A" /// Fach-/Hochschulreife, Schulbesuch Klassen 11-13
                7 "4A" /// Fach-/Hochschulreife und Abschluss einer Lehrausbildung ...
                8 "5B" /// Meister-/Techniker- oder Fachschulabschluss ...
                9 "5A" /// Fachhochschulabschluss, Hochschulabschluss ...
                10 "6" /// Promotion
                99 "entf./nicht zuordenbar"
label values is is
numlabel is, add mask("[#] ") force
tab is, miss

******************************************************************************
*  OPTIONAL:
*
*  Ausschluss der Personen, die gegenwaertig noch in der Ausbildung sind:
*  keep if (EF287>2)
*  oder z.B.: tab is if (EF287>2)
*
*  Ausschluss von Personen, die unter 15 Jahre alt sind:
*  keep if (EF44>=15)
*  oder z.B.: tab is if (EF44>=15)
******************************************************************************
