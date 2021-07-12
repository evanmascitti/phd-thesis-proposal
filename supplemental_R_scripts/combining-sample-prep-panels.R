library(magrittr)
library(magick)


img1 <- magick::image_read('presentations/presentation-figs/cement-mixer.JPG') %>% 
  image_convert(format = "png")

img2 <- magick::image_read('presentations/presentation-figs/deriving-proctor-values.png')

img3 <- magick::image_read('presentations/committee-meeting-2-presentation-dependencies/heat-lamps.JPG') %>% 
  image_convert(format = "png")

imgs <- c(img1, img2, img3 )

imgs %>% 
  image_scale(geometry = geometry_size_pixels(height = 800)) %>% 
  image_border('white', "10x10") %>% 
  image_append() %>% 
  image_write('./presentations/presentation-figs/specimen-preparation-process-panels.png', format = 'png')


imgs %>% 
  image_scale(geometry = geometry_size_pixels(height = 800)) %>% 
  image_border('white', "10x10") %>% 
  image_append() %>% 
  image_scale('400')
