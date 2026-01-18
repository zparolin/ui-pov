********************************************************************************
* Explore Dataset and Estimate Poverty Rates for Black Individuals by Year
* Created: 2026-01-18
********************************************************************************

clear all
set more off

* Load the dataset
use "postcollapse_usa.dta", clear

* Display dataset summary
describe, short
di _n "Total observations: " _N

* Look for race/ethnicity variables
di _n "=== Searching for race/ethnicity variables ==="
ds *race* *black* *white* *hisp* *ethnic*

* Look for year variables
di _n "=== Searching for year/time variables ==="
ds *year* *cohort* *time*

* Look for poverty variables
di _n "=== Searching for poverty variables ==="
ds *pov*

* Show first few observations
di _n "=== First 10 observations ==="
list in 1/10, clean

* Describe key variables in detail
describe

log close _all
