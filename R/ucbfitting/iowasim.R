#This is a function that mimics participants of an Iowa Gambling Tasks
#Alpha is the learning rate
#consistency is the inverse temperature parameter of choices over time
#weith is how positive and negative rewards are evaluated
#Trials is the number of simulated trials

iowasim<-function(alpha=0.5, consistency=0.5, weight=0.5, trials=150){

  #initialise valence
  v1<-v2<-v3<-v4<-0
  #valence frame
  valence<-as.data.frame(matrix(0, nrow=1, ncol=4))
  #names v1-v4
  names(valence)<-c("v1","v2","v3","v4")
  #collect frame
  collect<-data.frame(reward=rep(0,trials), loss=rep(0, trials), chosen=rep(0, trials))

  #for 1,2,3,4,...,trials
  for (i in 1:trials){
  
      #thetat is dependent on consistency
      theta<-(i/10)^consistency
      #propabilities via softmax
      p<-exp(theta*valence)/sum(exp(theta*valence))
      #choices proportional to probs
      collect[i,3]<-sample(1:4, 1, prob=p)
      
      #if choices is 1, update!
      if (collect[i,3]==1){
        #outcome
        collect[i,1:2]<-data.frame(reward=100, loss=ifelse(runif(1)>=0.5,0, -250))
        #new valence
        v1<-(1-weight)*collect[i,1]+weight*collect[i,2]
        #frame update
        valence$v1<-valence$v1+alpha*(v1-valence$v1)
      }
      #same for choice==2
      if (collect[i,3]==2){
        collect[i,1:2]<-data.frame(reward=100, loss=ifelse(runif(1)>=0.9,-1250, 0))
        v2<-(1-weight)*collect[i,1]+weight*collect[i,2]
        valence$v2<-valence$v2+alpha*(v2-valence$v2)
      }
      #and choice==3
      if (collect[i,3]==3){
        collect[i,1:2]<-data.frame(reward=50, loss=ifelse(runif(1)>=0.5,-50,0))
        v3<-(1-weight)*collect[i,1]+weight*collect[i,2]
        valence$v3<-valence$v3+alpha*(v3-valence$v3)
      }
      #and choice==4
      if (collect[i,3]==4){
        collect[i,1:2]<-data.frame(reward=50, loss=ifelse(runif(1)>=0.9, -250, 0))
        v4<-(1-weight)*collect[i,1]+weight*collect[i,2]
        valence$v4<-valence$v4+alpha*(v4-valence$v4)
      }
  }

#return the collector frame  
return(collect)
}
#END