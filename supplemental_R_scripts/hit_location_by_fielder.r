library(tidyverse)
library(lubridate)

# read data file containing all batted balls for August 2020
batted_balls <- read_csv('data/lit-review-data/aug_2020_mlb_batted_balls.csv') %>% 
  mutate(hit_location= as.numeric(hit_location))

position_lookup <- tibble(hit_location= c(1:9),
                          position_name= c('pitcher', 'catcher', '1B', '2B', 
                                           '3B', 'SS', 'LF', 'CF', 'RF'),
                          position_location= c(rep('skin', times=6), rep('turf', times=3))
)

# plot the number of balls fielded by players who typically stand on the skin vs
# outfielders; there are some missing data but can't tell why they don't have 
# an attribute of who fielded the ball. Filter out strikeouts which aren't batted 
# balls but are still recorded as putouts for the catcher. This includes both 
# hits and outs. 
batted_balls %>%
  select(type, bb_type, hit_location) %>% 
  left_join(position_lookup) %>% 
  filter(type != 'S') %>% 
  drop_na() %>% 
  ggplot(aes(y= position_location))+
  geom_bar()

# It's about equally split between the three outfielders and everyone else  