library(xml2)
library(dplyr)
library(tidyverse)
library(ggplot2)


files <- dir("~/VAST_Challenge/Labeled_data", recursive=TRUE, full.names=TRUE, pattern="\\.xml$")
file_number = 0
DF <- tibble(
  filenames = character(),
  x = double(),
  y = double(),
  Width = double(),
  Height = double(),
  Label = character()
)

for(file in files){
  
  # print("File number: %s\t%s ", file_number, file)
  xmldoc <- read_xml(file, encoding = "utf-8", as_html = FALSE)
  l<- c()
  xml_value <- function(x) {
    result <- xmldoc %>% 
      xml_find_all(x) %>% 
      xml_text()
    return(result)
  }
  
  calculate_WandH <- function(max_value,min_value){
    for( i in 1:length(max_value)) {
      result <- max_value[[i]] - min_value[[i]]
      l <- c(l,result)
    }
    return(l)
  }
  
  filenames <- tools::file_path_sans_ext(xml_value(".//filename"))
  Label <- xml_value(".//name")
  Xmin <- as.double(xml_value(".//xmin"))
  Ymin <- as.double(xml_value(".//ymin"))
  Xmax <- as.double(xml_value(".//xmax"))
  Ymax<- as.double(xml_value(".//ymax"))
  
  Width <- calculate_WandH(Xmax , Xmin)
  Height <- calculate_WandH(Ymax , Ymin)
  
  
  df <- tibble(filenames = filenames,x = Xmin, y = Ymin, Width = Width,Height = Height, Label = Label)
  
  DF <- rbind(DF, df)
  
  file_number = file_number + 1
  
}

PersonsRelatedObjs = DF  %>% mutate(Persons = str_replace(filenames, '_.*', '')) %>%  select(Persons, Label)
class(DF)


PersonsRelatedObjs %>% group_by(Label) %>% summarize(n = n())
PersonsRelatedObjs %>% count(Persons,Label)

ggplot(data = PersonsRelatedObjs,
       mapping = aes(x = Label, y = Persons)) +
  geom_point() + geom_smooth(method = "lm")

ggplot(PersonsRelatedObjs) + 
  geom_histogram(aes(x = Persons, fill = "steelblue" ))

PersonsRelatedObjs %>%
  ggplot(aes(x = Label)) +
  geom_bar(stat = "count") # default

PersonsRelatedObjs %>%
  ggplot(aes(x = Persons)) +
  geom_bar(stat = "coount") # default




by_Label <- DF %>% group_by(Label)



# Writ it to the csv file
# write.csv(DF, "~/VAST_Challenge/VAST-Mini-Challenge2/Data/Labeled_Yolo_persons_appended.csv", row.names=FALSE, quote=FALSE)


