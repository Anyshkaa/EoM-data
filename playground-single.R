library(tidyverse)
source("functions.R")

participant_code <- "P4"
BASE_DIR <- "data"
participant_path <- file.path(BASE_DIR, participant_code)

df_rri <- read.csv(file.path(participant_path, "rri.csv"))
df_rmsdd <- read.csv(file.path(participant_path, "RMSSD.csv"))
df_sdnn <- read.csv(file.path(participant_path, "SDNN.csv"))
df_hr <- read.csv(file.path(participant_path, "hr.csv"))

ls_session <- jsonlite::fromJSON(file.path(participant_path, "sessionData.json"))
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
df_markers <- arrange(df_markers, df_markers$Start)
df_baseline <- data.frame(Start = 0, End = df_markers$Start[1],
                          video="baseline", i_video=NA_integer_)
df_rests <- data.frame(Start = df_markers$End[1:3], 
                    End = df_markers$Start[2:4],
                    video = paste0("rest", 1:3),
                    i_video = rep(NA, 3))

df_markers <- rbind(df_markers, df_rests, df_baseline)
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

ggplot(df_hr, aes(sessionTime, HR, color=video)) + geom_line()
