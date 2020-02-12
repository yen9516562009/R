#QA Process of loading LEHD dataset in SQL query
#Jeff Yen
#11/20/2019



#Set up workspace
maindir = dirname(rstudioapi::getSourceEditorContext()$path)
setwd(maindir)

#Import functions
install.packages("here")
library(here)
source(here("Common_functions","readSQL.R"))
source(here("Common_functions","common_functions.R"))
source(here("Common_functions","config.R"))

#Import packages
packages <- c("RODBC","tidyverse","openxlsx","hash","plyr","devtools", "data.table")
pkgTest(packages)

#Initialize start time
sleep_for_a_minute <- function() { Sys.sleep(60) }
start_time <- Sys.time()

#Import Database Data
channel <- odbcDriverConnect('driver={SQL Server}; server=socioec; database=socioec_data; trusted_connection=true')
sql_query <- getSQL("../Queries/import_lodes.sql")
database_data <- sqlQuery(channel,sql_query,stringsAsFactors = FALSE)
odbcClose(channel)
gc() #release memory



####Import Source Data####
setwd("D:/LEHD/")
file_names <- dir(path = ".", pattern = ".csv")
s <- lapply(file_names, fread) #append each csv into a list

#and fliter it by w_geocode = "6073" (San Diego)
new_s = list()
k = 1
for (i in s){
  i$w_geocode <- as.character(i$w_geocode)
  i$h_geocode <- as.character(i$h_geocode)
  p = substr(i$h_geocode,1,4) == "6073" | substr(i$w_geocode,1,4) == "6073"
  i <- i[p,]
  new_s[[k]] = i
  k = k + 1
}

#Drop s and release memory
s <- NULL
i <- NULL
gc()

#Flip a list
source_data <- as.data.frame(do.call(rbind, new_s)) # or do in this way: source_data <- ldply(new_s, data.frame)

#check data structure
str(database_data)
str(source_data)



####Clean Data####
#Remove unnecessary columns from databased_data and source_data
database_data$type <- NULL
database_data$yr <- NULL
source_data$createdate <- NULL
gc()

#Rename the header of source_data based on database_data
all.equal(colnames(source_data), colnames(database_data)) #check all the inconsistencies of columnnames
names(source_data) <- colnames(database_data)
all.equal(colnames(source_data), colnames(database_data)) # should return TRUE

#Convert source_data$w_geoid and $h_geoid to character
source_data$w_geoid <- sapply(source_data$w_geoid,as.numeric)
source_data$h_geoid <- sapply(source_data$h_geoid,as.numeric)
gc() #release memory

#Sorting Data Frame
database_data <- database_data[order(database_data$w_geoid, database_data$h_geoid, database_data$S000, database_data$SA01, 
                                     database_data$SA02, database_data$SA03, database_data$SE01, database_data$SE02,
                                     database_data$SE03, database_data$SI01, database_data$SI02, database_data$SI03),]
gc() #release memory

source_data <- source_data[order(source_data$w_geoid, source_data$h_geoid, source_data$S000, source_data$SA01, 
               source_data$SA02, source_data$SA03, source_data$SE01, source_data$SE02,
               source_data$SE03, source_data$SI01, source_data$SI02, source_data$SI03),]
gc() #release memory

#Remove rownames (This works, but looking for other solutions to fix inconconsistency of rownames types)
rownames(source_data) <-NULL
rownames(database_data) <-NULL



####Check Data Types and Values####
#Check data types
str(database_data)
str(source_data)

#Compare files 
all(source_data == database_data) #chekc cell values only
all.equal(source_data, database_data) #chekc cell values and data types and will return the conflicted cells
identical(source_data, database_data) #chekc cell values and data types
which(source_data!=database_data, arr.ind = TRUE) #which command shows exactly which columns are incorrect


#Display running time of R code
end_time <- Sys.time()
end_time - start_time