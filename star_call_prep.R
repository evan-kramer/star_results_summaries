# STAR Call Prep
# Evan Kramer

# Set up
options(java.parameters = "-Xmx16G")
library(tidyverse)
library(lubridate)
library(haven)
library(knitr)
library(rmarkdown)
library(kableExtra)
setwd("X:/Accountability/School Year 2019-20/06 Analysis/Year by Year Analysis/")
data = F
analysis = F
output = F
compress = F
to_pdf = T

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
  if(star_scores$star_score_differences > 0) {
    metric_scores_table = arrange(metric_scores, metric_points_difference)
  } else {
    metric_scores_table = arrange(metric_scores, desc(metric_points_difference))
  }
  
  # All students
  filter(metric_scores_table, str_detect(student_group, "All"), 
         school_name == sch) %>%
    transmute(
      `School Name` = school_name,
      Framework = school_framework,
      `Metric` = metric,
      `Metric Points (Current)` = round(x2019_metric_points_earned, 2),
      `Metric Points (Prior)` = x2018_metric_points_earned,
      `Metric Points Possible (Current)` = x2019_metric_points_possible,
      `Metric Points Possible (Prior)` = x2018_metric_points_possible
    ) %>% 
    left_join(
      filter(metric_scores, student_group == "All Students") %>% 
        group_by(metric, school_framework) %>% 
        summarize(`Metric Points (Current State Average)` = round(mean(x2019_metric_points_earned, na.rm = T), 2)),
      by = c("Metric" = "metric", "Framework" = "school_framework")
    ) %>% 
    select(`School Name`, Framework, Metric, 
           starts_with("Metric Points ("), everything()) %>% 
    print()
  
  
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
    # for(sch in sort(unique(star_scores$school_name))) {
    for(sch in sort(unique(star_scores$school_name))[1:3]) {
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
      zip = "C:/Program Files/7-Zip/7Z" #Have to download 7-Zip program and point to it https://www.7-zip.org/download.html
    )
  }  
} else {
  rm(compress)
}

# Output to pdf
if(to_pdf) {
  if(!"star_scores" %in% ls()) {
    print("You sure you have the data for this?")
  } else {
    # Initiate loop for plots
    # for(sch in sort(unique(star_scores$school_name))) {
    (school_list = bind_rows(
      filter(star_scores, str_detect(school_name, "KIPP") & str_detect(school_name, "Promise")),
      filter(star_scores, str_detect(school_name, "Kimball") & str_detect(school_name, "Elem")),
      filter(star_scores, str_detect(school_name, "Payne") & str_detect(school_name, "Elem")),
      filter(star_scores, str_detect(school_name, "DC Prep") & str_detect(school_name, "Edgewood Middle")),
      filter(star_scores, str_detect(school_name, "Columbia Heights") & str_detect(school_name, "Educ")),
      filter(star_scores, str_detect(school_name, "Truesdell") & str_detect(school_name, "Educ")),
      filter(star_scores, str_detect(school_name, "Phelps") & str_detect(school_name, "Architecture")),
      filter(star_scores, str_detect(school_name, "DC") & str_detect(school_name, "Scholars")),
      filter(star_scores, str_detect(school_name, "Richard Wright") & str_detect(school_name, "Journalism"))
    ))
    if(nrow(school_list) == 9) {
      for(sch in school_list$school_name) {
        rmarkdown::render("C:/Users/evan.kramer/Documents/star_results_summaries/knit_loop_pdf.Rmd",
                          output_format = "pdf_document",
                          output_file = str_c(sch, " STAR Summary.pdf"),
                          output_dir = "C:/Users/evan.kramer/Downloads/star_summaries/PDF/")
      }
    } else {
      print("Wrong number of schools in list")
    }
  }
} else {
  rm(to_pdf)
}