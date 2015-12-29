library(plyr)
library(dplyr)
library(ggplot2)
library(readr)

gap_dat <- read_tsv("04_gap-merged.tsv") %>% 
  mutate(country = factor(country),
         continent = factor(continent))
gap_dat %>% str
# Classes ‘tbl_df’, ‘tbl’ and 'data.frame':	3312 obs. of  6 variables:
# $ country  : Factor w/ 187 levels "Afghanistan",..: 1 1 1 1 1 1 1 1 1 1 ...
# $ continent: Factor w/ 6 levels "Africa","Americas",..: 3 3 3 3 3 3 3 3 3 3 ...
# $ year     : int  1952 1957 1962 1967 1972 1977 1982 1987 1992 1997 ...
# $ lifeExp  : num  28.8 30.3 32 34 36.1 ...
# $ pop      : int  8425333 9240934 10267083 11537966 13079460 14880372 12881816 13867957 16317921 22227415 ...
# $ gdpPercap: num  779 821 853 836 740 ...
gap_dat$continent %>% summary()
# Africa Americas     Asia   Europe      FSU  Oceania     NA's 
#    613      343      557     1302      122       74      301 
## 301 rows have no continent data.  That is a problem.

## I've never heard of the continent of FSU.
tmp <- gap_dat %>%
  filter(continent == "FSU") %>%
  droplevels()
tmp$country %>% levels()
## [1] Belarus    Kazakhstan Latvia     Lithuania  Russia     Ukraine
## FSU = Former Soviet Union (?)

## which countries do not have continent data?
tmp <- gap_dat %>%
  filter(is.na(continent)) %>%
  droplevels()
tmp$country %>% levels()
# [1] "Armenia"               "Aruba"                 "Australia"            
# [4] "Bahamas"               "Barbados"              "Belize"               
# [7] "Canada"                "French Guiana"         "French Polynesia"     
# [10] "Georgia"               "Grenada"               "Guadeloupe"           
# [13] "Haiti"                 "Hong Kong, China"      "Maldives"             
# [16] "Martinique"            "Micronesia, Fed. Sts." "Netherlands Antilles" 
# [19] "New Caledonia"         "Papua New Guinea"      "Reunion"              
# [22] "Samoa"                 "Sao Tome and Principe" "Tonga"                
# [25] "Uzbekistan"            "Vanuatu"      

# writeLines(tmp$country %>% levels, "foo.txt")

## populate missing values of continent
cont_dat <- c('country, continent',
              'Armenia, FSU',
              'Aruba, Americas',
              'Australia, Oceania',
              'Bahamas, Americas',
              'Barbados, Americas',
              'Belize, Americas',
              'Canada, Americas',
              'French Guiana, Americas',
              'French Polynesia, Oceania',
              'Georgia, FSU',
              'Grenada, Americas',
              'Guadeloupe, Americas',
              'Haiti, Americas',
              '"Hong Kong, China", Asia',
              'Maldives, Asia',
              'Martinique, Americas',
              '"Micronesia, Fed. Sts.", Oceania',
              'Netherlands Antilles, Americas',
              'New Caledonia, Oceania',
              'Papua New Guinea, Oceania',
              'Reunion, Africa',
              'Samoa, Oceania',
              'Sao Tome and Principe, Africa',
              'Tonga, Oceania',
              'Uzbekistan, FSU',
              'Vanuatu, Oceania')

cont_dat <- read.csv(text = cont_dat, strip.white = TRUE)

gap_dat <- gap_dat %>%
  ## 2015-12-29
  ## dplyr bug means we can't use inner_join right now
  ## https://github.com/hadley/dplyr/issues/1559
  #left_join(cont_dat, by = "country") %>%
  merge(cont_dat, by = "country", all = TRUE) %>% 
  tbl_df() %>%
  mutate(continent = factor(ifelse(is.na(continent.y),
                                   as.character(continent.x),
                                   as.character(continent.y))),
         continent.x = NULL,
         continent.y = NULL) %>%
  arrange(country, year)
gap_dat %>% str()
# Classes ‘tbl_df’, ‘tbl’ and 'data.frame':	3312 obs. of  6 variables:
# $ country  : Factor w/ 187 levels "Afghanistan",..: 1 1 1 1 1 1 1 1 1 1 ...
# $ year     : int  1952 1957 1962 1967 1972 1977 1982 1987 1992 1997 ...
# $ lifeExp  : num  28.8 30.3 32 34 36.1 ...
# $ pop      : int  8425333 9240934 10267083 11537966 13079460 14880372 12881816 13867957 16317921 22227415 ...
# $ gdpPercap: num  779 821 853 836 740 ...
# $ continent: Factor w/ 6 levels "Africa","Americas",..: 3 3 3 3 3 3 3 3 3 3 ...

gap_dat$continent %>% summary()
# Africa Americas     Asia   Europe      FSU  Oceania 
#    637      470      577     1302      139      187 

my_vars <- c('country', 'continent', 'year',
             'lifeExp', 'pop', 'gdpPercap')
gap_dat <- gap_dat[my_vars]

write_tsv(gap_dat, "06_gap-merged-with-continent.tsv")
