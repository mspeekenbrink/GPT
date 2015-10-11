"""
Main File to optimize Expectancy-Valence model hyper-parameters
File is dependent on igt and GPUCB class
Output: csv-files that contain the predictive survace of the current GP
@author: hanshalbe
"""
#Get the requirements
import igt as igt
import GPUCB as gpucb
import numpy as np
import pandas as pd

#Set the parameters of the simulated IGT
m=igt.Iowa(alpha=0.2, consistency=0, weight=0.5)

#function to optimize is the log-loss in the IGT
def optimisealpha(X):
    #150 simulations
    m.simulate(n=150)
    #propose given the inputs
    m.propose(palpha=X[0,0], pconsistency=0, pweight=X[0,1])
    #calculate log-loss
    m.logloss()
    #get log-loss
    loss=m.loss
    #return loss
    return(loss)
    
#intialize GPUCB object, alpha, weight = [0.01, 0.02,...,0.99]    
gp=gpucb.GP_UCB(optimisealpha, bounds=np.array([[0.01,0.99],[0.01,0.99]]), length=99)
#beta=1.96 (approx normal 95%), initial steps=100
gp.optimize(beta=1.96, steps=5)
#get current predictions
mean, var=gp.gausspro._raw_predict(_Xnew=gp.candidates)
#store in data frame
d100=pd.DataFrame({'alpha':gp.candidates[:,0], 'weight':gp.candidates[:,1], 'mu':mean.squeeze()})
#save frame as csv
d100.to_csv('/home/hanshalbe/Desktop/GPT/data/d100.csv')
#get 400 more steps (ntotal=500)
#gp.optimizemore(n=400)
#get current predictions
#mean, var=gp.gausspro._raw_predict(_Xnew=gp.candidates)
#store in data frame
#d500=pd.DataFrame({'alpha':gp.candidates[:,0], 'weight':gp.candidates[:,1], 'mu':mean.squeeze()})
#save as csv
#d500.to_csv('/home/hanshalbe/Desktop/GPT/data/d500.csv')
#get 500 more steps (ntotal=1000)
#gp.optimizemore(n=500)
#get current predictions
#mean, var=gp.gausspro._raw_predict(_Xnew=gp.candidates)
#store in data frame
#d1000=pd.DataFrame({'alpha':gp.candidates[:,0], 'weight':gp.candidates[:,1], 'mu':mean.squeeze()})
#save as csv
#d1000.to_csv('/home/hanshalbe/Desktop/GPT/data/d1000.csv')