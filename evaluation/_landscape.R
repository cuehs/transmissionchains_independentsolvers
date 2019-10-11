generateNKLandscape <- function(N,K){
  landscape <- list()
  bestPayoff <- 0
  if(K > 0){
    fun <- benchmarkGeneratorNKL(N,K)
    for(i in 0:(2^(N)-1)){
      binString <- dezToBin(i,N)
      payoff <- fun(as.numeric(strsplit(binString, NULL)[[1]])) * -1
      landscape[[binString]] <- payoff
      if(payoff > bestPayoff){
        bestPayoff <- payoff
      }
    }
  }
  else{
    rel <- sample(1:(2^N))
    for(i in 0:(2^(N)-1)){
      binString <- dezToBin(i,N) 
      payoff<-lengths(regmatches(dezToBin(rel[i+1],N), gregexpr("1", dezToBin(rel[i+1],N))))
      landscape[[binString]] <- payoff
      if(payoff > bestPayoff){
        bestPayoff <- payoff
      }
    }
  }
  landscape <- 
    lapply(landscape,function(x)(round((x/bestPayoff)^8*1000)))

  return(landscape)
}

