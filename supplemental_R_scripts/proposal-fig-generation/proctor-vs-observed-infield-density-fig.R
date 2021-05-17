suppressPackageStartupMessages({
  library(tidyverse)
})

pirates_cores <- readr::read_csv("data/lit-review-data/pirates_density_cores/2018_pirates_inf_cores.csv",
                                 col_types = 'Dccccddd') 


# Filter for the data I trust the most - the home plate cores 
# from Oct 2018, taken from areas that were either undisturbed or 
# were adequately rolled 

d_max_summary <- pirates_cores %>%
  filter(avg_depth <4,
         date == "2018-10-18",
         field_location == "HP",
         !str_detect(details, 'poorly')) %>%
  select(avg_depth, dry_density)

d_max_summary %>% 
  ggplot(aes(dry_density, avg_depth, color = factor(avg_depth)))+
  geom_jitter()

d_max_summary %>% 
  summarise(across(dry_density, list(mean = mean, `95_pct_ci` = ~1.96*sd(.)),
                   .names = "{.fn}_{.col}"))

# compute 95% confidence interval around mean
density_mod <- lm(formula = dry_density ~ 1, data = d_max_summary)
ci_95 <- confint(density_mod,level = 0.95)




# make Proctor plot with band showing confidence interval for DuraEdge 
# max density observed in the field 
# The example dataset for soiltestr _is_ DuraEdge soil....
# for safety, clean it up and write out as a csv because 
# I will likely make some breaking changes to the proctor functions
# in soiltestr

# cleaned_example_proctor_data <- soiltestr::example_proctor_data %>% 
#   soiltestr::add_physical_properties() %>% 
#   rename(sample_name = soil_name,
#          effort = compaction_effort) %>% 
#   select(sample_name, effort, cylinder_number, Gs,
#          ambient_temp_c, water_content, dry_density)
# 
# cleaned_example_proctor_data %>% 
#   readr::write_csv(file = './data/proposed-experiments-data/DuraEdge-std-vs-mod-proctor-data-spring-2020.csv')

duraedge_proctor_data <- readr::read_csv(
  './data/proposed-experiments-data/DuraEdge-std-vs-mod-proctor-data-spring-2020.csv',
  col_types = 'ccidddd') %>%
  mutate(effort = str_to_title(paste(effort, "Effort")),
         effort = fct_reorder(effort, dry_density, max, .desc = T))


# 
#   ggplot(aes(water_content, dry_density, color = effort))+
#   geom_point()


theme_set(theme_classic())

# create separate data frame for ribbon data so it spans the whole range 
# of water contents without making a separate ribbon for each sample 

ribbon_df <- tibble(
  water_content = c(0,0.2),
  #water_content = range(duraedge_proctor_data$water_content),
  dry_density = ci_95
)

# assemble plot

proctor_vs_observed_infield_density <- duraedge_proctor_data %>% 
  ggplot(aes(water_content, dry_density, color = effort))+
  geom_hline(yintercept = mean(ci_95),
             color = alpha('darkblue', 0.5),
             linetype = 'longdash')+
  annotate(
    'text',
    label = expression('Mean'~rho~'for same soil installed on an MLB infield'),
    x = 0.13,
    y= mean(ci_95)+0.005,
    vjust = 0, 
    hjust = 0,
    size = 8/.pt,
    color = alpha('darkblue', 0.5)
  )+
  geom_smooth(method = lm,
              formula = y~splines::ns(x, 3),
              se = F,
              size = 0.25,
              show.legend = FALSE)+
  geom_point(alpha = 1/2)+
  colorblindr::scale_color_OkabeIto()+
  stat_function(fun = ~1 / ( (1/2.7) + (.x/0.9978) + ((.x/0.9978)*(1-1)/(1) ) ),
                xlim = c(0.08, 0.25),
                         # max(duraedge_proctor_data$water_content)),
                aes(color = NULL),
                color = 'grey40',
                linetype= 'dotted',
                size = 0.25)+
  ggplot2::annotate(
    "text",
    label = '100% saturation line',
    x = 0.225,
    y = 1.7,
    angle = -42,
    size= 6/.pt,
    color= 'grey50')+
  scale_y_continuous(expression('Dry density, Mg m'^-3),
                     breaks = c(1.6, 2.01, 2.18))+
  scale_x_continuous(expression('Water content, g g'^-1),
                     breaks = c(0, 0.080, 0.110))+
                     # breaks = scales::breaks_width(width = 0.05))+
  labs(
    #title = latex2exp::TeX('$\\rho_{max}$ in lab tests vs. an actual MLB infield'),
     title = expression('Laboratory'~rho[max]~'vs. actual infield construction'),
       #caption = expression('Grey band represents 95% confidence interval around mean infield value (n = 8)')
     )+
  guides(color = guide_legend(title = NULL, override.aes = list(size = 2)))+
  expand_limits(x = c(0, 0.3), y = 1.6)+
  ggplot2::coord_fixed(ratio = 0.32)+
  cowplot::background_grid(size.major = 0.25, size.minor = 0.25)+
  theme(panel.grid = element_line(linetype = 'dotted',
                                  size = 0.25),
        legend.position = c(0.8, 0.9))

  # code to make a ribbon for 95% CI rather than line and arrows 
  # geom_ribbon(data = ribbon_df, inherit.aes = FALSE,
  #             aes(x= water_content,
  #                 ymin = min(ci_95),
  #                 ymax = max(ci_95)),
  #             alpha = 1/30)+

proctor_vs_observed_infield_density

ecmfuns::export_plot(proctor_vs_observed_infield_density, dirs = 'figs')
