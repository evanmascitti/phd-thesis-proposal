goodall_traction <- read_csv('../../../research-articles-textbook-notes/research_papers/Goodall_2005/Table_4_traction.csv') %>%
  pivot_longer(cols = sil:lcs, names_to = 'soil_type', values_to = 'traction') %>% 
  select(soil_type, moisture, everything())

goodall_traction %>% 
  ggplot(aes(moisture, traction, color= soil_type))+
  geom_point()+
  geom_line()
