## agcensus 11 scraped AP data to usable format for telangana mapping app
library(dplyr)
library(magrittr)

datfiles <- dir(path = "./data/agcensus11_APrawfiles_renamed/",pattern = "*.csv")

for ( i in seq(datfiles))
{
  dat <- read.csv(paste0("./data/agcensus11_APrawfiles_renamed/",datfiles[i]), 
                  stringsAsFactors = F) %>% select(state_code, district_code, social_group,
                  size_class,7:ncol(.))
  write.csv(dat,paste0("./data/",datfiles[i]),row.names = F)
  
}