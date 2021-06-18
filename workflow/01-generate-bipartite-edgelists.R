###
#
# Generate the bipartite network
#
###

#question
research_desktop = TRUE

#data locations
bucket = 'D:\\data\\socialmediadata-beeradvocate'
if(research_desktop == TRUE){bucket = '/N/project/c19/beer-advocate'}
loc_import = 'data_raw'
loc_export = 'data_bipartite_network'

if(dir.exists( file.path(bucket,loc_export) ) == FALSE){dir.create( file.path(bucket,loc_export) )}

#libraries
library(data.table)

#load data
file_import = 'beer_reviews.csv'
df = fread( file.path(bucket, loc_import, file_import) )

#we have 5 values for weights. I will generate 5 different bipartite
#network edgelist data for those 5 different weights.
weights = c('review_overall',
            'review_aroma',
            'review_appearance',
            'review_palate',
            'review_taste')

scale_weights = function(data, ego, alter, weight){
    colnames = c(ego, alter, weight)
  result = data[ , ..colnames]
  result = result[  ,scale := scale(eval(parse(text = w)))]
  result = result[  ,scale := round(scale,3)]
  result = result[ ,scale_byuser := scale(eval(parse(text = w))), by = review_profilename]
  result = result[  ,scale := round(scale_byuser,3)]
  result
}

ego = 'beer_beerid'
alter = 'review_profilename'

weights = c('review_overall',
            'review_aroma',
            'review_appearance',
            'review_palate',
            'review_taste')

for (w in weights){
  print(w)
  tmp = scale_weights(data = df,
                      ego = ego,
                      alter = alter,
                      weight = w)
  fname = paste0('bipartite_edgelist_',w,'.csv')
  fwrite(tmp, file.path(bucket,loc_export,fname))
}



