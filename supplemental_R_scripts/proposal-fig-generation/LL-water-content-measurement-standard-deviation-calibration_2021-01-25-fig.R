# This script generates a figure and some data values to dynamically
# reference in an .Rmd document.

# The point is to determine the expected uncertainty around the water
# content determination for a liquid limit sample, which has been mixed
# homogenously. In other words the samples are "technical replicates," i.e.
# they _should_ be exactly the same from a philosophical viewpoint.

# In other words these samples represent as small a variation as one can
# possibly hope for in representing a "population" of identical specimens.

# I have commented out the code that generates the figure as I am
# happy with it but wish to use the dynamically-generated values
# from the script without needing to re-run the whole thing.

# Be sure to load ggplot2 if I need to adjust the figure.

# Note that this file lives in the dirt-drying folder of my 
# data-lab sub-directory, but I copied the data and the script 
# into my proposal folder so it can be run using `source()`.

suppressPackageStartupMessages({
  # library(ggplot2)
  library(magrittr)
})

# some working directory hacking to ensure script runs on
# both windows and unix (curse the OneDrive spaces....)

setwd(here::here())

data_path <- fs::path(
  'data', 
  'lit-review-data', 
  'LL-water-content-measurement-standard-deviation-calibration_2021-01-25.csv'
)


# assign tin tares as an object for joining
LL_tin_tares <- dplyr::bind_rows(asi468::tin_tares)

# read file and wrangle data 
LL_reps <- readr::read_csv(file = data_path, col_types = 'ciciddc') %>%
  dplyr::left_join(LL_tin_tares, by = c('tin_tare_set', 'tin_number')) %>%
  soiltestr::add_w() %>%
  dplyr::mutate(test_type = 'LL') %>%
  dplyr::select(test_type, replication, water_content)

# compute standard deviation of the 10 measurements 
LL_sd <- round(sd(LL_reps$water_content), 3)


# plot code starts below

# errorbar_endpts <- tibble::tibble(
#   test_type = 'LL',
#   xmin = mean(LL_reps$water_content) - 0.5*LL_sd,
#   xmax = mean(LL_reps$water_content) + 0.5*LL_sd
# )
# 
# LL_w_uncertainty_for_a_single_point <- LL_reps %>%
#   ggplot(aes(water_content, y = test_type))+
#   geom_errorbarh(data = errorbar_endpts,
#                  inherit.aes = FALSE,
#                  aes(xmin = xmin, xmax = xmax, y = test_type),
#                  height = 0.05,
#                  size = 0.25,
#                  position = position_nudge(y = 0.125))+
#   geom_point(color = 'steelblue', alpha = 1/2,
#              position = position_jitter(height = 0.03, seed = 2))+
#   annotate('text', x = mean(LL_reps$water_content),
#            y = 1.25,
#            label = glue::glue(
#              'Standard deviation = {LL_sd}'),
#            size = 3)+
#   scale_x_continuous(expression('Water content, g g'^-1),
#                      limits = c(0.25,0.35),
#                      breaks = scales::breaks_width(0.01))+
#   cowplot::theme_minimal_hgrid(font_size = 12, color = 'black')+
#   ggplot2::labs(title = expression('Expected uncertainty around'~italic(w)~'for a single LL point'),
#                 subtitle = 'Points represent replicate determinations from the same bowl of homogenously-mixed soil')+
#   ggplot2::theme(
#     panel.grid = element_blank(),
#     axis.text.y = element_blank(),
#     axis.ticks.y = element_blank(),
#     axis.title.y = element_blank()
#   )
# 
# ecmfuns::export_plot(x = LL_w_uncertainty_for_a_single_point,
#                      dirs = 'figs',
#                      formats = c('pdf', 'png'),
#                      rds = FALSE)

# remove all objects except the LL_sd value, which I wish to return
# to the R session

rm(list = grep(pattern = 'LL_sd', x = ls(),  invert = TRUE, value = TRUE))


