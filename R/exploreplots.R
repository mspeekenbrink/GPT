#House keeping
rm(list=ls())
#ggplot
library(ggplot2)

#get data
setwd("/home/hanshalbe/Desktop/FunctionLearning/AprioriData")

#DATA 
dlin<-read.csv("lin.csv")
dlin<-rbind(dlin[1:40,],dlin[grepl("ALM",dlin$Method),])
dlin$Model<-rep(c("Random", "Linear", "Quadratic", "Cubic", "Regression Tree", "GP"), each=40)
dlin$MSE<-dlin$MSE/mean(dlin$MSE[dlin$Model=="Random"])

dqua<-read.csv("quadratic.csv")
dqua<-rbind(dqua[1:40,],dqua[grepl("ALM",dqua$Method),])
dqua$Model<-rep(c("Random", "Linear", "Quadratic", "Cubic", "Regression Tree", "GP"), each=40)
dqua$MSE<-dqua$MSE/mean(dqua$MSE[dqua$Model=="Random"])


dcub<-read.csv("cubic.csv")
dcub<-rbind(dcub[1:40,],dcub[grepl("ALM",dcub$Method),])
dcub$Model<-rep(c("Random", "Linear", "Quadratic", "Cubic", "Regression Tree", "GP"), each=40)
dcub$MSE<-dcub$MSE/mean(dcub$MSE[dcub$Model=="Random"])

dnst<-read.csv("nonstat.csv")
dnst<-rbind(dnst[1:40,],dnst[grepl("ALM",dnst$Method),])
dnst$Model<-rep(c("Random", "Linear", "Quadratic", "Cubic", "Regression Tree", "GP"), each=40)
dnst$MSE<-dnst$MSE/mean(dnst$MSE[dnst$Model=="Random"])

dsin<-read.csv("sine.csv")
dsin<-rbind(dsin[1:40,],dsin[grepl("ALM",dsin$Method),])
dsin$Model<-rep(c("Random", "Linear", "Quadratic", "Cubic", "Regression Tree", "GP"), each=40)
dsin$MSE<-dsin$MSE/mean(dsin$MSE[dsin$Model=="Random"])

dlog<-read.csv("log.csv")
dlog<-rbind(dlog[1:40,],dlog[grepl("ALM",dlog$Method),])
dlog$Model<-rep(c("Random", "Linear", "Quadratic", "Cubic", "Regression Tree", "GP"), each=40)
dlog$MSE<-dlog$MSE/mean(dlog$MSE[dlog$Model=="Random"])


dplot<-rbind(dlin,dqua,dcub,dlog,dsin,dnst)
dplot$generate<-rep(c("Linear", "Quadratic", "Cubic", "Logarithm", "Sine", "Non-stationary"), each=nrow(dlin))
dplot$generate<-ordered(dplot$generate, 
                        levels = c("Linear", "Quadratic", "Cubic", "Logarithm", "Sine", "Non-stationary"))

dplot$Model<-ordered(dplot$Model, 
                        levels = c("Random", "Linear", "Quadratic", "Cubic", "Regression Tree", "GP"))

mycols<-colorRampPalette(c("burlywood1", "burlywood2", "burlywood3"), space = "Lab")

dplot<-subset(dplot, Model!="Regression Tree")
pd <- position_dodge(.1)
finalplot<-ggplot(dplot, aes(x=Sequence, y=MSE, shape=Model)) +
  geom_point(size=1.8, col="gray35") +
  geom_line(position=pd, col="gray35")+
  scale_y_continuous(lim=c(0,1), name="MSE") +
  scale_x_continuous(lim=c(0,40), name="Trial") +
  ggtitle("Performance over time\n")+ facet_wrap(~ generate, ncol = 2)+
  scale_shape_manual(values=c(17,18,15,4,8))+theme(text = element_text(size=12))
print(finalplot)


setwd("/home/hanshalbe/Desktop/GPT")
pdf("figs/activeperfomance.pdf")
print(finalplot)
dev.off()
