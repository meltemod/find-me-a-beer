###
#
# Generate the one-mode beer networks
#
###

#question
research_desktop = TRUE

#data locations
bucket = 'D:\\data\\socialmediadata-beeradvocate'
if(research_desktop == TRUE){bucket = '/N/project/c19/beer-advocate'}
loc_import = 'data_bipartite_network'
loc_export = 'data_onemode_network'

if(dir.exists( file.path(bucket,loc_export) ) == FALSE){dir.create( file.path(bucket,loc_export) )}

#libraries
library(data.table)

#load data
weights = c('review_overall',
            'review_aroma',
            'review_appearance',
            'review_palate',
            'review_taste')

fname = paste0('bipartite_edgelist_', weights[1], '.csv')

df = fread(file.path(bucket,loc_import,fname))

df1 = df[ ,.(beer_name, review_profilename, scale)]
setnames(df1, c('beer_name', 'scale'), c('beer_name.1', 'scale.1') )
df2 = df[ ,.(beer_name, review_profilename, scale)]
setnames(df2, c('beer_name', 'scale'), c('beer_name.2', 'scale.2') )
rm(df)
gc()
result = merge(df1, df2, by = 'review_profilename', allow.cartesian=TRUE)
result = result[ beer_name.1 != beer_name.2]
