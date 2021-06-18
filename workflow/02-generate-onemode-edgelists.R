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
library(fst)

#load data
weights = c('review_overall',
            'review_aroma',
            'review_appearance',
            'review_palate',
            'review_taste')


one_mode_edgelist = function(data,
                             ego = 'beer_beerid',
                             alter = 'review_profilename',
                             weight,
                             type = c('origin', 'scale', 'scale_byuser')){
  if(type == 'origin'){
    n = c(ego, alter, weight)
  }else{
    n = c(ego, alter, type)
  }
  data = data[ ,..n]
  gc()
  result = merge(data, data, by = 'review_profilename', allow.cartesian=TRUE)
  result = result[ beer_beerid.x < beer_beerid.y, -c('review_profilename')] #eliminate duplicates
  result
}

# get_scores = function(result,
#                              ego = 'beer_beerid',
#                              alter = 'review_profilename',
#                              weight,
#                              type = c('origin', 'scale', 'scale_byuser')){
#   cname = paste0(type,'_overlap')
#   n1 = names(result)[2]
#   n2 = names(result)[4]
#   print('calculating scores...')
#   result[ , (cname):= round(eval(parse(text=n1)) * eval(parse(text=n2)),3)]
#   n = c('beer_beerid.x', 'beer_beerid.y', cname)
#   result = result[ , ..n]
#   cname_mean = paste0(cname,'_mean')
#   cname_sd = paste0(cname,'_sd')
#   print('calculating counts...')
#   result[, count := .N, by = c('beer_beerid.x', 'beer_beerid.y')]
#   print('calculating means...')
#   result[, (cname_mean) := round(mean(scale_overlap),3), by = c('beer_beerid.x', 'beer_beerid.y')]
#   print('calculating sds...')
#   result[, (cname_sd) := round(sd(scale_overlap),3), by = c('beer_beerid.x', 'beer_beerid.y')]
#   n = c('beer_beerid.x', 'beer_beerid.y', 'count', cname_mean, cname_sd)
#   result = result[, ..n]
#   result = unique(result)
#   result
# }


for(w in weights){
  print(paste('opening',w ,'data'))
  fname = paste0('bipartite_edgelist_', w, '.csv')
  df = fread(file.path(bucket,loc_import,fname))
  df = data.table(df)
  df = df[review_profilename != '']
  for(t in c('origin', 'scale', 'scale_byuser')){
    print(paste(w,t))

    df_new = one_mode_edgelist(data = df, weight = w, type = t)
    fname = paste0('onemode_edgelist_', w, "_", t, ".fst")
    write_fst(df_new, file.path(bucket,loc_export,fname), 100)
    rm(df_new)
    gc()
  }
  rm(df)
  gc()
}
