# load packages 
library(tidyverse)
library(leaflet)
library(DT)
library(plotly)
library(crosstalk)
library(htmltools)

# read in ipeds data on all american colleges (data from https://nces.ed.gov/ipeds/datacenter)
colleges <- read_csv("ipeds_data.csv")

# read in ipeds value labels for categorical variables 
labels <- read_csv("data_value_labels.csv")

# convert level values to labels ----
  # 1	Four or more years
  # 2	At least 2 but less than 4 years
  # 3	Less than 2 years (below associate)

colleges <- 
  labels %>% 
  filter(VariableName == "ICLEVEL (HD2016)") %>% 
  mutate(Value = as.numeric(Value)) %>% 
  select(-VariableName) %>% 
  rename(lvl = ValueLabel) %>% 
  full_join(colleges, c("Value" = "level")) %>% 
  select(-Value)


# convert control values to labels + filter to include only 4 year colleges ----
  # 1	Public
  # 2	Private not-for-profit
  # 3	Private for-profit

colleges <- 
  labels %>% 
  filter(VariableName == "CONTROL (HD2016)") %>% 
  mutate(Value = as.numeric(Value)) %>% 
  select(-VariableName) %>% 
  rename(sector = ValueLabel) %>% 
  full_join(colleges, c("Value" = "control")) %>% 
  select(id, name, lat, lon, everything(), -Value) %>% 
  filter(!is.na(sector)) %>% 
  filter(lvl == "Four or more years")

