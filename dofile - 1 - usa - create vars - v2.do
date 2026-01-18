

	******************************
	**# Section 1 - Loop Through Countries
	******************************
	*Creates dataset with all countries everytime
	*do "$root_\Data Work - Rafael\Codes\Data_creation\4_join_countries.do"

		*Creates dataset with all countries everytime
	*do "$root_\Data Work - Rafael\Codes\Data_creation\4_join_countries.do"
	clear all
	use "$data\USA_processed.dta", clear
	
	cap gen country = "USA"

	* U.S. CPI-U (All Urban Consumers), 1982–84=100, normalized to 2019=100
* Source: BLS, Annual Averages, Not Seasonally Adjusted

	* Suppose your variable is called id
	gen id_clean = subinstr(id, "US", "", .)

	* Convert to numeric, replacing the string variable
	destring id_clean, replace
	ren id_clean x11101ll 
	gen wave = year 
	
	* Merge in OPM Thresholds
	cap drop _merge
	merge m:1 x11101ll wave ///
	using "$data\merge - opm.dta"
		drop if _merge==2
		
	
	* Merge in SPM Transfers
	gen X11101LL = id
	foreach ii of numlist 1970(1)1997 1999(2)2019 {
	cap drop _merge
	cd "$data/imp"
	merge 1:1 year X11101LL using psid_merge_spm_`ii'.dta, update
	}

	
	* Recalculate Xfers
	egen tr_sum_imp_2 = rowtotal(SPMu_EngVal SPMu_SNAPSub SPMu_SchLunch SPMu_WICval SPMu_Welf SPMu_SS SPMu_SSI SPMu_UE2 SPMu_FedEcRecov SPMu_Stimulus)
	
	egen tax_sum_imp_2 = rowtotal(SPMu_FICA SPMu_stTax SPMu_FedTax)

	** OPM Pov
	gen pov_opm = hh_net_inc < opmthresh & opmthresh!=. * hh_net_inc!=.
	gen pov_opm_pre = I11101 < opmthresh & opmthresh!=. * I11101!=.
	gen pov_opm_SPM_2   = (I11101 + tr_sum_imp_2 - tax_sum_imp_2) < opmthresh ///
						& I11101<. & opmthresh<. & tr_sum_imp_2<. & tax_sum_imp_2<.
					

gen cpi2019 = .

	replace cpi2019 = 15.2 if year==1970
	replace cpi2019 = 15.8 if year==1971
	replace cpi2019 = 16.3 if year==1972
	replace cpi2019 = 17.4 if year==1973
	replace cpi2019 = 19.3 if year==1974
	replace cpi2019 = 21.0 if year==1975
	replace cpi2019 = 22.2 if year==1976
	replace cpi2019 = 23.7 if year==1977
	replace cpi2019 = 25.5 if year==1978
	replace cpi2019 = 28.4 if year==1979
	replace cpi2019 = 32.2 if year==1980
	replace cpi2019 = 35.5 if year==1981
	replace cpi2019 = 37.7 if year==1982
	replace cpi2019 = 38.9 if year==1983
	replace cpi2019 = 40.6 if year==1984
	replace cpi2019 = 42.1 if year==1985
	replace cpi2019 = 42.9 if year==1986
	replace cpi2019 = 44.4 if year==1987
	replace cpi2019 = 46.3 if year==1988
	replace cpi2019 = 48.5 if year==1989
	replace cpi2019 = 51.1 if year==1990
	replace cpi2019 = 53.3 if year==1991
	replace cpi2019 = 54.9 if year==1992
	replace cpi2019 = 56.5 if year==1993
	replace cpi2019 = 57.9 if year==1994
	replace cpi2019 = 59.6 if year==1995
	replace cpi2019 = 61.3 if year==1996
	replace cpi2019 = 62.7 if year==1997
	replace cpi2019 = 63.8 if year==1998
	replace cpi2019 = 65.1 if year==1999
	replace cpi2019 = 67.3 if year==2000
	replace cpi2019 = 69.3 if year==2001
	replace cpi2019 = 70.4 if year==2002
	replace cpi2019 = 72.0 if year==2003
	replace cpi2019 = 73.9 if year==2004
	replace cpi2019 = 76.4 if year==2005
	replace cpi2019 = 78.9 if year==2006
	replace cpi2019 = 81.1 if year==2007
	replace cpi2019 = 84.2 if year==2008
	replace cpi2019 = 83.9 if year==2009
	replace cpi2019 = 85.3 if year==2010
	replace cpi2019 = 88.0 if year==2011
	replace cpi2019 = 89.8 if year==2012
	replace cpi2019 = 91.1 if year==2013
	replace cpi2019 = 92.6 if year==2014
	replace cpi2019 = 92.7 if year==2015
	replace cpi2019 = 93.9 if year==2016
	replace cpi2019 = 95.9 if year==2017
	replace cpi2019 = 98.2 if year==2018
	replace cpi2019 = 100.0 if year==2019

		drop if age==. & hh_net_inc_eq==.
		
		
		** SELECT AGE BAND (ex: age 25-35)
		global minage 28
		global maxage 38
		
		gen minage = $minage
		gen maxage = $maxage
	

	******************************************************

		*************************
		*** Ascriptive       ***
		************************
			
			* Race
				gen rwhite = D11112LL==1
				gen rblack = D11112LL==2
				gen rhisp = D11112LL==5
				gen rasian = D11112LL==4
				gen rother = D11112LL==3 | D11112LL==7
		
			* Birthyear
				gen birthyear = year - age
				bysort id: egen first_age_obs = min(age)
	
			* Ages Observed:
			
				* Age 0 to 5
				cap drop hold
				gen hold = 0
				foreach x of numlist 0 / 5 {
					replace hold = 1 if age==`x'
				}
				bysort country id: egen obsage_05 = sum(hold)
					replace obsage_05 = 0 if obsage_05==.
					replace obsage_05 = obsage_05 / 6 
					
				* Age 6 to 10
				cap drop hold
				gen hold = 0
				foreach x of numlist 6 / 10 {
					replace hold = 1 if age==`x'
				}
				bysort country id: egen obsage_610 = sum(hold)
					replace obsage_610 = 0 if obsage_610==.
					replace obsage_610 = obsage_610 / 5	
					
				* Age 11 to 17
				cap drop hold
				gen hold = 0
				foreach x of numlist 11 / 17 {
					replace hold = 1 if age==`x'
				}
				bysort country id: egen obsage_1117 = sum(hold)
					replace obsage_1117 = 0 if obsage_1117==.
					replace obsage_1117 = obsage_1117 / 8	
					
				* Age 25 to 35
				cap drop hold
				gen hold = 0
				foreach x of numlist $minage / $maxage {
					replace hold = 1 if age==`x'
				}
				bysort country id: egen obsage_2535 = sum(hold)
					replace obsage_2535 = 0 if obsage_2535==.
					
				* TOTAL CHOBS
				gen tot_chobs = obsage_1117*8 + obsage_610*5 + obsage_05*6
	
			* Year at Age 25
				bysort country id : egen year_age25 = max(year) if inrange(age,minage,maxage)
				*NOTE: year_age25 actually means last year observed in the data. Need to eventually correct variable name for replication package. To get minimum year while in adulthood (roughly corresponding to year at age 25), just substitute max with min.
				
			* Year at Age 25
				bysort country id : egen age_max = max(age) if inrange(age, minage, maxage)	
				
	
		*********************************************
		*** Parents' Poverty Status, Ages 25-35 ***
		********************************************
		cap drop pov_par_2535*
		cap gen obs = 1
		bysort id: egen pov_par_2535a = mean(poverty) if inrange(age,$minage,$maxage) & (D11105==1 | D11105 ==2) & chpov==.
			* // heads and partners only 
			* // missings for chpov, otherwise we're getting people who end up on our final sample and 
				* assigning them their own values. 
			
	*	bysort id: egen pov_par_2535b = mean(pov_par_2535a) // store universally for individuals
			* This is parent's poverty status between age 25-35. 
			* Need to attached to children. Do so by calculating mean parental poverty at HH-Year level.
			* Produce child's values at max of Parents 25-35y/o poverty when in childhood.
				* Max better than mean if parents come in and out of HH during childhood.
		
		* Count of obs during this period:
		bysort id: egen pov_par_obs_a  = sum(obs) if inrange(age,$minage,$maxage) & (D11105==1 | D11105 ==2)
		bysort id: egen pov_par_obs_b  = mean(pov_par_obs_a) 
		
		* Weight parental pov by number of obs during age range:
		bysort year country hh_code: egen pov_par_2535 = mean(pov_par_2535a)
			// parental pov stored at HH-Year level
			
		* Attach to children:
		bysort id: egen pov_parents_a = max(pov_par_2535) if inrange(age,0,17)
		bysort id: egen pov_parents = mean(pov_parents_a)
		drop pov_parents_a
				
		*************************
		*** Family Structure ***
		************************
		
		* Married/Partnered
			gen married = 0 if D11104!=. 
				replace married = 1 if D11104==1 
		
		* Children, Family Size
			gen hh_nchild = D11107
			gen hh_nchild_u5 = H11103 + H11104
			gen hh_npers = D11106  
				replace hh_npers = 5 if hh_npers>5 & hh_npers!=.
			gen head_hh = D11105 ==1
			replace head_hh = . if mi(D11105)
			
		
		*************************
		*** Education        ***
		************************
		/*
		** UK EDU
			replace high_school = 1 if inrange(edu4,1,2) // less than HS
				* edu4 = 2 = lower secondary
			replace high_school = 2 if inrange(edu4,3,3) // 
				* edu4 = 3 = upper secondary 
			replace high_school = 3 if inrange(edu4,4,4)
		*/
		
		* EDU:
		gen edu_hsdegree = high_school==2 | high_school==3
			gen edu_hsdegree_only = high_school==2 
		gen edu_somecollege = high_school==3
		replace edu_hsdegree = . if mi(high_school)
		replace edu_somecollege = . if mi(high_school)
		
		gen edu_college = inrange(years_of_edu,16,100)
		
		* Partner has College Degree?
		
			gen partner_college = edu_partner==3
			replace partner_college = . if mi(edu_partner) 
	
		*************************
		*** Cohort Income Ranks for RRS           ***
		************************
		foreach q in hh_net_inc_eq hh_inc_pretax_eq  {
			
			cap drop xx
			gen xx = `q' / cpi2019 / 100
			bysort country id: egen m_`q'_cha = mean(xx) if inrange(age,0,17)
			bysort country id: egen m_`q'_ch = mean(m_`q'_cha) 
				drop m_`q'_cha
		
			bysort country id: egen m_`q'_cha = mean(xx) if inrange(age,$minage,$maxage)
			bysort country id: egen m_`q'_ad = mean(m_`q'_cha) 
				drop m_`q'_cha	
				
			* Create 100 quantile bins within each cohort using pweights
			
			gen rank_ch_`q'=.
			gen rank_ad_`q'= .
			levelsof birthyear if !missing(m_`q'_ch) & !missing(m_`q'_ad), local(byears)
			foreach y of local byears {
					cap drop mm*
					quietly xtile mm1  = m_`q'_ch [pw=W11101] if birthyear == `y', nq(100)
					quietly xtile mm2  = m_`q'_ad [pw=W11101] if birthyear == `y', nq(100)
					replace rank_ch_`q'= mm1 if birthyear==`y'
					replace rank_ad_`q'= mm2 if birthyear==`y'
					drop mm*
			}
		}
					cap drop xx		

		
		*************************
		*** Absolute Poverty           ***
		************************
		
		gen real_hh_net_inc_eq = hh_net_inc_eq * (100/cpi)
		sum real_hh_net_inc_eq if year == 1980 [w=W11101], de
		gen povline_abs = r(p50) * .50
		gen pov_abs = real_hh_net_inc_eq < povline_abs & real_hh_net_inc_eq!=. & povline_abs!=.
		
		*************************
		*** Poverty in Childhood          ***
		************************
	
		* SPM Versions:
		bysort country id: egen aa = mean(pov_opm_SPM) if inrange(age,0,17)
		bysort country id: egen chpov_opm_SPM = mean(aa)
		drop aa
		
		bysort country id: egen aa = mean(pov_opm_SPM_2) if inrange(age,0,17)
		bysort country id: egen chpov_opm_SPM_2 = mean(aa)
		drop aa
	
		* OPM
		bysort country id: egen aa = mean(pov_opm) if inrange(age,0,17)
		bysort country id: egen chpov_opm = mean(aa)
		drop aa
		
		
		* Absolute
		bysort country id: egen aa = mean(pov_abs) if inrange(age,0,17)
		bysort country id: egen chpov_abs = mean(aa)
		drop aa
		
		** Child Poverty by Age **
		bysort country id: egen aa = mean(poverty) if inrange(age,0,5)
		bysort country id: egen chpov_age05 = mean(aa)
		drop aa
		
		bysort country id: egen aa = mean(poverty) if inrange(age,6,11)
		bysort country id: egen chpov_age611 = mean(aa)
		drop aa
		
		bysort country id: egen aa = mean(poverty) if inrange(age,12,17)
		bysort country id: egen chpov_age1217 = mean(aa)
		drop aa
		
		* Add new Age Bins for the R&R:
		bysort country id: egen aa = mean(poverty) if inrange(age,10,10)
		bysort country id: egen chpov_age10 = mean(aa)
		drop aa
		
		bysort country id: egen aa = mean(poverty) if inrange(age,10,17)
		bysort country id: egen  chpov_age1017 = mean(aa)
		drop aa
		
		

		* Pov: 25, 50% Threshold
			bysort year country : egen med_inc = median(hh_net_inc_eq)
			gen povthresh = .50 * med_inc
			foreach q in 25 50 100 {
				gen poverty_`q' = hh_net_inc_eq < (povthresh * (`q'/100) )
				gen poverty_pre_trans_`q' = hh_net_inc_eq < (povthresh * (`q'/100) )
			}
			
		gen rtn_pre = hh_inc_pretax_eq / opmthresh
		gen rtn_post = hh_net_inc_eq / opmthresh
		
		* Ranks
		foreach q in rtn_pre rtn_post {
			
			bysort country id: egen m_`q'_cha = mean(`q') if inrange(age,0,17)
			bysort country id: egen m_`q'_ch = mean(m_`q'_cha) 
				drop m_`q'_cha
				gen log_m_`q'_ch = log(m_`q'_ch)
				
			bysort country id: egen m_`q'_cha = mean(`q') if inrange(age,$minage,$maxage)
			bysort country id: egen m_`q'_ad = mean(m_`q'_cha) 
				drop m_`q'_cha	
				gen log_m_`q'_ad = log(m_`q'_ad) 	
		}
		
	
		
		* Extent of Exposure: P_c^Ch= P_c^Hi+ P_c^Med + P_c^Lo
			
			gen chpov_ext_hi = inrange(chpov,.330001,1)
			gen chpov_ext_med = inrange(chpov,.0001,.330001) 
			gen chpov_ext_lo =  inrange(chpov,0,0)
		
		* Poverty in Young Adulthood
			
			* OPM Line with SPM Components:
			bysort country id : egen aa = mean(pov_opm_SPM) if inrange(age, minage, maxage) 
				bysort country id : egen pov_opm_SPM_2535 = mean(aa) 
				cap drop aa
			
			bysort country id : egen aa = mean(pov_opm_SPM_2) if inrange(age, minage, maxage) 
				bysort country id : egen pov_opm_SPM_2_2525 = mean(aa) 
				cap drop aa
			
			* OPM with PSID Xfers:
			
			bysort country id : egen poverty_opm_2535a_pre = mean(pov_opm_pre) if inrange(age, minage, maxage) 
				bysort country id : egen poverty_opm_pre_2535 = mean(poverty_opm_2535a_pre) 
				cap drop poverty_opm_2535a_pre
			
			bysort country id : egen poverty_opm_2535a = mean(pov_opm) if inrange(age, minage, maxage) 
				bysort country id : egen poverty_opm_2535 = mean(poverty_opm_2535a) 
				cap drop poverty_opm_2535a
			
			bysort country id : egen poverty_abs_2535a = mean(pov_abs) if inrange(age, minage, maxage) 
				bysort country id : egen poverty_abs_2535 = mean(poverty_abs_2535a) 
				cap drop poverty_abs_2535a
			
			bysort country id : egen poverty_2426a = mean(poverty) if inrange(age, minage, maxage) 
				bysort country id : egen poverty_2426 = mean(poverty_2426a) 
				cap drop poverty_2426a
				
			bysort country id : egen prett_poverty_2426a = mean(poverty_pre_transf) if inrange(age, minage, maxage) 
				bysort country id : egen prett_poverty_2426 = mean(prett_poverty_2426a) 
				cap drop prett_poverty_2426a
				
				* Deep Pov:
				foreach q in 25 50 100 {
				bysort country id : egen poverty_2426a = mean(poverty_`q') if inrange(age, 0, 17) 
				bysort country id : egen chpov_`q' = mean(poverty_2426a) 
				cap drop poverty_2426a
				
				bysort country id : egen poverty_2426a = mean(poverty_`q') if inrange(age, minage, maxage) 
				bysort country id : egen poverty_`q'_2426 = mean(poverty_2426a) 
				cap drop poverty_2426a
				
				bysort country id : egen prett_poverty_2426a = mean(poverty_pre_trans_`q') if inrange(age, minage, maxage) 
					bysort country id : egen prett_poverty_`q'_2426 = mean(prett_poverty_2426a) 
					cap drop prett_poverty_2426a
				}

		*************************
		*** Employment           ***
		************************
		* Full Time
			gen fulltime = hours_worked_week>30 & hours_worked_week!=. 
			replace fulltime = . if mi(hours_worked_week)
	
		
		* Others' Employment: binary, whether other unemployed
			gen emp_others = .
				replace emp_others = 0 if hh_labor_inc!=.
				replace emp_others = 1 if (ind_labor_earn < hh_labor_inc) & hh_labor_inc>0 & hh_labor_inc!=.
				
		*********************
		* Weights:
		********************

			* Weights
			bysort country id : egen weight_cha = mean(W11101) if inrange(age, 0,17) 
				bysort country id : egen weight_ch = mean(weight_cha) 
				cap drop weight_cha
				
		* Normalize weights so that each calendar year has same total weight
		gen weight_ch_norm = .

		* Step 1: compute total weight by year
		bysort year: egen sum_w = total(weight_ch)

		* Step 2: compute average total weight across all years
		summ sum_w, meanonly
		scalar target = r(mean)

		* Step 3: rescale within each year so all years hit target
		gen double factor = target / sum_w
		bysort year: replace weight_ch_norm = weight_ch * factor


		
			* Long Weights:
			cap drop weight_long
			gen weight_long = .
				replace weight_long = W11103 
		
			
		*********************
		* Misc:
		********************
			
				
		* Health / Disab.
		gen disability = M11124==1
		gen health_selfrate = M11126
	
	cap drop _merge
	cd "$data"
		merge m:m x11101ll year using psid_merge.dta
			drop if _merge==2
		
		*** PSID VARIABLE CREATION ***
		gen union = psid_emp16V1==1 | psid_emp16V2==1 | psid_emp16V3==1 | psid_emp17==1
			replace union = . if psid_emp16V1==. & psid_emp16V2==. & psid_emp16V3==. & psid_emp17==.
		xtile wealth_decile = psid_wlt02, nq(10)
			replace wealth_decile = . if psid_wlt02==.
		gen homeowner = psid_prp01==1
			replace homeowner =. if psid_prp01==. 
		gen health_sr = psid_hlt10
			replace health_sr = . if psid_hlt10==.
		gen health_asthhbp = psid_hlt01==1 | psid_hlt02==1
			replace health_asthhbp = . if psid_hlt01==. & psid_hlt02==. 
		gen incarc = inrange(psid_crm01,1,3) | psid_crm02==1 
			replace incarc = . if psid_crm01 ==. &  psid_crm02==.
		gen foodinsecure = inrange(psid_foodinscat,3,4)
			replace foodinsecure = . if psid_foodinscat==.

			
	
	***************************************************************************
	* COLLAPSE
	***************************************************************************
	
	* Prepare Collapse Indicators
	*gen yessample = obsage_05!=0 & obsage_610!=0 & obsage_1117!=0 & obsage_2535>1 & obsage_2535!=. & inrange(age,minage,maxage)
	gen yessample = obsage_05!=0 & obsage_610!=0 & obsage_1117!=0 & obsage_2535>1 & obsage_2535!=. & inrange(age,minage,maxage)
	bysort id: egen ever_yessample = max(yessample)
	save "$data\precollapse_predrop_usa", replace
	
	* Limit to people observed once in each childhood age class.
	*keep if obsage_05!=0 & obsage_610!=0 & obsage_1117!=0
	keep if (obsage_610!=0 & obsage_1117!=0) | (obsage_05!=0 & obsage_1117!=0) 
	keep if tot_chobs>4
	
	* Limit to people observed at least three times in adulthood ages:
	keep if obsage_2535>2 & obsage_2535!=.
	
	
	* Mean Values:
	global keep_mean years_of_edu single_adult_hh share_child_nomale share_child_nofemale share_child_noadult ind_labor_earn hours_worked_week hourly_wage high_school female employ_mom employ_dad edu_attain_mom edu_attain_dad dummy_employed child_under_uniqueadult child_under_marriage  avg_num_child age_of_mom_at_birth     fulltime  health_selfrate age_max prett_poverty_2426 exposure_to_poverty_pre living_child_head hh_nchild hh_npers married hh_nchild_u5 head_hh      weight_long poverty_25_2426 prett_poverty_25_2426  poverty_50_2426 prett_poverty_50_2426  ///
	log_m_rtn_pre_ch log_m_rtn_pre_ad log_m_rtn_post_ch log_m_rtn_post_ad pov_parents  povline_abs pov_abs  poverty_abs_2535 poverty_opm_pre_2535 poverty_opm_2535 m_rtn_post_ch weight_ch_norm   pov_opm_SPM_2535 pov_opm_SPM_2_2525 ///
	union wealth_decile homeowner health_sr foodinsecure rank_ad_hh_inc_pretax_eq rank_ad_hh_net_inc_eq rank_ch_hh_inc_pretax_eq rank_ch_hh_net_inc_eq  m_hh_net_inc_eq_ch m_hh_net_inc_eq_ad m_hh_inc_pretax_eq_ch m_hh_inc_pretax_eq_ad P11101
	
	* Max Values
	global keep_max bachelor edu_somecollege edu_hsdegree disability single_parent  id_head_childhood age ///
		rwhite rblack rhisp rasian rother  ///
		first_age_obs obsage_05 obsage_610 obsage_1117 partner_college emp_others ///
		edu_college 
		

	*rafa 05/03 - added this so that I can use your processed dataset without rerunning everytime
	save "$data\precollapse_usa", replace
	keep if inrange(age,minage,maxage)	
	
	collapse  (mean) $keep_mean weight_ch year_age25 poverty_2426 exposure_to_poverty low_exp high_exp medium_exp  chpov* ///
				(max) $keep_max		, by( country id)
		
	* Bonus Vars:	
	gen year = year_age25 // rename var.	 
	
	*rafa 05/03 - added this so that I can use your processed dataset without rerunning everytime
	save "$data\postcollapse_usa", replace
	save "$data\data_ready_usa", replace // zp
	

	