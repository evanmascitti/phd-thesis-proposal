# read the two files (one for regular season and one for post-season) I queried
# them separately because there were **just** too big to download in one single
# file.....statcast limits queries to 40,000 rows and the last 3 games of the WS
# puts the data set over this limit.
# bind the two files and select only relevant columns 

complete <- c('data/lit-review-data/2020-savant-data-reg-season.csv',
  'data/lit-review-data/2020-savant-data-post-season.csv') %>% 
  map(read_csv) %>% 
  reduce(rbind) %>% 
  select(game_date, home_team, hc_x, hc_y)

complete %>% write_csv('data/lit-review-data/complete-2020-savant-data.csv')
