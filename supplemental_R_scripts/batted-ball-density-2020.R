# Original comments: This script uses a "dirty hack" to draw a plot and then
# draw an identical plot
# but with the data made invisible. The coordinates are identical; the only step
# needed to manually assemble the final figure is to use Illustrator or other
# vector graphics editor to copy the "field_boundaries" file on top of the kernel
# density plot....then change the fill of the entire field_dimensions object to
# none. That will leave the paths and permit the colors to be seen. Then save
# the result as a new svg file. Finally, if you want to trim so the objects take
# up the whole space, you'll have to make a clipping mask or crop. Still haven't
# mastered the saving dimensions and the relation to the plot.background and
# panel.background


## Updated comments, 2020-11-03. Today I learned to use more of the featurs in
## cowplot, which makes the above approach not needed. The ggdraw() function
## allows one to plot multiple ggplots on top of one another as individual
## layers. Then the new plot can be saved as usual.

# I tweaked some of the functions from baseballr and they are stored in
# the package called balldensityplots; it is on my GitHub page. 

library(tidyverse)
library(extrafont)
library(baseballr)
library(ecmfuns)
library(magick)
library(balldensityplots)
library(cowplot)

loadfonts()


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
  labs(title= 'Kernel density of MLB batted balls',
       caption = paste0('- Coordinates indicate where ball was fielded by defender.\n\n- Data shown for 2020 season (n = ', n_value, '; source: MLB Statcast).'),
       fill= 'Density')+
  theme_ballfield()+
  theme(plot.margin = margin(0,0,0,0, unit = "pt"),
        plot.title= element_text(size = 13),
        legend.title = element_text(size = 11),
        plot.caption = element_text(size = 9))
  

# print the plot of all the data 
# batted_balls_2020_plot 

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
  labs(title= 'Kernel density of MLB batted balls',
       caption = paste0('- Coordinates indicate where ball was fielded by defender.\n\n- Data shown for 2020 season (n = ', n_value, '; source: MLB Statcast).'),
       fill= 'Density')+
  #scale_fill_gradient(low = 'transparent', high = 'transparent') +
  geom_ballfield()+
  theme_ballfield()+
  theme(plot.margin = margin(0,0,0,0, unit = "pt"),
        plot.title= element_text(size = 13),
        legend.title = element_text(size = 11),
        plot.caption = element_text(size = 9))

# show the plot
 field_boundaries

# combine the actual data with the field boundaries "layer" using cowplot::draw_plot

batted_balls_w_boundaries <- ggdraw() +
  draw_plot(batted_balls_2020_plot)+ 
  draw_plot(field_boundaries)
#batted_balls_w_boundaries
batted_balls_w_boundaries
# save the completed plot to disk

#ggsave(batted_balls_w_boundaries, filename = 'images/illustrations/batted_ball_density/mlb_batted_balls_2020.pdf')
