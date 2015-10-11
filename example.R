require(MASS)
require(plyr)
require(reshape2)
install.packages("ggplot2")
require(ggplot2)
install.packages('gridExtra')
library(gridExtra)

calcSigma <- function(X1,X2,l=1) {
  Sigma <- matrix(rep(0, length(X1)*length(X2)), nrow=length(X1))
  for (i in 1:nrow(Sigma)) {
    for (j in 1:ncol(Sigma)) {
      Sigma[i,j] <- exp(-0.5*(abs(X1[i]-X2[j])/l)^2)
    }
  }
  return(Sigma)
}

# 1. Plot some sample functions from the Gaussian process
# as shown in Figure 2.2(a)

# Define the points at which we want to define the functions
x.star <- seq(0,10,len=50)

# Calculate the covariance matrix
sigma <- calcSigma(x.star,x.star)

f <- data.frame(x=c(0.1,1,3,5,7.5,9, 9.9), y=c(-1.2,-2,0,0.2,2,-1, -0.8))
x <- f$x
k.xx <- calcSigma(x,x)
k.xxs <- calcSigma(x,x.star)
k.xsx <- calcSigma(x.star,x)
k.xsxs <- calcSigma(x.star,x.star)
sigma.n <- 0.1

# Recalculate the mean and covariance functions
f.bar.star <- k.xsx%*%solve(k.xx + sigma.n^2*diag(1, ncol(k.xx)))%*%f$y
cov.f.star <- k.xsxs - k.xsx%*%solve(k.xx + sigma.n^2*diag(1, ncol(k.xx)))%*%k.xxs

# Recalulate the sample functions
values <- matrix(rep(0,length(x.star)*n.samples), ncol=n.samples)
for (i in 1:n.samples) {
  values[,i] <- mvrnorm(1, f.bar.star, cov.f.star)
}
values <- cbind(x=x.star,as.data.frame(values))
values <- melt(values,id="x")

sig<-sqrt(diag(cov.f.star))
mark<-which(sig==max(sig))

# Plot the result, including error bars on the observed points
opt1 <- ggplot(values, aes(x=x,y=value)) + 
  geom_line(aes(group=variable), colour="grey80") +
  geom_line(data=NULL,aes(x=x.star,y=f.bar.star),colour="red", size=1) + 
  geom_line(data=NULL,aes(x=x.star,y=f.bar.star+sig),colour="red", size=1,linetype=3) + 
  geom_point(data=f,aes(x=x,y=y)) +
  geom_point(data=NULL,aes(x=x.star[mark],y=(f.bar.star+sig)[mark]), colour="blue", shape=9) +
  theme_bw() +
  scale_y_continuous(lim=c(-4,4), name="Output f(x)") +
  scale_x_continuous(lim=c(0,10), name="Input") +
  xlab("input, x")+ggtitle("Optimal design: Step 1")+
  theme(text = element_text(size=24))
opt1

f<-rbind(f,c(x.star[mark], f.bar.star[mark]))
x <- f$x
k.xx <- calcSigma(x,x)
k.xxs <- calcSigma(x,x.star)
k.xsx <- calcSigma(x.star,x)
k.xsxs <- calcSigma(x.star,x.star)
sigma.n <- 0.1

# Recalculate the mean and covariance functions
f.bar.star2 <- k.xsx%*%solve(k.xx + sigma.n^2*diag(1, ncol(k.xx)))%*%f$y
cov.f.star2 <- k.xsxs - k.xsx%*%solve(k.xx + sigma.n^2*diag(1, ncol(k.xx)))%*%k.xxs

# Recalulate the sample functions
values <- matrix(rep(0,length(x.star)*n.samples), ncol=n.samples)
for (i in 1:n.samples) {
  values[,i] <- mvrnorm(1, f.bar.star, cov.f.star)
}
values <- cbind(x=x.star,as.data.frame(values))
values <- melt(values,id="x")

sig2<-sqrt(diag(cov.f.star2))
mark2<-which(sig2==max(sig2))
# Plot the result, including error bars on the observed points
opt2 <- ggplot(values, aes(x=x,y=value)) + 
  geom_line(aes(group=variable), colour="grey80") +
  geom_line(data=NULL,aes(x=x.star,y=f.bar.star2),colour="red", size=2) + 
  geom_line(data=NULL,aes(x=x.star,y=f.bar.star2+sig2),colour="red", size=2,linetype=3) + 
  geom_point(data=f,aes(x=x,y=y)) +
  geom_point(data=NULL,aes(x=x.star[mark2],y=(f.bar.star2+sig2)[mark2]), colour="blue", shape=9) +
  theme_bw() +
  scale_y_continuous(lim=c(-4,4), name="Output f(x)") +
  scale_x_continuous(lim=c(0,10), name="Input") +
  xlab("input, x")+ggtitle("Optimal design: Step 2")+
  theme(text = element_text(size=24))

pdf("sample.pdf", width=18, height=9)
grid.arrange(opt1, opt2, nrow=1)
dev.off()

install.packages('lme4')
print(require(lme4))
