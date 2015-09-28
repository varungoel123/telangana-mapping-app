library(RPostgreSQL)
library(dplyr)
library(magrittr)
library(stringr)

#setwd("~/Documents/ResRA/main_app_v1/data/")
source("./db_details.R") # contains confidential db details

# loads the PostgreSQL driver
drv <- dbDriver("PostgreSQL")
# creates a connection to the postgres database
# note that "con" will be used later in each connection to the database


dbDisconnect(con)

con <- dbConnect(drv, dbname = dbname,
                 host = host, port = 5432,
                 user = username, password = pw)

file_list <- dir("./data",pattern = ".csv$")[-1]
#file_list = "variables_telangana_rkvy_12_14_district.csv" 
for (i in seq(file_list)){
dbWriteTable(con, str_replace_all(file_list[i],".csv",""),
             assign(str_replace_all(file_list[i],".csv",""),
                    read.csv(paste("./data",file_list[i],sep="/"))))
}

#### drop all tables in db with DROP SCHEMA public cascade;
### then use CREATE SCHEMA public;
### SHORTEN SOME NAMES: EG hierarchy_lookup_telangana_fertilizer_dealers_till_2013_district


