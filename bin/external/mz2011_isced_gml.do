* mz11_isced_gml.do

// version 13.0     // Stata/MP 13.0 for Windows
// clear
// capture log close
// set more off
// * set mem 500m // ab Stata Version 12 ist der Befehl nicht mehr notwendig
// set dp comma
//
// * Im Kommando "<DIR>" das lokale Arbeitsverzeichnis eintragen
// cd "<DIR>"
// log using isced11.log, replace

/**************************************************************************
GESIS - Leibniz-Institut fuer Sozialwissenschaften
German Microdata Lab (GML)
Postfach 12 21 55
68072 Mannheim
Tel.: 0621/1246-265 Fax:  0621/1246-100
E-Mail: gml@gesis.org
Christine Krings, Andreas Herwig
Version: 27.05.2014
***************************************************************************/


/***************************************************************************
STATA-Syntax zur Umsetzung der Bildungsklassifikation ISCED-1997 mit dem
Mikrozensus 2011
ISCED-Version des German Microdata Lab, GESIS

Bei Nutzung dieser Routine bitte wie folgt zitieren:
(hier wird auch die Skalenkonstruktion beschrieben)
Schroedter, J. H.; Lechert, Y.; Luettinger, P. (2006): Die Umsetzung der
Bildungsskala ISCED-1997 fuer die Volkszaehlung 1970, die Mikrozensus-
Zusatzerhebung 1971 und die Mikrozensen 1976-2004.
ZUMA-Methodenbericht 2006/08. URL: http://www.gesis.org/fileadmin/upload/
forschung/publikationen/gesis_reihen/gesis_methodenberichte/2006/
06_08_Schroedter.pdf
Programm: http://www.gesis.org/missy/fileadmin/missy/klassifikationen/ISCED/
ISCED_STATA/mz11_isced_gml.do

Literaturhinweise, Quellen:
United Nations Educational, Scientific and Cultural Organization 1997:
International Standard Classification of Education ISCED 1997.
http://www.uis.unesco.org/Library/Documents/isced97-en.pdf
OECD 1999: Classifying Educational Programmes. Manual for ISCED-97.
Implementation in OECD Countries. 1999 Edition.
http://www.oecd.org/education/skills-beyond-school/1962350.pdf

Datenbasis: Mikrozensus-Scientific Use File 2011
Datenbeschreibung:
	http://www.gesis.org/missy/auswahl-datensatz/mikrozensus-2011/
***************************************************************************/


****************************************************************************
*                                    MZ 2011
****************************************************************************

* Im folgenden Kommando ist "<mz2011>" durch den lokalen Dateinamen
* zu ersetzen; ggf. mit Variablenauswahl.
// use "<mz2011>", replace

/* *************************************************************************
Bildung der Variable "Allgemeinbildender Schulabschluss"

Klasse 5-10 zu Haupt-/Volksschule
Klasse 11-13 zu Fachhochschulreife/Abitur
In den Mikrozensen bis 2004 gab es zur Frage "Allgemeiner Schulabschluss
vorhanden" die Antwortkategorie "Ohne Angabe" (siehe u.a. MZ2004: EF258=9),
die zur Bildung der Variable as=2 "ohne Angabe ob allgemeinbildender
Schulabschluss" benoetigt wurde. Zur besseren Verstaendlichkeit entfaellt diese
Kategorie ab MZ2005 und wird statt dessen bei der Frage "Hoechster Allgemeiner
Schulabschluss" erfragt (siehe u.a. MZ2006: EF310=9) und zur Kategorie as=3
"ohne Angabe zur Art des Schulabschlusses" zusammengefasst.

Im Mikrozensus 2008 wird bei der Frage zum Besuch von Schule und Hochschule
in den letzten 4 Wochen erstmals auch erfragt, ob die Schule wegen Ferien oder
Uebergang in eine andere Schule/Ausbildung nicht besucht wurde
(Variable EF287=2). Diese Angabe wird im Folgenden wie ein Schulbesuch (EF287=1)
behandelt.

Ab dem Mikrozensus 2010 werden bei der korrigierten Variablen zum hoechsten allg.
Schulabschluss (EF310k) Personen mit Abschluss der Polytechnischen Oberschule
der DDR nach Abschluss mit 8. oder 9. Klasse, die 1975 oder spaeter geboren
wurden, nicht der Kategorie 2 "Polytechnische Oberschule, usw." zugeordnet,
sondern der Kategorie 1 "Haupt-(Volks-)schulabschluss".
***************************************************************************/
recode EF310k (-3 -5=0 "entf.") ///
(6=1 "kein SA") ///
(1=4 "HS/VS/Kl.5-10") ///
(2 3 7=5 "RS/POS") ///
(4 5=6 "FHR/ABI/Kl.11-13") ///
(9=3 "o.A. zur Art d. SA"),generate (as)

replace as=1 if (EF309==8)
replace as=7 if (((EF287>=1 & EF287<=2) | EF288==1) & EF290==2)
replace as=8 if (((EF287>=1 & EF287<=2) | EF288==1) & EF290==3)
recode  as (4 7=4) (6 8=6)
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

Ab dem Mikrozensus 2010 werden bei der korrigierten Variablen zum hoechsten
berufl. Abschluss (EF312k) Personen mit Anlernausbildung, die 1953 oder
frueher geboren wurden, nicht der Kategorie 1 "Anlernausbildung, usw." zugeordnet,
sondern der Kategorie 3 "Abschluss einer Lehre, usw.".
***************************************************************************/
recode EF312k (-3 -5=0 "Entfaellt (Pers<15)") ///
             (1 2=4 "Anlernausb./Praktikum/BVJ") ///
             (3 4 5 6=5 "Lehrausb./Berufsfachschule/Vorber.mittl.Dienst") ///
             (7 8 9 10 11 12=6 "Meister/Technik./Fachschule/Verw.FH/Berufsak.") ///
             (13 14=7 "FH/Hochschule") ///
             (15=8 "Promotion") ///
             (99=3 "o.A. zur Art d. BA"), generate (ba)
replace ba=1 if EF311==8
label variable ba "Beruflicher Abschluss"
label define ba 1 "kein BA", add modify

/***************************************************************************
Bildung der Hilfsvariable "Gegenwaertiger Besuch berufliche Schule"

Im Mikrozensus 2008 wurden die Fragen zum Schulbesuch (EF287-EF293)
modifiziert. Insbesondere wurden die ehemals drei Fragen zur Art der besuchten
allgemeinbildenden Schule, der beruflichen Schule und der (Fach-)Hochschule
2008 in eine Frage (Variable EF289; MZ 2007: Variablen EF289-EF291)
zusammengefasst.
***************************************************************************/
generate ba2=.
replace ba2 = 4 if EF289>=16 & EF289<=20 ///
                   & ((EF287>=1 & EF287<=2) | EF288==1)
replace ba2 = 5 if EF289==10 | EF289==12 | EF289==13 | EF289==14 | EF289==15  ///
                   & ((EF287>=1 & EF287<=2) | EF288==1)
replace ba2 = 6 if EF289>=21 & EF289<=25 ///
				   & ((EF287>=1 & EF287<=2) | EF288==1)
replace ba2 = 7 if EF289==26 | EF289==27 ///
                   & ((EF287>=1 & EF287<=2) | EF288==1)
replace ba2 = 8 if EF289==28 ///
				   & ((EF287>=1 & EF287<=2) | EF288==1)

recode ba2 99=.
label variable ba2 "Gegenwaertiger Besuch berufliche Schule"
label define ba2 4 "Berufsschule/BGJ/BVJ" ///
                 5 "berufl. Schule verm. RS/FHR" ///
                 6 "Fachschule, Fach-/Berufsakademie/2-3j. SdG, Verw.FH" ///
                 7 "FH/Hochschule" ///
                 8 "Promotion"
label values ba2 ba2


/****************************************************************************
Modifikation der Variable "Berufsbildender Abschluss"

Wenn der angestrebte berufliche Abschluss hoeher ist als der gegenwaertige,
ersetzt dieser den "eigentlichen" beruflichen Abschluss.
****************************************************************************/
recode ba 1 3=4         if ba2==4 & ba2>ba
recode ba 1 3 4=5       if ba2==5 & ba2>ba
recode ba 1 3 4 5=6     if ba2==6 & ba2>ba
recode ba 1 3 4 5 6=7   if ba2==7 & ba2>ba
recode ba 1 3 4 5 6 7=8 if ba2==8 & ba2>ba

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
generate is=99
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
label define is 1 "1B" ///
                2 "1A" ///
                3 "2B" ///
                4 "2A" ///
                5 "3B" ///
                6 "3A" ///
                7 "4A" ///
                8 "5B" ///
                9 "5A" ///
                10 "6" ///
                99 "entf./nicht zuordenbar"
label values is is
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
