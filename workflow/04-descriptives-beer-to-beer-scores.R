###
#
# Descriptives: beer-to-beer scores
#
###
#question
research_desktop = TRUE

#data locations
bucket = 'D:\\data\\socialmediadata-beeradvocate'
if(research_desktop == TRUE){bucket = '/N/project/c19/beer-advocate'}
loc_import = 'data_beer_to_beer_scores'
loc_export = 'descriptives_beer_to_beer_scores'

if(dir.exists( file.path(bucket,loc_export) ) == FALSE){dir.create( file.path(bucket,loc_export) )}

#libraries
library(data.table)
library(fst)
library(stringr)
library(ggplot2)

weights = c('review_overall',
            'review_aroma',
            'review_appearance',
            'review_palate',
            'review_taste')
type = c('origin', 'scale', 'scale_byuser')

w = weights[1]
t = type[1]



fname = paste0('beer_to_beer_score_', w, "_", t, ".fst")
df = read_fst(file.path(bucket,loc_import,fname))
df = as.data.table(df)

keep = sample(c(1:nrow(df)), nrow(df)/150, replace=F)
df = df[keep]

p = ggplot(df, aes(x = score_overall_origin)) +
  geom_histogram(color="black", alpha = .2, fill = "#FF6666") +
  geom_vline(aes(xintercept=mean(score_overall_origin)),
             color="red", linetype="dashed", size=.5) +
  aes(y = stat(count)*150/10^6) +
  labs(x = "beer-to-beer scores", y="count (in million)") +
  theme_classic()
p

ggsave(file.path(bucket, loc_export, "test1.jpg"))



