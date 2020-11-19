////////////////////////////////////////////////////////////////////////////////
//
//		Immigration and Labor Market Integration in Germany: A Long View
//
//		0 -- Master
//
//		Maximilian Sprengholz
//		maximilian.sprengholz@hu-berlin.de
//
////////////////////////////////////////////////////////////////////////////////

// 	Prep
clear
set seed 1234
set more off
set matsize 5000

// 	Project directories
global dir "C:/Users/sprenmax/Seafile/Projects/a-long-view/"
global dir_t "${dir}results/output/"
global dir_g "${dir}results/figures/"
global dir_src "${dir}/src/" // source code (do)
global dir_bin "${dir}/bin/" // external source code
global dir_data "${dir}/data/"
/*
 Because the Microcensus data is not open, they are not part of the repository.
 The following macros point to the directory of the original and processed
 Scientific Use Files (SUFs).
*/
global dir_mz "C:/Users/sprenmax/Desktop/MZ/Daten/" // Microcensus data
global dir_mzproc "C:/Users/sprenmax/Desktop/MZ/newdata/Max/" // Microcensus data processed

// Run code
do "${dir_src}mz_o_01_kldb.do" // prep kldb -> isco translation
do "${dir_src}mz_o_02_gen.do" // generate pooled and harmonized analysis dataset
do "${dir_src}mz_o_03_analysis.do" // analysis
do "${dir_src}mz_o_04_analysis_incl_east.do" // analysis
do "${dir_src}mz_o_04_emr_inflows.do" // visualization of register data on foreigner inflows
