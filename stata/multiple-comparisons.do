
* Last updated: 	April 04, 2023
* Version: 			Horace Gninafon
* Note: 			
********* Start here:

*===============================================================================

  clear all
  set more off
* Set path
  global path "C:\Users\Horace Gninafon\Documents\Hackathon\ReplicationFiles\01_Data"
  

import delimited "${path}\01_Survey\round_2_clean.csv"
ssc install qqvalue



 * 3. Destring variables of interest
local vars prob_shirt_oth_st prob_joke_st prob_meeting_st prob_vh_st prob_pungwe_st prob_testify_st tg_inv

foreach x of var `vars' { 
replace `x' = "" if `x' == "NA"
destring `x', replace	
}
	
gen General_Fear=(treat_assign=="TG")
replace General_Fear=. if treat_assign=="TP"
label val General_Fear General_Fear
label def General_Fear 1"TG" 0"CG"


reg prob_shirt_oth_st General_Fear [pweight=tg_inv], robust
test General_Fear, mtest(b)
test General_Fear, mtest(holm)


reg prob_joke_st General_Fear [pweight=tg_inv], robust
test General_Fear, mtest(b)
test General_Fear, mtest(holm)


reg prob_meeting_st General_Fear [pweight=tg_inv], robust
test General_Fear, mtest(b)
test General_Fear, mtest(holm)


reg prob_vh_st General_Fear [pweight=tg_inv], robust
test General_Fear, mtest(b)
test General_Fear, mtest(holm)


reg prob_pungwe_st General_Fear [pweight=tg_inv], robust
test General_Fear, mtest(b)
test General_Fear, mtest(holm)


reg prob_pungwe_st General_Fear [pweight=tg_inv], robust
test General_Fear, mtest(b)
test General_Fear, mtest(holm)



reg prob_testify_st General_Fear [pweight=tg_inv], robust
test General_Fear, mtest(b)
test General_Fear, mtest(holm)

qqvalue p, method(hochberg)

