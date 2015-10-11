# -*- coding: utf-8 -*-
"""
Created on Thu Oct  8 18:03:33 2015

@author: hanshalbe
"""

"""
Main File to optimize Expectancy-Valence model hyper-parameters
File is dependent on igt and GPUCB class
Output: csv-files that contain the predictive survace of the current GP
@author: hanshalbe
"""
#Get the requirements
import numpy as np
import pandas as pd
import GPy

types = pd.read_csv('/home/hanshalbe/movies.csv', index_col=False, header=0, squeeze=True)
data=types.values
mark=np.random.random_integers(low = 0, high = 5000, size = 1)
Xcand=np.atleast_2d(data[:,0:4])
ycand=np.atleast_2d(data[:,4])

noise_var = 1 ** 2
likelihood = GPy.likelihoods.gaussian.Gaussian(variance=noise_var)
kernel = GPy.kern.RBF(input_dim=4, variance=1., lengthscale=1.0, ARD=True)
X=np.atleast_2d(data[mark,0:4])
y=np.atleast_2d(data[mark,4])
for i in range(0,200):
    gausspro = GPy.core.GP(X,y, kernel=kernel,likelihood=likelihood)
    gausspro.optimize()
    print(gausspro.X, gausspro.Y)    
    mean, var =gausspro._raw_predict(_Xnew=Xcand)
    mean = mean.squeeze()
    std_dev = np.sqrt(var.squeeze())
    #upper confidence bound is mu+beta*sigma
    ucb = mean + 3*std_dev
    #mark the highest upper confidence point
    mark_max=np.argmax(ucb)
    Xnew=np.array([Xcand[mark_max,:]])
    ynew=np.array([ycand[0,mark_max]])
    X=np.concatenate([X,Xnew])
    y=np.vstack([y,ynew])