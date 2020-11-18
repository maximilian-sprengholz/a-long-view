// * mz07_isced_gml.do
//
// * Quelle: http://www.gesis.org/missy/fileadmin/missy/klassifikationen/
// * ISCED/ISCED_STATA/ISCED_2007.do
//
//
// version 10.1     // Stata for Windows version 10.1
// clear
// capture log close
// set more off
// set mem 500m
// set dp comma
//
// * Im Kommando "<DIR>" das lokale Arbeitsverzeichnis eintragen
// cd <DIR>
//
// log using isced07.log

/**************************************************************************
GESIS - Leibniz-Institut f�r Sozialwissenschaften
German Microdata Lab (GML)
Postfach 12 21 55
68072 Mannheim
Tel.: 0621/1246-265 Fax:  0621/1246-100
E-Mail: gml@gesis.org
Delia J�ger, Tony Siegel, Bernhard Schimpl-Neimanns
Version: 11.06.2013
***************************************************************************/



/***************************************************************************
STATA-Syntax zur Umsetzung der Bildungsklassifikation ISCED-1997 mit dem
Mikrozensus 2007
ISCED-Version des German Microdata Lab, GESIS

Bei Nutzung dieser Routine bitte wie folgt zitieren:
(hier wird auch die Skalenkonstruktion beschrieben)
Schroedter, J. H.; Lechert, Y.; L�ttinger, P. (2006): Die Umsetzung der
Bildungsskala ISCED-1997 f�r die Volksz�hlung 1970, die Mikrozensus-Zusatzerhebung
1971 und die Mikrozensen 1976-2004. ZUMA-Methodenbericht 2006/08.
http://www.gesis.org/dienstleistungen/tools-standards/mikrodaten-tools/isced/
Programm: http://www.gesis.org/missy/fileadmin/missy/klassifikationen/
          ISCED/ISCED_STATA/ISCED_2007.do

Literaturhinweise, Quellen:
United Nations Educational, Scientific and Cultural Organization 1997:
International Standard Classification of Education ISCED 1997.
http://www.uis.unesco.org/Library/Documents/isced97-en.pdf
OECD 1999: Classifying Educational Programmes. Manual for ISCED-97.
Implementation in OECD Countries. 1999 Edition.
http://www.staffs.ac.uk/institutes/access/docs/OECD-education-classifications.pdf

Datenbasis: Mikrozensus-Scientific Use File 2007
Datenbeschreibung: http://www.gesis.org/missy/missy-home/auswahl-datensatz/
                   mikrozensus-2007/
***************************************************************************/


****************************************************************************
*                               MZ 2007
****************************************************************************

* Im folgenden Kommando ist "<mz2007>" durch den lokalen Dateinamen
* zu ersetzen; ggf. ohne Variablenauswahl.
// use "<mz2007.dta>"


/* *************************************************************************
Bildung der Variable "Allgemeinbildender Schulabschluss"

Klasse 5-10 zu Haupt-/Volksschule
Klasse 11-13 zu Fachhochschulreife/Abitur
In den Mikrozensen bis 2004 gab es zur Frage "Allgemeiner Schulabschluss
Vorhanden" die Antwortkategorie "Ohne Angabe" (siehe u.a. MZ2004: EF258=9),
die zur Bildung der Variable as=2 "ohne Angabe ob allgemeinbildender
Schulabschluss" ben�tigt wurde. Zur besseren Verst�ndlichkeit entf�llt diese
Kategorie ab MZ2005 und wird statt dessen bei der Frage "H�chster Allgemeiner
Schulabschluss" erfragt (siehe u.a. MZ2006: EF310=9) und zur Kategorie as=3
"ohne Angabe zur Art des Schulabschlusses" zusammengefasst.
***************************************************************************/
recode EF310 (0=0 "entf.")  ///
	     (1=4 "HS/VS/Kl.5-10") ///
             (2 3=5 "RS/POS") ///
       	     (4 5=6 "FHR/ABI/Kl.11-13") ///
             (9=3 "o.A. zur Art d. SA"), generate (as)
replace as=1 if (EF309==8)
replace as=7 if ((EF287==1 | EF288==1) & EF289==2)
replace as=8 if ((EF287==1 | EF288==1) & EF289==3)
recode  as (4 7=4) (6 8=6)
label variable as "Allgemeinbildender Schulabschluss"
label define as 1 "kein SA", add modify


/***************************************************************************
Bildung der Variable "Berufsbildender Abschluss"

In den Mikrozensen bis 2004 gab es zur Frage "Beruflicher Ausbildungs-
oder Hochschul-/Fachhochschulabschluss vorhanden?" die Antwortkategorie
"Ohne Angabe" (siehe u.a. MZ2004: EF260=9), die zur Bildung der Variable
ba=2 "ohne Angabe ob beruflicher Abschluss" ben�tigt wurde. Zur besseren
Verst�ndlichkeit entf�llt diese Kategorie ab MZ2005 und wird statt dessen
bei der Frage "H�chster beruflicher Ausbildungs- oder Hochschul-/
Fachhochschulabschluss" erfragt (siehe u.a. MZ2006: EF312=99) und zur
Kategorie ba=3 "ohne Angabe zur Art des beruflichen Abschlusses"
zusammengefasst.
***************************************************************************/
recode EF312 (0=0 "Entf�llt (Pers<15)") ///
	     (1 2=4 "Anlernausb./Praktikum/BVJ") ///
             (3 4 11=5 "Lehrausb./Berufsfachschule/Vorber.mittl.Dienst") ///
             (5 6 7=6 "Meister/Technik./Fachschule/Verw.FH") ///
             (8 9=7 "FH/Hochschule") ///
	     (10=8 "Promotion") ///
             (99=3 "o.A. zur Art d. BA"), generate (ba)
replace ba=1 if EF311==8
label variable ba "Beruflicher Abschluss"
label define ba 1 "kein BA", add modify

/***************************************************************************
Bildung der Hilfsvariable "Gegenw�rtiger Besuch berufliche Schule"
***************************************************************************/
generate ba2=.
replace ba2 = 4 if EF290==1 | EF290==2 & (EF287==1 | EF288==1)

replace ba2 = 5 if EF290==3 | EF290==4 & (EF287==1 | EF288==1)

replace ba2 = 6 if EF290==5 | EF291==1 & (EF287==1 | EF288==1)

replace ba2 = 7 if EF291==2 | EF291==3 & (EF287==1 | EF288==1)

replace ba2 = 8 if EF291==4 & (EF287==1 | EF288==1)

recode ba2 99=.
label variable ba2 "Gegenw�rtiger Besuch berufliche Schule"
label define ba2 4 "Berufsschule/BGJ/BVJ" ///
		 5 "berufl. Schule verm. RS/FHR" ///
                 6 "Fachschule, Fach-/Berufsakademie/2-3j. SdG, Verw.FH" ///
		 7 "FH/Hochschule" ///
                 8 "Promotion"
label values ba2 ba2

/****************************************************************************
Modifikation der Variable "Berufsbildender Abschluss" .

Wenn der angestrebte berufliche Abschluss h�her ist als der gegenw�rtige,
ersetzt dieser den "eigentlichen" beruflichen Abschluss .
****************************************************************************/
recode ba 1 3=4 if ba2==4 & ba2>ba
recode ba 1 3 4=5 if ba2==5 & ba2>ba
recode ba 1 3 4 5=6 if ba2==6 & ba2>ba
recode ba 1 3 4 5 6=7 if ba2==7 & ba2>ba
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
replace is=2  if ((EF287==1 | EF288==1) & EF289==1)
replace is=3  if ((as==0 | as==1) & (ba==3 | ba==4)) | (as==3 | as==4) ///
                 & (ba==0 | ba==1 | ba==3 | ba==4)
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
		10 "6"  ///
		99 "entf./nicht zuordenbar"
label values is is
tab is, miss

******************************************************************************
*  OPTIONAL:
*
*  Ausschluss der Personen, die gegenw�rtig noch in der Ausbildung sind
*  keep if (EF287~=1)
*  oder z.B. tab is if (EF287~=1)
*
*  Ausschluss von Personen, die unter 15 Jahre alt sind
*  keep if (EF44>=15)
*  oder z.B. tab is if (EF44>=15)
******************************************************************************
