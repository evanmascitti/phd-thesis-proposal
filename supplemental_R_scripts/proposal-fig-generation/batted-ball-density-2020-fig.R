suppressPackageStartupMessages({
  library(balldensityplots)
  library(tidyverse)
})

all_data_2020_mlb <- c("data/lit-review-data/2020-savant-data-reg-season.csv",
                       "data/lit-review-data/2020-savant-data-post-season.csv") %>% 
  map(read_csv) %>% 
  reduce(rbind) %>% 
  select(home_team, game_date, hc_x, hc_y) %>% 
  filter(hc_x != 'null',
         hc_y != 'null') %>% 
  mutate(hc_x= as.double(hc_x),
         hc_y= as.double(hc_y)) %>%
  filter(hc_x >25,
         hc_x < 228,
         hc_y < 220,
         hc_y > 30
  )

n_value <- scales::comma(length(all_data_2020_mlb$hc_x))

last_ws_data <- all_data_2020_mlb %>% 
  filter(game_date == "10/27/2020")

(batted_balls_w_boundaries_2020 <- balldensityplots::ggspraychart_ecm(
  data = all_data_2020_mlb)+
  scale_fill_binned(type = "gradient", low = "#b1d3e6", 
                    high = "#940000")+
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
  theme_ballfield()+
  guides(fill = guide_colorbar(title = 'Fielded ball density\nLow \u2190    \u2192 High',
                               title.position = 'top',
                                 title.hjust = 0.5,
                               direction = 'horizontal',
                               ticks = FALSE))+
  theme(
    plot.caption = element_text(size = 9, hjust = 0),
    legend.title.align = 0.5,
    legend.title = element_text(size = 8.5)))


# Arrows not working, probably thanks to Windows....
# Do it manually with cairo_pdf device 
# as suggested here: https://stackoverflow.com/questions/12768176/unicode-characters-in-ggplot2-pdf-output
# ecmfuns::export_plot(batted_balls_w_boundaries_2020, dirs = 'figs')

ggsave('figs/pdf/batted-balls-w-boundaries-2020.pdf',
       plot = batted_balls_w_boundaries_2020,
       device = cairo_pdf,
       width = 5, 
       height = 4.5)

ggsave('figs/png/batted-balls-w-boundaries-2020.png',
       plot = batted_balls_w_boundaries_2020,
       device = ragg::agg_png,
       width = 5, 
       height = 4.5)
