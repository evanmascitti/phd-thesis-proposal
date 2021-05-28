# This is to draw a diagram illusrating the intergranular void ratio
# concept. 
# I still have to manually panel the drawing of the grains 
# with this diagram in Illustrator as I don't know how 
# to draw the sand grains in ggplot. 



suppressPackageStartupMessages({
  library(ggplot2)
  library(showtext)
  library(tibble)
  library(purrr)
  library(soiltestr)
})

# configure fonts 
all_fonts <- systemfonts::system_fonts()


fira_math_path <- all_fonts[grepl(pattern = 'fira.*math', x = all_fonts$name, ignore.case = T), ]$path

font_add('fira-math', fira_math_path)

showtext_auto()


# draw a phase diagram with the numbers on it 
# this is two stages
# I might want to eventually generalize it,
# but for now I am just trying to show what 
# the clay and water volumes are both considered voids for 
# computing e_sa

base_list <- ggphase_diagram(sand_pct = 0.75, clay_pct = 0.25, G_sa = 2.7, G_c = 2.7, dry_density = 2.055, water_content = 0.117, sand_color = '#c2b280', clay_color = 'coral4', alpha_level = 1/2, labels = FALSE)


base_plot <- base_list$phase_diagram_plot

# create a series data frames for labels and lines 

phase_volumes <- base_list$phase_volumes %>%
  dplyr::select(dplyr::matches('v_(sa|c|w)$'))

phase_masses <- base_list$phase_volumes %>% 
  dplyr::select(dplyr::matches('m_(sa|c|w)$')) 

hz_segments <- tibble(
  x = 0.205,
  xend = 0.21,
  y = c(0.01,(phase_volumes$v_sa - 0.01) , (phase_volumes$v_sa + 0.01), 0.99),
  yend= y
)

vertical_segments <- tibble(
  x = 0.21,
  xend = 0.21,
  y = c(0.01, (phase_volumes$v_sa  + 0.01)),
  yend= c((phase_volumes$v_sa - 0.01), 0.99))

lumped_labels <- tibble(
  x= 0.245,
  y= c(phase_volumes$v_sa/2, 1-(1-phase_volumes$v_sa)/2),
  label = c(expression(V[sand]),
            expression(V[voids])))

# these are the relevant values computed by ggphase diagram 
# they are used by the plot and by the proposal as 
# dynamically generated text 

individual_phase_labels <- tibble(
  x= 0.15,
  y= c(phase_volumes$v_sa/2, 
       (phase_volumes$v_sa + phase_volumes$v_c/2), 
       (phase_volumes$v_sa + phase_volumes$v_c + phase_volumes$v_w/2)),
  label = c(bquote(V[sand]==.(round(phase_volumes$v_sa, digits = 2))),
            bquote(V[clay]==.(round(phase_volumes$v_c, digits = 2))),
            bquote(V[water]==.(round(phase_volumes$v_w, digits = 2))))
)


# draw plot 
output_plot <- base_plot+
  geom_segment(data = hz_segments,
               inherit.aes = F, 
               aes(x=x, xend=xend, y=y, yend=yend))+
  geom_segment(data = vertical_segments,
               inherit.aes = F, 
               aes(x=x, xend=xend, y=y, yend=yend))+
  geom_text(data = individual_phase_labels,
            inherit.aes = FALSE,
            aes(x=x,y=y,label=label),
            size = 4,
            parse = TRUE,
            family = 'fira-math')+
  geom_text(data = lumped_labels,
            inherit.aes = FALSE,
            aes(x=x,y=y,label=label),
            size = 5,
            parse = TRUE,
            family = 'fira-math')+
  scale_x_continuous(limits = c(0.075, 0.35))
  
  
# write to disk
svglite::svglite(file = here::here('images/illustrations/transitional-fines-content/intergranular-voids-ggplot-75-pct-sand.svg'),
                 width = 6, height = 9, 
                 )
output_plot
dev.off()

# save water content as its own object so I can avoid deleting 
# it with a regular expression 

phase_diagram_w <- base_list$phase_volumes$w

# remove other objects so only the data I want is passed back to 
# the R session that sources this file 

rm(list = ls()[!stringr::str_detect(ls(), 'phase_masses|phase_volumes|phase_diagram_w')])

