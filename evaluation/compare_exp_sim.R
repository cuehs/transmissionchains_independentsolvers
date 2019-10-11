STATISTICAL_TESTS <- F 
tmpE <- 
  movement %>%ungroup()%>% mutate(source = "experiment")

tmpS <- simulationDf %>% ungroup()%>%
  mutate(source = paste0("simulation\n(r=",down,")"))

# influence of experimental manipulation
payoffDf <- bind_rows(
  tmpE %>% filter(behavior == "e") %>%
    arrange(source,type,landscapeId,strength,K,groupSize) %>% 
    group_by(source,type,landscapeId,strength,K) %>% 
    summarise(payoff = unique(if_else(type == "par",max(payoff),last(payoff)))),
  tmpS %>% filter(groupSize <= 8)%>% 
    group_by(source,type,landscapeId,strength,K) %>% 
    filter(step == max(step))%>%
    arrange(source,type,landscapeId,strength,K,groupSize,down) %>% 
    summarise(payoff = unique(if_else(type == "par",max(payoff),last(payoff))))
)%>%
  ungroup()%>% 
  mutate(source = as_factor(source),
         source = fct_relevel(source,"experiment","simulation\n(r=0)","simulation\n(r=0.11)"))


payoffDf%>%
  mutate(type = if_else(type == "par", "independent solvers","transmission chains"))%>%
  mutate(strength = factor(paste("individuals skill",strength),
                           levels = c("individuals skill 6","individuals skill 3")))%>%
  ggplot(aes(source,payoff/1000,fill=type))+
  geom_boxplot(position=position_dodge(width=.8))+
  facet_grid(strength~paste("difficulty",K))+
  labs(x = "", y = "group performance", fill = "",linetype = "")+
  theme(legend.position = "bottom",legend.margin = margin(-20,0,0,0,"pt"))+
  scale_fill_manual(values=c("#d95f02","#1b9e77"))+
  scale_linetype_manual(values = c("solid","dotted","dashed"))

ggsave("03_performance.pdf", width = 17 , height = 12, units = "cm")
ggsave("03_performance.png", width = 17 , height = 12, units = "cm")
if(STATISTICAL_TESTS){
  forTest <- payoffDf%>% filter(source == "experiment")
  
  
  compareDf<- forTest%>% ungroup()%>% mutate(K = as_factor(as.character(K)))
  
  ttestBF(formula = payoff ~ K, data = compareDf,nullInterval =  c(0,-Inf))
  
  t.test(formula = payoff ~ K, data = compareDf)
  
  compareDf<- forTest%>% ungroup()%>% mutate(strength = as_factor(as.character(strength)))
  
  ttestBF(formula = payoff ~ strength, data = compareDf,nullInterval =  c(0,-Inf))
  
  t.test(formula = payoff ~ strength, data = compareDf)
  
  compareDf<- forTest%>% ungroup()%>% filter(K== 1)%>% mutate(type = as_factor(type))
  Me <- ttestBF(formula = payoff ~ type, data = compareDf,nullInterval =  c(0,-Inf))
  
  t.test(formula = payoff ~ type, data = compareDf)
  
  

  
  compareDf<- forTest%>% ungroup()%>% filter(K== 1,strength == 3)%>% mutate(type = as_factor(type))
  Mew <- ttestBF(formula = payoff ~ type, data = compareDf,nullInterval =  c(0,-Inf))

  t.test(formula = payoff ~ type, data = compareDf)
  
  compareDf<- forTest%>% ungroup()%>% filter(K== 1,strength == 6)%>% mutate(type = as_factor(type))
  Mes <- ttestBF(formula = payoff ~ type, data = compareDf,nullInterval =  c(0,-Inf))
  t.test(formula = payoff ~ type, data = compareDf)
  
  compareDf<- forTest%>% ungroup()%>% filter(K== 8)%>% mutate(type = as_factor(type))
  Md <- ttestBF(formula = payoff ~ type, data = compareDf,nullInterval =  c(0,-Inf))
  
  t.test(formula = payoff ~ type, data = compareDf)
  
  
  compareDf<- forTest%>% ungroup()%>% filter(K== 8,strength == 3)%>% mutate(type = as_factor(type))
  Mdw  <- ttestBF(formula = payoff ~ type, data = compareDf,nullInterval =  c(0,Inf))
  t.test(formula = payoff ~ type, data = compareDf)
  
  compareDf<- forTest%>% ungroup()%>% filter(K== 8,strength == 6)%>% mutate(type = as_factor(type))
  Mds <- ttestBF(formula = payoff ~ type, data = compareDf,nullInterval =  c(0,Inf))
  t.test(formula = payoff ~ type, data = compareDf)
  
  lapply(list(Med,Mes,Mdw,Mds),summary)
}



#influence of group size
if(!exists("groupSizeDf")){
  groupSizeDf <- tibble()
  for(i in 1:16){
    print(i)
    tmp <- bind_rows(
      tmpE %>% filter(behavior == "e",groupSize <= i) %>%
        arrange(source,type,landscapeId,strength,K,groupSize) %>% 
        group_by(source,type,landscapeId,strength,K) %>% 
        summarise(payoff = unique(if_else(type == "par",max(payoff),last(payoff)))),
      tmpS %>% filter(groupSize <= i,source != "simulation\n(r=0)")%>% 
        group_by(source,type,landscapeId,strength,K) %>% 
        filter(step == max(step))%>%
        arrange(source,type,landscapeId,strength,K,groupSize,down) %>% 
        summarise(payoff = unique(if_else(type == "par",max(payoff),last(payoff))))
    )%>%
      ungroup()%>% 
      mutate(source = as_factor(source),
             source = fct_relevel(source,"experiment","simulation\n(r=0.11)"))%>%
      mutate(totalPlayer = i)
    groupSizeDf <- bind_rows(groupSizeDf,tmp)
    
  }
  groupSizeDf  <- filter(groupSizeDf, (source != "experiment" | totalPlayer <= 8))
}

groupSizeDf %>% 
  mutate(stregthF = paste("individuals skill",strength),
         stregthF = factor(stregthF),
         stregthF= fct_relevel(stregthF,"individuals skill 6","individuals skill 3"),
         type = if_else(type == "par", "independent solvers","transmission chains"))%>%
  group_by(source,totalPlayer,type,stregthF,K) %>% 
  summarise(meanPayoff = median(payoff)/1000 )%>%
  ggplot(aes(totalPlayer,meanPayoff,color=type,linetype=source))+
  geom_line(size = 1)+
  facet_grid(stregthF~paste("difficulty",K))+
  labs(x = "group size", y="group performance", color= "",linetype = "")+
  theme(legend.position = "bottom")+scale_color_manual(values=c("#d95f02","#1b9e77"))

ggsave("04_groupSize.pdf", width = 17 , height = 12, units = "cm")
ggsave("04_groupSize.png", width = 17 , height = 12, units = "cm")

# influence of diversity
masksTmp<- tmpE %>% 
  filter(step == 1)%>%
  group_by(landscapeId,type,strength,K,groupSize) %>%
  mutate(mask =maskToBinary(mask) )%>%
  group_by(landscapeId,strength,K,type)%>%
  summarise(diversity = mutation2(mask))%>%
  select(type,landscapeId,strength,K,diversity)


tmp <- tmpE %>%
  arrange(source,type,landscapeId,strength,K,groupSize) %>% 
  group_by(source,type,landscapeId,strength,K) %>% 
  summarise(payoff = unique(if_else(type == "par",max(payoff),last(payoff))))%>%
  full_join(masksTmp)

tmp %>%ungroup()%>% mutate(type = if_else(type == "par", "independent solvers","transmission chains"))%>%
  ggplot(aes(diversity,payoff/1000,color=type)) +
  geom_smooth(method = "glm",se = T,size=1)+
  geom_jitter(alpha = .2)+
  labs(x="diversity", y="group performance", shape =" ", color = "")+
  theme(legend.position = "bottom",legend.direction = "vertical",legend.margin = margin(-20,0,0,0,"pt"))+
  guides(shape = guide_legend(override.aes = list(alpha=1)))+scale_color_manual(values=c("#d95f02","#1b9e77"))

ggsave("diversity.pdf", width = 9.6 , height = 8, units = "cm")
ggsave("diversity.png", width = 9.6 , height = 8, units = "cm")
if(STATISTICAL_TESTS){
  summary(lm(payoff ~ diversity,data =tmp))
  summary(regressionBF(payoff ~ diversity,data =tmp))
  
  summary(lm(payoff ~ diversity+type,data =tmp))
  summary(lm(payoff ~ diversity,data =filter(tmp, type == "seq")))
  summary(lm(payoff ~ diversity,data =filter(tmp, type == "par")))
  summary(generalTestBF(payoff ~ diversity,data =filter(tmp, type == "seq")))
  summary(generalTestBF(payoff ~ diversity,data =filter(tmp, type == "par")))
}

#influence of time 
x1<-tmpE %>%filter(type == "seq",strength == 6)%>%
  group_by(source,type,landscapeId,strength,K,groupSize) %>%
  filter(behavior!="b" & behavior!="e") %>% mutate(step = 1:n())%>%
  complete(step = 1:13)%>%
  fill(type,landscapeId,strength,K,groupSize,payoff)
y1 <- tmpS %>%filter(type == "seq",strength == 6 ,groupSize<=8)%>%
  filter(step%%2 == 1)%>%   ungroup()%>%
  mutate(source = paste0("simulation\n(r=",down,")"))

# seq
tmp <- bind_rows(x1,y1)%>% 
  group_by(source,type,landscapeId,strength,K) %>%
  arrange(source,type,landscapeId,strength,K,groupSize,step)%>%
  mutate(newStep = 1:n()) %>%
  group_by(source,type,strength,newStep)%>%
  summarise(meanPayoff = mean(payoff)/1000 )%>% ungroup()%>%
  mutate(type = "sequential")

B <- tmp%>% mutate(type = if_else(type == "par", "independent solvers","transmission chains"))%>% ggplot()+
  geom_line(aes(newStep,meanPayoff,linetype=source),color="#1b9e77",size = .8) +
  geom_vline(xintercept = seq(1,96,13),linetype = "dashed",alpha = .5)+
  labs(x="total search steps", y="group performance", linetype = "")+
  theme(legend.position = "none")+
  scale_linetype_manual(values = c("solid","dotted","dashed"))+ theme(legend.key.width=unit(3,"line"))+
  facet_wrap(~type)


x2<-tmpE %>%filter(type == "par",strength == 6)%>%
  group_by(source,type,landscapeId,strength,K,groupSize) %>%
  filter(behavior!="b" & behavior!="e") %>% mutate(step = 1:n())%>%
  complete(step = 1:13)%>%
  fill(type,landscapeId,strength,K,groupSize,payoff)
y2 <- tmpS %>%filter(type == "par",strength == 6,groupSize<=8)%>%
  filter(step%%2 == 1)%>%   ungroup()%>%
  mutate(source = paste0("simulation\n(r=",down,")"))

tmp <- bind_rows(x2,y2)%>% 
  group_by(source,type,landscapeId,strength,K,groupSize) %>%
  arrange(source,type,landscapeId,strength,K,step)%>%
  mutate(newStep = 1:n(),newStep = ((newStep-1) * 8)+1) %>%
  group_by(source,type,landscapeId,strength,K,newStep)%>%
  summarise(payoff = max(payoff)) %>%
  group_by(source,type,strength,newStep)%>%
  summarise(meanPayoff = mean(payoff)/1000 ) %>% ungroup()%>%
  mutate(type = "parallel")

legendforplot <- get_legend(tmp %>% ggplot()+
  geom_line(aes(newStep,meanPayoff,linetype=source),size = 1) +
  theme(legend.position = "bottom",legend.direction = "horizontal",legend.margin = margin(0,0,0,0,"pt"))+
  scale_linetype_manual(values = c("solid","dotted","dashed"))+ theme(legend.key.width=unit(3,"line"))+
    labs(linetype = "")
  )

A<- tmp %>% mutate(type = "independent solvers")%>%
  ggplot()+
  
  geom_step(aes(newStep,meanPayoff,linetype=source),color="#d95f02",size = .8) +
  #geom_vline(xintercept = seq(1,104,8),linetype = "dashed",alpha = .5)+
  labs(x="total search steps", y="group performance", linetype = "")+
  theme(legend.position = "none")+
  scale_linetype_manual(values = c("solid","dotted","dashed"))+ theme(legend.key.width=unit(3,"line"))+
  facet_wrap(~type)+scale_color_manual(guide="none")+guides(color="none")

plot_grid(plot_grid(A,B),plot_grid(NULL,legendforplot,NULL,ncol=3),nrow=2,rel_heights = c(10,1))
ggsave("time.pdf",  width = 17 , height = 9, units = "cm")
ggsave("time.png",  width = 17 , height = 9, units = "cm")
