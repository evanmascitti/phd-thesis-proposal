table3data <- readr::read_csv("data/lit-review-data/Sherwood_Ryley_1970/table3.csv") %>% 
  tidyr::pivot_longer(cols = `2`:`11`,
                      names_to = 'soil',
                      values_to = 'water_content') %>% 
  dplyr::mutate(soil = factor(paste("Soil #", soil)),
         soil = fct_reorder(soil, water_content),
         method = if_else(method == 'fall_cone',
                          "Fall-cone device",
                          "Casagrande cup"),
         method = forcats::fct_relevel(method, "Fall-cone device", "Casagrande cup"))

sherwood_ryley_1970_table3_plot <- table3data %>% 
  ggplot2::ggplot(ggplot2::aes(water_content, 
                               method, 
                               color = method))+
  ggplot2::geom_point(position = ggplot2::position_jitter(height = 0.2, seed =1), alpha = 1/2)+
  ggplot2::stat_summary(geom = 'errorbarh', 
                        fun.data = ggplot2::mean_se,
                        height = 0.25,
                        color = 'black')+
  ggplot2::scale_x_continuous(name = bquote("Water content, % g g" ^ -1),
                              breaks =scales::breaks_width(width = 5, offset = 0))+
  ggplot2::labs(title = 'Reproducibility of two liquid limit methods',
       caption  = 'Error bars span 95% confidence interval of the mean. \nData re-plotted from Sherwood and Ryley, 1970 (Table 3).')+
  ggplot2::scale_color_manual(values = c(colorblindr::palette_OkabeIto[7:8]))+
  cowplot::theme_cowplot()+
  #cowplot::background_grid(major = "x", minor = "x")+
  ggplot2::facet_wrap(~soil, ncol=1)+
  ggplot2::theme(
    #panel.grid.minor = element_line(linetype = 'dotted'),
    strip.background = element_rect(fill = 'grey95'),
    legend.title.align = 0.5,
    legend.position = 'none',
    axis.title.y = element_blank(),
    axis.ticks.y = element_blank(),
    axis.line.y = element_blank())
ggplot2::last_plot()



