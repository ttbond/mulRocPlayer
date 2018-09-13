import numpy as np
from sklearn.metrics import roc_curve
from sklearn.metrics import auc
from math import isnan
import os

sourceFile=open("source.dat")
tmpstr=sourceFile.readline()
totalNum=int(float(tmpstr))
classNum=0
probMatrix=np.array([])
classMatrix=np.array([])
tmpstr=sourceFile.readline()
tmpstr=tmpstr.split('\n')[0]
className=tmpstr.split(' ')




for i in range(totalNum):
    tmpstr=sourceFile.readline()
    tmplist=tmpstr.split(' ')
    tmpProb=[]
    for j in tmplist:
        if j=='\n':
            break
        if isnan(float(j)):
            tmpProb.append(0)
        else:
            tmpProb.append(float(j))
    if i==0:
        classNum=len(tmplist)-1
        probMatrix=np.array(tmpProb)
    else:
        probMatrix = np.vstack((probMatrix, np.array(tmpProb)))
for i in range(totalNum):
    tmpstr=sourceFile.readline()
    tmplist=[]
    tmplist.append(int(float(tmpstr)))
    if i==0:
        classMatrix=np.array(tmplist)
    else:
        classMatrix=np.vstack((classMatrix,np.array(tmplist)))

rel_fpr=[]
rel_tpr=[]
rel_auc=[]
for i in range(classNum):
    classId=i
    relP=probMatrix[:,i].copy()
    relClass=classMatrix.copy()
    for j in range(np.shape(classMatrix)[0]):
        if relClass[j,0]!=classId:
            relClass[j,0]=0
        else:
            relClass[j,0]=1
    fpr, tpr, thresholds = roc_curve(relClass, relP, pos_label=1)
    tmpAUC = auc(fpr, tpr, reorder=False)
    print(tmpAUC)
    rel_fpr.append(fpr)
    rel_tpr.append(tpr)
    rel_auc.append(tmpAUC)


relFile=open('rel.dat','w')
for i in rel_auc:
    print(i,end=' ',file=relFile)
print('', file=relFile)
for i in className:
    print(i,end=' ',file=relFile)
print('',file=relFile)
for i in range(len(rel_fpr)):
    for j in rel_fpr[i]:
        print(j,end=' ',file=relFile)
    print('',file=relFile)
    for j in rel_tpr[i]:
        print(j,end=' ',file=relFile)
    print('',file=relFile)
relFile.close()
os.system('Rscript plotRoc.R')
os.system('rm Rplots.pdf')

