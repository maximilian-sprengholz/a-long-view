*******************************************************************************************.
*  Zentrum f�r Umfragen, Methoden und Analysen (ZUMA)
*  German Microdata Lab, Mannheim
*  Postfach 12 21 55
*  68072 Mannheim
*  Tel.: 0621/1246-265 Fax: 0621/1246-100
*  E-Mail: gml@gesis.org
*  Julia Schroedter, Yvonne Lechert, Paul L�ttinger
*  Version: 11.06.2013
*******************************************************************************************.



*******************************************************************************************.
*
* Stata-Job zur Umsetzung der Bildungsklassifikation ISCED-1997 mit dem Mikrozensus 2005
* ISCED-Version des German Microdata Lab, ZUMA
*
* Bei Nutzung dieser Routine bitte wie folgt zitieren:
* (hier wird auch die Skalenkonstruktion beschrieben)
* Schroedter, J. H.; Lechert, Y.; L�ttinger, P. (2006): Die Umsetzung der Bildungsskala
*    ISCED-1997 f�r die Volksz�hlung 1970, die Mikrozensus-Zusatzerhebung 1971 und die
*    Mikrozensen 1976-2004. ZUMA-Methodenbericht 2006/08.
* http://www.gesis.org/missy/studie/klassifikationen/
* sozialwissenschaftliche-klassifikationen/bildungsskala-isced-1997/
*
* Literaturhinweise, Quellen:
* United Nations Educational, Scientific and Cultural Organization 1997:
*    International Standard Classification of Education ISCED 1997.
*    http://www.uis.unesco.org/Library/Documents/isced97-en.pdf
* OECD 1999: Classifying Educational Programmes. Manual for ISCED-97.
*    Implementation in OECD Countries. 1999 Edition.
*    http://www.staffs.ac.uk/institutes/access/docs/OECD-education-classifications.pdf

* Datenbasis: Mikrozensus-Scientific Use File 2005
* Datenbeschreibung: http://www.gesis.org/missy/missy-home/auswahl-datensatz/mikrozensus-2005/
*
*******************************************************************************************.



// version 9.2
//
// set more off
//
// capture log close
//
// log using <isced05.log>, replace
//
// *Version: 11.06.2013
//
//
//
// *******************************************************************************************.
// *				MZ 2005
// *******************************************************************************************.
//
// set mem 500m
//
// use "<DATENFILE>", clear


*******************************************************************************************.
*	Bildung der Variable "Allgemein bildender Schulabschluss" .
*	Klasse 5-10 zu Haupt-/Volksschule .
*	Klasse 11-13 zu Fachhochschulreife/Abitur .
*	Im MZ 2005 gibt es die Kategorie "ohne Angabe ob allgemein
*	bildener Schulabschluss" nicht, damit entf�llt die Kategorie
*	'ohne Angabe zum Schulabschlluss' (siehe u.a. MZ2004 = Code 2).
*******************************************************************************************.

recode EF310 0=0 1=4 2 3=5 4 5=6 9=3, generate(as)
replace as=1 if (EF309==8)
replace as=7 if ((EF287==1 | EF288==1) & EF289==2)
replace as=8 if ((EF287==1 | EF288==1) & EF289==3)
recode as 4 7=4 6 8=6
label variable as "Allgemein bildender Schulabschluss"
#delimit ;
label define as1
	0 "entf."
	1 "kein SA"
	3 "o.A. zur Art d. SA"
	4 "HS/VS/Kl.5-10"
	5 "RS/POS"
	6 "FHR/ABI/Kl.11-13";
#delimit cr
label values as as1



*******************************************************************************************.
*	Bildung der Variable "Berufsbildender Abschluss" .
*	Im MZ 2005 gibt es die Kategorie "ohne Angabe ob beruflicher
*	Abschluss" nicht, damit entf�llt die Kategorie 'ohne Angabe zum
*	beriflichen Abschluss' (siehe u.a. MZ2004 = Code 2).
*******************************************************************************************.

recode EF312 0=0 1 2=4 3 4=5 5 6 7=6 8 9=7 10=8 99=3, generate(ba)
replace ba=1 if EF311==8
label variable ba "Beruflicher Abschluss"
#delimit ;
label define ba1
	0 "Entf�llt (Pers<15)"
	1 "kein BA"
	3 "o.A. zur Art d. BA"
	4 "Anlernausb./Praktikum/BVJ"
	5 "Lehrausb./Berufsfachschule"
	6 "Meister/Technik./Fachschule/Verw.FH"
	7 "FH/Hochschule"
	8 "Promotion";
#delimit cr
label values ba ba1


*******************************************************************************************.
*	Bildung der Hilfsvariable "Gegenw�rtiger Besuch berufliche Schule" .
*******************************************************************************************.

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


*******************************************************************************************.
*	Modifikation der Variable "Berufsbildender Abschluss" .
*	Wenn der angestrebte berufliche Abschluss h�her ist als der gegenw�rtige, .
*	ersetzt dieser den "eigentlichen" beruflichen Abschluss .
*******************************************************************************************.

recode ba 1 3=4 if ba2==4 & ba2> ba
recode ba 1 3 4=5 if ba2==5 & ba2>ba
recode ba 1 3 4 5=6 if ba2==6 & ba2>ba
recode ba 1 3 4 5 6=7 if ba2==7 & ba2>ba
recode ba 1 3 4 5 6 7=8 if ba2==8 & ba2>ba



*******************************************************************************************.
*	Kreuztabelle zur Zuordnung der ISCED-Stufen .
*******************************************************************************************.

tab as ba



*******************************************************************************************.
*	Bildung der Variable "ISCED-1997 - GML" .

*	Aufgrund der Streichung der Variablen 'Besuch eines Kindergartens, einer
*	Kindergrippe bzw. eines Kinderhorts' im MZ2005, kann die ISCED-Kategorie 0,
*	die den Elementarbereich (Vorschulbereich) abbildet nicht mehr gebildet werden
********************************************************************************************.



generate is=99
replace is=1 if (as==1 & ba==1)
replace is=2 if ((EF287==1 | EF288==1) & EF289==1)
replace is=3 if ((as==0 | as==1) & (ba==3 | ba==4)) | ((as==3 | as==4) /*
*/ & (ba==0 | ba==1 | ba==3 | ba==4))
replace is=4 if (as==5 & (ba==1 | ba==3 | ba==4))
replace is=5 if ((as==0 | as==1 | as==3 | as==4 | as==5) & ba==5)
replace is=6 if (as==6 & (ba==1 | ba==3 | ba==4))
replace is=7 if (as==6 & ba==5)
replace is=8 if (ba==6)
replace is=9 if (ba==7)
replace is=10 if (ba==8)

label variable is "ISCED-1997 - GML"
#delimit ;
label define is1
	1 "1B"
	2 "1A"
	3 "2B"
	4 "2A"
	5 "3B"
	6 "3A"
	7 "4A"
	8 "5B"
	9 "5A"
	10 "6"
	99 "entf./nicht zuordenbar";
#delimit cr
label values is is1

tab is

*******************************************************************************************.
*	OPTIONAL:
*
*	Ausschluss der Personen, die gegenw�rtig noch in der Ausbildung sind.
* keep if (EF287~=1)
*
*	Ausschluss von Personen, die unter 15 Jahre alt sind.
* keep if (EF44>=15)
*
*******************************************************************************************.
