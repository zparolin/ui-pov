
	
	*** IDEAS ****
	* Based on pre-TT income, # adults, # kids (by age), year, # adults employed
		* Simulate post-TT income by matching randomly with CPA ASEC in bin.
		* Get SPM income components and a new SPM income. 
	* Use SPM Thresolds all the way back with county IDs? Maybe later.
	
	* Set Paths
	
	display "`c(username)'"
			
	if "`c(username)'"== "parolin" { // Zachary
		global root_   "C:\Users\parolin\Dropbox\_Oxford\Papers\82_IGPovUSA"
	}
	
	if "`c(username)'"== "zachary.parolin" { // Zachary
		global root_   "C:\Users\zachary.parolin\Dropbox\_Oxford\Papers\82_IGPovUSA"
	}
	
	global data "$root_\data"
	global data_local "$data"
	global output "$root_\output"
	global home "$root_\dofiles" 
	global figs "$root_\output"
	global psidmerge "C:\Users\zachary.parolin\Dropbox\Family Room\ExpPov\Projects\Intergenerational Poverty\1_IGPov\output"

	stop
	**************************************************************
	
	** 0: Impute SPM Transfer Variables into PSID
		do "$home/dofile - 99 - cps asec transfer imputation - v2"
	
	
	** 1: Create Collapsed Dataset with Refined Indicators
		* The end of this file saves a local version of the collapsed dataset
		* Can skip this step if file is already created.
	
		cd "$home"
		do "dofile - 1 - usa - create vars - v2.do"
	
	**************************************************************
	* Start below if step 1 completed, data_ready.dta created.
	**************************************************************
	
	** 2: Base Analyses **
	
		* Open Ready Data:
			cd "$data_local"
			use data_ready_usa.dta, clear
			
			******************************************************************************************
			* SET GLOBALS
			cd "$home"
			do "dofile - x - globals.do" // must run to set globals, relevant for all analyses below.
			******************************************************************************************
	
		* 1: Start with descriptives in poverty rates for adults and children, pre and post TT. 
			
			do "{$home}\dofile - 2 - usa - trends in chpov and adpov.do"
				* Check for Full Sample AND Final Sample. Done.
					* Graphs show: pov rates by AGE and YEAR for final sample and full sample.
			
		* 2: Trends in IGPov by Definition
		
			do "{$home}\dofile - 2 - usa - trends.do"
		
		* FMTR Decomp
		
			
			/*
		
		* TABLE 3: Poverty in Adulthood and Childhood by Country
			cd "$home"
			do "dofile - 2 - Table 3.do"
			
		* TABLE 4: Pre-Tax/Transfer IG Pov w/ and w/o Family Background Controls
			cd "$home"
			do "dofile - 2 - Table 4.do"	
			
		* FIGURE 2: Benchmark Access
			cd "$home"
			do "dofile - 2 - Figure 2.do"
			
		* FIGURE 3: Benchmark Penalty
			cd "$home"
			do "dofile - 2 - Figure 3.do" 
			
		* FIGURE 4: Total Mediation
			cd "$home"
			do "dofile - 2 - Figure 4.do" 
			
		* FIGURE 5: Decomposition of IGPov
			cd "$home"
			do "dofile - 2 - Figure 5.do"	
			
		* FIGURE 6: Decomposition of IGPov - By Race and Place, USA
			cd "$home"
			do "dofile - 2 - Figure 6.do"	
			
	************************	
	** 3a: R&R Analyses **
	************************
	
		* PARENTAL POVERTY, AGE 25-35 *
			* Test how using parents' poverty from ages 25-35 affects analysis. 
			* (Var created in create vars.do: pov_parents)
		
			do "$home\dofile - RR - descriptives on Parental Poverty 2535.do"
			do "$home\dofile - RR - Figure 5 - with Parental Poverty 2535.do"
			
		* ALT ADULT AGES: 30-35 *
		
			do "$home\dofile - RR - prep data for 30 to 35.do"
			do "$home\dofile - RR - Figure 5 - Ages 30 to 35.do"	
			
		* POVERTY BY AGE OF CHILD: *
		
			* Table of Unconditional Associations
			* Decomposition By Age Group for US
			do "$home\dofile - RR - child poverty by age.do"
			
		* POVERTY EFFECT, CONDITIONAL INCOME: *	
		
		do "$home\dofile - RR - Figure 5 - controlling for childhood income.do"
		
		* DECOMPOSITION: CHPOV MEASURED AT AGE 10
		do "$home\dofile - RR - Figure 5 - chpov ages 10-12.do"
		
		* DECOMPOSITION: CHPOV MEASURED FROM AGES 10-17
		do "$home\dofile - RR - Figure 5 - chpov ages 10-17.do"
		
		* DECOMPOSITION: PRE-TT CHPOV AS ORIGINS
		do "$home\dofile - RR - Figure 5 - prett chpov as origin.do"
		
		* DECOMPOSITION: we add a control for parenthood (presence of children) into mediators list
		do "$home\dofile - RR - Figure 5 - no singpar in medlist.do"
			* ignore file name. 
		
		* REPRESENTATIVENESS?
		do "$home\dofile - RR - representativeness of sample.do"
	
	** 3b: Appendix Analyses **
	
		* Descriptive Statistics
		
		* Data Validation
			* Selective Attrition
				
				* Summary Table of Attrition
					* RPS files.
				
				* Reweighting
				cd "$home"
				do "dofile - 3 - attrition test - b - reweight.do"	
				
				* Estimates: Age 18-24
				cd "$home"
				do "dofile - 3 - attrition test - c - 2124.do"	
				
			* Equalizing Years
			* Equalizing Sample Sizes
			* Life-Cycle Bias
			* Intra vs. Intergen Poverty
		
		* Alt Poverty Measures
			* Absolute
			* 60%
		
		* DE Appendix:
			* East vs. West
			* Germany with Extended Mediators (fam BG, educ)	
				
		* US Appendix
				cd "$home"
				do "dofile - 3 - usa residual.do"		
			
		* UK Appendix:
			
			* Monthly or Annual vs. Monthly
				cd "$home"
				do "dofile - 3 - uk monthly.do"		
			
			
		**********************************************
		* ZP:
		* "dofile - 3 - alt inputs.do" // holding here.
		
        	