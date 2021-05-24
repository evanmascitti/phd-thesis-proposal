library(magick)
library(magrittr)

panels <- list.files(path = 'images/', pattern = 'example-pl-thread',
                     full.names = T)%>% 
  image_read() 

panels %>%
  image_scale('1000') %>% 
  image_annotate(text = paste0(LETTERS[1:2], '.'),
                 size = 100,
                 location = '+25+25',
                 color = 'white',
                 strokecolor = 'black',) %>% 
  image_append() %>% 
  image_write('./figs/png/example-pl-threads-panels.png')

