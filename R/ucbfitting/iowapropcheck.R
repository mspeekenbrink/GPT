iowapropcheck<-function(collect, alpha=0.5, consistency=0.5, weight=0.5){
  #initialise valence
  v1<-v2<-v3<-v4<-0
  #valence frame
  valence<-as.data.frame(matrix(0, nrow=1, ncol=4))
  #names v1-v4
  names(valence)<-c("v1","v2","v3","v4")
  #collect frame
  out<-as.data.frame(matrix(0, nrow=nrow(collect), ncol=4))
  trials<-nrow(collect)
  #for 1,2,3,4,...,trials
  for (i in 1:trials){
    
    #thetat is dependent on consistency
    theta<-(i/10)^consistency
    #propabilities via softmax
    p<-exp(theta*valence)/sum(exp(theta*valence))
   
    out[i,]<-p
    #if choices is 1, update!
    if (collect[i,3]==1){
      #new valence
      v1<-(1-weight)*collect[i,1]+weight*collect[i,2]
      #frame update
      valence$v1<-valence$v1+alpha*(v1-valence$v1)
    }
    #same for choice==2
    if (collect[i,3]==2){
      v2<-(1-weight)*collect[i,1]+weight*collect[i,2]
      valence$v2<-valence$v2+alpha*(v2-valence$v2)
    }
    #and choice==3
    if (collect[i,3]==3){
      v3<-(1-weight)*collect[i,1]+weight*collect[i,2]
      valence$v3<-valence$v3+alpha*(v3-valence$v3)
    }
    #and choice==4
    if (collect[i,3]==4){
      v4<-(1-weight)*collect[i,1]+weight*collect[i,2]
      valence$v4<-valence$v4+alpha*(v4-valence$v4)
    }
  }
  
  #return the collector frame  
  return(out)
}
#END