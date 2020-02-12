#QA Process of loading CTPP dataset in SQL query
#Jeff Yen
#11/20/2019



### initialize the work environment ###
#set up workspace
maindir = dirname(rstudioapi::getSourceEditorContext()$path)
setwd(maindir)

#import functions
source("../../../../config.R")
source("../readSQL.R")
source("../common_functions.R")

#import packages
install.packages("here")
library(here)
source(here("Common_functions","readSQL.R"))
source(here("Common_functions","common_functions.R"))
source(here("Common_functions","config.R"))
packages <- c("RODBC","tidyverse","openxlsx","hash","plyr", "data.table", "here")
pkgTest(packages)

#initialize start time
sleep_for_a_minute <- function() { Sys.sleep(60) }
start_time <- Sys.time()
end_time <- Sys.time()



### loading data ###
#import database_data (2012-2016)
channel <- odbcDriverConnect('driver={SQL Server}; server=socioeca; database=socioec_data; trusted_connection=true')
# sql_query <- getSQL("../CTPP.sql")
sql_query <- getSQL("../Queries/CTPP.sql")
database_data <- sqlQuery(channel,sql_query,stringsAsFactors = FALSE)
odbcClose(channel)

#import source_data
setwd("D:/CTPP/")
file_names <- dir(path = ".", pattern = ".csv") #where you have your files
source_data <- do.call(rbind,lapply(file_names,fread)) #use data.table to batching reading large number of csv files
source_data <- as.data.frame(source_data)
gc() #release memory



### data cleaning ###
#remove columns from dataframes
database_data$ctpp_id <- NULL
source_data$SOURCE <- NULL

#rename dataframes headers
names(source_data) <- colnames(database_data)

#clean up est and num
source_data$moe <- gsub("[ ,/,',',*,+,-]","", source_data$moe)
source_data$est <- gsub("[ ,/,',',*,+,-]","", source_data$est)

#convert est and moe in source_data to numeric
source_data[,4:5] <- sapply(source_data[,4:5],as.numeric) #4:est, 5:moe
# gc() #release memory

#sort soruce_data and database_data
database_data <- database_data[order(database_data$geo_id, database_data$tbl_id, database_data$line_num, database_data$est, database_data$moe),]
source_data <- source_data[order(source_data$geo_id, source_data$tbl_id, source_data$line_num, source_data$est, source_data$moe),]
gc() #release memory

#remove rownames (This works, but looking for other solutions to fix inconconsistency of rownames typNULLes)
rownames(database_data) <-NULL
rownames(source_data) <- NULL



### Check Data Types and Values ###
#Check data types
str(source_data)
str(database_data)

# compare files
all(source_data == database_data) #chekc cell values only
all.equal(source_data, database_data) #chekc cell values and data types and will return the conflicted cells
identical(source_data, database_data) #chekc cell values and data types
which(source_data!=database_data, arr.ind = TRUE) #which command shows exactly which columns are incorrect

### display running time of R code ###
end_time - start_time