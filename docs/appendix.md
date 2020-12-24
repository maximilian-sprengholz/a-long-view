---
title:
  'Online Appendix: From "guestworkers" to EU migrants: A gendered view on the labor market integration of different arrival cohorts in Germany'
subtitle: "Version <b>v1.2.0</b>"
date: "2020-12-24"
titleDelim: .
figureTemplate: __$$figureTitle$$ $$i$$$$titleDelim$$__ $$t$$
subfigureTemplate: __$$figureTitle$$ $$i$$$$titleDelim$$__ $$t$$
subfigureChildTemplate: __($$i$$)__ $$t$$
tableTemplate: __$$tableTitle$$ $$i$$$$titleDelim$$__ $$t$$
ccsTemplate: ""
figPrefix:
  - "figure"
  - "figures"
tblPrefix:
  - "table"
  - "tables"
subfigureRefIndexTemplate: $$i$$$$suf$$$$s$$

---


---

# Strategy

---


## Setting

This paper draws on data from the Microcensus Scientific Use Files (DOI: [10.21242/12211.1976.00.00.3.1.0](https://doi.org/10.21242/12211.1976.00.00.3.1.0) to [10.21242/12211.2015.00.00.3.1.0](https://doi.org/10.21242/12211.2015.00.00.3.1.0)) to provide a long-term overview of the labor market performance of different arrival cohorts of female and male migrants to Germany. Whereas there is a large body of research on the labor market outcomes of migrants to Germany, a more descriptive long-term and gender-specific overview is missing. We provide descriptive analyses for the employment rates, working hours, and occupational status levels of different arrival cohorts by gender, calendar year, and duration of stay. The data cover the time period 1976-2015.

To model labor market outcomes over time for first generation immigrants in Germany, we distinguish between __arrival year cohorts__. These correspond to the following periods:

| 1964-1973 | 1974-1983 | 1984-1993 | 1994-2003 | 2004-2010 |
| --------- | --------- | --------- | --------- | --------- |
: Arrival cohort periods {#tbl:def_cohorts}

## Indicators and Variables

We provide descriptive statistics (means) for the following __labor market outcomes__ by arrival cohort, gender, and calendar year:

- Employment rates
- Weekly working hours (actual); augmented by some figures on employment types
- ISEI-88 scores


| Variable       | Definition                                                                                                                                                                            |
| -------------- | ------------------------------------------------------------------------------------------------------ |
| Employment   | Dummy, 1 for individuals who state to be self-employed, working family members, employees and workers in public or private sector, in vocational training; 0 for un- and non-employed |
| Working hours | Actual weekly working hours of individual<br />Capped at 80h/week (values 80-95h/week are recoded as 80h/week, rest to missing)                                                       |
| ISEI-88      | ISEI-88 score for occupation of individual in employment                                                                                                                              |
| Duration of stay      | Years of residence in Germany                                                                                                                                                                   |
| Education         | Categorical, highest schooling or vocational degree:<br />ISCED 1-2 / ISCED 3-4 / ISCED 5-6                                                                                           |
: Variable defintion. {#tbl:def_vars}

## Sample

| Characteristics    | Values                                                            |
| ------------------ | ----------------------------------------------------------------- |
| Residence          | Main                                                              |
| Age                | 25-54                                                             |
| Citizenship        | Foreign (age at immigration otherwise not available)              |
| Years of residence | Capped at 30y.                                                    |
| Age at immigration | 18+                                                               |
| Sample Region      | West Germany (including East Berlin beginning in 1991)                                                     |
| Employed           | DV Employment: Yes/No<br />DV Working hours: Yes<br />DV ISEI-88: Yes |
: Sample restrictions. {#tbl:def_sample}

- The sample is not further restricted by current main activity (e.g. if in education or not)
- We have some missing data on the ISCED values (~2% for the analysis sample, similar for migrants and Germans). We apply listwise deletion, so that all the estimates apply for the same sample (only distinct by availability of dependent variable information)

## KldB to ISEI-88 conversion

Originally, occupations have been recorded according to the _Klassifikation der Berufe (KldB)_ [@bundesagenturfuerarbeit2020klassifikation] in the Microcensus. The KlbB classification is not directly translatable to _ISEI-88_ [@ganzeboom1992standard], but involves the intermediate step of converting to _ISCO-88 COM_ [@internationallabororganization2020isco]. Moreover, the KldB classification underwent several revisions over our analysis period that have to be translated to our base classification KldB92 (which offers the best overall feasability in the present context). In sum, we follow the conversion logic:

__KldB92 (3-digit)__ $\rightarrow$ __ISCO-88 COM__ $\rightarrow$ __ISEI-88__

This approach involves the following steps:

- __Kldb70/75/88__ $\rightarrow$ __Kldb92:__ no problem, nearly 1:1 correspondence
- __Kldb2010  (4-digit)__ $\rightarrow$ __Kldb92 (3-digit):__ KldB2010 codes have multiple corresponding KldB92 codes, because the official corresondence tables refer to the 5-digit classification. Consequently, within the 4-digit KldB2010 codes provided in the Microcensus might be various 5-digit codes corresponding to different KldB92 codes. Approximation:
    - In the Microcensus 2013, both KldB92 as well as KldB2010 have been coded. We use the actual incidences to derive _relative correspondence probabilities_ of single KldB92 codes within one KldB2010 code. Individuals with a particular KldB2010 code are randomly assigned to a KldB92 code based on these probabilities.
    - KldB2010 codes not present in the Microcensus 2013 (but possibly in later waves) are assigned according to a _list based probability_. For example, let a single Kldb2010 5-digit code have 4 corresponding KldB2010 4-digit codes. Of these 4 KldB2010 4-digit codes, the first 2 have a common KldB92 correspondence and the other 2 do not. Then the relative probability for each individual to receive one of the possible KldB92 codes would be $P=0.5$ for the first KldB92 code and $P=0.25$ for the other two.
- __KldB92__ $\rightarrow$ __ISCO-88 COM:__ Similar (but less pronounced) problem that some KldB92 codes have multiple corresponding ISCO-88 COM values. Translation is done using the list-based correspondence approached decribed above.
- __ISCO-88 COM__ $\rightarrow$ __ISEI-88:__ Direct correspondence based on the do-files provided by [GESIS](https://www.gesis.org/missy/materials/MZ/tools/isei).

---

# Descriptives

---

<p class="tip">
    Source is the Microcensus 1976-2015, except for the cohort composition in [@Fig:cohortcomp] which is based on municipality register data.
</p>

## Cohort composition

<div class="figure">
![Immigrant inflows to Germany by year and gender (lower panel). Citizenship composition of arrival cohorts by gender (upper panel).](../results/figures/sum_cohortcomp.svg){#fig:cohortcomp}

<p class="fignote">
Numbers include inflows to eastern Germany since 1991. Citizenship shares plotted for countries of origin with consistently available information for the full arrival period. For the Soviet Union, the Czech Republic, and Yugoslavia, both aggregated and disaggregated data are provided by the municipalities in some years. In these cases, we distributed the aggregated numbers among the constituting countries corresponding to their respective disaggregated shares.<br />
Source: German municipality registers [@destatis2020bevoelkerung-1].
</p>
</div>

## Selection

### Cohort size by period

<div id="fig:sum_cohortsize_period">
![Women, age 25-54](../results/figures/sum_cohortsize_period_f.svg){#fig:sum_cohortsize_period_f}

![Men, age 25-54](../results/figures/sum_cohortsize_period_m.svg){#fig:sum_cohortsize_period_m}

![Women, age 25+](../results/figures/sum_cohortsize_period_f_unres.svg){#fig:sum_cohortsize_period_f_unres}

![Men, age 25+](../results/figures/sum_cohortsize_period_m_unres.svg){#fig:sum_cohortsize_period_m_unres}

Cohort size development by period. Different age restrictions.
</div>
<p class="fignote">
Sample is restricted to western Germany, including Berlin. <br />
Source: Microcensus Scientific Use Files, DOI: <a href="https://doi.org/10.21242/12211.1976.00.00.3.1.0">10.21242/12211.1976.00.00.3.1.0</a> to <a href="https://doi.org/10.21242/12211.2015.00.00.3.1.0">10.21242/12211.2015.00.00.3.1.0</a>, own calculations.
</p>

!include ../results/output/sum_cohortsize_period_f.md

!include ../results/output/sum_cohortsize_period_f_unres.md

!include ../results/output/sum_cohortsize_period_m.md

!include ../results/output/sum_cohortsize_period_m_unres.md


<br />
Why do we see an increase in cohort size for all arrival cohorts from 2004-2006 and for the first cohort from 1976-1985? The reason is non-response on the arrival year variable, which substantially varies over years:

<div class="figure">
![Non-response on arrival year variable by year and gender.](../results/figures/sum_yimmi_nonres.svg){#fig:yimmi_nonres}

<p class="fignote">
Corresponds to analysis sample except for arrival year restrictions. Shares for persons with non-German citizenship who were born abroad. <br />
Source: Microcensus Scientific Use Files, DOI: <a href="https://doi.org/10.21242/12211.1976.00.00.3.1.0">10.21242/12211.1976.00.00.3.1.0</a> to <a href="https://doi.org/10.21242/12211.2015.00.00.3.1.0">10.21242/12211.2015.00.00.3.1.0</a>, own calculations.
</p>
</div>

Since 2005, the immigration year question is part of the mandatory questionnaire. The lower non-response rates mean overall higher observation numbers. [@Tbl:sum_cohort_sel_nonres_2004-2006] shows that the relative size of cohorts in percent increased to a similar extent at this cut-off. So, probably no selection on the cohort (selection on other characteristics still possible, of course). The changes for cohorts 1964-73 and 1994-2003 are due the age range of 25-54, shares are even closer across years without this restriction.

!include ../results/output/sum_cohort_sel_nonres_2004-2006.md



### Cohort size by duration of stay

<p class="tip">
    Generally, these plots are not really interpretable because many processes are at play that determine the population numbers. One issue is that persons who immigrated at age 18-23 show up in our analysis sample with a timelag due to the age restriction 25-54 (not a problem for the plots by period above). So, some initial gains in cohort size are due to this lag. Other gains certainly follow from the large variation in non-response rates on the arrival year (see above).
</p>

<div id="fig:sum_cohortsize_timeres">
![Women, age 25-54](../results/figures/sum_cohortsize_timeres_f.svg){#fig:sum_cohortsize_timeres_f}

![Men, age 25-54](../results/figures/sum_cohortsize_timeres_m.svg){#fig:sum_cohortsize_timeres_m}

![Women, age 18-54](../results/figures/sum_cohortsize_timeres_f_18_54.svg){#fig:sum_cohortsize_timeres_f_18_54}

![Men, age 18-54](../results/figures/sum_cohortsize_timeres_m_18_54.svg){#fig:sum_cohortsize_timeres_m_18_54}

![Women, age 25+](../results/figures/sum_cohortsize_timeres_f_unres.svg){#fig:sum_cohortsize_timeres_f_unres}

![Men, age 25+](../results/figures/sum_cohortsize_timeres_m_unres.svg){#fig:sum_cohortsize_timeres_m_unres}

Cohort size development by duration of stay. Different age restrictions.

</div>
<p class="fignote">
Sample is restricted to western Germany, including Berlin. <br />
Source: Microcensus Scientific Use Files, DOI: <a href="https://doi.org/10.21242/12211.1976.00.00.3.1.0">10.21242/12211.1976.00.00.3.1.0</a> to <a href="https://doi.org/10.21242/12211.2015.00.00.3.1.0">10.21242/12211.2015.00.00.3.1.0</a>, own calculations.
</p>

!include ../results/output/sum_cohortsize_timeres_f.md

!include ../results/output/sum_cohortsize_timeres_f_18_54.md

!include ../results/output/sum_cohortsize_timeres_f_unres.md

!include ../results/output/sum_cohortsize_timeres_m.md

!include ../results/output/sum_cohortsize_timeres_m_18_54.md

!include ../results/output/sum_cohortsize_timeres_m_unres.md



### Education by duration of stay

Regarding the presumed higher remigration rates for skilled individuals, we observe higher average levels of education for migrants with a shorter duration of stay compared to migrants with a longer duration of stay (see [@Tbl:sum_isced_remig_f; @Tbl:sum_isced_remig_m]). We find the largest differences within the first years of residence. For example, consider migrant women from arrival cohort 1984-1993. Given a duration of stay between 0 and 3 years, 25.4 percent of these women had some sort of tertiary education. Yet, for a duration of stay of 7-9 years, the share of women with tertiary education was only 18.3 percent. We find similar patterns across cohorts and stronger patterns for men than women, matching our results for occupational status (see [@Fig:isei88_res_timeres_f; @Fig:isei88_res_timeres_m]). Only a minor part of these patterns is explained by selectivity in arrival age (see [@Tbl:sum_isced_arrage_f; @Tbl:sum_isced_arrage_m; @Fig:isei88_res_timeres_f_18_54; @Fig:isei88_res_timeres_m_18_54]). Thus, on average, highly educated (labor) migrants seem to stay for rather short durations.

!include ../results/output/sum_isced_arrage_f.md

!include ../results/output/sum_isced_remig_f.md

!include ../results/output/sum_isced_remig_f_18_54.md

!include ../results/output/sum_isced_remig_f_unres.md

!include ../results/output/sum_isced_arrage_m.md

!include ../results/output/sum_isced_remig_m.md

!include ../results/output/sum_isced_remig_m_18_54.md

!include ../results/output/sum_isced_remig_m_unres.md


### Education by naturalization status

_Note: Unrestricted in terms of upper age bound._

We find that average educational levels of immigrant women and men are lower for longer durations of stay, but the decrease is much less pronounced than the one over the first years (see [@Tbl:sum_isced_remig_f; @Tbl:sum_isced_remig_m]). A possible explanation of this decline is again selective outmigration, but also selective naturalization might play a larger role, given that long durations of residence are required for migrants to naturalize in Germany (currently: 8 years). As we cannot follow the same individuals over time in the Microcensus, there is no way to assess the magnitude of both possible processes. However, in recent waves of the Microcensus information on naturalization is available. Based on the years 2007-2015, we compared the educational levels of migrants who naturalized and those who did not (without upper age limit, see [@Tbl:nat_isced_f_unres; @Tbl:nat_isced_m_unres]). Especially regarding the earlier cohorts, naturalized migrant women and men seem to be much better educated (naturalization rates being fairly even between genders). Consequently, if more and more skilled migrants naturalize with longer durations of stay, these drop out of our sample, leading to an underestimation of occupational mobility of arrival cohorts.

!include ../results/output/nat_isced_f_unres.md

!include ../results/output/nat_isced_m_unres.md



### Employment indicators by naturalization status

_Note: Restricted in terms of upper age bound (age 25-54)._

This comparison is most sensible for all arrival cohorts except the first (sample size). For the last cohort, differences might indicate a trend, but the generally short time-span after it's conclusion warrants caution.

#### Employment

In term of _employment rates_, naturalized immigrants seem to be quite positively selected (also ethnic Germans), women very strongly so. The difference is up to 10 pp. for women of the 1984-1993 cohort. Selectivity also seems a little different across cohorts, albeit this might be largely due to the different durations of stay. Although employment rates change considerably in some cases when including naturalized immigrants, the overall interpretation remains unchanged. Given the restrictions of our analysis, we would generally tend to underestimate the labor market integration of immigrants in terms of employment rates, particulalry regarding women, overestimating gaps to the native population.

!include ../results/output/nat_empl_dummy_f.md

!include ../results/output/nat_empl_dummy_n_f.md

!include ../results/output/nat_empl_dummy_m.md

!include ../results/output/nat_empl_dummy_n_m.md


<div id="fig:nat_empl_dummy">
![Women, by period](../results/figures/nat_empl_dummy_period_f.svg){#fig:nat_empl_dummy_period_f}

![Men, by period](../results/figures/nat_empl_dummy_period_m.svg){#fig:nat_empl_dummy_period_m}

Employment rates shown for non-German immigrants (our standard definition, solid lines) and all immigrants including those who naturalized (dashed lines).

</div>

<p class="fignote">
Sample is restricted to western Germany, including Berlin. <br />
Source: Microcensus Scientific Use Files, DOI: <a href="https://doi.org/10.21242/12211.1976.00.00.3.1.0">10.21242/12211.1976.00.00.3.1.0</a> to <a href="https://doi.org/10.21242/12211.2015.00.00.3.1.0">10.21242/12211.2015.00.00.3.1.0</a>, own calculations.
</p>


#### Working hours

In term of _working hours_, naturalized immigrants also seem to be slightly positive selected, at least women of the cohorts 1974-83, 1984-93 and 1994-03. However, the general interpretation of our results would be unchanged when including naturalized immigrants.

!include ../results/output/nat_ahours_f.md

!include ../results/output/nat_ahours_n_f.md

!include ../results/output/nat_ahours_m.md

!include ../results/output/nat_ahours_n_m.md


<div id="fig:nat_ahours">
![Women, by period](../results/figures/nat_ahours_period_f.svg){#fig:nat_ahours_period_f}

![Men, by period](../results/figures/nat_ahours_period_m.svg){#fig:nat_ahours_period_m}

Weekly working hours shown for non-German immigrants (our standard definition, solid lines) and all immigrants including those who naturalized (dashed lines).

</div>
<p class="fignote">
Sample is restricted to western Germany, including Berlin. <br />
Source: Microcensus Scientific Use Files, DOI: <a href="https://doi.org/10.21242/12211.1976.00.00.3.1.0">10.21242/12211.1976.00.00.3.1.0</a> to <a href="https://doi.org/10.21242/12211.2015.00.00.3.1.0">10.21242/12211.2015.00.00.3.1.0</a>, own calculations.
</p>

#### ISEI-88

In terms of _occupational status_, the picture is much more mixed. Naturalized immigrants are strongly positively selected compared to the non-naturalized for cohorts 1974-83 (women and men) and 1984-1993 (women). Cohort 1994-03 seems to be negatively selected. As for the other indicators: Interpretation remains largely unchangend when considering the naturalized. However, the relative labor market outcomes across cohorts change, they all are very similar now (except for the last cohort).

!include ../results/output/nat_isei88_res_f.md

!include ../results/output/nat_isei88_res_n_f.md

!include ../results/output/nat_isei88_res_m.md

!include ../results/output/nat_isei88_res_n_m.md


<div id="fig:nat_isei_res">
![Women, by period](../results/figures/nat_isei88_res_period_f.svg){#fig:nat_isei88_res_period_f}

![Men, by period](../results/figures/nat_isei88_res_period_m.svg){#fig:nat_isei88_res_period_m}

Employment rates shown for non-German immigrants (our standard definition, solid lines) and all immigrants including those who naturalized (dashed lines).
</div>
<p class="fignote">
Sample is restricted to western Germany, including Berlin.<br />
Source: Microcensus Scientific Use Files, DOI: <a href="https://doi.org/10.21242/12211.1976.00.00.3.1.0">10.21242/12211.1976.00.00.3.1.0</a> to <a href="https://doi.org/10.21242/12211.2015.00.00.3.1.0">10.21242/12211.2015.00.00.3.1.0</a>, own calculations.
</p>


### Covariate distribution by arrival cohort and gender: Education, age, and arrival age
!include ../results/output/sum_edu_age_init.md

!include ../results/output/sum_arrage_f.md

!include ../results/output/sum_arrage_m.md


---

# Results

---

<p class="tip">
    Indicator means. Plotted if cell count >= 100.
</p>

## Employment

<div id="fig:empl_dummy">
![Women, by duration of stay](../results/figures/empl_dummy_timeres_f.svg){#fig:empl_dummy_timeres_f}

![Men, by duration of stay](../results/figures/empl_dummy_timeres_m.svg){#fig:empl_dummy_timeres_m}

![Women, by period](../results/figures/empl_dummy_period_f.svg){#fig:empl_dummy_period_f}

![Men, by period](../results/figures/empl_dummy_period_m.svg){#fig:empl_dummy_period_m}

Employment rates (as share of sample population) by arrival cohort, gender, duration of stay and period.

</div>
<p class="fignote">
Sample is restricted to western Germany, including Berlin . <br />
Source: Microcensus Scientific Use Files, DOI: <a href="https://doi.org/10.21242/12211.1976.00.00.3.1.0">10.21242/12211.1976.00.00.3.1.0</a> to <a href="https://doi.org/10.21242/12211.2015.00.00.3.1.0">10.21242/12211.2015.00.00.3.1.0</a>, own calculations.
</p>

!include ../results/output/empl_dummy_timeres_f.md

!include ../results/output/empl_dummy_timeres_m.md

!include ../results/output/empl_dummy_period_f.md

!include ../results/output/empl_dummy_period_m.md


__Additional check for drop in employment rates of men of 1964-1973 cohort beginning in 1991:__
Particularly affected by unemployment, as shown in the tables below. Many seem to have chosen  early retirement over unemployment.

!include ../results/output/sum_cohort_1_emplst_m.md

!include ../results/output/sum_cohort_1_subsis_m.md


## Working Hours

<div id="fig:ahours">
![Women, by duration of stay](../results/figures/ahours_timeres_f.svg){#fig:ahours_timeres_f}

![Men, by duration of stay](../results/figures/ahours_timeres_m.svg){#fig:ahours_timeres_m}

![Women, by period](../results/figures/ahours_period_f.svg){#fig:ahours_period_f}

![Men, by period](../results/figures/ahours_period_m.svg){#fig:ahours_period_m}

Weekly working hours by arrival cohort, gender, duration of stay and period.

</div>
<p class="fignote">
Sample is restricted to western Germany, including Berlin . <br />
Source: Microcensus Scientific Use Files, DOI: <a href="https://doi.org/10.21242/12211.1976.00.00.3.1.0">10.21242/12211.1976.00.00.3.1.0</a> to <a href="https://doi.org/10.21242/12211.2015.00.00.3.1.0">10.21242/12211.2015.00.00.3.1.0</a>, own calculations.
</p>

!include ../results/output/ahours_timeres_f.md

!include ../results/output/ahours_timeres_m.md

!include ../results/output/ahours_period_f.md

!include ../results/output/ahours_period_m.md


<div id="fig:emplst">
![Women, full-time employment](../results/figures/emplst1_period_f.svg){#fig:emplst1_period_f}

![Men, full-time employment](../results/figures/emplst1_period_m.svg){#fig:emplst1_period_m.svg}

![Women, part-time employment](../results/figures/emplst2_period_f.svg){#fig:emplst2_period_f}

![Men, part-time employment](../results/figures/emplst2_period_m.svg){#fig:emplst2_period_m.svg}

![Women, marginal employment](../results/figures/emplst3_period_f.svg){#fig:emplst3_period_f}

![Men, marginal employment](../results/figures/emplst3_period_m.svg){#fig:emplst3_period_m.svg}

Full-time, part-time and marginal employment (as share of employed sample population) by arrival cohort, gender, and period.

</div>
<p class="fignote">
Full-time employment means working at least 35 hours per week, part-time employment 15-35 hours, and marginal employment 1-15 hours. Sample is restricted to western Germany, including Berlin . <br />
Source: Microcensus Scientific Use Files, DOI: <a href="https://doi.org/10.21242/12211.1976.00.00.3.1.0">10.21242/12211.1976.00.00.3.1.0</a> to <a href="https://doi.org/10.21242/12211.2015.00.00.3.1.0">10.21242/12211.2015.00.00.3.1.0</a>, own calculations.
</p>


## ISEI

<div id="fig:isei88_res">
![Women, by duration of stay](../results/figures/isei88_res_timeres_f.svg){#fig:isei88_res_timeres_f}

![Men, by duration of stay](../results/figures/isei88_res_timeres_m.svg){#fig:isei88_res_timeres_m}

![Women, by period](../results/figures/isei88_res_period_f.svg){#fig:isei88_res_period_f}

![Men, by period](../results/figures/isei88_res_period_m.svg){#fig:isei88_res_period_m}

ISEI-88 scores by arrival cohort, gender, duration of stay and period.
</div>
<p class="fignote">
Sample is restricted to western Germany, including Berlin . <br />
Source: Microcensus Scientific Use Files, DOI: <a href="https://doi.org/10.21242/12211.1976.00.00.3.1.0">10.21242/12211.1976.00.00.3.1.0</a> to <a href="https://doi.org/10.21242/12211.2015.00.00.3.1.0">10.21242/12211.2015.00.00.3.1.0</a>, own calculations.
</p>

!include ../results/output/isei88_res_timeres_f.md

!include ../results/output/isei88_res_timeres_m.md

!include ../results/output/isei88_res_period_f.md

!include ../results/output/isei88_res_period_m.md


__Additional check for age restriction effects:__
Regarding skill selectivity in arrival age, our sample restriction to persons between age 25 and 54 means that migrants arriving at age 18-23 'grow into' our sample.  For example, a person who immigrated at age 20 is first part of our analysis sample after 5 years of stay in Germany. If those young migrants who grow into our sample are less skilled and take on lower status employment than older arrivals who are already included, this might explain part of the decline in occupational status over the first years of residence. Comparing the educational levels between these two groups for a duration of stay of 1-6 years, this general pattern is indeed what we find for all cohorts but the first (see [@Tbl:sum_isced_arrage_f; @Tbl:sum_isced_arrage_m]). Consequently, accounting for this kind of selectivity in our occupational status analysis (by extending the age range to 18-54) leads to attenuated declines in ISEI scores in the first years of residence, particularly for women:

<div id="fig:isei88_res_age">
![Women, age 25-54](../results/figures/isei88_res_timeres_f.svg){#fig:isei88_res_timeres_f}

![Men, age 25-54](../results/figures/isei88_res_timeres_m.svg){#fig:isei88_res_timeres_m}

![Women, age 18-54](../results/figures/isei88_res_timeres_f_18_54.svg){#fig:isei88_res_timeres_f_18_54}

![Men, age 18-54](../results/figures/isei88_res_timeres_m_18_54.svg){#fig:isei88_res_timeres_m_18_54}

ISEI-88 scores by arrival cohort, gender, and duration of stay and period. Different age restrictions.
</div>
<p class="fignote">
Sample is restricted to western Germany, including Berlin. <br />
Source: Microcensus Scientific Use Files, DOI: <a href="https://doi.org/10.21242/12211.1976.00.00.3.1.0">10.21242/12211.1976.00.00.3.1.0</a> to <a href="https://doi.org/10.21242/12211.2015.00.00.3.1.0">10.21242/12211.2015.00.00.3.1.0</a>, own calculations.
</p>

__Additional check for possible employment delays for the less educated:__
Turning to our second assumed selection issue, employment delays for the lower skilled, we compare the absolute number of employed migrants by cohort and duration of stay between different educational levels. Generally, in the very first years of residence, the number of employed migrants with ISCED levels 5-6 is as high or even higher than the number of those with ISCED levels 0-2 and 3-4. However, this composition quickly changes with longer durations of stay, when more and more migrants with low or medium educational levels take up employment. As a result, the average education of migrants in employment decreases in the first years of stay, matching the observed initial decline in occupational status Despite some smaller differences, this general pattern seems to hold for women and men of all cohorts.

<div id="fig:empl_dummy_timeres_edu_n">
![Women](../results/figures/empl_dummy_timeres_edu_n_f.svg){#fig:empl_dummy_timeres_edu_n_f}

![Men](../results/figures/empl_dummy_timeres_edu_n_m.svg){#fig:empl_dummy_timeres_edu_n_m}

Number of persons in employment (population projection) by arrival cohort, gender, and duration of stay.
</div>
<p class="fignote">
Sample is restricted to western Germany, including Berlin. <br />
Source: Microcensus Scientific Use Files, DOI: <a href="https://doi.org/10.21242/12211.1976.00.00.3.1.0">10.21242/12211.1976.00.00.3.1.0</a> to <a href="https://doi.org/10.21242/12211.2015.00.00.3.1.0">10.21242/12211.2015.00.00.3.1.0</a>, own calculations.
</p>

---

# References

---
