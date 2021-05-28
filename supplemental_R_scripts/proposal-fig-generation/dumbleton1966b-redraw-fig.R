library(magrittr)
library(ggplot2)

fig8_data <- readr::read_csv(
  'data/lit-review-data/Dubmleton1966b/dumbleton-1966b_fig-8.csv',
  col_types = 'ddd'
) %>% 
  tidyr::pivot_longer(
    cols = c(PL, LL),
    names_to = 'test_type',
    values_to = 'water_content'
  ) %>% 
  dplyr::mutate(
    test_type = factor(test_type, levels = c("PL", "LL"))
  )

pure_kaolinite_PL <- fig8_data[fig8_data$test_type == 'PL', 'water_content'][[1]][1]

pure_kaolinite_LL <- fig8_data[fig8_data$test_type == 'LL', 'water_content'][[1]][1]

pure_kaolin_water_contents <- fig8_data %>% 
  split(fig8_data$test_type) %>% 
  purrr::map('water_content') %>% 
  purrr::map_dbl(~.[1])

pure_montmorillonite_water_contents <- fig8_data %>% 
  split(fig8_data$test_type) %>% 
  purrr::map('water_content') %>% 
  purrr::map_dbl(~.[length(.)])

slopes_df <- tibble::tibble(
  test_type = unique(fig8_data$test_type),
  slope = (pure_montmorillonite_water_contents - pure_kaolin_water_contents) / 100,
  intercept = pure_kaolin_water_contents)
  
x_labels <- paste(unique(fig8_data$pct_montmorillonite), 100 - unique(fig8_data$pct_montmorillonite), sep=":")

dumbleton_west_1966b_fig8_redraw <- fig8_data %>% 
  ggplot(aes(pct_montmorillonite, water_content, color = test_type))+
  geom_point()+
  geom_abline(data= slopes_df, 
              aes(color= test_type,
                  slope = slope, 
                  intercept = pure_kaolin_water_contents),
              show.legend = FALSE,
              linetype = 'dashed',
              alpha = 1/2)+
  theme_classic()+
  scale_x_continuous('Montmorillonite : kaolinite ratio',
                     labels = x_labels)+
  scale_y_continuous(expression('Water content, g g'^-1%*%100),n.breaks = 10, limits = c(0, 160))+
  colorblindr::scale_color_OkabeIto()+
  guides(color = guide_legend(title = NULL, reverse = TRUE))+
  labs(title = 'Atterberg limits of clay mixtures',
       caption = '- Dashed lines represent simple linear interpolation\n- Reproduced from Dumbleton and West (1966b), Fig. 8')+
  coord_fixed(ratio = 0.75)+
  theme(plot.caption = element_text(hjust = 0) )


ecmfuns::export_plot(dumbleton_west_1966b_fig8_redraw)