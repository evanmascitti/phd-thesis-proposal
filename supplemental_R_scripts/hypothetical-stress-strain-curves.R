suppressPackageStartupMessages({
  library(ggplot2)
  library(magrittr)
}) 

brittle <- tibble::tibble(
  condition= 'Brittle (moderate toughness)',
  stress = c(seq(1, 30, length.out = 10)),
  strain = 0.05*c(0, 0.5, 1.5, 3, 5, 7.5, 11, 15, 20, 26)
)

ductile <- tibble::tibble(
  condition= 'Ductile (low toughness)',
  stress = seq(1, 4, length.out = 10),
  strain = c(0, 0.5, 1.5, 3, 5.1, 7.5, 12, 17, 22, 50)
)

intermediate <- tibble::tibble(
  condition= 'Intermediate (highest toughness)',
  stress = c(seq(1, 20, length.out = 6), 22),
  strain = c(0, 1, 2.5, 5, 7.5, 12, 35)
)

# 
# ggplot(ductile, aes(strain, stress))+
#   geom_point()+
#   scale_x_continuous(limits = c(0, 20))+
#   scale_y_continuous(limits = c(0, 55))+
#   geom_vline(xintercept = 10)


combined_data <- dplyr::bind_rows(ductile, brittle, intermediate) %>% 
  dplyr::mutate(condition = factor(condition),
                condition = forcats::fct_reorder(
                  .f = condition,
                  .x = stress
                ))

combined_data

hypothetical_stress_strain_curves <- ggplot(
  combined_data,
  aes(
    x = strain,
    y = stress,
    color = condition,
    fill = condition,
    group = condition 
  ))+
  geom_ribbon(aes(ymin = 0, ymax = stress),
              alpha = 1 / 5)+
  geom_vline(xintercept = 10, color = 'grey50')+
  annotate('text',
           label = "Max.\nacceptable\nstrain",
           x= 7.7, y = 30,
           hjust = 0,
           color = 'grey50',
           size = 3)+
  scale_x_continuous('Strain', limits = c(0, 20))+
  scale_y_continuous('Stress', limits = c(0, 40))+
  scale_fill_manual(values = c('lightblue', 'darkgreen', 'red' ))+
  scale_color_manual(values = c('lightblue', 'darkgreen', 'red' ))+
  guides(fill = guide_legend(reverse = T),
         color = guide_legend(reverse = T))+
  theme_minimal()+
  theme(axis.text = element_blank(),
        legend.position = c(0.8, 0.8),
        legend.title = element_blank())



ecmfuns::export_plot(hypothetical_stress_strain_curves)

############



# extra stuff....geom_area behaves weird so not using it with the preditions. 
# Don't care for the sharp breaks in the curves ,but it is good enough
# to prove the point 
# 
# predictions_df <- tibble(strain = seq(0, 30, by = 1))
# 
# predicted_data <- combined_data %>% 
#   group_by(condition) %>% 
#   nest() %>% 
#   mutate(model = map(data, lm, formula = stress ~ splines::ns(strain, 2)),
#          predictions = map(model, ~modelr::add_predictions(model = ., data = predictions_df, var = 'stress'))) %>% 
#   dplyr::select(condition, predictions) %>% 
#   unnest(predictions) %>% 
#   dplyr::mutate(
#     stress = dplyr::if_else(
#       condition = str_detect(condition, "brittle") & strain > 2.5,
#       true = NA_real_,
#       false = stress
#     )
#   )
# 
# ggplot(predicted_data, aes(x = strain, y = stress, 
#                            #color = condition, 
#                            fill = condition))+
#   # geom_point()+
#   # geom_line()+
#   geom_area(alpha = 1/2 , show.legend = T)+
#   scale_x_continuous(limits = c(0, 20))+
#   scale_y_continuous(limits = c(0, 55))+
#   geom_vline(xintercept = 10)
