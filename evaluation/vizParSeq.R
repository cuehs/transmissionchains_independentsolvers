vizDf<- tibble(player = integer(), type = character(), step = integer() ) %>%
  complete(player = 1:5, type = c("sequential","parallel"), step = 1:10)
vizDf<- vizDf %>% mutate(time=if_else(type =="parallel", (1 + (step-1) * 5)+4 ,((player-1)*10)+step))
vizDf %>% ggplot(aes(time,player,fill=factor(player)))+ geom_tile()+
  facet_grid(~type)+labs(x = "total exploration volume",y="",fill="player")+scale_y_discrete(labels = NULL)
