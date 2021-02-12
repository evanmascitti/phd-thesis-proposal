labels_data <- tibble::tibble(
  soil_type = c("CL", "CH", "CL-ML", 
                "CH-MH", "ML", "MH"),
  LL = c(30, 75, 40, 90, 30, 75),
  PI = c(30, 50, 17, 38, 5, 15 ),
  angle = c(0, 0, 0.6*0.5*(45+30), 0.6*0.5*(45+30), 0, 0))
  
moreno_maroto_chart <- ggplot2::ggplot(data = labels_data, 
                                       mapping = ggplot2::aes(
                                         LL, PI, label = soil_type))+
  ggplot2::geom_text(ggplot2::aes(angle = angle), family = 'sans')+
  ggplot2::scale_x_continuous(limits = c(0,100), 
                              breaks = scales::breaks_width(width = 20, offset = 0),
                              expand = ggplot2::expansion(c(0,0)))+
  ggplot2::scale_y_continuous(limits = c(0, 60), 
                              breaks = scales::breaks_width(width = 20, offset = 0),
                              expand = ggplot2::expansion(c(0,0)))+
  ggplot2::labs(x = "LL", y = "PI") + 
  cowplot::theme_cowplot() +
  cowplot::background_grid(minor = "xy", size.minor = 0.25, size.major = 0.25) + 
  ggplot2::geom_abline(slope = c(1/2, 1/3), linetype= 'dashed', color ='darkblue')+
  ggplot2::geom_vline(xintercept = 50)+
  ggplot2::annotate('text', color = 'darkblue', size = 3.25, 
                    label = 'C-line (PI = 0.5 x LL)', 
                    x= 66, y= 36.5, angle = 0.6*45)+
  ggplot2::annotate('text', color = 'darkblue', size = 3.25, 
                    label = 'M-line (PI = 0.33 x LL)', 
                    x= 68, y= 3.5+66*1/3, angle = 0.6*90*1/3)+
  ggplot2::coord_fixed(ratio = 1)+
  ggplot2::theme(
  panel.background = ggplot2::element_rect(color = 'black', size = 0.25, fill = 'transparent'),
  plot.margin = ggplot2::unit(rep(15, 4), "pt"),
  axis.title.y = ggplot2::element_text(angle = 0,
                                       vjust = 0.5),
  plot.background = ggplot2::element_rect(
    color = "black",
    fill = "transparent",
    size = 0.25)  )
  
