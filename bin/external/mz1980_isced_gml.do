*******************************************************************************************.
*  GESIS - Leibniz-Institut f�r Sozialwissenschaften
*  German Microdata Lab (GML), Mannheim
*  Postfach 12 21 55
*  68072 Mannheim
*  Tel.: 0621/1246-265 Fax:  0621/1246-100
*  E-Mail: gml@gesis.org
*  Yvonne Lechert, Julia Schroedter, Paul L�ttinger
*  Version: 11.06.2007
*******************************************************************************************.



********************************************************************************************.
*
* STATA-Job zur Umsetzung der Bildungsklassifikation ISCED-1997 mit dem Mikrozensus 1980
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

* Datenbasis: Mikrozensus 1980; Scientific Use File
* Datenbeschreibung: http://www.gesis.org/dienstleistungen/daten/amtliche-mikrodaten/mikrozensus/grundfile/mz1980/
*
*******************************************************************************************.

// version 10
// set more off
//
// capture log close
//
// log using <isced80.log>, replace
//
// *Version: 26.02.2008
//
// *****************************************************************************************.
// *					MZ 1980
// *****************************************************************************************.
//
// set mem 500m
//
// use <"DATENFILE">
//
// tab EF158, mis
// tab EF159, mis
// tab EF160, mis
// tab EF33, mis


* Recodierung und Filterf�hrung der Bildungsvariablen



*******************************************************************************************.
*	Bildung der Variable "Allgemein bildender Schulabschluss" (Codebuch EF78).
*******************************************************************************************.

generate as=-1
replace as=1 if (EF158==1)   /*Volksschule */
replace as=2 if (EF158==2)   /*Mittlere Reife */
replace as=3 if (EF158==3)   /*Fachhochschulfreife */
replace as=4 if (EF158==4)   /*Abi,Fachabitur */
replace as=5 if (EF158==0)   /*ohne Angabe */
replace as=6 if (EF158==.)   /*entf�llt */

label variable as "Allgemein bildender Schulabschluss"
#delimit ;
label define as1
	1 "VS"
	2 "MS"
	3 "FHR"
	4 "ABI"
	5 "o.A."
	6 "entf";
#delimit cr
label value as as1


*******************************************************************************************.
*	Bildung der Variable "Berufsbildender Abschluss" (Codebuch EF160).
*******************************************************************************************.

generate ba=-1
replace ba=1 if (EF160==9)  /*keinen Abschluss */
replace ba=2 if (EF160==1 | EF160==3)  /*Lehrabschluss */
replace ba=3 if ((EF159==2 | EF159==4) & EF160==9 )  /*berufliches Praktikum */
replace ba=4 if (EF160==2 | EF160==4)  /*Meister, Techniker */
replace ba=5 if (EF160==5)  /*Fachhochschulabschl. */
replace ba=6 if (EF160==6)  /*Universit?t */
replace ba=7 if (EF160==0)  /*keine Angabe */
replace ba=8 if (EF160==.)  /*entf?llt */

label variable ba "Beruflicher Abschluss"
#delimit ;
label define ba1
	1 "kein BA"
	2 "Lehrausb."
	3 "Praktikum"
	4 "Meister"
	5 "FH"
	6 "Hochschule"
	7 "o.A."
	8 "entf.";
#delimit cr
label value ba ba1


*******************************************************************************************.
*	Bildung der Variable "ISCED-1997 - GML" .
*******************************************************************************************.

generate is=-1

replace is=1 if (as==5 & ba==1) /*1b */

replace is=2 if (as==1 & (ba==1 | ba==3 | ba==7 | ba==8))          /*2b */
replace is=2 if ((as==5 | as==6) & ba==3)                          /*2b */
replace is=2 if (EF33==3 & (as==1 | as==5 | as==6))                /*2b */

replace is=3 if (as==2 & (ba==1 | ba==3 | ba==7 | ba==8))          /*2a */
replace is=2 if (EF33==2 & (as==1 | as==5 | as==6))                /*2a */
replace is=3 if (EF33==3 & as==2)                                  /*2a */
replace is=3 if (EF33==4 & (as==1 | as==2 | as==5 | as==6))        /*2a */

replace is=4 if ((as==1 | as==2 | as==5 | as==6) & ba==2)          /*3b */
replace is=4 if (EF33==6 & (as==1 | as==2 | as==5 | as==6))        /*3b */
replace is=4 if (EF33==9 & (as==1 | as==2 | as==5 | as==6))        /*3b */

replace is=5 if ((as==3 | as==4)&(ba==1 | ba==3 | ba==7 | ba==8))  /*3a */
replace is=5 if (as==4 & ba==3)                                    /*3a */
replace is=5 if (EF33==2 & (as==2 | as==4))                        /*3a */
replace is=5 if ((EF33==3 | EF33==4) & (as==3 | as==4))            /*3a */
replace is=5 if (EF33==5)                                          /*3a */

replace is=6 if ((as==3 | as==4) & ba==2)                          /*4a */
replace is=6 if (as==4 & ba==2)                                    /*4a */
replace is=6 if (EF33==6 & (as==3 | as==4))                        /*4a */
replace is=6 if (EF33==9 & (as==3 | as==4))                        /*4a */

replace is=8 if (as>=1 & (ba==5 | ba==6))                          /*5a */
replace is=8 if (EF33==7 | EF33==8)                                /*5a */

replace is=7 if (as>=1 & ba==4)                                    /*5b */

replace is=9 if (as==5 & (ba==7 | ba==8))                          /*ka */
replace is=10 if (as==6 & (ba==1 | ba==7 | ba==8))                 /*ent */

label variable is "ISCED-1997 - GML"
#delimit ;
label define is1
	1 "1B"
	2 "2B"
	3 "2A"
	4 "3B"
	5 "3A"
	6 "4A"
	7 "5B"
	8 "5A"
	9 "o.A."
	10 "entf.";
#delimit cr
label value is is1

tab is

*recode is 9=.
*recode is 10=.

*******************************************************************************************
*	OPTIONAL:
*	Auschluss der Personen, die unter 15 Jahre alt sind.
*
*
* keep if (EF66 > 15)
*******************************************************************************************
