library(readxl)
library(xlsx)

# set a temporary directory (for this project only)
# set up a filename list
# LU <- c("cNoChangedRES","UNDEVtoRES","cNoChangedIND","UNDEVtoIND","cNoChangedCOM","UNDEVtoCOM") #TEST_LU for Preliminary Study
# LU <- c("UNCIL","UNRES","UNTRANS") #TRANS_GALU
LU <- c("UNRAD","UNFWY","UNCOM","UNLIND","UNSCH","UNMFR","UNSFR") #TRANS_SALU

# band <- c("diffNIR", "diffRED")
band <- c("diffRED")

# import testing histograms
H_diffNIR = list()
H_diffRed = list()
k = 1 # initialize an index in datalist
w = 1

for (b in band){
  for (n in LU){
  # read testing histograms
    file <- paste("C:/Users/Y/Google Drive/JY/Data Analysis/R Scripts/3.Testing Histograms/",b,"/ZonalHi_",n,sep='',".xlsx")
    df <- read_excel(file,1)

  # Calculate total number of pixels in each ROI
    Total_Pixels=NULL
    for(t in 3:ncol(df)){
      df[,t] = df[,t]/sum(df[,t])
    }
  
  # import template histograms (th)
  file <- paste("C:/Users/Y/Google Drive/JY/Data Analysis/R Scripts/4.Generate Training Histograms/TNH_",b,sep='',".xlsx")
  th <- read_excel(file, sheet = 1, col_names = TRUE, col_types = NULL)#Mean

  # Histogram Curve Matching --- UNRAD_AVG
  HMRSSDA=NULL
  OBJECTID=NULL
  for(i in 3:ncol(df)){
    HMRSSDA[i-2] = 1 - (sum((df[,i]-th[2])^2)^0.5)
    OBJECTID[i-2] = i-2
  }
  HMRSSDA2 <- rbind(OBJECTID,HMRSSDA)

  # Histogram Curve Matching --- UNFWY_AVG
  for(i in 3:ncol(df)){
    HMRSSDA[i-2] = 1 - (sum((df[,i]-th[3])^2)^0.5)
  }
  HMRSSDA3 <- rbind(HMRSSDA2,HMRSSDA)

  # Histogram Curve Matching --- UNCOM_AVG
  for(i in 3:ncol(df)){
    HMRSSDA[i-2] = 1 - (sum((df[,i]-th[4])^2)^0.5)
  }
  HMRSSDA4 <- rbind(HMRSSDA3,HMRSSDA)

  # Histogram Curve Matching --- UNLIND_AVG
  for(i in 3:ncol(df)){
    HMRSSDA[i-2] = 1 - (sum((df[,i]-th[5])^2)^0.5)
  }
  HMRSSDA5 <- rbind(HMRSSDA4,HMRSSDA)

  # Histogram Curve Matching --- UNSCH_AVG
  for(i in 3:ncol(df)){
    HMRSSDA[i-2] = 1 - (sum((df[,i]-th[6])^2)^0.5)
  }
  HMRSSDA6 <- rbind(HMRSSDA5,HMRSSDA)

  # Histogram Curve Matching --- UNMFR_AVG
  for(i in 3:ncol(df)){
    HMRSSDA[i-2] = 1 - (sum((df[,i]-th[7])^2)^0.5)
  }
  HMRSSDA7 <- rbind(HMRSSDA6,HMRSSDA)
  
  # Histogram Curve Matching --- UNSFR_AVG
  for(i in 3:ncol(df)){
    HMRSSDA[i-2] = 1 - (sum((df[,i]-th[7])^2)^0.5)
  }
  HMRSSDA8 <- rbind(HMRSSDA7,HMRSSDA)

  # Output
  if (b == "diffNIR"){
    H_diffNIR[[k]] <- t(HMRSSDA8) # flip a matrix
    k = k + 1
  }
  else if (b == "diffRED"){
    H_diffRed[[w]] <- t(HMRSSDA8) # flip a matrix
    w = w + 1
  }
  
  
  }# ---end for-inner-loop---
  
  
if (b == "diffNIR"){
  # names(H_diffNIR) <- c("UNCIL","UNRES","UNTRANS")      #TRANS_GALU
  names(H_diffNIR) <- c("UNRAD","UNFWY","UNCOM","UNLIND","UNSCH","UNMFR","UNSFR")      #TRANS_SALU
  
  # initialize the first excel sheet output
  file <- paste("C:/Users/Y/Google Drive/JY/Data Analysis/R Scripts/6.HMRSSDA/All_",b,sep='',".xlsx")
  write.xlsx(H_diffNIR[1], file, sheetName = names(H_diffNIR[1]), col.names = TRUE, row.names = FALSE, append = FALSE)

  # append the outputs to mutiple sheets in a single excel file
  j = 2
  for (g in 2:length(H_diffNIR)){
    n <- names(H_diffNIR[j])
    write.xlsx(H_diffNIR[g], file,
               sheetName = n, col.names = TRUE, row.names = FALSE, append = TRUE)
    j = j + 1
  }

}

else if (b == "diffRED"){
  # names(H_diffRed) <- c("UNCIL","UNRES","UNTRANS")      #TRANS_GALU
  names(H_diffRed) <- c("UNRAD","UNFWY","UNCOM","UNLIND","UNSCH","UNMFR","UNSFR")      #TRANS_SALU

  # initialize the first excel sheet output
  file <- paste("C:/Users/Y/Google Drive/JY/Data Analysis/R Scripts/6.HMRSSDA/All_",b,sep='',".xlsx")
  write.xlsx(H_diffRed[1], file, sheetName = names(H_diffRed[1]), col.names = TRUE, row.names = FALSE, append = FALSE)

  # append the outputs to mutiple sheets in a single excel file
  v = 2
  for (g in 2:length(H_diffRed)){
    nm <- names(H_diffRed[v])
    write.xlsx(H_diffRed[g], file,
               sheetName = nm, col.names = TRUE, row.names = FALSE, append = TRUE)
    v = v + 1
  }
}
}# ---end for-outer-loop---




























