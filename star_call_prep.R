# STAR Call Prep
# Evan Kramer

# Set up
options(java.parameters = "-Xmx16G")
library(tidyverse)
library(lubridate)
library(haven)
setwd("C:/Users/evan.kramer/Downloads")
data = T
analysis = F
output = T

# Data
if(data) {
  star_scores = readxl::read_excel(
    "Year over Year STAR Data for Analysis_v2 10.24.xlsx",
    sheet = "STAR Scores"
  ) %>% 
    janitor::clean_names()
  framework_scores = readxl::read_excel(
    "Year over Year STAR Data for Analysis_v2 10.24.xlsx",
    sheet = "STAR Framework Scores"
  ) %>% 
    janitor::clean_names()
  student_group_scores = readxl::read_excel(
    "Year over Year STAR Data for Analysis_v2 10.24.xlsx",
    sheet = "STAR Student Group Scores"
  ) %>% 
    janitor::clean_names()
  metric_scores = readxl::read_excel(
    "Year over Year STAR Data for Analysis_v2 10.24.xlsx",
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
} else { 
  rm(analysis)
}

# Output 
if(output) {
  if(!"star_scores" %in% ls()) {
    print("You sure you have the data for this?")
  } else {
    # Initiate loop for plots
    # for(sch in sort(unique(star_scores$school_name))) {
    for(sch in sort(unique(star_scores$school_name))[1:3]) {
      # Reference RMD file
      rmarkdown::render("C:/Users/evan.kramer/Documents/star_results_summaries/knit_loop.Rmd",
                        output_file = str_c(sch, "_star_summary.html"),
                        output_dir = "C:/Users/evan.kramer/Downloads")
    }
  }
} else {
  rm(output)
}

