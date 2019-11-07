# STAR Call Prep
# Evan Kramer

# Set up
options(java.parameters = "-Xmx16G")
library(tidyverse)
library(lubridate)
library(haven)
setwd("X:/Accountability/School Year 2019-20/06 Analysis/Year by Year Analysis/")
data = F
analysis = F
output = F
compress = T

# Data
if(data) {
  file = "Year over Year STAR Data for Analysis_v6.xlsx"
  star_scores = readxl::read_excel(
    file,
    sheet = "STAR Scores"
  ) %>% 
    janitor::clean_names()
  framework_scores = readxl::read_excel(
    file,
    sheet = "STAR Framework Scores"
  ) %>% 
    janitor::clean_names()
  student_group_scores = readxl::read_excel(
    file,
    sheet = "STAR Student Group Scores"
  ) %>% 
    janitor::clean_names()
  metric_scores = readxl::read_excel(
    file,
    sheet = "STAR Metric Scores"
  ) %>% 
    janitor::clean_names()
} else {
  rm(data)
}

# Analysis
if(analysis) {
  # Set sch object as test
  for(sch in sort(unique(star_scores$school_name))[1:3]) {
  }
  
  # Sandbox
  # Framework changes for specific group
  # Highlight just the metrics with the largest changes
  # Indicate whether they switched from attendance growth to 90% attendance
  # Add a metric score column
  # Separate multiple frameworks by section and highlight if framework weight changed
} else { 
  rm(analysis)
}

# Output 
if(output) {
  if(!"star_scores" %in% ls()) {
    print("You sure you have the data for this?")
  } else {
    # Initiate loop for plots
    for(sch in sort(unique(star_scores$school_name))) {
    # for(sch in sort(unique(star_scores$school_name))[1:3]) {
      # Reference RMD file
      rmarkdown::render("C:/Users/evan.kramer/Documents/star_results_summaries/knit_loop.Rmd",
                        output_format = "html_document",
                        output_file = str_c(sch, " STAR Summary.html"),
                        output_dir = "C:/Users/evan.kramer/Downloads/star_summaries/")
    }
  }
} else {
  rm(output)
}

# Zip files together
if(compress) {
  # Confirm that there are files to zip together
  if(length(list.files("C:/Users/evan.kramer/Downloads/star_summaries")) > 0) {
    zip(
      zipfile = "C:/Users/evan.kramer/Downloads/STAR Summaries.zip",
      files = "C:/Users/evan.kramer/Downloads/star_summaries",
      flags = " a -tzip",
      zip = "C:/Program Files/7-Zip/7Z" # Have to download 7-Zip program and point to it https://www.7-zip.org/download.html
    )
  }  
} else {
  rm(compress)
}