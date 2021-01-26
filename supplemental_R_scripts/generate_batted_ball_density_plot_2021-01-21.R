library(balldensityplots)
library(tidyverse)

all_data_2020_mlb <- c("data/lit-review-data/2020-savant-data-reg-season.csv",
                       "data/lit-review-data/2020-savant-data-post-season.csv") %>% 
  map(read_csv) %>% 
  reduce(rbind) %>% 
  select(game_date, home_team, hc_x, hc_y) %>% 
  filter(hc_x != 'null',
         hc_y != 'null') %>% 
  mutate(hc_x= as.double(hc_x),
         hc_y= as.double(hc_y)) %>%
  select(home_team, game_date, hc_x, hc_y) %>% 
  filter(hc_x >25,
         hc_x < 228,
         hc_y < 220,
         hc_y > 30
  )

n_value <- scales::comma(length(all_data_2020_mlb$hc_x))

last_ws_data <- all_data_2020_mlb %>% 
  filter(game_date == "10/27/2020")

batted_balls_w_boundaries_2020 <- balldensityplots::ggspraychart_ecm(data = all_data_2020_mlb)+
  scale_fill_binned(type = "gradient", low = "#b1d3e6", 
                    high = "#940000")+
  theme_ballfield()+
  ggplot2::geom_curve(size= 0.625, data= last_ws_data, x = 34, xend = 220, y = -98, yend = -98, curvature = -0.65)+
  ggplot2::geom_segment(size= 0.625,data= last_ws_data, x = 128, xend = 34, y = -208, yend = -98)+
  ggplot2::geom_segment(size= 0.625,data= last_ws_data, x = 128, xend = 220, y = -208, yend = -98)+
  ggplot2::geom_curve(size= 0.625,data= last_ws_data, x = 81, xend = 172, y = -154, yend = -154, curvature = -0.65)+
  ggplot2::geom_segment(size= 0.625,data= last_ws_data, x = 101, xend = 127, y = -176, yend = -150)+
  ggplot2::geom_segment(size= 0.625,data= last_ws_data, x = 155, xend = 127, y = -176, yend = -150)+
  labs(title = "Density of MLB fielding plays",
       caption = glue::glue("- Map includes {n_value} batted balls from 2020 season 
                            - Data source: Baseball Savant database"))+
  coord_fixed(ratio = 1)+
  theme(
    plot.caption = element_text(size = 9, hjust = 0),
    legend.position = "none",
  )
