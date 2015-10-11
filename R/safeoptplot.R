d<-read.csv("/home/hanshalbe/Desktop/GPT/data/truth1.csv", header=TRUE)
d1<-read.csv("/home/hanshalbe/Desktop/GPT/data/safeopt10.csv", header=TRUE)
d2<-read.csv("/home/hanshalbe/Desktop/GPT/data/safeopt50.csv", header=TRUE)
d3<-read.csv("/home/hanshalbe/Desktop/GPT/data/safeopt100.csv", header=TRUE)

library(fields)

g.colors <- colorRampPalette( c("grey20", "grey80") )

pdf("safeoptimization.pdf", width=10, height=10)
par(oma=c(0,0,2,0))
par(mfrow=c(2,2))
image(image.smooth((matrix(d$y, nrow=sqrt(nrow(d))))), col=g.colors(9), zlim=c(-0.5,3),
      main=expression(omega==1), xlab=expression(x[1]), ylab=expression(x[2]),
      cex.lab=1.5, cex.main=2)
      
image(image.smooth((matrix(d$y, nrow=sqrt(nrow(d))))), col=g.colors(9), zlim=c(-0.5,3),
           main=expression(omega==10), xlab=expression(x[1]), ylab=expression(x[2]),
      cex.lab=1.5, cex.main=2)
points((d1$x1+5)*10, (d1$x2+5)*10, pch=3, cex=1.5)


image(image.smooth((matrix(d$y, nrow=sqrt(nrow(d))))), col=g.colors(9), zlim=c(-0.5,3),
           main=expression(omega==50), xlab=expression(x[1]), ylab=expression(x[2]),
      cex.lab=1.5, cex.main=2)
points((d2$x1+5)*10, (d2$x2+5)*10, pch=3, cex=1.5)

image(image.smooth((matrix(d$y, nrow=sqrt(nrow(d))))), col=g.colors(9), zlim=c(-0.5,3),
           main=expression(omega==100), xlab=expression(x[1]) , ylab=expression(x[2]), 
      cex.lab=1.5, cex.main=2)
points((d3$x1+5)*10, (d3$x2+5)*10, pch=3, cex=1.5)
title("GP Safe Optimization", outer=TRUE, cex.main=2)
dev.off()

getwd()
