# This script uses data from patton-mocha experiment; for its inspiration 
# see faceted-dne-vs-volumetric-water-content-fig.R in the cleatmarkmethod's 
# project 

suppressPackageStartupMessages({
  library(rlang)
  library(tidyverse)
  library(cowplot)
})
theme_set(theme_classic())


# read cleaned data file  and filter both tibbles it contains 
# so they have data just for the 75% sand @ modified effort. 

cleaned_data_list <- readr::read_rds(
  '../../cleatmarkmethod/ecmdata/derived-data/cleaned-rds-files/disturbance-vs-water-content-cleaned-data.rds'
) %>% 
  map(dplyr::filter, metric_label == 'rfi_diff', 
      str_detect(mix_ID, '02'),
      str_detect(effort, regex('mod', ignore_case = TRUE)))

# unload list as individual objects and delete original list to de-clutter 
# environment
invisible(list2env(cleaned_data_list, envir = rlang::current_env()))
rm(cleaned_data_list)


# clean up variable names in the large data frame 
# also, not sure where I shortened the names from 'volumetric_water_content'
# to 'volumetric_w_c', but that was probably a dumb idea.....however I am not certain 
# of what else could break if I change it at the source so I am going 
# to just patch it up here so the names match for plotting. 

all_metrics_w_water_contents <- all_metrics_w_water_contents %>% 
  mutate(
    effort = case_when(
      effort == 'stdeff' ~ 'Standard\neffort',
      effort == 'modeff' ~ 'Modified\neffort'),
    sample_name = case_when(
      mix_ID == 'mix01' ~ '60% sand',
      mix_ID == 'mix02' ~ '75% sand')
  )

tidied_w_vals <- tidied_w_vals %>% 
  mutate(
    effort = case_when(
      effort == 'Standard effort' ~ 'Standard\neffort',
      effort == 'Modified effort' ~ 'Modified\neffort')
  ) %>% 
  dplyr::rename(
    volumetric_water_content = volumetric_w_c,
    gravimetric_water_content = gravimetric_w_c
  )


# write plotting function - adapted from script referenced at top
# it is not really needed as I am just making one plot but it's good 
# practice for using quasiquotation 
#'
#' @param all_data_df data frame containing all the data points
#' @param derived_vals_df data frame containing derived w~crit~ for each tes;
#'   allows easy plotting of arrows pointing to w~crit~
#' @param x the variable that gets plotted on the x-axis  (unquoted name)
#' @param metric the variable the gets plotted on the y-axis (character string)
#'
#' @return ggplot object 
#' 
metrics_plot <- function(all_data_df, derived_vals_df, x, metric){
  
  
  # This data frame is custom made for this plot;
  # it is not really generalizable to other soils 
  # because I just chose the numbers by visually looking 
  # at the plot. Generally a no-no but I am ony making this once
  # and generating the numbers dynamically would require
  # some more curve-fitting rabbit holes that  I don't 
  # have time to go down right now 
  
  crit_pts_df <- tibble::tibble(
    letter = c(expression(C), expression(B), expression('A ('*theta[crit]*')')),
    x = c(0.14, 0.17, 0.24),
    y = c(31, 68, 20)
  )
  
  
  
  
  x_label <- x %>% 
    as.character() %>% 
    str_to_title() %>% 
    str_replace_all("_", " ")
  
 #  browser()
  y_val_for_segments <- ifelse(
    str_detect(x_label, regex('vol', ignore_case = T)),
    expr(volumetric_deformation_min),
    expr(gravimetric_deformation_min)
  )
  
  # x_val_for_segments <- if_else(
  #   str_detect(x_label, regex('vol', ignore_case = T)),
  #   expr(volumetric_water_content),
  #   expr(gravimetric_water_content)
  # )
  
  
  # set limits of x-axis
  if(str_detect(x_label, regex('vol', ignore_case = T))) {
    x_limits <- c(0, 0.4)
  } else {
    x_limits <- c(0, 0.3)
  }
  
  
  # filter for only the metric of interest for main plot and also the segments
  segments_df <- derived_vals_df %>% 
    filter(metric_label == metric)
  
  primary_df <- all_data_df %>%
    filter(metric_label == metric)
  
  # browser() 
  
  curve_plot <- primary_df %>% 
    ggplot(aes(x= !!enquo(x), y= value)) +
    geom_point( # removing color for now aes(color = factor(date)), 
               size = 1, alpha= 1/3) +
    geom_smooth(# aes(color = NULL),
                method = lm,
               #  formula = y~ splines::ns(x, 3),
                formula = y~ x + I(x^2) + I(x^3),
                se= F,
                size = 0.25)+
    geom_segment(data = segments_df,
                 inherit.aes = FALSE,
                 aes(x = !!enquo(x), #, envir = segments_df),
                     xend = !!enquo(x), # envir = segments_df),
                     y = 0.9*segments_df[[as_string(y_val_for_segments)]][[1]],
                     yend = 0),
                 size = 0.25,
                 arrow = arrow(length = unit(0.05, 'inches'), type = 'closed', angle = 20))+
    geom_label(data = crit_pts_df,
              inherit.aes = FALSE,
              aes(x = x, y= y, label = letter),
              color = 'grey25',
              size = 3,
              parse = TRUE
              )+
    expand_limits(y= c(0))+
    scale_x_continuous(# x_label, 
                       limits = x_limits,
                       breaks=scales::breaks_width(0.05),
                       labels = scales::label_number(accuracy = 0.01))+
    scale_y_continuous(expression('NRFI'))+
    colorblindr::scale_color_OkabeIto()+
    labs(title = str_replace_all(str_to_title(metric), "_", " "))+
    # facet_grid(effort~sample_name)+
    theme(panel.spacing.x = unit(12, 'mm'),
          strip.text.y = element_text(angle = 0, hjust = 0),
          strip.background = element_rect(fill = 'grey95'),
          legend.position = 'none')+
    cowplot::background_grid(color.major = 'grey90', color.minor = 'grey90',
                             size.major = 0.25, size.minor = 0.25)
  
  return(curve_plot)
  
  
}

# generate a tibble of arguments to pmap over 
# match number of expressions to a variable indicating 
# the number of metrics to plot 

n_metrics <- 1

volumetric_plot_args <- tibble(
  all_data_df = rerun(.n = n_metrics, all_metrics_w_water_contents),
  derived_vals_df = rerun(.n = n_metrics, tidied_w_vals),
  x = rerun(.n = n_metrics, expr(volumetric_water_content)),
  metric= unique(tidied_w_vals$metric_label)
)

volumetric_plots <- pmap(volumetric_plot_args, metrics_plot)%>% 
  set_names(volumetric_plot_args$metric)


example_w_crit_curve <- volumetric_plots[["rfi_diff"]] +
  labs(title = 'Example cleat mark test data: 75% sand, Modified effort',
       x= expression(theta))


print(example_w_crit_curve)

ecmfuns::export_plot(example_w_crit_curve, dirs = 'figs')