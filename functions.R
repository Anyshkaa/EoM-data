add_video_label <- function(dat, baseline="baseline"){
  dat$video <- "baseline"
  return(dat)
}

mark_video <- function(dat, start_time, end_time, label){
  dat$video[dat$sessionTime >= start_time & 
              dat$sessionTime <= end_time] <- label
  return(dat)
}