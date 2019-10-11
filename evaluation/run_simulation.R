if(F){
  #restart R session in Rstudio (do not call in code)
  #avoid memory issues
  #https://stackoverflow.com/questions/6313079/quit-and-restart-a-clean-r-session-from-within-r
  rm(list = ls(all.names = T))
  detach()
  gc(reset = T,full = T)
  graphics.off()
  .rs.restartR()
}
library(here)
source(here("_basic.R"))


plan(multiprocess)

landscapes <- 1000
Ns <- 10
Ks <- c(1,8)
strengths <- c(3,6)
repetitions <- 1

players <- 20
downs <- c(0,0.11)
mf <- 4
if(!exists("landscapeDf")){

source(here("generate_landscapes.R"))
  
}


message("run simulation")

listGlobals <- c("simulation","simulationPar","simulationSeq",
                 "landscapeDf","binaryNumbers",
                 "stepsNb","players","Ns","payoffForPosition",
                 "exploreAndInnovate","explore","innovate","mf")
listPackages <- c("purrr")

simulationDf <- tibble(playerId = integer(),type = character(),
                       landscapeId = integer(),strength = integer(),down=integer())%>%
  complete(playerId = 1:repetitions,type =c("seq","par"),
           landscapeId = landscapeDf$id,strength = strengths,down = downs)%>%
  left_join(landscapeDf%>%select(-landscape),by = c("landscapeId"="id"))


simulationDf <- simulationDf%>%
  mutate(sim=future_pmap(simulationDf,
                         ~simulation(type = ..2,levelid = ..3,strength = ..4,down = ..5),
                         .progress = TRUE,
                         .options = future_options(globals=listGlobals,
                                                   packages=listPackages)))

simulationDf <- simulationDf %>% unnest() %>%
  group_by(playerId,landscapeId,type,strength,down,K) %>%
  mutate(stepOld = 1:((max(strength)*mf+1)*players),payoff = sim)%>%
  ungroup()%>%
  select(-sim)

simulationDf <- simulationDf %>% group_by(playerId,landscapeId,type,strength,down,K)%>%
  mutate(groupSize= if_else(type == "seq",
                        rep(seq(1,players),each=max(strength)*mf+1),
                        rep(seq(1,players),times=max(strength)*mf+1)))%>%
  group_by(groupSize,landscapeId,type,strength,K,down,playerId) %>%
  mutate(step = 1:(max(strength)*mf+1))




A<-simulationDf %>% ungroup()%>%
  mutate(type = if_else(type == "par", "independent solvers","transmission chains"))%>%
  group_by(strength,K,type,playerId,landscapeId)%>%
  summarise(payoff = max(payoff))%>%
  group_by(strength,K,type) %>%
  summarise(meanPayoff = mean(payoff))%>%
  ggplot(aes(K,strength,fill=(meanPayoff/1000)))+
  geom_raster()+scale_fill_viridis(breaks = c(.3,.55,.8))+
  labs(x = "difficulty", y="individuals skill", fill = "group\nperformance     ")+
  facet_grid(~type)+ theme(legend.position="bottom")+
  coord_equal()




B<-simulationDf %>% ungroup()%>%
  mutate(type = if_else(type == "par", "parallel","sequential"))%>%
  group_by(strength,K,type,playerId,landscapeId)%>%
  summarise(payoff = max(payoff))%>%
  group_by(strength,K,type) %>%
  summarise(meanPayoff = mean(payoff))%>%
  group_by(strength,K)%>%
  summarise(meanPayoff = (meanPayoff[1]-meanPayoff[2])/1000)%>%
  ggplot(aes(K,strength,fill=(meanPayoff)))+
  geom_raster()+
  scale_fill_gradient2(breaks = c(-.3,0,.1),labels  = c("-0.3","0","0.1"))+
  labs(x = "difficulty", y="individuals skill", fill = "delta performance\n(is.-tc.)")+
  theme(legend.position="bottom")+
  coord_equal()

plot_grid(A,B,ncol=2,rel_widths = c(2,1.1),align = "vh",axis = "btlr",labels =  "AUTO")


ggsave("A01_performance_simulation.pdf",width = 24, height = 12, units = "cm",encoding = "CP1250")
ggsave("A01_performance_simulation.png",width = 24, height = 12, units = "cm")

  