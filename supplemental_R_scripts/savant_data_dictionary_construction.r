library(xfun)
library(tidyverse)
library(sjmisc)
savant_ref <- read_tsv('data/lit-review-data/savant_data_dictionary.tsv', col_names = FALSE)

savant_vars <- savant_ref %>% 
  mutate(row_number= row_number(),
         even= is_even(row_number) ) %>% 
  filter(even== FALSE)  %>% 
  rename(var_name= X1) %>% 
  select(var_name) %>% 
  .[[1]]

savant_descriptions <- savant_ref %>% 
  mutate(row_number= row_number(),
         even= is_even(row_number) ) %>% 
  filter(even== TRUE)  %>% 
  rename(var_name= X1) %>% 
  select(var_name) %>% 
  .[[1]]

savant_dictionary <- tibble(var_name= savant_vars, 
                            var_description= savant_descriptions)

# Not run 
# savant_dictionary %>% 
#   write_csv('savant_data_dictionary.csv')
