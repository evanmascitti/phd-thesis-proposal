# produces labor-per-area plot
# there is some duplicated code but w/e, it works 


suppressPackageStartupMessages({
  library(tidyverse)
  library(cowplot)
})

# compute field areas 
pnc_areas <- read_csv(
  here::here('data/lit-review-data/pnc-google-earth-dims.csv')) %>% 
  group_by(type) %>% 
  summarise(total_area_ft2= sum(ft2)) %>% 
  mutate(total_area_ha= measurements::conv_unit(total_area_ft2, from = "ft2", to = "hectare"),
         area_pct= total_area_ha/ sum(total_area_ha))

compute_area_pct <- function(df, area) {
  area_pct <- df %>% 
    filter(type == {{area}}) %>% 
    .$area_pct*100 %>% 
    signif(digits = 2)
  
  return(area_pct)
}

skin_area_pct <- compute_area_pct(pnc_areas, "Infield skin") +compute_area_pct(pnc_areas, "Home plate") + compute_area_pct(pnc_areas, "Game mound/bullpen")
turf_area_pct <- compute_area_pct(pnc_areas, "Turf")
wt_area_pct <- compute_area_pct(pnc_areas, "Warning track")


# compute labor hours
labor_man_hrs <- read_csv(
  here::here('data/lit-review-data/maintenance-man-hrs.csv')) %>% 
  mutate(time_hr= time_min/60) %>% 
  group_by(type)  %>% 
  summarise(total_man_hr= sum(people*time_hr) )

# read colors for plotting purposes
area_colors <- readr::read_csv(
  here::here('data/lit-review-data/useful_soil_colors_for_thesis.csv')) %>% 
  dplyr::mutate(type= soil_description)

# compute labor on a unit-area basis
labor_per_area_df <- pnc_areas %>% 
  left_join(labor_man_hrs) %>% 
  mutate(
    total_area_m2 = measurements::conv_unit(total_area_ha, "hectare", "m2"),
         man_hr_per_m2= total_man_hr / total_area_m2,
         man_hr_per_100m2= 100*man_hr_per_m2 ) %>% 
  select(type, man_hr_per_100m2) %>% 
  left_join(area_colors) %>% 
  filter(type %in% c("Turf", "Warning track", "Infield skin")) %>% 
  mutate(type= as_factor(type),
         type= fct_reorder(type, 1/man_hr_per_100m2),
         label= paste0("**", as.character(type), "**") )

# build plot 
labor_per_area <- labor_per_area_df %>% 
  ggplot(aes(man_hr_per_100m2, type, fill= hex_color, label= label))+
  geom_col(alpha = 0.9)+
  labs(title= "Labor allocation on a typical MLB game day*",
       caption= "* Values computed by the author via personal experience.",
       y="Field component",
       x = expression("Labor intensity, worker-hr"~m^-2))+
       # x= TeX("Labor intensity, worker-hr $\\m^{-2}$") )+
  ggtext::geom_richtext(aes(x= man_hr_per_100m2 +0.01), #, color= hex_color),
                        color= "black",
                        fill= NA, 
                        label.color= NA, 
                        size= 12/.pt, 
                        hjust= 0) +
  scale_fill_identity()+
  scale_color_identity()+
  scale_x_continuous(limits= c(0, 1.5), n.breaks = 5,
                     expand = expansion(mult = 0.02)
                     )+
  background_grid()+
  theme_minimal_vgrid()+
  theme(axis.title.y = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks.y = element_blank(),
        axis.line.y = element_blank(),
        axis.line.x= element_line(size = 0.5),
        plot.title = element_text(hjust = 0.5)
  )

# write to disk 

# first find the correct aspect ratio from the 
# player-locations figure 


aspect_ratio_tbl <- magick::image_read(
  here::here(
    'images', 'illustrations', 'player-locations', 'player-locations.png'
  )
) %>% 
  magick::image_info() %>% 
  dplyr::select(width, height)

aspect_ratio <- aspect_ratio_tbl$width / aspect_ratio_tbl$height


ecmfuns::export_plot(
  x = labor_per_area,
  base_asp = aspect_ratio,
  dpi = 600
)