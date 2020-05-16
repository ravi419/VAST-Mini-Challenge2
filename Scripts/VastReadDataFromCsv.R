## Read all csv files and write them into 1 single file
library(dplyr)
library(tidyverse)
# processFile <- function(f) {
#   df <- read.csv(f)
#   # ...and do stuff...
#   combined_df <- rbind(combined_df,df)
#   file.info(f)$size # dummy result
# }
# processFile <- function(f) {
#   df <- read.csv(f)
#   # ...and do stuff...
#   b <- tools::file_path_sans_ext(basename(f)
#   df <- df %>% add_column(filenames = b , .before = 1)
#   file.info(f)$size # dummy result
#   DF <- rbind(DF,df)
# }




# Find all .csv files
files <- dir("~/VAST_Challenge/MC2-Image-Data", recursive=TRUE, full.names=TRUE, pattern="\\.csv$")
DF <-  read.csv(files[1])
a <- tools::file_path_sans_ext(basename(files[1]))
DF <- DF %>% add_column(filenames = a , .before = 1)
#result <- sapply(files[-1], processFile)
#files


for (i in files[-1]){

  df <- read.csv(i)      # read the file
  a <- tools::file_path_sans_ext(basename(i))
  df <- df %>% add_column(filenames = a , .before = 1)
  DF <- rbind(DF, df)    # append the current file
}
write.csv(DF, "~/VAST_Challenge/VAST-Mini-Challenge2/Data/Yolo_persons_appended.csv", row.names=FALSE, quote=FALSE)
# f <- data.frame(f)
# #writing the appended file  

# # Apply the function to all files.

# write.csv(result, "Models_appended.csv", row.names=FALSE, quote=FALSE)