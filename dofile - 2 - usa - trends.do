
	* Open Ready Data:
			cd "$data_local"
			use data_ready_usa.dta, clear
			drop if chpov_opm_SPM_2==.
			
			* SET GLOBALS
			cd "$home"
			do "dofile - x - globals.do" // must run to set globals, relevant for all analyses below.
			
			
 cap  gen birthyear = year - age
 *   gen weight_ch2 = 1
    gen weight_ch2 = weight_ch
    drop if birthyear>=1989
   
   gen pov_opm_bin_2535 = inrange(poverty_opm_2535,.3333,1) & poverty_opm_2535!=.
   gen ever_chpov = chpov_opm>0 & chpov_opm!=.
   
   * Binary indicator of whether 20% in chpov:
  gen bi_chpov_spm2 = inrange(chpov_opm_SPM_2,.2,1) 
  gen bi_chpov_spm2_0 = inrange(chpov_opm_SPM_2,.001,1) 
  
    * Binary indicator of whether 20% in adulthood pov:
  gen bi_adpov_spm2 = inrange( pov_opm_SPM_2_2525,.2,1) 
   
	***************************************************************************
	* RANK-RANK SLOPES:
	**************************************************************************
		preserve
		tempfile res
		tempname p
		postfile `p' int birthyear double b lb ub long N using "`res'", replace

			local ad rank_ad_hh_net_inc_eq 	
			local ch rank_ch_hh_net_inc_eq 
		
		levelsof birthyear if !missing(pov_opm_SPM_2535) & !missing(chpov_opm_SPM_2), local(levels)
		foreach y of local levels {
			quietly reghdfe `ad' `ch' $covar_basic ///
				[aw=weight_ch2] if inrange(birthyear, `y'-1, `y'+1), absorb(year_age25)
			local b  = _b[`ch']
			local se = _se[`ch']
			local df = e(df_r)
			local t  = invttail(`df', .025)
			post `p' (`y') (`b') (`b' - `t'*`se') (`b' + `t'*`se') (e(N))
			di (`y'), (`b'), (`b' - `t'*`se'), (`b' + `t'*`se')
		}
		postclose `p'

		use "`res'", clear
		qui reg b c.birthyear
			local b  = _b[birthyear]
			local se = _se[birthyear]
			local df = e(df_r)
			local t  = invttail(`df', .025)
			di "`ad'", "`ch'", (`b'), (`b' - `t'*`se'), (`b' + `t'*`se')
		sort birthyear
		twoway (rcap lb ub birthyear) (connect b birthyear), ///
			ytitle("Coef. on childhood poverty (95% CI)") ///
			xtitle("Birth year (5-year centered)") ///
			title("Rank-Rank Slope") ///
			name(igpov_spm2, replace) ylab(0(.1).5)
		restore
	
	***************************************************************************
	* IGEs
	**************************************************************************
		preserve
		tempfile res
		tempname p
		postfile `p' int birthyear double b lb ub long N using "`res'", replace

			gen log_ch = log(m_hh_net_inc_eq_ch)	
			gen log_ad = log(m_hh_net_inc_eq_ad)	
			local ch m_hh_net_inc_eq_ch 
			local ad log_ad 	
			local ch log_ch 
			 
		
		levelsof birthyear if !missing(pov_opm_SPM_2535) & !missing(chpov_opm_SPM_2), local(levels)
		foreach y of local levels {
			quietly reghdfe `ad' `ch' $covar_basic ///
				[aw=weight_ch2] if inrange(birthyear, `y'-1, `y'+1), absorb(year_age25)
			local b  = _b[`ch']
			local se = _se[`ch']
			local df = e(df_r)
			local t  = invttail(`df', .025)
			post `p' (`y') (`b') (`b' - `t'*`se') (`b' + `t'*`se') (e(N))
			di (`y'), (`b'), (`b' - `t'*`se'), (`b' + `t'*`se')
		}
		postclose `p'

		use "`res'", clear
		qui reg b c.birthyear
			local b  = _b[birthyear]
			local se = _se[birthyear]
			local df = e(df_r)
			local t  = invttail(`df', .025)
			di "`ad'", "`ch'", (`b'), (`b' - `t'*`se'), (`b' + `t'*`se')
		sort birthyear
		twoway (rcap lb ub birthyear) (connect b birthyear), ///
			ytitle("Coef. on childhood poverty (95% CI)") ///
			xtitle("Birth year (5-year centered)") ///
			title("IGEs") ///
			name(igpov_spm2, replace) ylab(0(.1).5)
		restore
 
	***************************************************************************
	* ABSOLUTE INCOME MOBILITY
	**************************************************************************
		preserve
		tempfile res
		tempname p
		postfile `p' int birthyear double b lb ub long N using "`res'", replace

		 
			local ad m_hh_net_inc_eq_ad 	
			local ch m_hh_net_inc_eq_ch 
			gen yesmob = `ad' >= `ch' if `ad'!=. & `ch'!=.
		
		levelsof birthyear if !missing(pov_opm_SPM_2535) & !missing(chpov_opm_SPM_2), local(levels)
		foreach y of local levels {
			quietly ci mean yesmob  ///
				[aw=weight_ch2] if inrange(birthyear, `y'-1, `y'+1)
			post `p' (`y') (r(mean)) (r(lb)) (r(ub)) (e(N))
			*di (`y'), (`b'), (`b' - `t'*`se'), (`b' + `t'*`se')
		}
		postclose `p'

		use "`res'", clear
		sort birthyear
		twoway (rcap lb ub birthyear) (connect b birthyear), ///
			ytitle("Coef. on childhood poverty (95% CI)") ///
			xtitle("Birth year (5-year centered)") ///
			title("Abs. Income Mobility") ///
			name(igpov_spm2, replace) ylab(0(.1).8)
		restore
 
 
    ***************************************************************************
	* Absolute IGPov: %AdultPov among Childhood Poor by Time (no comparison grp)
	**************************************************************************
	preserve
	global whichpov pov_opm_SPM_2535 // CHOOSE POVERTY INDICATOR
		* pov_opm_SPM_2_2525 poverty_opm_pre_2535
	tempfile res
	tempname p
	postfile `p' int birthyear double mean lb ub grp using "`res'", replace

	levelsof birthyear if bi_chpov_spm2==1 & !missing(pov_opm_SPM_2535), local(levels)
	foreach y of local levels {
	foreach pp in 0 1 {	
		quietly ci means $whichpov [aw=weight_ch2] ///
			if bi_chpov_spm2_0==`pp' & inrange(birthyear, `y'-2, `y'+2)
		post `p' (`y') (`r(mean)') (`r(lb)') (`r(ub)') (`pp')
		
	}
	}
		
	postclose `p'

	use "`res'", clear
	sort birthyear
		twoway ///
    (rcap lb ub birthyear if grp==1, lcolor(navy%40)) ///
    (connected mean birthyear if grp==1, lcolor(navy) mcolor(navy) msymbol(circle)) ///
    (rcap lb ub birthyear if grp==0, lcolor(maroon%40)) ///
    (connected mean birthyear if grp==0, lcolor(maroon) mcolor(maroon) msymbol(triangle)) ///
    , ///
    ytitle("% Adult Poverty (Age 28-38)") ///
    xtitle("Birth Year") ///
    name(abs_igpov, replace) ///
    xlab(1960(5)1990) ylab(0(.05).3) ///
    legend(order(2 "Some Childhood Poverty" 4 "No Childhood Poverty") ///
           pos(6) ring(12) col(1) region(lcolor(none)))
	cd "$output"
	graph export "fig-trends-abs-igpov.pdf", as(pdf) replace 

	restore

 
// 	***************************************************************************
// 	* Absolute IGPov: Binary AdultPov>.2 among Childhood Poor by Time (no comparison grp)
// 	**************************************************************************
// 	preserve
// 	tempfile res
// 	tempname p
// 	postfile `p' int birthyear double mean lb ub using "`res'", replace
//
// 	levelsof birthyear if bi_chpov_spm2==1 & !missing(pov_opm_SPM_2_2525), local(levels)
// 	foreach y of local levels {
// 		quietly ci means bi_adpov_spm2 [aw=weight_ch2] ///
// 			if bi_chpov_spm2_0==1 & inrange(birthyear, `y'-1, `y'+1)
// 		post `p' (`y') (`r(mean)') (`r(lb)') (`r(ub)')
// 	}
// 	postclose `p'
//
// 	use "`res'", clear
// 	sort birthyear
// 	twoway (rcap lb ub birthyear) (connect mean birthyear), ///
// 		ytitle("% Adult poverty (childhood poor)") ///
// 		xtitle("Birth year (5-year centered)") ///
// 		title("Absolute IGPov") ///
// 		name(abs_igpov_2, replace)  ylab(0(.1).5)
// 	restore

	
	***************************************************************************
	* Relative IGPov:
	**************************************************************************
 
		preserve
		tempfile res
		tempname p
		postfile `p' int birthyear double b lb ub long N using "`res'", replace


		
		
			local ad pov_opm_SPM_2535	
				* poverty_opm_2535   pov_opm_SPM_2535 pov_opm_SPM_2_2525 ///
				poverty_opm_pre_2535
			local ch chpov_opm_SPM
				* chpov_opm chpov_opm_SPM_2 chpov_opm_SPM pov_parents
		
		levelsof birthyear if !missing(pov_opm_SPM_2535) & !missing(chpov_opm_SPM_2), local(levels)
		foreach y of local levels {
			quietly reghdfe `ad' `ch' $covar_basic ///
				[aw=weight_ch2] if inrange(birthyear, `y'-1, `y'+1), absorb(year_age25)
			local b  = _b[`ch']
			local se = _se[`ch']
			local df = e(df_r)
			local t  = invttail(`df', .025)
			post `p' (`y') (`b') (`b' - `t'*`se') (`b' + `t'*`se') (e(N))
			di (`y'), (`b'), (`b' - `t'*`se'), (`b' + `t'*`se')
		}
		postclose `p'

		use "`res'", clear
		qui reg b c.birthyear
			local b  = _b[birthyear]
			local se = _se[birthyear]
			local df = e(df_r)
			local t  = invttail(`df', .025)
			di "`ad'", "`ch'", (`b'), (`b' - `t'*`se'), (`b' + `t'*`se')
		sort birthyear
		twoway (rcap lb ub birthyear, lcolor(gs8)) (connect b birthyear, mcolor(gs0) lcolor(gs0)), ///
			ytitle("Relative IGPov") ///
			xtitle("Birth Year") ///
			name(igpov_spm2, replace) ylab(0(.1).5) xlab(1960(5)1990) leg(off)
		
		cd "$output" 
		graph export "fig-trends-abs-igpov.pdf", as(pdf) replace 	
		restore
		
	

	***************************************************************************
* Relative IGPov – Alt Versions Graph: five lines, indexed to base year
***************************************************************************

preserve

tempfile res
tempname p
postfile `p' int birthyear double b lb ub long N str60 series using "`res'", replace

*-------------------------
* Define (adult, child) pairs + legend labels
*-------------------------
local n 5
local ad1  pov_opm_SPM_2535
local ch1  chpov_opm_SPM
local lab1 "Adult SPM 25–35 × Child SPM"

local ad2  poverty_opm_2535
local ch2  chpov_opm
local lab2 "Adult OPM 25–35 × Child OPM"

local ad3  pov_opm_SPM_2_2525
local ch3  chpov_opm_SPM_2
local lab3 "Adult SPM(25–25) × Child SPM(alt)"

local ad4  poverty_opm_pre_2535
local ch4  chpov_opm
local lab4 "Adult pre-tax/transfer × Child OPM"

local ad5  pov_opm_SPM_2535
local ch5  pov_parents
local lab5 "Adult SPM 25–35 × Parent poverty"

*-------------------------
* Loop over combos and birth years
*-------------------------
forvalues i = 1/`n' {
    local ad = "`ad`i''"
    local ch = "`ch`i''"
    local lab = "`lab`i''"

    levelsof birthyear if !missing(`ad') & !missing(`ch'), local(levels)

    foreach y of local levels {
        quietly reghdfe `ad' `ch' $covar_basic ///
            [aw=weight_ch2] if inrange(birthyear, `y'-1, `y'+1), absorb(year_age25)
        local b  = _b[`ch']
        local se = _se[`ch']
        local df = e(df_r)
        local t  = invttail(`df', .025)
        post `p' (`y') (`b') (`b' - `t'*`se') (`b' + `t'*`se') (e(N)) ("`lab'")
    }
}

postclose `p'

*-------------------------
* Index to base year and plot percent changes
*-------------------------
use "`res'", clear
sort series birthyear

* Choose a common base year if possible; fallback to each series' earliest year when missing
local baseyear = 1960   // <-- set this to your preferred common base; keep as-is if OK

* Compute base b for each series
gen b0 = .
by series: egen b0_common = mean(cond(birthyear==`baseyear', b, .))
replace b0 = b0_common
by series: replace b0 = b[1] if missing(b0)   // fallback: earliest available year per series

* Percent change from base
// gen pct = 100*(b/b0 - 1)
gen pct = b- b0

* Optional: keep only years where pct is defined
drop if missing(pct)

* Plot (percent changes)
twoway ///
    (line pct birthyear if series=="Adult SPM 25–35 × Child SPM",    lwidth(thick) lcolor(gs0)   lpattern(solid)     msize(small)) ///
    (line pct birthyear if series=="Adult OPM 25–35 × Child OPM",       lcolor(ebblue) lpattern(dash)      msize(small)) ///
    (line pct birthyear if series=="Adult SPM(25–25) × Child SPM(alt)", lcolor(green) lpattern(dash)       msize(small)) ///
    (line pct birthyear if series=="Adult pre-tax/transfer × Child OPM", lcolor(gs6) lpattern(longdash)  msize(small)) ///
    (line pct birthyear if series=="Adult SPM 25–35 × Parent poverty",  lcolor(red) lpattern(shortdash) msize(small)), ///
    ytitle("Relative IGPov (p.p. change from base)") ///
    xtitle("Birth Year") ///
    xlab(1960(5)1990) ///
    legend(order(1 "SPM × Child SPM" ///
                 2 "OPM × Child OPM" ///
                 3 "SPM v2 × Child SPM v2" ///
                 4 "Pre-tax/transfer × Child OPM" ///
                 5 "SPM × Parent poverty") ///
                  position(6) ring(1) row(2) region(lstyle(none)) span) ///
    name(fig_rel_igpov_5lines_indexed, replace) ylab(-.3(.1).3)

cd "$output"
graph export "fig-trends-rel-igpov-5lines-indexed.pdf", as(pdf) replace

restore

	
	***************************************************************************
	* Pre-Tax/Transfer: Relative and Absolute
	**************************************************************************
 
		* RELATIVE
		preserve
		tempfile res
		tempname p
		postfile `p' int birthyear double b lb ub long N using "`res'", replace
		
		global whichchpov chpov_opm_SPM
		* 	chpov_opm_SPM_2

		levelsof birthyear if !missing(pov_opm_SPM_2535) & !missing($whichchpov), local(levels)
		foreach y of local levels {
			quietly reghdfe poverty_opm_pre_2535 $whichchpov $covar_basic ///
				[aw=weight_ch2] if inrange(birthyear, `y'-1, `y'+1), absorb(year_age25)
			local b  = _b[$whichchpov]
			local se = _se[$whichchpov]
			local df = e(df_r)
			local t  = invttail(`df', .025)
			post `p' (`y') (`b') (`b' - `t'*`se') (`b' + `t'*`se') (e(N))
		}
		postclose `p'

		use "`res'", clear
		sort birthyear
		twoway (rcap lb ub birthyear) (connect b birthyear), ///
			ytitle("Coef. on childhood poverty (95% CI)") ///
			xtitle("Birth year (5-year centered)") ///
			title("Pre-TT IGPOV: OPM poverty with SPM v2") ///
			name(pre_rel, replace) ylab(0(.1).5)
		restore

		** ABSOLUTE:
		preserve
		tempfile res
		tempname p
		postfile `p' int birthyear double mean lb ub using "`res'", replace

		levelsof birthyear if bi_chpov_spm2==1 & !missing(pov_opm_SPM_2_2525), local(levels)
		foreach y of local levels {
			quietly ci means poverty_opm_pre_2535 [aw=weight_ch2] ///
				if bi_chpov_spm2==1 & inrange(birthyear, `y'-1, `y'+1)
			post `p' (`y') (`r(mean)') (`r(lb)') (`r(ub)')
		}
		postclose `p'

		use "`res'", clear
		sort birthyear
		twoway (rcap lb ub birthyear) (connect mean birthyear), ///
			ytitle("% Adult poverty (childhood poor)") ///
			xtitle("Birth year (5-year centered)") ///
			title("Pre-TT Absolute IGPov") ///
			name(pre_abs, replace)  ylab(0(.1).5)
		restore
		
		grc1leg pre_rel pre_abs, ycommon


	**************************************************************************
   
		   *****************************
		   *****************************
		   *** GRAPH IGPOV and Pov Means BY GROUP ***
		   *****************************
		   *****************************
				
			global povoutcome pov_opm_SPM_2535
			global chpovoutcome chpov_opm_SPM
			
	
			* Ensure group dummies exist
			cap gen byte all = 1
			cap gen byte male = (female==0) if !missing(female)
			cap gen byte parent_college    = (edu_attain_mom==3 | edu_attain_dad==3)
			cap gen byte parent_nocollege  = (parent_college==0) if !missing(parent_college)

			* Groups we need across all figures
			local allgroups all male female parent_college parent_nocollege rwhite rblack

			* Rolling-window center years (5-year windows centered on y)
			levelsof birthyear, local(levels)

			* Minimum N per (group x window) to keep a plotted point
			local minN 100

			********************************************************
			* 1) Collect β (same as before)
			********************************************************
			tempname Hbeta
			tempfile results_beta
			postfile `Hbeta' str20 group int byear double beta lb ub N using "`results_beta'", replace

			foreach g of local allgroups {
			  foreach y of local levels {
				preserve
				  qui keep if `g'==1
				  qui keep if inrange(birthyear, `y'-2, `y'+2)
				  qui count
				  if r(N)>0 {
					qui reghdfe $povoutcome $chpovoutcome $covar_basic [aw=weight_ch2], absorb(year_age25)
					scalar b  = _b[$chpovoutcome]
					scalar se = _se[$chpovoutcome]
					scalar df = e(df_r)
					scalar t  = invttail(df,.025)
					post `Hbeta' ("`g'") (`y') (b) (b - t*se) (b + t*se) (e(N))
				  }
				restore
			  }
			}
			postclose `Hbeta'

			********************************************************
			* 2) Collect MEANS: childhood poverty & adult poverty
			********************************************************
			tempname Hmean
			tempfile results_mean
			postfile `Hmean' str20 group int byear ///
				double mch lbch ubch Nch ///
				double mad lbad ubad Nad ///
				using "`results_mean'", replace

			foreach g of local allgroups {
			  foreach y of local levels {
				preserve
				  qui keep if `g'==1
				  qui keep if inrange(birthyear, `y'-2, `y'+2)
				  qui count
				  if r(N)>0 {
					* childhood poverty mean + CI
					qui ci means $chpovoutcome [aw=weight_ch2]
					scalar mch  = r(mean)
					scalar lbch = r(lb)
					scalar ubch = r(ub)
					scalar Nch  = r(N)

					* adult poverty mean + CI
					qui ci means $povoutcome [aw=weight_ch2]
					scalar mad  = r(mean)
					scalar lbad = r(lb)
					scalar ubad = r(ub)
					scalar Nad  = r(N)

					post `Hmean' ("`g'") (`y') (mch) (lbch) (ubch) (Nch) (mad) (lbad) (ubad) (Nad)
				  }
				restore
			  }
			}
			postclose `Hmean'

			********************************************************
			* 3) Prep plotting data & compute common y-axes
			********************************************************

			* β dataset
			use "`results_beta'", clear
			gen byte keep = (N>=`minN')
			keep if keep
			drop keep
			tempfile beta_data
			save "`beta_data'", replace

			* Combined means dataset (child + adult)
			use "`results_mean'", clear
			gen byte keep = (Nch>=`minN' & Nad>=`minN')
			keep if keep
			drop keep
			tempfile means_dual
			save "`means_dual'", replace

			* Compute common y-axis range for β (use CI bounds)
			use "`beta_data'", clear
			summ lb, meanonly
			local ymin_b = r(min)
			summ ub, meanonly
			local ymax_b = r(max)
			local pad_b = 0.02*(`ymax_b' - `ymin_b')
			local ymin_bv = `ymin_b' - `pad_b'
			local ymax_bv = `ymax_b' + `pad_b'

			* Compute common y-axis range for MEANS (use BOTH series' CI bounds)
			use "`means_dual'", clear
			summ lbch lbad, meanonly
			local ymin_m = r(min)
			summ ubch ubad, meanonly
			local ymax_m = r(max)
			local pad_m = 0.02*(`ymax_m' - `ymin_m')
			local ymin_mv = `ymin_m' - `pad_m'
			local ymax_mv = `ymax_m' + `pad_m'

			********************************************************
			* 4) Helpers to build bundles with common axes
			********************************************************
			program drop _all

			* β bundle (unchanged)
			program define _mk_bundle_beta
				args BUNDLE GLIST DATA YMIN YMAX
				use "`DATA'", clear
				label var byear "Birthyear (5-year centered)"
				label var beta  "β on childhood poverty"
				local glist
				foreach g of local GLIST {
					preserve
						keep if group=="`g'"
						sort byear
						twoway ///
						  (rcap lb ub byear, lwidth(medthin)) ///
						  (connected beta byear, msymbol(O) msize(small) lwidth(medthick)), ///
						  title("`g'") ///
						  ytitle("β (adult poverty on childhood poverty)") ///
						  xtitle("Birthyear (center of 5-yr window)") ///
						  legend(order(2 "β" 1 "95% CI")) ///
						  yscale(range(`YMIN' `YMAX')) ///
						  name(Gb_`BUNDLE'_`g', replace)
						quietly graph save Gb_`BUNDLE'_`g', replace
					restore
					local glist `glist' Gb_`BUNDLE'_`g'
				}
				local first : word 1 of `glist'
				grc1leg `glist', legendfrom(`first') name(FIGb_`BUNDLE', replace) cols(3) ycommon xcommon
			end

			* Dual-means bundle: childhood + adult in SAME panel
			program define _mk_bundle_meandual
				// syntax: _mk_bundle_meandual BUNDLE "group1 group2 group3" DATA YMIN YMAX
				args BUNDLE GLIST DATA YMIN YMAX
				use "`DATA'", clear
				label var byear "Birthyear (5-year centered)"
				local glist
				foreach g of local GLIST {
					preserve
						keep if group=="`g'"
						sort byear
						twoway ///
						  (rcap lbch ubch byear, lwidth(thin)   lcolor(navy%40)) ///
						  (rcap lbad ubad byear, lwidth(thin)   lcolor(maroon%40)) ///
						  (connected mch  byear, msymbol(O)     msize(small) lwidth(medthick) lcolor(navy)) ///
						  (connected mad  byear, msymbol(T)     msize(small) lwidth(medthick) lcolor(maroon)) ///
						, ///
						  title("`g'") ///
						  ytitle("Mean poverty rate") ///
						  xtitle("Birthyear (center of 5-yr window)") ///
						  legend(order(3 "Childhood poverty mean" 4 "Adult poverty mean") rows(1) region(lstyle(none))) ///
						  yscale(range(`YMIN' `YMAX')) ///
						  name(GmDual_`BUNDLE'_`g', replace)
						quietly graph save GmDual_`BUNDLE'_`g', replace
					restore
					local glist `glist' GmDual_`BUNDLE'_`g'
				}
				local first : word 1 of `glist'
				grc1leg `glist', legendfrom(`first') name(FIGmDual_`BUNDLE', replace) cols(3) ycommon xcommon
			end

			********************************************************
			* 5) Build the three requested bundles (β + Dual Means)
			********************************************************
			* β figures
			_mk_bundle_beta A "all male female" "`beta_data'" `ymin_bv' `ymax_bv'
			_mk_bundle_beta B "all parent_college parent_nocollege" "`beta_data'" `ymin_bv' `ymax_bv'
			_mk_bundle_beta C "all rwhite rblack" "`beta_data'" `ymin_bv' `ymax_bv'

			* Dual means (child + adult in same figure)
			_mk_bundle_meandual A "all male female" "`means_dual'" `ymin_mv' `ymax_mv'
			_mk_bundle_meandual B "all parent_college parent_nocollege" "`means_dual'" `ymin_mv' `ymax_mv'
			_mk_bundle_meandual C "all rwhite rblack" "`means_dual'" `ymin_mv' `ymax_mv'

			* Optional exports:
			 cd "$output"
			 graph export "fig_beta_A.png",     name(FIGb_A)      width(2000) replace
			 graph export "fig_beta_B.png",     name(FIGb_B)      width(2000) replace
			 graph export "fig_beta_C.png",     name(FIGb_C)      width(2000) replace
// 			 graph export "fig_MEANdual_A.png", name(FIGmDual_A)  width(2000) replace
// 			 graph export "fig_MEANdual_B.png", name(FIGmDual_B)  width(2000) replace
// 			 graph export "fig_MEANdual_C.png", name(FIGmDual_C)  width(2000) replace



   
    * IGPOV: OPM POV - PRE-T
//
//    levelsof birthyear, local(levels)
//    foreach y of local levels {
//    	preserve
// 	qui keep if inrange(birthyear,`y'-2,`y'+2)
//    qui  reghdfe poverty_opm_pre_2535 chpov_opm $covar_basic  [aw=weight_ch2], absorb(year_age25)    
//    di "`y'", _b[chpov], (_b[chpov] - invttail(e(df_r), .025) * _se[chpov]), (_b[chpov] + invttail(e(df_r), .025) * _se[chpov]), e(N)
//    restore
//    }
//   
    * ABSOLUTE IGPOV: OPM POV
   levelsof birthyear, local(levels)
   foreach y of local levels {
   	preserve
	qui keep if inrange(birthyear,`y'-2,`y'+2)
   qui  ci mean pov_opm_bin_2535 if inrange(chpov_opm,.33,1)  [aw=weight_ch2] 
   di "`y'", "`g'", r(mean), r(lb), r(ub)
   restore
   }
   
//   
//   
//   
//    * IGPOV
//    levelsof birthyear, local(levels)
//    foreach y of local levels {
//    	preserve
// 	qui keep if inrange(birthyear,`y'-2,`y'+2)
//    qui  reghdfe poverty_2426 chpov $covar_basic  [aw=weight_ch2], absorb(year_age25)    
//    di "`y'", _b[chpov], (_b[chpov] - invttail(e(df_r), .025) * _se[chpov]), (_b[chpov] + invttail(e(df_r), .025) * _se[chpov]), e(N)
//    restore
//    }
//   
//   
// 	* IGPOV: ABS POV
//    levelsof birthyear, local(levels)
//    foreach y of local levels {
//    	preserve
// 	qui keep if inrange(birthyear,`y'-3,`y'+3)
//    qui  reghdfe poverty_opm_2535 chpov_opm $covar_basic  [aw=weight_ch2], absorb(year_age25)    
//    di "`y'", _b[chpov], (_b[chpov] - invttail(e(df_r), .025) * _se[chpov]), (_b[chpov] + invttail(e(df_r), .025) * _se[chpov]), e(N)
//    restore
//    }
//   
//    * ABS IGPOV: OPM POV
//    levelsof birthyear, local(levels)
//    foreach g in all rwhite rblack  {
//    foreach y of local levels {
//    	cap gen all = 1
//    	preserve
// 	qui keep if inrange(birthyear,`y'-2,`y'+2) & `g'==1
//    qui  sum pov_abs_bin_2535 if inrange(chpov_abs,.33,1)  [aw=weight_ch2] 
//    di "`y'", "`g'", r(mean)
//    restore
//    }
//    }
//   
//    * ABS IGPOV: ABS POV
//    levelsof birthyear, local(levels)
//    foreach g in all rwhite rblack  {
//    foreach y of local levels {
//    	cap gen all = 1
//    	preserve
// 	qui keep if inrange(birthyear,`y'-2,`y'+2) & `g'==1
//    qui  sum pov_abs_bin_2535 if inrange(chpov_abs,.33,1)  [aw=weight_ch2] 
//    di "`y'", "`g'", r(mean)
//    restore
//    }
//    }
//   
//    * ABS IGPOV: REL POV
//     levelsof birthyear, local(levels)
//    foreach y of local levels {
//    	preserve
// 	qui keep if inrange(birthyear,`y'-2,`y'+2)
//    qui  sum poverty_2426 if inrange(chpov,.20,1)  [aw=weight_ch2] 
//    di "`y'", r(mean)
//    restore
//    }
//   
//   
   
   
 
