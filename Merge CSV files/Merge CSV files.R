library(plyr)
library(readr)

# set up workspace
setwd("G:/CoStar2019/")

# obtain Properties List from folder names
PT <- list.dirs(path = ".", full.names = FALSE, recursive = TRUE)

# remove first element from PT list
PT <- PT[- 1]

# list for number of rows
NR <- list()

# merge all csv files in each folder
for (dir in PT){
  myfiles = list.files(path = dir, pattern="*.csv", full.names = TRUE)
  dat_csv = ldply(myfiles, read_csv)
  
  file = paste("",dir, sep="",".csv")
  write.csv(dat_csv, file, row.names=FALSE)

  # calculate total # of rows in each merged property table (exclude header)
  NR[[dir]] <- nrow(dat_csv)-1
  
  # reset dat_csv by removing it
  rm(dat_csv)
}