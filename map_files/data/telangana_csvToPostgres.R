library(RPostgreSQL)
library(dplyr)
library(magrittr)
library(stringr)

setwd("~/Documents/ResRA/main_app_v1/data/")
source("./db_details.R") # contains confidential db details
pw <- "resra@!$3"
dbname = "appdev_db"
host = "139.162.17.147"
username = "postgres"
# loads the PostgreSQL driver
drv <- dbDriver("PostgreSQL")
# creates a connection to the postgres database
# note that "con" will be used later in each connection to the database


dbDisconnect(con)

con <- dbConnect(drv, dbname = dbname,
                 host = host, port = 5432,
                 user = username, password = pw)

file_list <- "hierarchy_lookup_agcensus_05_crop_district.csv"
for (i in seq(file_list)){
dbWriteTable(con, str_replace_all(file_list[i],".csv",""),
             assign(str_replace_all(file_list[i],".csv",""),
                    read.csv(file_list[i])))
}

#### drop all tables in db with DROP SCHEMA public cascade;
### then use CREATE SCHEMA public;


