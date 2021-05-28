# This generates a plot from the example data 
# in soiltestr, then combines it with a photograph.
# I used magick to put the photo into a ggplot 
# environment and then combined them with patchwork.
# the other approach would be to save the plot as a 
# png and then use magick to combine and annotate
# them, but this requires fiddling with the 
# text sizes to get the right resolution.
# I'd prefer to just leave everything in the ggplot 
# environment as the sizing is handled automatically 
# and there are no intermediate png files left over.

library(magrittr)
library(soiltestr)
library(patchwork)
library(magick)


example_flow_curve <- example_LL_data[example_LL_data$expt_mix_num == 3L, ] %>% 
  dplyr::left_join(asi468::tin_tares$`2020-05-24`, by = 'tin_number') %>%   add_w() %>% 
  ggflowcurve()+
  ggplot2::labs(y = expression('Water content, g g'))

LL_photo <- magick::image_read(c('images/ll-test-setup.jpg'))

LL_image_ggplot <- magick::image_ggplot(LL_photo)

example_LL_combined_panels <- patchwork::wrap_plots(LL_image_ggplot, example_flow_curve)+
  plot_annotation(tag_levels = 'A',
                  tag_suffix = '.')

ecmfuns::export_plot(example_LL_combined_panels, formats = 'png', rds = FALSE, dpi=600)
