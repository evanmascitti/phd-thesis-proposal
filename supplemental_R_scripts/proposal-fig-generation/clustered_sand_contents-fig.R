library(magrittr)


ggplot2::theme_set(ggplot2::theme_minimal())


sand_pcts <- tibble::tibble(
                    sand_pct_equal_interval= seq(0, 100, 20),
                    sand_pct_clustered = c(50, 60, 65, 70, 75, 80),
                    # c(0, 25,50,57.5,62.5,65,67.5,70,72.5,75, 77.5, 82.5)),
                    ) %>% 
  dplyr::mutate(pt_number = 1:nrow(.)) %>% 
  tidyr::pivot_longer(cols = dplyr::contains('sand_pct'),
                      names_to = 'method',
                      values_to = 'sand_pct') %>% 
  dplyr::relocate(pt_number, .before = dplyr::everything()) %>% 
  dplyr::mutate(method = stringr::str_trim(
    stringr::str_replace_all(
      stringr::str_to_title(
        stringr::str_remove(method, 'sand_pct')), '_', ' ')))

( sand_pcts_to_choose <- sand_pcts %>% 
  ggplot2::ggplot(ggplot2::aes(sand_pct, method, color=method))+
  ggplot2::geom_rect(xmin=65, xmax= 75, ymin=-Inf, ymax=2.2,
            alpha=1/100,
            color=NA)+
  ggplot2::geom_point(alpha=0.7, size= 4)+
  ggplot2::scale_x_continuous("% Sand-size",
                     breaks = scales::breaks_width(width = 10, offset = 0),
                     limits = c(0, 100),
                     expand = ggplot2::expansion(mult=c(0,0), add = c(2,2)))+
  ggplot2::annotate("text",
           label= "Critical transition range",
           size=5,
           x= 67.5,
           y=2.5)+
  ggplot2::geom_segment(color= "black", x=65, xend= 75,
               y=2.3, yend=2.3)+
  ggplot2::geom_segment(color= "black", x=65, xend=65, y=2.2, yend=2.3)+
  ggplot2::geom_segment(color= "black", x=75, xend=75, y=2.2, yend=2.3)+
  ggplot2::geom_segment(color= "black", x=mean(c(65, 75)), xend=mean(c(65, 75)), y=2.3, yend=2.4)+
  ggplot2::scale_color_brewer(name= "Data point spacing",
                     palette = "Dark2")+
    ggplot2::labs(title = "Clustering of mixtures around the transitional fines content")+
  ggplot2::theme(
    panel.grid = ggplot2::element_line(size - 0.25, color = 'grey90'),
    axis.text.y = ggplot2::element_blank(),
    axis.title.y = ggplot2::element_blank(),
    panel.grid.major.y = ggplot2::element_blank(),
    panel.grid.minor.x = ggplot2::element_blank(),
    #text = ggplot2::element_text(size=22),
    #axis.text.x = ggplot2::element_text(size=22),
   # axis.title.x = ggplot2::element_text(size=28),
    legend.position = "none"
  ))


ecmfuns::export_plot(dirs = 'figs', x = sand_pcts_to_choose, formats = c('pdf', 'png'))
