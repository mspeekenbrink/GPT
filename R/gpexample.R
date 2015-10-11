#house keeping
rm(list=ls())

#Load packages
packages <- c('ggplot2', 'plyr', 'reshape2', 'MASS')
lapply(packages, library, character.only = TRUE)

# Set a seed for repeatable plots
set.seed(121)

#Squared exponential Kernel
calcSigma <- function(X1,X2,l=1.5) {
  Sigma <- matrix(rep(0, length(X1)*length(X2)), nrow=length(X1))
  for (i in 1:nrow(Sigma)) {
    for (j in 1:ncol(Sigma)) {
      Sigma[i,j] <- exp(-0.5*(abs(X1[i]-X2[j])/l)^2)
    }
  }
  return(Sigma)
}


#Input grid
x.star <- seq(0,10,len=50)

# Calculate covariance matrix
sigma <- calcSigma(x.star,x.star)

# Generate a number of functions from the process
n.samples <- 20

values <- matrix(rep(0,length(x.star)*n.samples), ncol=n.samples)
for (i in 1:n.samples) {
  # Each column represents a sample from a multivariate normal distribution
  # with zero mean and covariance sigma
  values[,i] <- mvrnorm(1, rep(0, length(x.star)), sigma)
}
values <- cbind(x=x.star,as.data.frame(values))
#get it back together
values <- melt(values,id="x")

#some observations to learn
f <- data.frame(x=c(-4,-1,0,1,2.5,4.6)+5,y=c(0,1,2,1,1.5,1.2))

# Calculate the covariance matrices
# using the same x.star values as above
x <- f$x
#all covariances
k.xx <- calcSigma(x,x)
k.xxs <- calcSigma(x,x.star)
k.xsx <- calcSigma(x.star,x)
k.xsxs <- calcSigma(x.star,x.star)

#tiny bit of noise
sigma.n <- 0.01

#GP inference:

##Mean
f.bar.star <- k.xsx%*%solve(k.xx + sigma.n^2*diag(1, ncol(k.xx)))%*%f$y
#covariance
cov.f.star <- k.xsxs - k.xsx%*%solve(k.xx + sigma.n^2*diag(1, ncol(k.xx)))%*%k.xxs

#Sample from posterior
values2 <- matrix(rep(0,length(x.star)*n.samples), ncol=n.samples)
for (i in 1:n.samples) {
  values2[,i] <- mvrnorm(1, f.bar.star, cov.f.star)
}
values2 <- cbind(x=x.star,as.data.frame(values2))
#get it back together
values2 <- melt(values2,id="x")

#bind it together for plot
vplot<-rbind(values, values2)
#mark factors
vplot$time<-rep(c("Prior", "Posterior"), each=nrow(values))
#correct order for plot
vplot$time<- ordered(vplot$time, levels = c("Prior", "Posterior"))
#frame of points
names(f)<-c("x", "value")
#only for posterior of course
f$time<-"Posterior"
#lines of mean
dline1<-data.frame(x=values$x,value=rep(0, nrow(values)), time="Prior")
dline2<-data.frame(x=values$x,value=f.bar.star, time="Posterior")
#bind them
dline<-rbind(dline1, dline2)

#do the plot
fig <- ggplot(vplot,aes(x=x,y=value)) +
  #lines for each sampled function
  geom_line(aes(group=variable), colour="darkgrey") +
  #theme is white
  theme_bw() + 
  #title for the plot
  ggtitle("Samples from a Gaussian Process\n")+
  #scale y
  scale_y_continuous(lim=c(-3.2,3), name=expression(y)) +
  #scale x
  scale_x_continuous(lim=c(0,10), name=expression(x)) +
  #different plots for prior and posterior
  facet_wrap(~ time, ncol = 2)+
  #lines of mean for both plots
  geom_line(data=dline, colour="gray35", size=1.25)+
  #observation points
  geom_point(data = f, colour = "black", size = 3)+
  #font change
  theme(text = element_text(size=16))

#Save
pdf("figs/gpexample.pdf", width=10, height=6)
#the plot
fig
#close pdf-device
dev.off()
#END