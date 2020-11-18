*******************************************************************************************.
*  GESIS - Leibniz-Institut f�r Sozialwissenschaften
*  German Microdata Lab (GML), Mannheim
*  Postfach 12 21 55
*  68072 Mannheim
*  Tel.: 0621/1246-265 Fax:  0621/1246-100
*  E-Mail: gml@gesis.org
*  Yvonne Lechert, Julia Schroedter, Paul L�ttinger
*  Version: 20.06.2006
*******************************************************************************************.



*******************************************************************************************.
*
* STATA-Job zur Umsetzung der Bildungsklassifikation ISCED-1997 mit dem Mikrozensus 1993
* ISCED-Version des German Microdata Lab, GESIS
*
* Bei Nutzung dieser Routine bitte wie folgt zitieren:
* (hier wird auch die Skalenkonstruktion beschrieben)
* Schroedter, J. H.; Lechert, Y.; L�ttinger, P. (2006): Die Umsetzung der Bildungsskala
*    ISCED-1997 f�r die Volksz�hlung 1970, die Mikrozensus-Zusatzerhebung 1971 und die
*    Mikrozensen 1976-2004. ZUMA-Methodenbericht 2006/08.
* http://www.gesis.org/dienstleistungen/tools-standards/mikrodaten-tools/isced/
*
* Literaturhinweise, Quellen:
* United Nations Educational, Scientific and Cultural Organization 1997:
*    International Standard Classification of Education ISCED 1997.
*    http://www.uis.unesco.org/TEMPLATE/pdf/isced/ISCED_A.pdf
* OECD 1999: Classifying Educational Programmes. Manual for ISCED-97.
*    Implementation in OECD Countries. 1999 Edition.
*    http://www.staffs.ac.uk/institutes/access/docs/OECD-education-classifications.pdf

* Datenbasis: Mikrozensus-Scientific Use File 1993
* Datenbeschreibung: http://www.gesis.org/dienstleistungen/daten/amtliche-mikrodaten/mikrozensus/grundfile/mz1993/
*
*******************************************************************************************.


//
// version 9.2
//
// set more off
//
// capture log close
//
// log using <isced93.log>, replace
//
// *Version: 26.09.2006
//
//
//
// *******************************************************************************************.
// *				MZ 1993
// *******************************************************************************************.
//
// set mem 500m
//
// use "<DATENFILE>"



*******************************************************************************************.
*	Bildung der Variable "Allgemein bildender Schulabschluss" .
*	Klasse 5-10 zu Haupt-/Volksschule .
*	Klasse 11-13 zu Fachhochschulreife/Abitur .
*******************************************************************************************.

recode ef121 1=4 2 3=5 4 5=6 8=3 9=0, generate(as)
replace as=1 if (ef59==2)
replace as=2 if (ef59==8)
replace as=7 if (ef56==3 & (ef121==8 | ef121==9))
replace as=8 if (ef56==4 & (ef121==8 | ef121==9))
recode as 4 7=4 6 8=6
label variable as "Allgemein bildender Schulabschluss"
#delimit ;
label define as1
	0 "entf."
	1 "kein SA"
	2 "o.A. ob SA"
	3 "o.A. zur Art d. SA"
	4 "HS/VS/Kl.5-10"
	5 "RS/POS"
	6 "FHR/ABI/Kl.11-13";
#delimit cr
label values as as1



*******************************************************************************************.
*	Bildung der Variable "Berufsbildender Abschluss" .
*******************************************************************************************.

recode ef122 1=1 2=5 3=4 4 5=6 6 7=7 8=2 9=0, generate(ba)
label variable ba "Beruflicher Abschluss"
#delimit ;
label define ba1
	0 "Entf./o.A."
	1 "kein BA"
	2 "o.A. ob BA"
	4 "Berufl. Praktikum (1J)"
	5 "Lehr-/Anlernausb. (2J)"
	6 "Meister/Technik./Fachschule"
	7 "FH/Hochschule/Verw.FH";
#delimit cr
label values ba ba1

* Anmerkung: ***.
* keine Kategorie "Promotion" vorhanden/m�glich ***.
* keine Unterscheidung m�glich zwischen Lehr- und Anlernausbildung (aber  ***.
* Bedingung: mind. 2-j�hrige Dauer, berufl. Praktikum: mind. 1 Jahr, Info: IHB 93) ***.
* berufl. Praktikum  als Einzelkategorie vorhanden ***.



*******************************************************************************************.
*	Bildung der Hilfsvariable "Gegenw�rtiger Besuch berufliche Schule" .
*******************************************************************************************.

recode ef56 5=5  6 7=7, generate(ba2), if ef56>=5 & ef56<=7
label variable ba2 "Gegenw�rtiger Besuch berufliche Schule"
#delimit ;
label define ba21
	5 "Berufliche Schule"
	7 "FH/Hochschule";
#delimit cr
label values ba2 ba21

* Anmerkung: die berufliche Schule wird hier, da nicht n�her spezifiziert ***.
* zu der Lehrausbildung gez�hlt. ***.



*******************************************************************************************.
*	Modifikation der Variable "Berufsbildender Abschluss" .
*	Wenn der angestrebte berufliche Abschluss h�her ist als der gegenw�rtige, .
*	ersetzt dieser den "eigentlichen" beruflichen Abschluss .
*******************************************************************************************.

recode ba 0 1 2 4=5 if ba2==5 & ba2>ba
recode ba 1 2 4 5 6=7 if ba2==7 & ba2>ba



*******************************************************************************************.
*	Kreuztabelle zur Zuordnung der ISCED-Stufen .
*******************************************************************************************.

tab as ba



*******************************************************************************************.
*	Bildung der Variable "ISCED-1997 - GML" .
*******************************************************************************************.

generate is=99
replace is=0 if (ef56==1 & ef23>= 3)
replace is=1 if (as==0 & ba==1) | (as==1 & (ba==1 | ba==2)) /*
*/ | (as==2 & ba==1)
replace is=2 if ((ef56==2 | ef56==8) & (ef23<=14 & ba==0))
replace is=3 if ((as==0 | as==1 | as==2) & ba==4) | ((as==3 | as==4) /*
*/ & (ba==0 | ba==1 | ba==2 | ba==4))
replace is=4 if (as==5 & (ba==0 | ba==1 | ba==2 | ba==4))
replace is=5 if ((as==0 | as==1 | as==2 | as==3 | as==4 | as==5) & ba==5)
replace is=6 if (as==6 & (ba==0 | ba==1 | ba==2 | ba==4))
replace is=7 if (as==6 & ba==5)
replace is=8 if (ba==6)
replace is=9 if (ba==7)

label variable is "ISCED-1997 - GML"
#delimit ;
label define is1
	0 "0"
	1 "1B"
	2 "1A"
	3 "2B"
	4 "2A"
	5 "3B"
	6 "3A"
	7 "4A"
	8 "5B"
	9 "5A"
	99 "entf./nicht zuordenbar";
#delimit cr
label values is is1

* keine Kategorie "Promotion" (6) m�glich ***.

tab is

*******************************************************************************************.
*	OPTIONAL:
*
*	Ausschluss der Personen, die gegenw�rtig noch in der Ausbildung sind.
* keep if (ef56==9)
*
*	Ausschluss von Personen, die unter 15 Jahre alt sind.
* keep if (ef23>=15)
*
*******************************************************************************************.
