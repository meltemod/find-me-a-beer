###
#
# Generate beer-to-beer scores
#
###
#question
research_desktop = TRUE

#data locations
bucket = 'D:\\data\\socialmediadata-beeradvocate'
if(research_desktop == TRUE){bucket = '/N/project/c19/beer-advocate'}
loc_import = 'data_onemode_network'
loc_export = 'data_beer_to_beer_scores'

if(dir.exists( file.path(bucket,loc_export) ) == FALSE){dir.create( file.path(bucket,loc_export) )}

#libraries
library(data.table)
library(fst)
library(stringr)

#=============================================

weights = c('review_overall',
            'review_aroma',
            'review_appearance',
            'review_palate',
            'review_taste')
type = c('origin', 'scale', 'scale_byuser')


generate_score = function(w,t){
  fname = paste0('onemode_edgelist_', w, "_", t, ".fst")
  df = read_fst(file.path(bucket,loc_import,fname))
  df = as.data.table(df)
  cname = paste0("score_",str_sub(w,8,nchar(w)),"_",t)
  sc1 = names(df)[2]
  sc2 = names(df)[4]
  df[, score:= sqrt( eval(parse(text = sc1)) * eval(parse(text = sc2)) )]
  df = df[, c(1,3,5)]
  key = names(df)[1:2]
  df = df[, mean(score), by = key]
  df[, V1 := round(V1,2)]
  setnames(df, "V1", cname)
  fname2 = paste0('beer_to_beer_score_', w, "_", t, ".fst")
  write_fst(df, file.path(bucket,loc_export,fname2), 100)
  rm(df)
  gc()
  paste("Completed running...", w, t, "...at", Sys.time())
}

generate_score(w = weights[1], t = type[1]) #running
generate_score(w = weights[2], t = type[1]) #running
generate_score(w = weights[3], t = type[1]) #running
generate_score(w = weights[4], t = type[1]) #running
generate_score(w = weights[5], t = type[1]) #running
generate_score(w = weights[1], t = type[2])
generate_score(w = weights[2], t = type[2])
generate_score(w = weights[3], t = type[2])
generate_score(w = weights[4], t = type[2])
generate_score(w = weights[5], t = type[2])
generate_score(w = weights[1], t = type[3])
generate_score(w = weights[2], t = type[3])
generate_score(w = weights[3], t = type[3])
generate_score(w = weights[4], t = type[3])
generate_score(w = weights[5], t = type[3])
