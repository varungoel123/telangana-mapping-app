######## recode size class and social group variables
## 99 is all
library(car) ## recode package


##-------- recode hierarchy files -------------
file <- list.files(path = './data', pattern = "*hierarchy_lookup_tel_agcensus_11",full.names = T)[-c(2,6)]

for (i in seq(file)){
dd <- read.csv(file[i],stringsAsFactors = F)

dd$var_code[dd$level_code=="social_group"] <- recode(dd$var_code[dd$level_code=="social_group"], "'SCHEDULED CASTE'=1; 
'SCHEDULED TRIBES'=2; 'OTHERS'=3; 'INSTITUTIONAL'=4; 'ALL SOCIAL GROUPS'=99")
dd$var_code[dd$level_code=="size_class"] <- recode(dd$var_code[dd$level_code=="size_class"],"'Below 0.5'=11; '0.5-1.0'=12; '1.0-2.0'=21; 
'2.0-3.0'=31; '3.0-4.0'=32; '4.0-5.0'=41; '5.0-7.5'=42;
      '7.5-10.0'=43; '10.0-20.0'=51; '20.0 & ABOVE'=52; 'ALL CLASSES'=99")
write.csv(dd,file[i],row.names = F)
}

##--------- recode data files------------##
file <- list.files(path = './data', pattern = "^tel_agcensus_11",full.names = T)[-c(2,6)]

for (i in seq(file)){
  dd <- read.csv(file[i],stringsAsFactors = F)
  
  dd$social_group <- recode(dd$social_group, "'SCHEDULED CASTE'=1; 
'SCHEDULED TRIBES'=2; 'OTHERS'=3; 'INSTITUTIONAL'=4; 'ALL SOCIAL GROUPS'=99")
  dd$size_class <- recode(dd$size_class,"'Below 0.5'=11; '0.5-1.0'=12; '1.0-2.0'=21; 
'2.0-3.0'=31; '3.0-4.0'=32; '4.0-5.0'=41; '5.0-7.5'=42;
      '7.5-10.0'=43; '10.0-20.0'=51; '20.0 & ABOVE'=52; 'ALL CLASSES'=99")
  write.csv(dd,file[i],row.names = F)
}