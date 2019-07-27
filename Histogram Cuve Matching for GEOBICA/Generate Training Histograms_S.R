# Increase the JVM heap size in rJava's options support
# Note that this step must be performed prior to loading any packages.
options(java.parameters = "-Xmx4000m")

library(readxl)
library(xlsx)

# set a temporary directory (for this project only)
setwd("C:/Users/Y/Google Drive/JY/Data Analysis/R Scripts")

# read.dbf(file, as.is = FALSE)

# set up a list for all LU transitions classes
# LU <- c("cNoChangedRES","UNDEVtoRES","cNoChangedIND","UNDEVtoIND","cNoChangedCOM","UNDEVtoCOM") #TEST_LU for Preliminary Study
# LU <- c("UNCIL","UNRES","UNTRANS") #TRANS_GALU
LU <- c("UNRAD","UNFWY","UNCOM","UNLIND","UNSCH","UNMFR","UNSFR") #TRANS_SALU

band <- c("diffRED") #specify a difference waveband

# read xlsx files
MEAN = list()
i = 1
j = 1
df <- NULL
for (b in band){
  for (n in LU){
    file <- paste("C:/Users/Y/Google Drive/JY/Data Analysis/R Scripts/2.Select Training Histogram/",b,"/NHi_",n,"_",b,sep='',".xlsx")
    df <- read_excel(file,2)
    
    # Calculate total number of pixels in each ROI
    Total_Pixels=NULL
    for(t in 3:ncol(df)){
      df[,t] = df[,t]/sum(df[,t])
    }
    
    # Calculate mean at each bin
    avg = apply(df[,3:ncol(df)],1,mean)
    
    
    # # Output normalized histograms per class
    # if ( n == "UNSFR" | n == "UNRES"){
    #   file <- paste("C:/Users/Y/Google Drive/JY/Data Analysis//R Scripts/5.Normalized Histograms/NHi_",n,"_",b,sep='',".csv")
    #   write.csv(df, file, row.names = FALSE)
    #   gc()
    # }
    # # else{
    #   file <- paste("C:/Users/Y/Google Drive/JY/Data Analysis//R Scripts/5.Normalized Histograms/NHi_",n,"_",b,sep='',".xlsx")
    #   write.xlsx(df, file)
    #   gc()
    # # }
    
    # and append each avg to a list
    MEAN[[i]] <- avg
    i = i + 1 #indexing MEAN

    }

    # format output tables # flip a list
    fMEAN = do.call(cbind, MEAN)
    fMEAN <- cbind(df[2], MEAN)
    
    # rename each column
    # names(fMEAN) <- c("DN(bin)","UNCIL","UNRES","UNTRANS")      #TRANS_GALU
    names(fMEAN) <- c("DN(bin)","UNRAD","UNFWY","UNCOM","UNLIND","UNSCH","UNMFR","UNSFR")      #TRANS_SALU
    
    # export all training histogramsto an xlsx
    file <- paste("C:/Users/Y/Google Drive/JY/Data Analysis//R Scripts/4.Generate Training Histograms/TNH_",b,sep='',".xlsx")
    write.xlsx(fMEAN, file, row.names = FALSE)

} # ---end for-loop---