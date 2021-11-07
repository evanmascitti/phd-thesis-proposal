setwd("E:/onedrive-psu/PSU2019-present/A_inf_soils_PhD/sandClay1/")

library(kableExtra)
library(purrr)


w_data <- readr::read_rds("ecmdata/derived-data/cleaned-rds-files/cleat-mark-test-time-volumetric-water-contents-cleaned-data.rds")

metrics_data <- readr::read_rds("ecmdata/derived-data/cleaned-rds-files/cleat-mark-ply-metrics.rds")


mix_meta <- readr::read_csv(
  "./ecmdata/metadata/mixture-metadata.csv",
  show_col_types = FALSE,
  lazy = FALSE,
  na = "-") %>%
  dplyr::rename(mix_comments = comments)

test_meta <- readr::read_csv(
  "./ecmdata/metadata/cleat-mark-test-dates.csv",
  show_col_types = FALSE,
  lazy = FALSE,
  na = "-"
) %>%
  tidyr::pivot_longer(
    cols = dplyr::contains('test_date'),
    names_to = 'run',
    values_to = 'date',
    names_prefix = 'test_date_',
    names_transform = list(run = as.numeric)) %>%
  dplyr::rename(test_comments = comments)

meta <- dplyr::left_join(
  mix_meta, test_meta, by = 'sample_name')


# combine everything together...don't use the data from 2021-09-22....samples were really sticky
combined_data <- purrr::reduce(list(w_data, metrics_data, meta), .f = dplyr::left_join) %>%
  dplyr::filter(date > '2021-09-22')


names(combined_data)

interaction_model <- lm(
  data = combined_data,
  formula = dne ~ volumetric_water_content + clay_name * splines::ns(sand_pct, 3)
)

interaction_anova_kbl <- car::Anova(mod = interaction_model, type = 2) %>% 
  tibble::rownames_to_column(var = "Term") %>% 
  tibble::as_tibble() %>% 
  dplyr::select(-`Sum Sq`) %>% 
  dplyr::mutate(Term = c(
    "Volumetric water content",
    "Clay type",
    "Sand %",
    "Clay type x sand %",
    "Residual"
  )) %>% 
  set_names(c("Term", "Deg. Fr.", "F-value", "p-value")) %>% 
  dplyr::mutate(
    `p-value` = dplyr::case_when(
      `p-value` < 0.001 ~ "<0.001 ***",
      `p-value` >= 0.001 & `p-value` < 0.01 ~ paste(as.character(round(`p-value`, digits = 3), " **")),
      `p-value` >= 0.01 & `p-value` < 0.05 ~ paste(as.character(round(`p-value`, digits = 3)), "  *"))) %>% 
  dplyr::mutate(`F-value` = round(`F-value`, digits = 1))





# clean up

setwd("E:/onedrive-psu/PSU2019-present/A_inf_soils_PhD/drafts/phd-thesis-proposal/")
