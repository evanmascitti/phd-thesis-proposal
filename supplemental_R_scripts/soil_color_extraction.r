library(tidyverse)
library(imager)
library(magick)
library(ImaginR)
library(ecmfuns)

# pull out some colors to use for the figures I want to make and
# put them into a tibble

filenames <- paste0("data/lit-review-data/soil-color-images/", list.files('data/lit-review-data/soil-color-images/')  ) 

color_names <- list.files('data/lit-review-data/soil-color-images/') %>% 
  str_sub(end= -5)

cols <- filenames %>% 
  as.list() %>% 
  set_names(., color_names) %>% 
  map(load.image) %>% 
  map_chr(ecmfuns::hex_extract) 



color_hex_codes <-  tibble(soil_description= color_names, 
       hex_color= map_chr(cols, ~.[1]) )
 
# not run ; over-write if new colors are added. 
 
# write_csv(color_hex_codes, 'data/lit-review-data/useful_soil_colors_for_thesis.csv')
