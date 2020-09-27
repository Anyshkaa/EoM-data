library(tidyverse)
source("functions.R")

participant_code <- "P4"
BASE_DIR <- "data"

p4 <- preprocess_participant(file.path(BASE_DIR, "P4"))

ggplot(p4$hr, aes(sessionTime, HR, color = video)) + geom_line()

p3 <- preprocess_participant(file.path(BASE_DIR, "P3"))

ggplot(p3$hr, aes(sessionTime, HR, color = video)) + geom_line()

p4$hr$participant <- "P4"
p3$hr$participant <- "P3"
all_hr <- rbind(p3$hr, p4$hr)

ggplot(all_hr, aes(sessionTime, HR, color = video)) + geom_line() +
  facet_wrap(~participant)

## All toghether ----
participants <- list.dirs(BASE_DIR, full.names = FALSE, recursive = FALSE)

res <- list()
for(participant in participants){
  dat <- preprocess_participant(file.path(BASE_DIR, participant))
  ## This just adds 
  for(n in names(dat)){
    dat[[n]]$participant <- participant
  }
  res[[participant]] <- dat
}

all_hr <- bind_rows(lapply(res, `[`, "hr"))[["hr"]]
ggplot(all_hr, aes(sessionTime, HR, color = video)) + geom_line() +
  facet_wrap(~participant)

all_sdnn <- bind_rows(lapply(res, `[`, "sdnn"))[["sdnn"]]
ggplot(all_sdnn, aes(sessionTime, SDNN, color = video)) + geom_line() +
  facet_wrap(~participant)
