library(here)
source(here("_basic.R"))



NExp <- 10
landscapesExp <- 100
KsExp <- c(1,8)
idcounter <- 0

    landscapesLExp <- tibble(id =integer(), K =integer()) %>%
      complete(id = 1:landscapesExp,K = KsExp) %>%
      mutate(id = 0:(n()-1))
    
    landscapesLExp<-landscapesLExp%>%
      mutate(body =
               pmap(landscapesLExp,~generateNKLandscape(N = NExp, K = ..2)))

#write_file(toJSON(landscapesLExp),here("landscapes.json"))
