library(magrittr)
library(magick)

# find all repair images 
all_daily_process_imgs <- list.files(path = '../../cleatmarkmethod/photos-and-screen-recordings/daily-repairs/', full.names = T)[c(2, 3, 9, 10)]

# grab only the relevant ones 
daily_process_imgs <- all_daily_process_imgs[c(2, 3, 9, 10)]

panels <- all_daily_process_imgs %>% 
  image_read() %>% 
  magick::image_annotate(
    text = paste0(LETTERS[1:length(daily_process_imgs)], "."),
    size = 500, 
    location = magick::geometry_point(200,0), 
    color = 'black') %>% 
  image_montage(tile = '2x2', geometry = '0x400+5+5')

# test out 
panels %>% image_scale('400')


# save to disk 
magick::image_write(image = panels, 
                    path = 'figs/png/daily-specimen-repairs-panels.png',
                    format = 'png')