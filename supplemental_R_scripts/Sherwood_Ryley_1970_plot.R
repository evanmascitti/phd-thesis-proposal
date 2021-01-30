table3data <- readr::read_csv("data/lit-review-data/Sherwood_Ryley_1970/table3.csv") %>% 
  tidyr::pivot_longer(cols = `2`:`11`,
                      names_to = 'soil',
                      values_to = 'water_content')

sherwood_ryley_1970_table3_plot <- table3data %>% 
  ggplot2::ggplot(ggplot2::aes(water_content, forcats::fct_relevel(method, "fall_cone", "casagrande"), color = method))+
  ggplot2::geom_point(position = ggplot2::position_jitter(height = 0.2), alpha = 9/10)+
  ggplot2::stat_summary(geom = 'errorbarh', fun.data = ggplot2::mean_se)+
  cowplot::theme_cowplot()+
  ggplot2::facet_wrap(~soil, ncol=1)


