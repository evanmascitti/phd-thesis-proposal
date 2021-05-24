# This script generates an example flow curve figure and 
# combines it with an image of the LL test. It uses patchwork 
# to combine the panels and annotate them with capital letters. 
# Then I export the figure as a png file. 


library(soiltestr)
library(patchwork)

example_flow_curve <- example_LL_data[example_LL_data$expt_mix_num == 3L, ] %>% 
  dplyr::left_join(asi468::tin_tares$`2020-05-24`, by = 'tin_number') %>%   add_w() %>% 
  ggflowcurve()+
  ggplot2::labs(y = expression('Water content, g g'))

LL_photo <- magick::image_read(c('images/ll-test-setup.jpg'))

LL_image_ggplot <- magick::image_ggplot(LL_photo)

example_LL_combined_panels <- patchwork::wrap_plots(LL_image_ggplot, example_flow_curve)+
  plot_annotation(tag_levels = 'A',
                  tag_suffix = '.')

ecmfuns::export_plot(example_LL_combined_panels, formats = 'png', rds = FALSE)
