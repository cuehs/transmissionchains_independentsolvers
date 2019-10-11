library(here)
source(here("_basic.R"))

structure <- 
  read_csv(here("../data/full/structure.csv"),
           col_names = c("playerId","level","landscapeId","isSmooth","isSequential","isLowStrength","times"),
           col_types = "iiillli")%>%
  mutate(playerId = playerId+1,
         level=level+1,
         landscapeId = landscapeId +1)


movement <-
  read_csv(here("../data/full/movement.csv"),
           col_names = c("time","playerId","level","type","step","behavior","values","mask"),
           col_types = "ciiciccc")%>%   select(-time)%>% spread("type","values")%>%

  mutate(payoff = as.numeric(payoff),
         playerId = playerId +1,
         level = level+1,
         step = step+1) 

participant <- read_csv(here("../data/full//participant.csv"),
                        col_names = c("time","playerId","gender","age"),
                        col_types = "cici")%>%
  mutate(playerId = playerId +1)

movement <- 
full_join(movement,structure,by = c("playerId" = "playerId", "level" = "level")) 

#clean data
finishedPlayerId <- movement %>%
  group_by(playerId) %>% filter(behavior == "e") %>% 
  mutate(n=n()) %>% filter(n==128) %>% pull(playerId) %>% unique()

message(paste("total dropouts:", movement %>% pull(playerId) %>% unique()%>%length()-length(finishedPlayerId)))

movement <- movement %>% filter(playerId %in%finishedPlayerId )

movement <- movement %>% mutate(
  type = if_else(isSequential, "seq","par"),
  strength = if_else(isLowStrength,3,6),
  K = if_else(isSmooth,1,8),
  groupSize = times) %>%
  select(-isSmooth,-isSequential,-isLowStrength,-times)

#removing groupsize <5
levelsRemoved<-movement %>% group_by(type,landscapeId,strength,K) %>% 
  filter(max(groupSize)<6) %>%
  filter(groupSize == 1,behavior == "s")%>%
  ungroup()%>%
  summarise(n = n())  %>% pull(n)

message(paste("total levels removed:",levelsRemoved))

movement <- movement %>% group_by(type,landscapeId,strength,K) %>% 
  filter(max(groupSize)>6) 

# some data
participant %>% group_by(gender)%>%tally()

participant %>% summarise(mean(age),median(age),sd(age))

movement %>% group_by(level,playerId) %>% 
  filter(step == max(step)) %>%   group_by(playerId) %>% summarise(bonus=sum(payoff)*0.017) %>%
  summarise(mean(bonus),median(bonus),sd(bonus))

read_csv(here("../data/full/movement.csv"),
           col_names = c("time","playerId","level","type","step","behavior","values","mask"),
           col_types = "ciiciccc")%>% mutate(time = ymd_hms(time))%>%
    select(playerId,time)%>%group_by(playerId)%>%filter(time == max(time) | time == min(time))%>%
  group_by(playerId) %>% summarise(duration = time[2]-time[1])%>%
  ungroup() %>% summarise(mean(duration),median(duration),sd(duration))

movement %>% group_by(level,playerId) %>% 
  filter(step == max(step)) %>%
  group_by(K,type,strength) %>%
  summarise(n = n())
#number of steps played
movement %>% group_by(type,landscapeId,strength,K,playerId) %>%filter(behavior != "b") %>%
  summarise(n = n()-1)%>% group_by(strength)%>%summarise(mean(n))


movement %>% group_by(type,landscapeId,strength,K,groupSize) %>%
  mutate(stayLow = 
           (payoff<lag(payoff)) &
           (lead(position) != lag(position))) %>%
  mutate(stayLow=if_else(is.na(stayLow),F,stayLow))%>%
  group_by(stayLow) %>% tally() %>% mutate(n/sum(n))
#source(here("_check_data.R"))

