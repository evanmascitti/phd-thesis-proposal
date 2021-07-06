library(magick)
library(magrittr)

panels <- c("images/example-pl-thread-above-pl.png",
            "images/example-pl-thread-at-pl.jpg")  %>% 
  image_read() 

panels %>%
  image_scale('1000') %>% 
  image_annotate(text = paste0(LETTERS[1:2], '.'),
                 size = 100,
                 location = '+25+25',
                 color = 'white',
                 strokecolor = 'black',) %>% 
  image_border(color = 'white', geometry = "20x20") %>% 
  image_append() %>% 
  image_write('./figs/png/example-pl-threads-panels.png')

