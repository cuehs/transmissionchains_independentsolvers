dezToBin <-function(x,N){
  paste(sapply(strsplit(paste(rev(intToBits(x))),""),'[[',2)[(32-N+1):32],collapse="")
}
dezToBin <- cmpfun(dezToBin)

mutation <- function(...){
  parameters <- as.list(...)
  error <- F
  for(i in parameters){
    for(j in parameters){
      if(sum(abs(as.numeric(str_split(i,"",simplify = T)) - as.numeric(str_split(j,"",simplify = T))))>0){
        error <- T
      }
    }
  }
  return(error)
  
}


maskToBinary <- function(mask){
  tmp <- str_split(mask,"e",simplify = T)
  tmp <- if_else(tmp == "tru",1,0)
  return(paste0(tmp[1:(length(tmp)-1)],collapse = ""))
}

mutation2 <- function(...){
  parameters <- as.list(...)
  a <- NULL
  for(i in parameters){
    for(j in parameters){
      a<- c(a,sum(abs(as.numeric(str_split(i,"",simplify = T)) - as.numeric(str_split(j,"",simplify = T)))))
    }
  }
  return(sum(a)/length(a))
  
}
continueOzilation <- function(landscapeId,payoff){
  payoffNotNa <- payoff[!is.na(payoff)]
  if(length(payoffNotNa) <=2){
    return(rep(payoffNotNa[length(payoffNotNa)],length(payoff)))
  }
  for(p in 1:length(payoff)){
    if(is.na(payoff[p])){
      payoff[p] <- payoffNotNa[length(payoffNotNa)- ((p%%2)*2)]
    }
  }
  return(payoff)
}
