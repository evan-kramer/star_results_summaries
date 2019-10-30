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
  # LEA and school name
  n_distinct(star_scores$lea_code, star_scores$school_code)
  n_distinct(star_scores$school_name)
  
  # STAR score change
  
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
  student_groups = student_group_scores$student_group[student_group_scores$school_name == sch]
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






# Which schools dropped most? Why?
readxl::read_excel(
  "Year over Year STAR Data for Analysis_v2 10.24.xlsx",
  sheet = "STAR Scores"
) %>% 
  janitor::clean_names() %>% 
  arrange(star_score_differences) %>% 
  filter(row_number() <= 5) %>% 
  select(
    ends_with("_code"), ends_with("_name"), 
    star_score_difference = star_score_differences,
    star_score_2019 = x2019_star_score, 
    star_score_2018 = x2018_star_score
  ) %>% 
  # List of schools that declined most 
  print() %>% 
  select(-ends_with("_name")) %>% 
  left_join(
    readxl::read_excel(
      "Year over Year STAR Data for Analysis_v2 10.24.xlsx",
      sheet = "STAR Student Group Scores"
    ) %>% 
      janitor::clean_names(),
    by = c("lea_code", "school_code")
  )

# For the 5 biggest losers, which student groups and metrics dropped most? 
# readxl::read_excel(
#   "Year over Year STAR Data for Analysis_v2 10.24.xlsx",
#   sheet = "STAR Scores"
# ) %>% 
#   janitor::clean_names() %>% 
#   arrange(star_score_differences) %>% 
#   filter(row_number() <= 5) %>% 
#   left_join(
#     readxl::read_excel(
#       "Year over Year STAR Data for Analysis_v2 10.24.xlsx",
#       sheet = "STAR Student Group Scores"
#     ) %>% 
#       janitor::clean_names(),
#     by = c("lea_code", "school_code")
#   ) %>% 
#   arrange(student_group_score_diff) 

