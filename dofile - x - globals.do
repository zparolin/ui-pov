	
	***************************************************************************
	* GLOBALS
	***************************************************************************	
	
	** BASE LIST
	
	global covar_basic age_max female first_age_obs obsage_05 obsage_610 obsage_1117 living_child_head
	
	global covar share_child_nomale  share_child_nofemale  employ_mom employ_dad ///
		edu_attain_mom edu_attain_dad ///
		child_under_uniqueadult   avg_num_child age_of_mom_at_birth 
		* age_of_dad_at_birth
		
// 	global covar_i	 i.industry_mom i.industry_dad 

// 	global covar_usa z_wealth_decile z_foodinsecure z_disability z_homeowner z_health_sr z_health_asthhbp z_incarc
	
	global medlist ///
		edu_hsdegree edu_college single_parent  fulltime  dummy_employed ///
		union married partner_college emp_others  health_selfrate
	
	
		** TREAT MISSINGS
		
		*Identify missings:
			foreach x in $covar_basic $covar $medlist  ///
			   {
				cap gen miss_`x' = mi(`x')
				replace `x' = 0 if mi(`x')
			}
			
		global miss_covar_basic miss_age_max miss_female miss_first_age_obs miss_obsage_05 miss_obsage_610 miss_obsage_1117 miss_living_child_head
		
		global miss_covar miss_share_child_nomale miss_share_child_nofemale ///
		miss_employ_mom miss_employ_dad miss_edu_attain_mom miss_edu_attain_dad ///
			miss_child_under_uniqueadult miss_avg_num_child miss_age_of_mom_at_birth 
			
// 			///
// 			miss_age_of_dad_at_birth ///
// 		  miss_industry_mom  miss_industry_dad 

		global miss_medlist ///
			miss_edu_hsdegree  miss_single_parent miss_fulltime miss_dummy_employed ///
				miss_married miss_partner_college miss_emp_others miss_edu_college miss_union
				
// 		global miss_covar_usa	miss_z_wealth_decile miss_z_foodinsecure miss_z_disability miss_z_homeowner miss_z_health_sr miss_z_health_asthhbp miss_z_incarc 
				
		*And now redefine the previous globals so that they include the missing dummies
		
		global covar_basic $covar_basic $miss_covar_basic
		
		global covar $covar $miss_covar
		
// 		global covar_usa $covar_usa $miss_covar_usa

		global medlist ///
			$medlist  $miss_medlist

	