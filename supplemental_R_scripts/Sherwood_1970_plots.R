library(tidyverse)
library(cowplot)
library(patchwork)
library(colorspace)
ggplot2::theme_set(
  theme_cowplot() )

# plot variation across laboratories --------------------------------------

sherwood_data <-
    list.files(
      "data/lit-review-data/Sherwood_1970/",
      full.names = T,
      pattern = "csv"
    ) %>%
    set_names(str_remove(
      string = basename(.), pattern = "(Sherwood_1970_)"
    )) %>%
    set_names(str_remove(
      string = names(.), pattern = ".csv"
    )) %>%
    map(read_csv)
  
att_lims_across_labs <-
    sherwood_data$atterberg_limits_across_labs %>%
    pivot_longer(
      cols = PL:LL,
      names_to = "test",
      values_to = "water_content"
    ) %>%
    dplyr::mutate(
      soil = paste("Soil", soil),
      test = if_else(.$test == "PL",
                     "Plastic limit",
                     "Liquid limit")
    )

mean_att_lims_across_labs <- att_lims_across_labs %>%
    group_by(soil, test) %>%
    summarize(water_content = mean(water_content, na.rm = TRUE)) %>%
    ungroup()



# plot inter-operator variability for the same lab ------------------------

# wrangle data 
  
LL_across_operators <-sherwood_data$liquid_limit_across_operators %>% 
    pivot_longer(
      cols = B:W,
      names_to = "soil",
      values_to = 'water_content'
    ) %>%
    dplyr::filter(method == "Casagrande cup") %>%
    dplyr::select(-method) %>%
    dplyr::mutate(test = "Liquid limit",
                  soil = paste("Soil", soil) ) %>%  
    dplyr::select(operator, soil, test, water_content)
  
PL_across_operators <- sherwood_data$plastic_limit_across_operators %>% 
    pivot_longer(
      cols = B:W,
      names_to = "soil",
      values_to = 'water_content'
    ) %>% 
    dplyr::mutate(test = "Plastic limit",
                  soil = paste("Soil", soil) ) %>% 
    dplyr::select(operator, soil, test, water_content)


att_lims_across_operators <- rbind(
    LL_across_operators, 
    PL_across_operators
  )

mean_att_lims_across_operators <- att_lims_across_operators %>%
    group_by(soil, test) %>%
    summarize(water_content = mean(water_content, na.rm = TRUE)) %>%
    ungroup()


# compare single-operator variability with data from table 1 ------------------------

att_lims_single_operator_table1 <-  sherwood_data$liquid_limit_single_operator_table1 %>% 
  rbind(sherwood_data$plastic_limit_single_operator_table1) %>% 
  pivot_longer(cols = B:W,
               names_to = "soil",
               values_to = "water_content") %>% 
  dplyr::mutate(soil = paste("Soil", soil))

mean_att_lims_single_operator_table1 <- att_lims_single_operator_table1%>% 
  group_by(soil, test) %>%
  summarize(water_content = mean(water_content, na.rm = TRUE)) %>%
  ungroup()

# make tibble for appendix 4 experiment 

att_lims_single_operator_appendix4 <- sherwood_data$atterberg_limits_single_operator_appendix4 %>% 
  pivot_longer(cols = PL:LL,
               names_to = "test", 
               values_to = "water_content") %>% 
  dplyr::mutate(test = if_else(
    test == "PL",
    "Plastic limit",
    "Liquid limit"),
    soil = paste("Soil", soil))

mean_att_lims_single_operator_appendix4 <- att_lims_single_operator_appendix4 %>%
  group_by(soil, test) %>%
  summarize(water_content = mean(water_content, na.rm = TRUE)) %>%
  ungroup()

# make tibble for table 1 experiment 

att_lims_single_operator_table1 <- sherwood_data$plastic_limit_single_operator_table1 %>% 
  rbind(sherwood_data$liquid_limit_single_operator_table1) %>% 
  pivot_longer(cols = B:W,
               names_to = "soil", 
               values_to = "water_content") %>% 
  dplyr::mutate(test = if_else(
    test == "PL",
    "Plastic limit",
    "Liquid limit"
  ))

mean_att_lims_single_operator_table1 <- att_lims_single_operator_table1 %>% 
  group_by(soil, test) %>%
  summarize(water_content = mean(water_content, na.rm = TRUE)) %>%
  ungroup()


# make plots for the 3 types of variation ---------------------------------


# write plotting function to compare the three sources of variation (the third
# one via two separate experiments)

plot_att_lims_variation_hz <- function(df, mean_df, plot_title, plot_subtitle, plot_caption){
  df %>%
    ggplot(aes(
      x = water_content, y = test, color = test
    )) +
    scale_x_continuous(
      name = bquote("Water content, % g g" ^ -1),
      breaks = scales::breaks_width(5),
      limits = c(0, 100),
      expand = expansion(mult = 0, add = 3)
    ) +
    geom_vline(
      xintercept = seq(0, 100, 5),
      color = 'grey85',
      linetype = 'dotted'
    ) +
    geom_label(
      data = mean_df,
      aes(label = test),
      nudge_y = 1.6,
      size = 3.25,
      color = 'grey35',
      label.size = 0,
      vjust = "inward",
      label.padding = unit(0.5, "lines")
    ) +
    geom_point(
      position = position_jitter(height = 0.2, seed = 1),
      alpha = 1 / 3,
      show.legend = FALSE
    ) +
    stat_summary(
      geom = "errorbarh",
      fun.data = ~ mean_se(., mult = 1.96),
      height = 0.4,
      size = 0.625,
      color = 'black'
    ) +
    colorblindr::scale_color_OkabeIto() +
    labs(title = plot_title,
         subtitle = plot_subtitle,
         caption = plot_caption
    ) +
    cowplot::theme_cowplot() +
    facet_wrap(~ soil, ncol = 1) +
    ggplot2::theme(
      axis.line.y = element_blank(),
      axis.title.y = element_blank(),
      axis.text.y = element_blank(),
      axis.ticks.y = element_blank(),
      strip.text = element_text(face = "bold"),
      strip.background = element_rect(fill = 'grey95')
    )
}


att_lims_variation_plot_args <- tibble::tibble(
  df = list(att_lims_across_labs, att_lims_across_operators, att_lims_single_operator_table1, att_lims_single_operator_appendix4),
  mean_df= list(mean_att_lims_across_labs, mean_att_lims_across_operators, mean_att_lims_single_operator_table1, mean_att_lims_single_operator_appendix4),
  plot_title = c(
    "Inter-lab variation of Atterberg limits for 3 soils",
    "Inter-operator variation of Atterberg limits for 3 soils",
    "Variation among 6 replicate tests by the same operator",
    "Variation among 10 replicate tests by the same operator"),
  plot_caption = c(
    "Error bars span 95% confidence interval of the mean. Data re-plotted from Sherwood, 1970 (Table 4).",
    "Error bars span 95% confidence interval of the mean. Data re-plotted from Sherwood, 1970 (Table 3).",
    "Error bars span 95% confidence interval of the mean. Data re-plotted from Sherwood, 1970 (Table 1).",
    "Error bars span 95% confidence interval of the mean. Data re-plotted from Sherwood, 1970 (Appendix 4)."),
  plot_subtitle = c("", "All operators were employed by the Road Research Laboratory.", "", "")
)

sherwood_variability_plots <- pmap(.l= att_lims_variation_plot_args, .f= plot_att_lims_variation_hz) %>% 
  setNames(c("across_labs", "across_operators", "single_operator_table1", "single_operator_appendix4"))


#######




# compare variation by single operator with that of RRL operators  --------


att_lims_variation_sources <- sherwood_data$liquid_limit_across_operators_and_labs %>% 
  rbind(sherwood_data$plastic_limit_across_operators_and_labs) %>% 
  arrange(soil, comparison) %>% 
  dplyr::mutate(comparison = fct_reorder(comparison, cov))

var_sources_facet_labs <- c("41 operators from \ndifferent laboratories", 
                            "6 results by a \nsingle RRL operator", 
                            "8 individual \nRRL operators" ) %>% 
  set_names(unique(att_lims_variation_sources$comparison) )

att_lims_variation_sources_plot <- att_lims_variation_sources %>% 
  ggplot(aes(cov, comparison, fill = test))+
  geom_col(position = 'dodge2', alpha= 2/3)+
  colorblindr::scale_fill_OkabeIto()+
  scale_x_continuous(limits = c(0,15),
                     breaks = scales::breaks_width(width = 5, offset = 0))+
  labs(title = "Variation among replicated Atterberg limit tests",
       caption = "Data re-plotted from Sherwood, 1970 (Tables 5 and 8).",
       y= "Replication type",
       x= "Coefficient of variation (%)",
       fill = "Test")+
  background_grid(major = "y", minor = "y")+
  facet_wrap(~soil, nrow=3)+
  theme(panel.grid.major = element_line(linetype = 'dotted'),
        panel.grid.minor = element_line(linetype = 'dotted'),
        strip.background = element_rect(fill = 'grey95'),
        legend.title.align = 0.5)



###############################
# produce some summary values to reference in the text --------------------
sherwood_data$atterberg_limits_across_labs %>% 
  group_by(soil) %>% 
  summarise(sherwood_PL_across_labs_cov = sd(PL, na.rm = TRUE)/mean(PL, na.rm = TRUE),
            sherwood_LL_across_labs_cov = sd(LL, na.rm = TRUE)/mean(LL, na.rm = TRUE)) 

summary_covs_across_labs <- sherwood_data$atterberg_limits_across_labs %>% 
  group_by(soil) %>% 
  summarise(PL = round(100*sd(PL, na.rm = TRUE)/mean(PL, na.rm = TRUE), 1),
            LL = round(100*sd(LL, na.rm = TRUE)/mean(LL, na.rm = TRUE), 1))

