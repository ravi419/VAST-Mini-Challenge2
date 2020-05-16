## Read all csv files and write them into 1 single file
library(dplyr)
library(tidyverse)

# Find all .csv files
files <- dir("~/VAST_Challenge/MC2-Image-Data", recursive=TRUE, full.names=TRUE, pattern="\\.csv$")
DF <-  read.csv(files[1])
# Get the filename 
a <- tools::file_path_sans_ext(basename(files[1]))
# Append the filename as the first column of the DF
DF <- DF %>% add_column(filenames = a , .before = 1)

# For all he files repeat the same as above and append everything to the DF 
for (i in files[-1]){

  df <- read.csv(i)      # read the file
  a <- tools::file_path_sans_ext(basename(i))
  df <- df %>% add_column(filenames = a , .before = 1)
  DF <- rbind(DF, df)    # append the current file
}

# Writ it to the csv file
write.csv(DF, "~/VAST_Challenge/VAST-Mini-Challenge2/Data/Yolo_persons_appended.csv", row.names=FALSE, quote=FALSE)
