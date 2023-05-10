library(randomizr)
library(foreign)
library(dplyr)

#Different randomization approaches with example data from Asunka et al (2019).
set.seed(1234)
#merge the data (copied from replication code)
dat <-read.dta("AsunkaEtAl_replication.dta")
ec <- read.dta("EC_data.dta")
d_sub1 <- merge(dat, ec, by="pscode")

data <- mutate(d_sub1,eovharass1=ifelse(eovharass1=="Yes",1,0),
               eovharass2=ifelse(eovharass2=="Yes",1,0), treatment=ifelse(observer=="Yes",1,0),
               competitive=ifelse(competition=="Competitive",1,0),
               urban=ifelse(stationdensity=="Rural",0,1))

data <- data[!is.na(data$treatment),] #remove missing rows

#Using this merged dataset, we will show how treatment *could* have been assigned

#First, using simple randomization where the prob argument sets the probability of treatment assignment for each row
data$ZSimple <- simple_ra(N = nrow(data), prob = 0.5)
sum(data$ZSimple)/nrow(data) #just over 50%.

#Next, complete randomization with half of the observations assigned to treatment:
data$ZComplete <- complete_ra(N = nrow(data), m = round(nrow(data)/2))
sum(data$ZComplete)/nrow(data) #As close to half as possible

#Implementing block randomization, blocking on the stationdensity variable
data$ZBlock <- block_ra(blocks = as.factor(data$stationdensity))
table(data$ZBlock, data$stationdensity) #balanced on rural and urban

#Implementing cluster random assignment, using the const variable as clusters
data$ZCluster <- cluster_ra(clusters = data$const)
table(data$const, data$ZCluster)

#Implementing blocked and clustered random assignment, blocking on stationdensity and clustering on const.
data$ZBlockCluster <- block_and_cluster_ra(blocks = as.factor(data$stationdensity),
                                           clusters = data$const)
table(data$ZBlockCluster, data$stationdensity)
table(data$const, data$ZBlockCluster)

#Implementing multi-stage using cluster randomization in stage one with three levels and then block randomization in the second stage. This is what is used in the actual study!
#First stage: cluster random assignment of const into saturation levels
data$s1 <- cluster_ra(clusters = data$const, conditions = c("low", "medium", "high"))
#set probability of treatment assignment by saturation
data$s1prob <- ifelse(data$s1 == "low", 0.3, ifelse(data$s1 == "medium", 0.5, 0.8))
#Get vector of probabilities of treatment assignment
blockprobs <- unique(as.data.frame(cbind(data$const, data$s1prob)))
blockprobs <- blockprobs[order(blockprobs$V1),]
#Second stage: use block randomization with probabilities from above
data$s2 <- block_ra(blocks = data$const, block_prob = c(as.numeric(blockprobs[,2])))
#check treatment by saturation level
table(data$s2, data$s1)

#Implementing stepped-wedge randomization

# For next steps: https://book.declaredesign.org/library/experimental-causal.html#stepped-wedge-experiments

#Implementing factorial design randomization

#For next steps: https://declaredesign.org/r/designlibrary/articles/factorial.html

#Implementing restricted randomization

# Maybe a while loop using RI? Randomizr help file might have an example.