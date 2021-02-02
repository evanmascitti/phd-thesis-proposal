sand_pcts <- tibble::tibble(method= c(rep("Equal interval", 10), rep("Clustered", 12) ),
                    sand_pct= c(seq(0, 90, 10),
                                c(0, 25,50,57.5,62.5,65,67.5,70,72.5,75, 77.5, 82.5))
)

sand_pcts_to_choose <- sand_pcts %>% 
  ggplot2::ggplot(ggplot2::aes(sand_pct, method, color=method))+
  ggplot2::geom_rect(xmin=62.5, xmax= 77.5, ymin=-Inf, ymax=2.2,
            alpha=1/50,
            color=NA)+
  ggplot2::geom_point(alpha=0.7, size= 5)+
  ggplot2::scale_x_continuous("% sand",
                     breaks = scales::breaks_width(width = 5, offset = 0),
                     limits = c(0, 100),
                     expand = ggplot2::expansion(mult=c(0,0), add = c(2,2)))+
  ggplot2::annotate("text",
           label= "Critical transition range",
           size=8,
           x= 70,
           y=2.5)+
  ggplot2::geom_segment(color= "black", x=65, xend= 75,
               y=2.3, yend=2.3)+
  ggplot2::geom_segment(color= "black", x=62.5, xend=65, y=2.2, yend=2.3)+
  ggplot2::geom_segment(color= "black", x=77.5, xend=75, y=2.2, yend=2.3)+
  ggplot2::geom_segment(color= "black", x=70, xend=70, y=2.3, yend=2.4)+
  ggplot2::scale_color_brewer(name= "Data point spacing",
                     palette = "Dark2")+
  ggplot2::theme(
    axis.text.y = ggplot2::element_blank(),
    axis.title.y = ggplot2::element_blank(),
    panel.grid.major.y = ggplot2::element_blank(),
    text = ggplot2::element_text(size=22),
    axis.text.x = ggplot2::element_text(size=22),
    axis.title.x = ggplot2::element_text(size=28),
    legend.position = "top"
  )

