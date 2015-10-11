#house keeping
rm(list=ls())

#Load packages
packages <- c('ggplot2', 'plyr', 'reshape2', 'MASS')
lapply(packages, library, character.only = TRUE)

#Squared exponential covariance
calcSigma <- function(X1,X2,l=1) {
  Sigma <- matrix(rep(0, length(X1)*length(X2)), nrow=length(X1))
  for (i in 1:nrow(Sigma)) {
    for (j in 1:ncol(Sigma)) {
      Sigma[i,j] <- exp(-0.5*(abs(X1[i]-X2[j])/l)^2)
    }
  }
  return(Sigma)
}

#Input space
x.star <- seq(0,10,len=50)

# Calculate the covariance matrix
sigma <- calcSigma(x.star,x.star)

#observation so far
f1 <- data.frame(x=c(0.1,1,3,9, 9.9), y=c(-1.2,-2,2,-1, -0.8))

#GP-inference
x <- f1$x
k.xx <- calcSigma(x,x)
k.xxs <- calcSigma(x,x.star)
k.xsx <- calcSigma(x.star,x)
k.xsxs <- calcSigma(x.star,x.star)
sigma.n <- 0.01

# Calculate the mean and covariance functions
f.bar.star <- k.xsx%*%solve(k.xx + sigma.n^2*diag(1, ncol(k.xx)))%*%f1$y
cov.f.star <- k.xsxs - k.xsx%*%solve(k.xx + sigma.n^2*diag(1, ncol(k.xx)))%*%k.xxs

#20 sampled functions
n.samples<-20
# Generate samples
values <- matrix(rep(0,length(x.star)*n.samples), ncol=n.samples)
for (i in 1:n.samples) {
  values[,i] <- mvrnorm(1, f.bar.star, cov.f.star)
}
#back together
values <- cbind(x=x.star,as.data.frame(values))
#store
values1 <- melt(values,id="x")

#get variance
sig<-sqrt(diag(cov.f.star))
#mark point with highest variance
mark1<-which(sig==max(sig))


#STEP2
#add point with highest variance and assume outcome is mean
f2<-rbind(f1,c(x.star[mark1], f.bar.star[mark1]))

#GP inference
x <- f2$x
k.xx <- calcSigma(x,x)
k.xxs <- calcSigma(x,x.star)
k.xsx <- calcSigma(x.star,x)
k.xsxs <- calcSigma(x.star,x.star)
sigma.n <- 0.01

# Recalculate the mean and covariance functions
f.bar.star2 <- k.xsx%*%solve(k.xx + sigma.n^2*diag(1, ncol(k.xx)))%*%f2$y
cov.f.star2 <- k.xsxs - k.xsx%*%solve(k.xx + sigma.n^2*diag(1, ncol(k.xx)))%*%k.xxs

# Generate new samples
values <- matrix(rep(0,length(x.star)*n.samples), ncol=n.samples)
for (i in 1:n.samples) {
  values[,i] <- mvrnorm(1, f.bar.star2, cov.f.star2)
}
values <- cbind(x=x.star,as.data.frame(values))
#Store as value 2
values2 <- melt(values,id="x")

#Get variance
sig2<-sqrt(diag(cov.f.star2))
#mark next point
mark2<-which(sig2==max(sig2))

#Plot-frame
dplot<-rbind(values1, values2)
#different steps for facet_wrap
dplot$time<-rep(c("Step 1", "Step 2"), each=nrow(values1))

#same for the observations
f1$time<-"Step 1"
f2$time<-"Step 2"
f<-rbind(f1,f2)

#mean predictions
mu<-data.frame(x= rep(x.star,2), y=c(f.bar.star, f.bar.star2), time=rep(c("Step 1", "Step 2"), each=length(f.bar.star)))
dvar<-mu
dvar$y<-dvar$y+c(sig,sig2)

#marking the next point
nextpoint<-data.frame(x=c(x.star[mark1], x.star[mark2]),
                          y=c((f.bar.star+sig)[mark1], (f.bar.star2+sig2)[mark2]))

nextpoint$time<-c("Step 1", "Step 2")
upy<-max(dplot$value)+0.1
lowy<-min(dplot$value)-0.1
# Plot the result
learnplot <- ggplot(dplot, aes(x=x,y=value)) + 
  #sampled functions
  geom_line(aes(group=variable), colour="grey80") +
  #mean predictions
  geom_line(data=mu,aes(x=x,y=y),colour="gray50", size=2) + 
  #variance added
  geom_line(data=dvar,aes(x=x,y=y),colour="gray35", size=2,linetype=3) + 
  #observations
  geom_point(data=f,aes(x=x,y=y), size=3) +
  #next point/candidate point
  geom_point(data=nextpoint,aes(x=x,y=y), colour="black", size=3, shape=17) +
  #white theme
  theme_bw() +
  #y-lab
  scale_y_continuous(lim=c(lowy,upy), name="Output f(x)") +
  #x-lab
  scale_x_continuous(lim=c(0,10), name="Input") +
  #title
  ggtitle("Optimal design\n")+
  #bigger fonts
  theme(text = element_text(size=16))+
  #one plot for each sample step
  facet_wrap(~ time, ncol = 2)
 
#What does it look like?
learnplot
setwd("/home/hanshalbe/Desktop/GPT")
#Save as pdf
pdf("figs/optlearnexample.pdf", width=10, height=6)
learnplot
dev.off()
#END