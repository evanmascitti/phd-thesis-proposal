# I will still need to draw the sand grains in Illustrator as I'm not sure # how to make them oriented and aligned with sand-grain shapes instead of just cicles.
# However drawing the blue background and the clay particle would be really tedious 
# so I am going to try it with ggplot 


# with the help of the relatively new sytemfonts package 
# and the older sysfonts and showtext packages,
# I also figured out how to reliably use system fonts 
# in R plots. Cool! 


# The key is finding the path to the actual font file,
# then using sysfonts to add it to the environment I guess?
# Maybe a hidden object? idk. Anywa, it works when I call the 
## family. You have to give it a name when adding to the session
# with add_font().

suppressPackageStartupMessages({
  library(ggplot2)
  library(magrittr)
  library(showtext)
})

all_fonts <- systemfonts::system_fonts()

# roboto_path <- all_fonts %>% 
#   dplyr::filter(family == 'Roboto', stringr::str_detect(path, stringr::regex('regular', ignore_case = TRUE))) %>% 
#   purrr::pluck('path')
# font_add(family = "Roboto", regular = roboto_path)
# 
# times_font_path <- all_fonts %>% 
#   dplyr::filter(stringr::str_detect(name, 'Times')) %>% 
#   purrr::pluck('path') %>% .[[1]]
# font_add(family = 'TNR', regular = times_font_path)
# 
# 
# crazy_font_path <- all_fonts %>% 
#   dplyr::filter(stringr::str_detect(name, 'Chiller')) %>% 
#   purrr::pluck('path') %>% 
#   .[[1]]
# font_add(family = 'chiller', regular = crazy_font_path)

# use Fira Math for the titles 

fira_math_path <- all_fonts[grepl(pattern = 'fira.*math', x = all_fonts$name, ignore.case = T), ]$path

font_add('fira-math', fira_math_path)

showtext_auto()

theme_set(theme_void())

set.seed(1)

clay_coords <- function(n_particles, particle_length = 7.5){
  
  clay_coords <- tibble::tibble(
    x = sample(x=100, size = n_particles, replace = TRUE),
    xadj = runif(n=n_particles, min = -7.5, max = 7.5),
    xend = x + xadj,
    y = sample(x=200, size = n_particles, replace = TRUE),
    yadj = runif(n=n_particles, min = -7.5, max =7.5),
    yend = y + yadj
  ) %>% 
    dplyr::select(-c(contains('adj')))
  
}


plot_clay_particles <- function(df, title){
  
  df %>% 
    ggplot()+
    geom_rect(aes(xmin=0, ymin=0, xmax=100, ymax=200), fill = "#d4f1f9")+
    geom_segment(aes(x=x, xend=xend, y=y, yend=yend), size = 0.25, color = 'coral4')+
    coord_fixed()+
    labs(title = title)+
    scale_x_continuous(limits = c(0,100), expand = c(0,0))+
    scale_y_continuous(limits = c(0,200), expand = c(0,0))+
    theme(panel.border = element_rect(color = 'black',
                                      size = 0.25,
                                      fill = NA),
          plot.margin = margin(5, 5, 5, 5),
          plot.title = element_text(family = 'fira-math',
                                    hjust = 0.5,
                                    size = 6))
  }

n_particles_vec <- c(0, 500, rep(4e3, 3))

titles_vec <- list(
  expression(m[fines]==0),
  expression(m[fines]<TFC),
  expression(m[fines]==TFC),
  expression(m[fines]>TFC),
  expression(m[fines]==1)
)

panels <-  n_particles_vec %>% 
  purrr::map(clay_coords) %>% 
  purrr::map2(.x = ., .y = titles_vec, .f = plot_clay_particles) %>% 
  patchwork::wrap_plots(., nrow = 1)+
  theme(plot.margin = margin())

panels

svglite::svglite(file = './images/illustrations/transitional-fines-content/tfc-clay-panels.svg',
                 width = 3.25,
                 height = 2.25
                 )
panels
dev.off()

