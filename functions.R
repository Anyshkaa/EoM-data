add_video_label <- function(dat, baseline="baseline"){
  dat$video <- "baseline"
  return(dat)
}

mark_video <- function(dat, start_time, end_time, label){
  dat$video[dat$sessionTime >= start_time & 
              dat$sessionTime <= end_time] <- label
  return(dat)
}

#' Preprocesses standard data found at the passed path
#'
#' @param pth path to the participant's data
#'
#' @return returns list with hr, rmsdd, rri and sdnn data
#' @export
#'
#' @examples
preprocess_participant <- function(pth){
  df_rri <- read.csv(file.path(pth, "rri.csv"))
  df_rmsdd <- read.csv(file.path(pth, "RMSSD.csv"))
  df_sdnn <- read.csv(file.path(pth, "SDNN.csv"))
  df_hr <- read.csv(file.path(pth, "hr.csv"))
  
  ls_session <- jsonlite::fromJSON(file.path(pth, "sessionData.json"))
  df_markers <- ls_session$manualMarkers
  
  # This is using dplyr syntax, could be done with base R as well, just be longer
  df_markers <- filter(df_markers, grepl("Video", message)) %>%
    select(-label) # keeps only video rows
  df_markers <- mutate(df_markers, message = gsub("Video ", "", message))
  # SEparate is from Tidyr package
  df_markers <- separate(df_markers, col = message, sep = ":", 
                         into = c("Action", "i_video"), convert = TRUE)
  
  df_markers <- pivot_wider(df_markers, values_from = "timestamp", 
                            names_from=c("Action"))
  
  df_markers <- mutate(df_markers, video = paste0("video", i_video))
  
  #' add_video_label and mark_video are custom functions 
  #' so there is less repetition and less errors
  df_hr <- add_video_label(df_hr)
  df_rmsdd <- add_video_label(df_rmsdd)
  df_rri <- add_video_label(df_rri)
  df_sdnn  <- add_video_label(df_sdnn)
  
  for(i in 1:nrow(df_markers)){
    video_info <- df_markers[i,]
    df_hr <- mark_video(df_hr, video_info$Start, video_info$End, video_info$video)
    df_rmsdd <- mark_video(df_rmsdd, video_info$Start, video_info$End, video_info$video)
    df_rri <- mark_video(df_rri, video_info$Start, video_info$End, video_info$video)
    df_sdnn <- mark_video(df_sdnn, video_info$Start, video_info$End, video_info$video)
  }

  return(list(hr = df_hr, rmsdd = df_rmsdd, rri = df_rri,
              sndd = df_sdnn))
}