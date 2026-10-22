* =============================================================================
* identify_mothers.do
*
* Identifies mothers and links them to their children within households in
* historical US full-count census data (IPUMS), one census year at a time.
* As written the loop runs for 1880; add further census years to the
* "foreach y in ..." list to process them.
*
* Folder layout (all under $maindir, set below):
*   extracts/    input: one full-count extract per year, e.g. 1880_100%.dta
*                (uses the variables serial, pernum, age, occ1950, momloc,
*                stepmom and momrule_hist)
*   clean_data/  output: mothers_<year>.dta
*   (a log file for each year is written to $maindir)
*
* The data are not included in this repository, so the code cannot be run
* as-is. It is shared as a code sample.
* =============================================================================

clear
set more off
cap log close
set logtype text


global maindir "PATH/TO/PROJECT/FOLDER"   // placeholder: set to your project folder
global rawdir "$maindir/extracts"
global datdir "$maindir/clean_data"

foreach y in 1880 {

log using "$maindir/clean_mothers_`y'_log.txt", replace

di "starting year `y'"
di "$S_TIME $S_DATE"

	** Define subsets of full count data so only working with ~5 mil observations at a time and keep households together
	
	use "$rawdir/`y'_100%.dta", clear
	
	summ serial
	local max_serial = r(max)
	local n1 = floor(_N/5000000)

	
	di `max_serial'
	di `n1'
	local n2 = `n1'-1

	local start1 = 1
	local end`n1' = `max_serial'

	di `start1'
	di `end`n1''

	
	** Define intermediate starting and ending observations
	forvalues i=1/`n2' {
		local end`i' = floor(`max_serial'/`n1')*(`i')
		local j=`i' + 1
		local start`j' = `end`i'' + 1
	}

	forvalues i=1/`n1' {
		di "Start / end `i'"
		di `start`i''
		di `end`i''
	}

	** Initialize clean dataset for particular year
	
	clear
	set obs 1
	gen year=.
	save "$datdir/mothers_`y'.dta", replace
	

	forvalues i=1/`n1' {
	
	di "Year `y', subgroup `i' of `n1'"
	di "$S_TIME $S_DATE"
	
	use "$rawdir/`y'_100%.dta", clear
	keep if serial>=`start`i'' & serial<=`end`i''
	gen ingroup = `i'
	gen popcheck = _N

	** Creating a variable to identify household head's occupation
	gen head_occ = occ1950 if pernum == 1


	bysort serial (pernum): replace head_occ = head_occ[_n-1] if missing(head_occ)
	bysort serial (pernum): replace head_occ = head_occ[_n+1] if missing(head_occ)	
	label values head_occ `: value label occ1950'

	
    ** Identifying mothers (version 1: whether a woman is a mother or not)
    gen x = (momloc != 0)
    egen check_x = count(x), by(serial)
    gsort serial -x

    gen x_id = 1 if x == 1 & serial != serial[_n-1]
    replace x_id = x_id[_n-1] + 1 if x == 1 & serial == serial[_n-1] & missing(x_id) & !missing(x_id[_n-1])

    summ x_id
    local max_id = r(max)

    forvalues i = 1/`max_id' {
        gen ztemp = momloc if x == 1 & x_id == `i'
        egen z`i' = mean(ztemp), by(serial)
        drop ztemp
    }

    gen mother_v1 =(pernum == z1)
    forvalues i = 2/`max_id' {
        replace mother_v1 =1 if pernum == z`i'
    }

    drop x check_x x_id z*
	
	
	** Creating mother_v2 to identify women who have stepchildren/adopted children
	
	gen is_child_with_nonbiomom = (stepmom != 0 & momloc != 0 & inrange(momrule_hist, 1, 7))

	preserve
		keep if is_child_with_nonbiomom
		gen child_momloc = momloc
		keep serial child_momloc
		rename child_momloc pernum
		gen is_nonbiomom = 1
		duplicates drop
		tempfile nonbiomom_list
		save `nonbiomom_list'
	restore

	merge m:1 serial pernum using `nonbiomom_list', nogen
	replace is_nonbiomom = 0 if missing(is_nonbiomom)

	gen mother_v2 = (is_nonbiomom == 1)


    ** Identify children by age for mother_v1
    
	forvalues a = 0/15 {
        gen x = (age == `a' & momloc != 0)
        egen check_x = count(x), by(serial)
        gsort serial -x

        gen x_id = 1 if x == 1 & serial != serial[_n-1]
        replace x_id = x_id[_n-1] + 1 if x == 1 & serial == serial[_n-1] & missing(x_id) & !missing(x_id[_n-1])

        summ x_id
        local max_id = r(max)

        forvalues i = 1/`max_id' {
            gen ztemp = momloc if x == 1 & x_id == `i'
            egen z`i' = mean(ztemp), by(serial)
            drop ztemp
        }

        gen mother_v1_`a' = (pernum == z1)
        forvalues i = 2/`max_id' {
            replace mother_v1_`a' = 1 if pernum == z`i'
        }

        drop x check_x x_id z*
    }
	
	
	** Identifying children by age for mother_v2 (where momloc!=0 and is_nonbiomom == 1) [stepmoms and mothers by adoption]
	
	forvalues a = 0/15 {
		gen x = (age == `a' & stepmom != 0 & momloc != 0 & inrange(momrule_hist, 1, 7))
		egen check_x = count(x), by(serial)
		gsort serial -x

		gen x_id = 1 if x == 1 & serial != serial[_n-1]
		replace x_id = x_id[_n-1] + 1 if x == 1 & serial == serial[_n-1] & missing(x_id) & !missing(x_id[_n-1])

		summ x_id
		local max_id = r(max)

    forvalues i = 1/`max_id' {
        gen ztemp = momloc if x == 1 & x_id == `i'
        egen z`i' = mean(ztemp), by(serial)
        drop ztemp
		
		}

    gen mother_v2_`a' = (pernum == z1 & is_nonbiomom == 1)
    forvalues i = 2/`max_id' {
        replace mother_v2_`a' = 1 if pernum == z`i' & is_nonbiomom == 1
		
		}

    drop x check_x x_id z*
	
	}
	
	** Identifying biological mothers by age: mother_v3_a

	
	forvalues a = 0/15 {
		gen x = (age == `a' & momloc != 0 & stepmom == 0 & inrange(momrule_hist, 1, 6))
		egen check_x = count(x), by(serial)
		gsort serial -x

		gen x_id = 1 if x == 1 & serial != serial[_n-1]
		replace x_id = x_id[_n-1] + 1 if x == 1 & serial == serial[_n-1] & missing(x_id) & !missing(x_id[_n-1])

		summ x_id
		local max_id = r(max)

    forvalues i = 1/`max_id' {
        gen ztemp = momloc if x == 1 & x_id == `i'
        egen z`i' = mean(ztemp), by(serial)
        drop ztemp
    }

    gen mother_v3_`a' = (pernum == z1)
    forvalues i = 2/`max_id' {
        replace mother_v3_`a' = 1 if pernum == z`i'
    }

    drop x check_x x_id z*
	}

	** Identifying the oldest biological child a mother has 
	
	gen is_biochild = (momloc != 0 & stepmom == 0 & inrange(momrule_hist, 1, 6))
	preserve
		keep if is_biochild
		gen mother_pernum = momloc
		rename age child_age
		keep serial mother_pernum child_age
		collapse (max) child_age, by(serial mother_pernum)
		rename mother_pernum pernum
		tempfile oldest_biochild
		save `oldest_biochild'
	restore

	merge m:1 serial pernum using `oldest_biochild', nogen
	rename child_age eldch_bio

	drop is_biochild

	** Creating an indicator, "bio_mom", if a woman has only biological children
	
	egen total_stepmom_roles = rowtotal(mother_v2_0 mother_v2_1 mother_v2_2 mother_v2_3 mother_v2_4 mother_v2_5 mother_v2_6 mother_v2_7 mother_v2_8 mother_v2_9 mother_v2_10 mother_v2_11 mother_v2_12 mother_v2_13 mother_v2_14 mother_v2_15)

	gen bio_mom = (total_stepmom_roles == 0)

	drop total_stepmom_roles

	replace bio_mom = 0 if is_nonbiomom == 1

	
	
	** Calculating mother's age at first birth
	
	gen age_at_fb = .
	replace age_at_fb = age - eldch_bio if !missing(eldch_bio)
	
	
	** Creating age cohorts
	
	gen age_cohort = ""

	replace age_cohort = "10-14" if age_at_fb >= 10 & age_at_fb < 15
	replace age_cohort = "15-19" if age_at_fb >= 15 & age_at_fb < 20
	replace age_cohort = "20-24" if age_at_fb >= 20 & age_at_fb < 25
	replace age_cohort = "25-29" if age_at_fb >= 25 & age_at_fb < 30
	replace age_cohort = "30-35" if age_at_fb >= 30 & age_at_fb <= 35

	label variable age_cohort "Age cohort based on age at first birth"

	encode age_cohort, gen(age_cohort_cat)
	drop age_cohort 
	rename age_cohort_cat age_cohort
	
	
    append using "$datdir/mothers_`y'.dta"
    save "$datdir/mothers_`y'.dta", replace

	}

	}


di "End"
di "$S_TIME $S_DATE"



