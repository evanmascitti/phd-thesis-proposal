# This is to draw a diagram illusrating the intergranular void ratio
# concept. 
# I still have to manually panel the drawing of the grains 
# with this diagram in Illustrator as I don't know how 
# to draw the sand grains in ggplot. 



suppressPackageStartupMessages({
  library(ggplot2)
  library(magrittr)
  library(showtext)
  library(tibble)
  library(soiltestr)
})

# configure fonts 
all_fonts <- systemfonts::system_fonts()
hz_segments <- tibble(
  x = 0.205,
  xend = 0.21,
  y = c(0.01, 0.44, 0.45, 0.99),
  yend= y
)

fira_math_path <- all_fonts[grepl(pattern = 'fira.*math', x = all_fonts$name, ignore.case = T), ]$path

font_add('fira-math', fira_math_path)

showtext_auto()

# create data frames for labels 

vertical_segments <- tibble(
  x = 0.21,
  xend = 0.21,
  y = c(0.01, 0.45),
  yend= c(0.44, 0.99))

lumped_labels <- tibble(
  x= 0.245,
  y= c(mean(vertical_segments$y), mean(vertical_segments$yend)),
  label = c(expression(V[sand]),
  expression(V[voids])))

individual_phase_labels <- tibble(
  x= 0.15,
  y= c(mean(vertical_segments$y), 0.6, 0.875),
  label = c(expression(V[sand]),
            expression(V[clay]),
            expression(V[water])))



# draw plot 
intergranular_voids <- ggphase_diagram(sand_pct = 0.6, clay_pct = 0.4, G_sa = 2.7, G_c = 2.7, dry_density = 2, water_content = 0.13, sand_color = '#c2b280', clay_color = 'coral4', alpha_level = 1/2, labels = FALSE, values = FALSE)+
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


svglite::svglite(file = 'images/illustrations/transitional-fines-content/intergranular-voids-ggplot.svg',
                 width = 2.5, height = 4, 
                 )
intergranular_voids
dev.off()

intergranular_voids
