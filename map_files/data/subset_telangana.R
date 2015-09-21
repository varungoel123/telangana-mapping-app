library(dplyr)
library(magrittr)



setwd("~/Documents/ResRA/telangana-mapping-app/data/")
telangana_dist <- c(532,536,534,541,538,535,539,533,537,540)

for (i in dir(pattern = ".csv")){
  dat <- read.csv(i,header = T, stringsAsFactors = F) %>% filter(
    district_code %in% telangana_dist)
  write.csv(dat,paste("telangana",i,sep="_"),row.names = F)
}