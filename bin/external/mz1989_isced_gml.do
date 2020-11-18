*******************************************************************************************.
*  GESIS - Leibniz-Institut f�r Sozialwissenschaften
*  German Microdata Lab (GML), Mannheim
*  Postfach 12 21 55
*  68072 Mannheim
*  Tel.: 0621/1246-265 Fax:  0621/1246-100
*  E-Mail: gml@gesis.org
*  Yvonne Lechert, Julia Schroedter, Paul L?ttinger
*  Version: 20.06.2006
*******************************************************************************************.



********************************************************************************************.
*
* STATA-Job zur Umsetzung der Bildungsklassifikation ISCED-1997 mit dem Mikrozensus 1989
* ISCED-Version des German Microdata Lab, GESIS
*
* Bei Nutzung dieser Routine bitte wie folgt zitieren:
* (hier wird auch die Skalenkonstruktion beschrieben)
* Schroedter, J. H.; Lechert, Y.; L?ttinger, P. (2006): Die Umsetzung der Bildungsskala
*    ISCED-1997 f?r die Volksz?hlung 1970, die Mikrozensus-Zusatzerhebung 1971 und die
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

* Datenbasis: Mikrozensus-Scientific Use File 1989
* Datenbeschreibung: http://www.gesis.org/dienstleistungen/daten/amtliche-mikrodaten/mikrozensus/grundfile/mz1989/
*
*******************************************************************************************.


// version 9.2
//
// set more off
//
// capture log close
//
// log using <isced89.log>, replace
//
// *Version: 26.09.2006
//
//
//
// *******************************************************************************************.
// *				MZ 1989
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

recode ef121 1=4 2=5 3 4=6 8=2 9=0, generate(as)
label variable as "Allgemein bildender Schulabschluss"
#delimit ;
label define as1
	0 "entf."
	2 "o.A. "
	4 "HS/VS/Sch�ler"
	5 "RS/Sch�lerRS/IntegrGS"
	6 "FHR/ABI/Sch�ler";
#delimit cr
label values as as1

recode ef56 3 5=5 4=6, generate(as2), if (ef56>=2 & ef56<=5)
replace as2=4 if (ef23>=11 & ef56==2)
recode as2 2=.
label variable as2 "Besuch Schule (allgemein)"
#delimit ;
label define as21
	4 "GS/HS/VS (>10J.)"
	5 "RS/Integr.GS"
	6 "Gym./Fachobersch.";
#delimit cr
label values as2 as21

*** Anmerkung: Integrierte Gesamtschule z�hlt zu RS, da (zumindest 2001)	***.
*** dort im Bundesdurchschnitt ca. 46 % den RS-Abschluss erworben haben 	***.
*** Quelle: Cortina et al., 2003: Das Bildungswesen in der BRD: S. 479	        ***.
*** Grund-/Haupt-/Volksschule z�hlt zu VS/HS, wenn Person mind. 11 Jahre 	***.

recode as 0 2=4 if as2==4 & as2>as
recode as 0 2 4=5 if as2==5 & as2>as
recode as 0 2 4 5=6 if as2==6 & as2>as



*******************************************************************************************.
*	Bildung der Variable "Berufsbildender Abschluss" .
*******************************************************************************************.

recode ef122 1=1 2=5 3=4 4=6 5 6=7 8=2 9=0, generate(ba)
label variable ba "Beruflicher Abschluss"
#delimit ;
label define ba1
	0 "Entf�llt"
	1 "kein BA"
	2 "o.A. ob BA"
	4 "Berufl. Praktikum (6M)"
	5 "Lehr-/Anlernausb. (2J)"
	6 "Meister/Techniker"
	7 "FH/Hochschule/Verw.FH";
#delimit cr
label values ba ba1

* Anmerkung: ***.
* keine Kategorie "Promotion" vorhanden/m�glich ***.
* keine Unterscheidung m�glich zwischen Lehr- und Anlernausbildung (aber  ***.
* Bedingung: mind. 2-j�hrige Dauer, berufl. Praktikum: mind. 6 Monate; Info: IHB 89) ***.
* berufl. Praktikum (mind. 6 Monate) aber als Einzelkategrie ***.



*******************************************************************************************.
*	Bildung der Hilfsvariable "Gegenw�rtiger Besuch berufliche Schule" .
*******************************************************************************************.

recode ef56 6=4 7=6 8 9=7 10=5, generate(ba2), if ef56>5 & ef56<=10
label variable ba2 "Gegenw�rtiger Besuch berufliche Schule"
#delimit ;
label define ba21
	4 "Berufsfachschule/BGJ/BVJ"
	5 "Berufsschule"
	6 "Fachschule"
	7 "FH/Hochschule";
#delimit cr
label values ba2 ba21



*******************************************************************************************.
*	Modifikation der Variable "Berufsbildender Abschluss" .
*	Wenn der angestrebte berufliche Abschluss h�her ist als der gegenw�rtige, .
*	ersetzt dieser den "eigentlichen" beruflichen Abschluss .
*******************************************************************************************.

recode ba 0 1 2=4 if ba2==4 & ba2>ba
recode ba 0 1 2 4=5 if ba2==5 & ba2>ba
recode ba 0 1 2 4 5=6 if ba2==6 & ba2>ba
recode ba 0 1 2 4 5 6=7 if ba2==7 & ba2>ba



*******************************************************************************************.
*	Kreuztabelle zur Zuordnung der ISCED-Stufen .
*******************************************************************************************.

tab as ba



*******************************************************************************************.
*	Bildung der Variable "ISCED-1997 - GML" .
*******************************************************************************************.

generate is=99
replace is=0 if (ef56==1 & ef23>= 3)
replace is=1 if (as==0 & ba==1) | (as==2 & (ba==0 | ba==1))
replace is=2 if ((ef56==2) & (ef23<=14 & ba==0))
replace is=3 if ((as==0 | as==2) & ba==4) | /*
*/ (as==4 & (ba==0 | ba==1 | ba==2 | ba==4))
replace is=4 if (as==5 & (ba==0 | ba==1 | ba==2 | ba==4))
replace is=5 if ((as==0 | as==2 | as==4 | as==5) & ba==5)
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
* keep if (ef56==99)
*
*	Ausschluss von Personen, die unter 15 Jahre alt sind.
* keep if (ef23>=15)
*
*******************************************************************************************.
