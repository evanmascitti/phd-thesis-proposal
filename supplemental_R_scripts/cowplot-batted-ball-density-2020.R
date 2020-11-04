# This script uses a "dirty hack" to draw a plot and then draw an identical plot
# but with the data made invisible. The coordinates are identical; the only step
# needed to manually assemble the final figure is to use Illustrator or other
# vetor grapics editor to copy the "field_boundaries" file on top of the kernel
# density plot....then change the fill of the entire field_dimensions object to
# none. That will leave the paths and permit the colors to be seen. Then save
# the result as a new svg file. Finally, if you want to trim so the objects take
# up the whole space, you'll have to make a clipping mask or crop. Still haven't
# mastered the saving dimensions and the relation to the plot.background and
# panel.background

library(tidyverse)
library(baseballr)
library(extrafont)
library(ecmfuns)
library(balldensityplots)
library(cowplot)
loadfonts()

# write a function that plots only the field boundaries, plus a "dummy"
# stat_density_2d that is present but has alpha set to zero

# read the data file for all batted balls in 2020
batted_balls_2020 <- read_csv('data/lit-review-data/complete-2020-savant-data.csv') %>%
  filter(hc_x != 'null',
         hc_y != 'null') %>% 
  mutate(hc_x= as.double(hc_x),
         hc_y= as.double(hc_y)) %>%
  select(home_team, game_date, hc_x, hc_y) %>% 
  drop_na()

# set the number of total data points in a character vector object with length 1 
n_value <- scales::comma(length(batted_balls_2020$hc_x))


# make a kernel density plot of all the batted balls 
batted_balls_2020_plot <- batted_balls_2020 %>%
  ggspraychart_ecm(high_color =  "#940000")+
  labs(title= 'Kernel density of all MLB batted balls in 2020',
       caption = paste0('- Coordinates indicate where a ball was caught or first touched the ground. \n\n- Data shown for all balls in play during 2020 season (n = ', n_value, '; source: MLB Statcast).'),
       fill= 'Density')+
  theme_ballfield()


# print the plot of all the data 
# batted_balls_2020_plot 


# Putting a geom_ballfield on top of this plot is giving me a bad time because
# ggplot2 is making many, many copies of it and therefore a very large file. So
# instead I am going to make a separate ggplot from just one game and then not
# use the geom_stat_density geoms. That should allow the same data structure to
# be kept and so the dimensions of the geom_ballfield should be identical.


########

# Now for the second part, the field boundaries
# subset the data to just one game, Aug 9 at PNC Park (no particular reason- just need to pare 
# down the size of the data set so the boundaries are not drawn many times)

pit_aug_2020_batted_balls <- batted_balls_2020 %>% 
  filter(home_team== "PIT",
         game_date== "2020-08-09")

# plot the field boundaries
field_boundaries <- pit_aug_2020_batted_balls %>%
  ggspraychart_ecm_skeleton() +
  labs(title= 'Kernel density of all MLB batted balls in 2020',
       caption = paste0('- Coordinates indicate where a ball was caught or first touched the ground. \n\n- Data shown for all balls in play during 2020 season (n = ', n_value, '; source: MLB Statcast).'),
       fill= 'Density')+
  scale_fill_gradient(low = 'transparent', high = 'transparent') +
  geom_ballfield()+
  cowplot::theme_map()+
  theme_ballfield()


ggdraw(batted_balls_2020_plot) +
  draw_plot(field_boundaries)

