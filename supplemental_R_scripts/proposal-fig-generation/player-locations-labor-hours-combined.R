# this puts the player locations figure and the labor intensity
# figure into a single png file 


# ensure labor-per-area figure is up-to-date 

source(
  file = here::here(
    'supplemental_R_scripts', 'proposal-fig-generation',
    'labor-per-area-plot.R'
  )
)

suppressPackageStartupMessages({
  library(magick)
  library(magrittr)
})


player_locations <- magick::image_read(
  here::here(
    'images', 'illustrations', 'player-locations',
    'player-locations.png'
  )
)

# player_locations_gg <- magick::image_ggplot(player_locations)


labor_per_area <- magick::image_read(
  here::here(
    'figs', 'png', 'labor-per-area.png'
  )
) 

# labor_per_area_gg <- magick::image_ggplot(labor_per_area)

 # player_locations_df <- player_locations %>% 
 #  magick::image_info() %>% 
 #  dplyr::select(height, width)

# player_locations_ratio <- player_locations_df$width / # player_locations_df$height


# player_locations_labor_hours_combined <- patchwork::wrap_plots(
#   list(player_locations_gg,
#   labor_per_area_gg),
#   ncol = 1
# )


min_width <- c(player_locations, labor_per_area) %>%
  image_info() %>%
  purrr::pluck("width") %>%
  min()


combined_panels <- c(player_locations, labor_per_area) %>%
  image_scale(geometry = geometry_size_pixels(width = min_width)) %>%
  image_border('10x10', color = 'white') %>% 
  image_append(stack = TRUE)

# check in RStudio viewer
# image_scale(combined_panels, '300')

# write to new png file 

magick::image_write(
  image = combined_panels,
  format = "png",
  path = here::here(
    'figs', 'png', 'player-locations-labor-hours-combined.png'
))
  
  
  
# ecmfuns::export_plot(x = player_locations_labor_hours_combined, formats = "png", rds = FALSE, base_asp = player_locations_ratio / 2)
  
  