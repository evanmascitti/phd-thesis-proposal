# load packages quietly
suppressPackageStartupMessages({
  library(dplyr)
  library(magrittr)
  library(ganttrify)
})

# load data from csv file 
phd <- readr::read_csv('data/lit-review-data/tables/phd-gantt-chart-dates.csv',
                col_types = "ccDD") %>% 
  tidyr::fill(everything(), .direction = 'down')
  

# build plot 
phd_gantt_chart <- ganttrify(project = phd, 
          by_date = TRUE,
          exact_date = TRUE,
          project_start_date = '2019-01-01',
          colour_palette = RColorBrewer::brewer.pal(name = 'Dark2', n = length(unique(phd$wp))),
          mark_quarters = FALSE,
          mark_years = TRUE,
          colour_stripe = 'grey95',
          month_number_label = F,
          x_axis_position = 'bottom',
          alpha_wp = 0.8,
          alpha_activity = 0.6,
          hide_wp = F,
          size_wp = 2) +
  ggplot2::geom_vline(xintercept = Sys.Date(), color = 'firebrick', linetype ='longdash', size = 0.25)+
  ggplot2::scale_x_date(name = NULL)+
  ggplot2::scale_y_discrete(name = NULL,
                   #labels = scales::label_wrap(30)
                   )+
  ggplot2::labs(title = "Gantt chart for Evan's PhD progress",
                caption = "Red line indicates date document was last compiled.")+
  ggplot2::theme(axis.text.x = ggplot2::element_text(face = 'bold'),
        plot.margin = ggplot2::margin(10,20,10,20),
        axis.text.y.left = ggplot2::element_text(hjust = 1),
        panel.grid.major.x = ggplot2::element_line(size = 0.25),
        panel.grid.minor.x = ggplot2::element_line(size = 0.25),
        panel.grid.minor.y = ggplot2::element_blank(),
        panel.grid.major.y = ggplot2::element_blank()
  )

# write to disk 

ecmfuns::export_plot(phd_gantt_chart, formats = c('pdf', 'png'), dirs = 'figs', rds = F, base_asp = 16/9)

# print plot if running interactively

if(interactive()) {print(phd_gantt_chart)}