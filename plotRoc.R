#! /path/to/Rscript
readLineToNumList<- function(fileLink){
  line <- readLines(fileLink,1)
  line <- strsplit(line,' ')
  line <- unlist(line)
  return(as.numeric(line))
}
readLineToStrList<- function(fileLink){
  line <- readLines(fileLink,1)
  line <- strsplit(line,' ')
  line <- unlist(line)
  return(line)
}

library(ggplot2)
dataFile <- file('rel.dat',"r")
auc<-readLineToNumList(dataFile)
className<-readLineToStrList(dataFile)
auc_bar_frame<-data.frame(className,auc)
auc_bar_frame$className<-factor(auc_bar_frame$className,levels=className)
auc_bar<-ggplot(data=auc_bar_frame,aes(x=className,y=auc,fill=className))+
  geom_bar(stat="identity",position='dodge',width=0.7)+
  coord_cartesian(ylim=c(0.85,1)) +
  theme(axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank(),
        axis.line.x=element_blank(),
        legend.position = "none")+
  ylab("AUC")+
  scale_y_continuous(expand = c(0,0))

classNum<-length(className)
fpr<-numeric()
tpr<-numeric()
class_name<-numeric()
for(i in 1:classNum){
  tmpFpr<-readLineToNumList(dataFile)
  tmpTpr<-readLineToNumList(dataFile)
  fpr<-c(fpr,tmpFpr)
  tpr<-c(tpr,tmpTpr)
  class_name<-c(class_name,rep(className[i],length(tmpFpr)))
}
close(dataFile)
auc_curve_frame<-data.frame(fpr,tpr,class_name)
auc_curve_frame$class_name<-factor(auc_curve_frame$class_name,levels=className)
auc_curve<-ggplot()+
  geom_line(data=auc_curve_frame,aes(x=fpr,y=tpr,colour=class_name))+
  xlab("FPR")+
  ylab("TPR")+
  labs(colour="one vs others",title="ROC of real data")+
  theme(plot.title = element_text(hjust=0.5),legend.position = c(0.18,0.33),legend.key.width=unit(2,'cm'))+
  guides(colour = guide_legend(override.aes = list(size=2)))+
  scale_y_continuous(limits = c(0,1))

library(viridis)
library(cowplot)
left_part<-ggdraw()+
  draw_plot(auc_curve,0,0,1,1)+
  draw_plot(auc_bar,0.52,0.23,0.4,0.4)
png(filename='roc.png',width=874,height=566)
print(left_part)
dev.off()
