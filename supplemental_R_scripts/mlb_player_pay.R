# read data 
library(magrittr)
ggplot2::theme_set(cowplot::theme_cowplot())


remove_y_lines <- function(){
  ggplot2::theme(
    axis.line.y = ggplot2::element_blank(),
    axis.ticks.y = ggplot2::element_blank(),
  )
}


salaries <- tibble::tibble(
  path  = "data/lit-review-data/player_salaries/mlb_salaries_2000-2020_excel_format.xlsx",
  sheet = 1:length(readxl::excel_sheets("data/lit-review-data/player_salaries/mlb_salaries_2000-2020_excel_format.xlsx"))
) %>% 
  purrr::pmap(readxl::read_excel, skip = 1) %>% 
  purrr::set_names(2020:2000) %>%  
  purrr::map(.f= dplyr::select, dplyr::contains('player'), matches(match = "\\d{4}")) %>% 
  purrr::map(dplyr::rename, player = 1, salary = 2) %>% 
  tibble::enframe(name = 'year') %>% 
  tidyr::unnest(value) %>% 
  dplyr::mutate(year = as.double(year))

years <- 2020:2000

total_2019_payroll_billions <- salaries %>% 
  dplyr::filter(year == 2019) %>% 
  .$salary %>% 
  sum(., na.rm = T)/10^9

salary_distribution_2019_plot <- salaries  %>%
  dplyr::filter(year == 2019) %>% 
  ggplot2::ggplot(ggplot2::aes(salary))+
  ggplot2::geom_histogram(bins = 30,
                          alpha= 0.5, 
                          fill= 'darkgreen', 
                          color = 'darkgreen',
                          size = 0.25)+
  ggplot2::scale_x_continuous(name = expression(Annual~player~salary~(log[10]~scale)),
                              trans= 'log10',
                              limits= c(5*10^5, 5*10^7),
                              breaks = 5*10^c(5:7),
                              labels = scales::label_dollar())+
  ggplot2::scale_y_continuous(name = "n",
                              limits = c(0, 100),
                              breaks = seq(0, 100, 20))+
  # ggplot2::geom_segment(ggplot2::aes(x= 6*10^5,
  #                                    xend = 6.2*10^5,
  #                                    y= 97,
  #                                    yend= 100),
  #                       size = 0.25,
  #                       color ='grey75')+
  ggplot2::annotate('text', 
                    x=0.8*10^6,
                    y=96,
                    label = 'league minimum \n($555,000)',
                    vjust = 'inward',
                    hjust = 'inward',
                    label.size = 0,
                    label.padding = ggplot2::unit(0.125, "lines"), 
                    color = 'grey50',
                    size = 1.75)+
  ggplot2::labs(title = '2019 MLB player salaries',
                subtitle = glue::glue("Total payroll = {scales::dollar(total_2019_payroll_billions, suffix = ' billion')}"))+
  cowplot::theme_cowplot(font_size = 12)+
  ggplot2::theme(
    axis.title.y = ggplot2::element_text(angle = 0, vjust = 0.5),
    axis.line.y = ggplot2::element_blank(),
    plot.margin = ggplot2::margin(rep(20, 4))
  )
salary_distribution_2019_plot
salary_time_series <- salaries %>% 
  dplyr::group_by(year) %>% 
  dplyr::summarise(mean_salary = mean(salary, na.rm= T),
                   median_salary = median(salary, na.rm= T)) %>% 
  tidyr::pivot_longer(cols = mean_salary:median_salary,
                      names_to = 'salary_measurement',
                      values_to = 'salary') %>%
  dplyr::filter(year < 2020) %>% 
  ggplot2::ggplot(ggplot2::aes(year, salary, color = salary_measurement))+
  ggplot2::scale_x_continuous(breaks = scales::breaks_width(width = 10, offset = 0))+
  ggplot2::geom_line()+
  colorblindr::scale_color_OkabeIto()+
  cowplot::theme_cowplot(font_size = 12)+
  ggplot2::facet_wrap(~salary_measurement, scales = 'free')

#### 

# assign some values to reference in the text 
mlb_salaries_2019 <- dplyr::filter(salaries, year == 2019)

median_2019_salary <- mlb_salaries_2019 %>% 
  .$salary %>%
  median(na.rm = T)

mean_2019_salary <- mlb_salaries_2019 %>% 
  .$salary %>%
  mean(na.rm = T)

median_2019_salary_millions <-  round((median_2019_salary*10^-6 ), 2)

n_players_2019 <- length(na.omit(mlb_salaries_2019$salary))

total_2019_million_dollar_players <- mlb_salaries_2019 %>% 
  dplyr::filter(salary > 10^6) %>% 
  tidyr::drop_na() %>% 
  nrow()

total_2019_10_million_dollar_players <- mlb_salaries_2019 %>% 
  dplyr::filter(salary > 10^7) %>% 
  tidyr::drop_na() %>% 
  nrow()

#############

# plot MLB gross revenues 

# read raw data and compute inflation adjustment
# see https://towardsdatascience.com/the-what-and-why-of-inflation-adjustment-5eedb496e080

mlb_revenues_raw <- readr::read_csv("data/lit-review-data/mlb_revenue/mlb_revenue_1995-2019.csv") %>% 
  dplyr::mutate(gross_revenue = gross_revenue_billions_usd*10^9) %>% 
  dplyr::select(-gross_revenue_billions_usd)

index_cpi <- max(mlb_revenues_raw$cpi)

mlb_revenues <- mlb_revenues_raw %>% 
  dplyr::mutate(infl_adj_rev = gross_revenue*(index_cpi/cpi))

mlb_revenues_plot <- mlb_revenues %>% 
  ggplot2::ggplot(ggplot2::aes(year, infl_adj_rev/10^9))+
  ggplot2::geom_line(color = 'darkgreen', alpha= 0.8)+
  ggplot2::geom_point(color = 'darkgreen', alpha = 0.8)+
  ggplot2::scale_y_continuous(name = 'Gross revenues, billions USD',
                              labels = scales::label_dollar(suffix = " B", accuracy = 1),
                              breaks = seq(0,12,2),
                              limits = c(0, 12))+
  cowplot::theme_cowplot(font_size = 12)+
  cowplot::background_grid(color.major = 'grey95')+
  ggplot2::labs(title = 'MLB gross revenues*',
                caption = '*Values inflation-adjusted to 2019 dollars. \nData source: Forbes',
                x= "")+
  remove_y_lines()+
  ggplot2::theme(plot.margin = ggplot2::margin(rep(15, 4)))



