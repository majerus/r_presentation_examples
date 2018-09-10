# Springboard Rise - Demo 1
# 9/8/2018

# load packages
library(tidyverse)
library(RSQLite)
library(DBI)
library(knitr)
library(plotly)

# load ipeds data on american colleges
source("load_data.r")

# create db connection
con <- DBI::dbConnect(RSQLite::SQLite(), path = ":dbname:")

# put some data in db
copy_to(dest = con,
        df = colleges,
        name = "colleges",
        temporary = FALSE)

# let's reference our table
tbl(con, "colleges")

# use dplyr to build a query
tbl(con, "colleges") %>% 
  select(name, apps16) %>% 
  filter(apps16 >= 10000) %>%  
  arrange(desc(apps16))

# let's do that again
tbl(con, "colleges") %>% 
  group_by(st, sector) %>%
  summarise(n = n()) 

# now let's collect our data 
df <- 
tbl(con, "colleges") %>% 
  group_by(st, sector) %>%
  summarise(n = n()) %>% 
  mutate(sector = ifelse(sector == "Private for-profit", "For-Profit", sector),
         sector = ifelse(sector == "Private not-for-profit", "Private", sector)) %>% 
  collect()

# table time
df %>% 
  spread(sector, n) %>% 
  DT::datatable()

# and now plots
plot <- 
  df %>% 
  ggplot(., aes(x = sector, y = n, fill = sector)) + 
  geom_bar(stat = "identity") + 
  facet_wrap(~st)

plot

# let's make that interactive! 
ggplotly(plot)

# disconnect from db
dbDisconnect(con)

