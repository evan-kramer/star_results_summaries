# STAR Call Prep
# Evan Kramer

# Set up
options(java.parameters = "-Xmx16G")
library(tidyverse)
library(lubridate)
library(haven)
setwd("C:/Users/evan.kramer/Downloads")
data = T
analysis = T
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
  for(sch in sort(unique(star_scores$school_name))[1:3]) {
  }
  
  # LEA and school name
  n_distinct(star_scores$lea_code, star_scores$school_code)
  n_distinct(star_scores$school_name)
  
  # STAR score change (and relative performance)
  transmute(
    star_scores, 
    school_name, 
    pctile = round(100 * percent_rank(star_score_differences))
  )
  
  # Number of frameworks
  frameworks = framework_scores$school_framework[framework_scores$school_name == sch]
  unique(
    case_when(
      length(frameworks) == 1 ~ str_c(
        case_when(
          str_detect(frameworks, "Alt") | str_detect(frameworks, "Elem") ~ "an ",
          T ~ "a " 
        ),
        framework_scores$school_framework[framework_scores$school_name == sch],
        " framework only"
      ),
      length(frameworks) == 2 ~ str_c(
        "both ",
        frameworks[1],
        " and ",
        frameworks[2],
        " frameworks"
      )
    ) 
  )
  
  # Framework performance
  filter(framework_scores, school_name == sch) %>% 
    transmute(
      `School Name` = school_name,
      `Framework` = school_framework,
      `Framework Points (Current)` = round(x2019_framework_points_earned, 2),
      `Framework Points (Prior)` = x2018_framework_points_earned,
      `Framework Points Possible (Current)` = x2019_framework_points_possible,
      `Framework Points Possible (Prior)` = x2018_framework_points_possible
    ) 
  
  # Student group performance
  student_group_scores$student_group[student_group_scores$school_name == sch]
  filter(student_group_scores, school_name == sch) %>% 
    arrange(student_group_score_diff) %>%
    transmute(
      `School Name` = school_name, 
      `Student Group` = student_group,
      `Student Group Points (Current)` = x2019_student_group_points_earned,
      `Student Group Points (Prior)` = x2018_student_group_points_earned,
      `Student Group Points Possible (Current)` = x2019_student_group_points_possible,
      `Student Group Points Possible (Prior)` = x2018_student_group_points_possible
    ) %>% 
    left_join(
      group_by(student_group_scores, student_group) %>% 
        summarize(`Student Group Points (Current State Average)` = mean(x2019_student_group_points_earned, na.rm = T)),
      by = c("Student Group" = "student_group")
    ) %>% 
    select(`School Name`, `Student Group`, 
           starts_with("Student Group Points ("), everything())
  
  # Metric performance
  # All students metric scores
  filter(metric_scores, str_detect(student_group, "All"), 
         school_name == sch) %>% 
    arrange(metric_points_difference) %>%
    transmute(
      `School Name` = school_name,
      `Metric` = metric,
      `Metric Points (Current)` = round(x2019_metric_points_earned, 2),
      `Metric Points (Prior)` = x2018_metric_points_earned,
      `Metric Points Possible (Current)` = x2019_metric_points_possible,
      `Metric Points Possible (Prior)` = x2018_metric_points_possible
    ) %>% 
    left_join(
      filter(metric_scores, student_group == "All Students") %>% 
        group_by(metric) %>% 
        summarize(`Metric Points (Current State Average)` = round(mean(x2019_metric_points_earned, na.rm = T), 2)),
      by = c("Metric" = "metric")
    ) %>% 
    select(`School Name`, Metric, 
           starts_with("Metric Points ("), everything())

  # Subgroup with biggest change? 
  group_by(student_group_scores, school_name) %>% 
    filter(school_name == sch & student_group_score_diff == max(student_group_score_diff, na.rm = T)) %>% 
    select(school_name, student_group) %>%
    left_join(
      metric_scores, 
      by = c("school_name", "student_group")
    )
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

