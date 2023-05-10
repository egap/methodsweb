
* Last updated: 	May 10, 2023
* Version: 			
* Note: 
version 16			
********* Start here:
*===============================================================================

*Set path

clear all


global path "C:\Users\Horace Gninafon\Documents\GitHub\methodsweb\Types of Randomization"
use "${path}\Asunka et al. 2017\AsunkaEtAl_replication.dta", clear

* We use data from the paper "Electoral Fraud or Violence: The Effect of Observers on Party Manipulation Strategies" by Asunka et al. (2017). The replication data and code for this study can be accessed from: Replication Data for: Electoral Fraud or Violence: The Effect of Observers on Party Manipulation Strategies.

* Unique ID
isid pscode

* merge the two data set Asunka et al. 2017 used
merge 1:1 pscode using "${path}\Asunka et al. 2017\EC_data.dta", nogen

* We use data from the paper "Electoral Fraud or Violence: The Effect of Observers on Party Manipulation Strategies" by Asunka et al. (2017). The replication data and code for this study can be accessed from: Replication Data for: Electoral Fraud or Violence: The Effect of Observers on Party Manipulation Strategies.

* Unique ID
isid pscode

* merge the two data set Asunka et al. 2017 used
merge 1:1 pscode using "${path}\Asunka et al. 2017\EC_data.dta", nogen


* Simple randomization
set seed 123 
simple_ra Treatment, replace

* Simple randmization: Using the "prob" option in the "simple_ra" function allows you to specify the probability of being assigned to the treatment group as you can see bellow
set seed 123
simple_ra Treatment, replace prob(.4) 

* Simple randmization: If you want to have multiple treatment groups in your randomized controlled trial, you can use the "num_arms(#)" option in the "simple_ra" function. This option allows you to specify the number of treatment arms you want to have in your study. In the following example, we are having 4 treatment groups
set seed 123
simple_ra Treatment, replace num_arms(4)

 
**********************************
* Complete randomization
**********************************
* The "complete_ra" function of stata will allow you to perform a complete randomization. The syntax of this command is similar to the one used to perform the simple randomization: "simple_ra".

*To select a sample of 1000 polling stations from all the 2,310 polling stations, you can use the "sample" command. The syntax for this command is as follows:
set seed 123
complete_ra Treatment, m(1000) replace

* To perform a complete randomization in Stata for selecting 700 polling stations in the first group, 840 polling stations in the second group, and 770 polling stations in the third group, you can use the "complete_ra" function. Simply specify the desired group sizes using the "m_each()" option, where the total of "m_each" must equal the population size, which in this case is 200.
set seed 123
complete_ra Treatment, m_each(700 840 770) replace

**********************************
* Block randomization
**********************************
* The "block_ra" function of stata will allow you to perform a block randomization. The following syntax allows you to perform block randomization by randomly assigning individuals to treatment or control groups within each block. In this case, the blocks are the urban and rural areas.
set seed 123
block_ra Treatment, block_var(stationdensity) replace

* If you intend to have multiple treatment in each Block, you can perform the following syntax:
set seed 123
block_ra Treatment, block_var(stationdensity) num_arms(4) replace

**********************************
* Cluster assignment
*********************************

*Assuming that the constituencies (the variable renamed "const") are the clusters, we will use the "cluster_ra" function to perform a cluster randomization
set seed 123
cluster_ra Treatment_clust, cluster_var(const) 

tab Treatment_clust sat

**********************************
* Block and Cluster assignment
*********************************

* To perform block randomization by environment of residence (block) and constituency (cluster), you can use the following syntax. This will ensure that clusters are assigned to either the treatment or control group within each block (urban or rural), based on their residence environment.

set seed 232
block_and_cluster_ra Treatment_clust_block , block_var(stationdensity) cluster_var(const) replace




