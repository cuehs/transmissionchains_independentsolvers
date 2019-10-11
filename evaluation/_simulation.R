simulation <- function(type,levelid,strength,down ){
  stopifnot(exists(c("landscapeDf","Ns","players","stepsNb")))
  stopifnot(strength>1)
  stopifnot(type %in% c("par","seq"))
  landscape <- unlist(landscapeDf[landscapeDf$id==levelid,]$landscape)
  landscape <- list2env(split(unname(landscape),names(landscape)),hash = T)
  switch(type,
         par = simulationPar(landscape,strength,down),
         seq = simulationSeq(landscape,strength,down)
         )
}

simulationPar <- function(landscape,strength,down){
  N<-Ns
  player <- players
  step <- strength*(mf/2)
  
  mask <- matrix(nrow=player,ncol=strength)
  position <- matrix(nrow=player,ncol=N)
  currentPayoff <- matrix(nrow=player,ncol=2)
  startingPosition <- sample(c(0,1),N,replace = T)
  savePayoff <- NULL
  
  for(p in 1:player){
    position[p,] <- startingPosition
    mask[p,] <- sample(N,strength)
    currentPayoff[p,1]  <- payoffForPosition(landscape,position[p,])
  }
  savePayoff <- c(savePayoff,currentPayoff[,1])
  for(s in 1:step){
    for(p in 1:player){
      newPositions <- explore(landscape,position[p,],mask[p,],down,s)
      position[p,] <- newPositions[2,]
      currentPayoff[p,1]  <- payoffForPosition(landscape,newPositions[1,])
      currentPayoff[p,2]  <- payoffForPosition(landscape,newPositions[2,])

    }
    savePayoff <- c(savePayoff,currentPayoff)
  }
  return(savePayoff)
}

simulationSeq <- function(landscape,strength,down){
  N<-Ns
  player <- players
  step <- strength*(mf/2)

  mask <- matrix(nrow=player,ncol=strength)
  position <- matrix(nrow=player,ncol=N)
  currentPayoff <- matrix(nrow=player,ncol=2)
  savePayoff <- NULL
  
  for(p in 1:player){
    if(p==1){
      position[p,] <- sample(c(0,1),N,replace = T)
    }else{
      position[p,] <- position[p-1,]
    }
    mask[p,] <- sample(N,strength)
    currentPayoff[p,1]  <- payoffForPosition(landscape,position[p,])
    savePayoff <- c(savePayoff,currentPayoff[p,1])
    for(s in 1:step){
      newPositions <- explore(landscape,position[p,],mask[p,],down,s)
      position[p,] <- newPositions[2,]
      currentPayoff[p,1]  <- payoffForPosition(landscape,newPositions[1,])
      currentPayoff[p,2]  <- payoffForPosition(landscape,newPositions[2,])
      savePayoff <- c(savePayoff,currentPayoff[p,])
    }
    
  }
  return(savePayoff)
}

explore <- function(landscape,position,mask,down,s){
  currentPayoff <- payoffForPosition(landscape,position)
  maxPosition <- position
  maxPayoff <- currentPayoff
  if(length(mask>1)){
    whichDimension <- sample(mask,1)
  }else{
    whichDimension <- mask
  }
  newPosition <- position
  newPosition[whichDimension] <-  !position[whichDimension]
  
  if((payoffForPosition(landscape,newPosition)  >  maxPayoff+1*10^-6) |
     ((runif(1) < down) & (2*length(mask)-s)> (length(mask) -2))){
    maxPosition <- matrix(c(newPosition,newPosition),nrow=2,byrow = T)
    
  }else{
    maxPosition <- matrix(c(newPosition,position),nrow=2,byrow=T)
  }
  
  return(maxPosition)
}


payoffForPosition <- function(landscape,position){
  return(landscape[[paste(position,collapse = "")]])
}

#exploreAndInnovate <- cmpfun(exploreAndInnovate)
explore <- cmpfun(explore)
#innovate <- cmpfun(innovate)
payoffForPosition <- cmpfun(payoffForPosition)
dezToBin <- cmpfun(dezToBin)
