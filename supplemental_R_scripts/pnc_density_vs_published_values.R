library(tidyverse)
readr::read_csv("data/lit-review-data/pirates_density_cores/2018_pirates_inf_cores.csv") %>% 
  .$date %>% 
  unique()
pirates_cores <- readr::read_csv("data/lit-review-data/pirates_density_cores/2018_pirates_inf_cores.csv") %>% 
  rename(source = facility) %>% 
  filter(avg_depth <4) %>% 
  mutate(source_line1 = "Author's unpublished data <br>from an MLB stadium",
         source_line2 = "<br> <br> (intact core sections)") %>% 
  filter(date == "2018-10-18") %>% 
  select(source_line1, source_line2, dry_density) %>% 
  drop_na()

avg_pirates_density <- pirates_cores %>% 
  group_by(source_line1) %>% 
  summarise(dry_density = mean(dry_density, na.rm= TRUE)) 

brosnan_densities <- tibble::tibble(
  treatment = c("low compaction treatment", "medium compaction treatment", "heavy compaction treatment"),
  dry_density = c(1.46, 1.54, 1.63),
  source_line1 = "Brosnan et al., 2011",
  source_line2 = "<br>(nuclear density gauge)") %>% 
  select(source_line1, source_line2, dry_density)

goodall_densities <- read_csv('data/lit-review-data/goodall_2005_table3_physical_properties.csv') %>% 
  mutate(source_line1 = 'Goodall et al., 2005',
         source_line2 = '<br> (Proctor tests)') %>% 
  select(source_line1, source_line2, dry_density)


combined_densities <- rbind(pirates_cores, brosnan_densities, goodall_densities) %>% 
  mutate(source_line1 = fct_reorder(source_line1, desc(dry_density)))

data_labels <- combined_densities %>% 
  group_by(source_line1, source_line2) %>% 
  summarize(dry_density = max(dry_density) + 0.06)

lit_review_density_comparison_plot <- combined_densities %>% 
  ggplot(aes(dry_density, source_line1))+
  geom_point(aes(color = source_line1), position = position_jitter(height = 0.05, seed = 2), alpha= 2/3, size = 2.5)+
  ggtext::geom_richtext(data = data_labels, aes(label = source_line1), 
                        hjust = 0, lineheight = unit(0.7, "lines"), label.color = NA,
                        fill = 'transparent')+
  ggtext::geom_richtext(data = data_labels, aes(label = source_line2),
                        hjust = 0, lineheight = unit(0.7, "lines"), label.color = NA,
                        fill = 'transparent', color = 'grey50',
                        nudge_y = -0.1)+
  scale_x_continuous(limits = c(1.3, 2.7),
                     breaks = seq(1.4, 2.4, 0.2),
                     labels = scales::label_number(accuracy = 0.1))+
  scale_color_brewer(palette = 'Dark2')+
  labs(title = 'Range of infield soil bulk density',
       subtitle = 'Data collection method in parentheses.',
       x= bquote("Dry density, Mg m"^-3))+
  #guides(color= guide_legend(title = 'Data source', reverse = T))+
  cowplot::theme_cowplot()+
  ggplot2::theme(legend.position = 'none',
        axis.line.y= element_blank(),
        axis.text.y = element_blank(),
        axis.ticks.y = element_blank(),
        axis.title.y = element_blank(),
        plot.background = element_rect(size = 0.25, color = 'grey75'),
        plot.margin = ggplot2::margin(10, 10, 10, 10)
  )

lit_review_density_comparison_plot
