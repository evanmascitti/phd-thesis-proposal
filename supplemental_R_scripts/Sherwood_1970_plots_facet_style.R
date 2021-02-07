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
    ) %>% 
  mutate(test_condition = 'inter_lab') %>% 
  select(test_condition, soil, test, water_content)

mean_att_lims_across_labs <- att_lims_across_labs %>%
    group_by(test_condition, soil, test) %>%
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
  ) %>% 
  mutate(test_condition = 'inter_operator') %>% 
  select(test_condition, soil, test, water_content)

mean_att_lims_across_operators <- att_lims_across_operators %>%
    group_by(test_condition, soil, test, water_content) %>%
    summarize(water_content = mean(water_content, na.rm = TRUE)) %>%
    ungroup()

# compare single-operator variability with data from table 1 ------------------------

att_lims_single_operator_table1 <-  sherwood_data$liquid_limit_single_operator_table1 %>% 
  rbind(sherwood_data$plastic_limit_single_operator_table1) %>% 
  pivot_longer(cols = B:W,
               names_to = "soil",
               values_to = "water_content") %>% 
  dplyr::mutate(soil = paste("Soil", soil),
                test_condition = 'single_operator') %>%
  select(test_condition, soil, test, water_content)

mean_att_lims_single_operator_table1 <- att_lims_single_operator_table1%>% 
  group_by(test_condition, soil, test) %>%
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
    soil = paste("Soil", soil),
    test_condition = 'single_operator') %>%
  select(test_condition, soil, test, water_content)

mean_att_lims_single_operator_appendix4 <- att_lims_single_operator_appendix4 %>%
  group_by(test_condition, soil, test) %>%
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
  ),
  soil = paste("Soil", soil)) %>% 
  mutate(test_condition = 'single_operator') %>% 
  select(test_condition, soil, test, water_content)

mean_att_lims_single_operator_table1 <- att_lims_single_operator_table1 %>% 
  group_by(test_condition, soil, test) %>%
  summarize(water_content = mean(water_content, na.rm = TRUE)) %>%
  ungroup()



# combine the tibbles into one for the actual values and one for t --------


mean_values <- rbind(att_lims_across_labs,
                     att_lims_across_operators,
                     att_lims_single_operator_table1) %>% 
  mutate(group_var = paste(test_condition, soil, test, sep= "-"),
         soil = stringr::str_remove(string = soil, pattern = "Soil "))

# unique(att_lims_single_operator_table1$soil)

all_mean_values <- rbind(mean_att_lims_across_labs,
      mean_att_lims_across_operators,
      mean_att_lims_single_operator_table1) %>% 
  mutate(group_var = paste(test_condition, soil, test, sep= "-"),
         soil = stringr::str_remove(string = soil, pattern = "Soil "))




# make plots for the 3 types of variation ---------------------------------

# first create some facet labels 

test_condition_labs <- c("Single operators at 41 different laboratories",
                         "8 operators at the Road Research Laboratory",
                         "6 results by a single operator") %>% 
  set_names(c('inter_lab', 'inter_operator', 'single_operator'))

att_lims_variation_plot <- ggplot(
  data = mean_values,
  mapping = aes(
      x = water_content, y = soil, color = test, group = group_var
    )) +
    scale_x_continuous(
      name = bquote("Water content, % g g" ^ -1),
      breaks = scales::breaks_width(10),
      limits = c(0, 100),
      expand = expansion(mult = 0, add = 3)
    ) +
    geom_vline(
      xintercept = seq(0, 100, 5),
      color = 'grey85',
      linetype = 'dotted'
    ) +
    geom_point(
      position = position_jitter(height = 0.2, seed = 1),
      alpha = 1 / 3,
      size = 3) +
    stat_summary(
      geom = "errorbarh",
      fun.data = ~ mean_se(., mult = 1.96),
      height = 0.4,
      size = 0.625,
      color = 'black'
    ) +
    colorblindr::scale_color_OkabeIto() +
    labs(title = 'Relative uncertainty among replicate Atterberg limit tests',
         caption = 'Error bars span 95% confidence interval of the mean. \nData re-plotted from Sherwood, 1970 (Tables 1, 3, 4).',
         y= 'Soil\nidentifier')+
  cowplot::theme_cowplot() +
  # to put all the soils on one panel: 
  facet_wrap(~ test_condition, ncol = 1, labeller = labeller(test_condition = test_condition_labs)) +
  # to make one plot for each soil:
  #facet_grid(test_condition ~ soil, labeller = labeller(test_condition = test_condition_labs)) +
  guides(color = guide_legend(override.aes = list(size= 4, alpha = 1/2)))+
  ggplot2::theme(
      axis.line.y = element_blank(),
      axis.title.y = element_text(angle = 0, vjust = 0.5),
      strip.text = element_text(face = "bold"),
      strip.background = element_rect(fill = 'grey95'),
      legend.title.align = 0.5,
      legend.title = element_blank(),
      legend.position = 'top',
      legend.text = element_text(hjust = 1),
      legend.text.align = 0.5,
      #legend.key.size = unit(6, "mm")
    )

att_lims_variation_plot

#######

# compare variation by single operator with that of RRL operators  --------
sherwood_data$liquid_limit_across_operators_and_labs
sherwood_data$plastic_limit_across_operators_and_labs

att_lims_variation_sources <- sherwood_data$liquid_limit_across_operators_and_labs %>% 
  rbind(sherwood_data$plastic_limit_across_operators_and_labs) %>% 
  arrange(soil, comparison) %>% 
  dplyr::mutate(comparison = fct_reorder(comparison, cov),
                test = as_factor((test)) ) %>%  
  dplyr::mutate(test = fct_reorder(test, cov))

att_lims_variation_sources_grouped <- att_lims_variation_sources %>% 
  group_by(test, comparison) %>% 
  summarise(cov = mean(cov))

var_sources_facet_labs <- c("41 operators from \ndifferent laboratories", 
                            "6 results by a \nsingle RRL operator", 
                            "8 individual \nRRL operators" ) %>% 
  set_names(unique(att_lims_variation_sources$comparison) )

att_lims_cov_plot <- att_lims_variation_sources_grouped %>% 
  ggplot(aes(cov, comparison, fill = test))+
  geom_col(width = 0.7, position = position_dodge(width = 0.8), alpha= 1/2)+
  scale_y_discrete(labels = scales::label_wrap(width = 24))+
  scale_fill_manual(values= rev(colorblindr::palette_OkabeIto[1:2]),)+
  guides(fill = guide_legend(reverse = T))+
  #colorblindr::scale_fill_OkabeIto(guide = guide_legend(reverse = T))+
  scale_x_continuous(limits = c(0,15),
                     breaks = scales::breaks_width(width = 1, offset = 0),
                     expand= expansion(mult = 0, add = 0))+
  labs(title = "Coefficients of variation among Atterberg limit tests replicates",
       subtitle = "Data re-plotted from Sherwood, 1970 (Tables 5 and 8). \nBars represent mean COV across soils B, G, and W.",
       x= "Coefficient of variation (%)",
       fill = "Test")+
  background_grid(major = "x", minor = "x")+
  theme(panel.grid.major = element_line(linetype = 'dotted'),
        panel.grid.minor = element_line(linetype = 'dotted'),
        strip.background = element_rect(fill = 'grey95'),
        legend.title.align = 0.5,
        legend.position = c(0.725, 0.55),
        axis.title.y = element_blank(),
        axis.ticks.y = element_blank())
last_plot()


###############################
# produce some summary values to reference in the text --------------------

summary_covs_across_labs <- sherwood_data$atterberg_limits_across_labs %>% 
  group_by(soil) %>% 
  summarise(LL_cov = round(100*sd(LL, na.rm = TRUE)/mean(LL, na.rm = TRUE), 1),
            PL_cov = round(100*sd(PL, na.rm = TRUE)/mean(PL, na.rm = TRUE), 1))

sherwood_across_labs_ranges <- sherwood_data$atterberg_limits_across_labs %>% 
  group_by(soil) %>% 
  summarize(LL_range = round(max(LL, na.rm = T) - min(LL, na.rm = T), 1),
            LL_mean = mean(LL, na.rm= TRUE),
            PL_range = round(max(PL, na.rm = T) - min(PL, na.rm = T), 1),
            PL_mean = mean(PL, na.rm= TRUE),
            LL_percent_range = round(0.5*LL_range/LL_mean , 2)*100,
            PL_percent_range = round(0.5*PL_range/PL_mean , 2)*100)
sherwood_across_labs_ranges

sherwood_single_operator_ranges <- att_lims_single_operator_table1 %>% 
  arrange(soil) %>% 
  group_by(soil, test) %>% 
  summarize(w_range = round((max(water_content, na.rm = T) - min(water_content, na.rm = T)), 1)) %>% 
  ungroup() %>% 
  pivot_wider(names_from = test,
              values_from = w_range) %>% 
  rename(LL = `Liquid limit`,
         PL = `Plastic limit`)

