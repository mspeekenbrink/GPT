"""
Created on Fri Oct  2 15:47:06 2015
Class to implement Gaussian Process Upper Confidence Optimazion
@author: Eric Schulz, firstandlastnamewithadotinbetween.13@ucl.ac.uk
      
    """

from __future__ import print_function, absolute_import, division

import numpy as np
import GPy

class GP_UCB(object):
    """
Base class for Gaussian Process Upper Confidence Optimization
Parameters:
    -----------
    function: object
        a function taking in a [1,n]-numpy array and producing a scalar output
        this is the target function to be optimized
    bounds: numpy array
        Defines the bounds of the to be optimized parameters.
        Currently 1-3d is possible.
    length: float
        length of the discretized candidate space over which the optimization
        routine searches
    var: scalar
        expected observation noise
    """
    
    def __init__(self, function, bounds, length):
        
        
        """
Intialize the class with the following Parameters:
--------
   function: 
      is the function to be maximized
   noise: 
      is the assumed noise level
   dims: 
      dimensions of the input space
   candidates:
      all possible observation points
   likelihood:
      likelihood of GP
   kernel:
      kernel of the GP, by default a Radial Basis -> lowest regret
        """
        self.function=function
        self.dims = len(bounds)
        self.candidates=self.generate_candidates(bounds, length)
        self.kernel = GPy.kern.Matern52(input_dim=self.dims)
        # Measurement noise
        self.noise_var = 0.05 ** 2
        self.likelihood = GPy.likelihoods.gaussian.Gaussian(variance=self.noise_var)
        self.kernel = GPy.kern.Matern32(input_dim=len(bounds), variance=2., lengthscale=1.0, ARD=True)

        
    def cartesian(self, arrays, out=None):
        """
        Function to generate the cartesian product of an array
        Takes in a number of np.arrays and generates all possible combinations
        """
        arrays = [np.asarray(x) for x in arrays]
        dtype = arrays[0].dtype
        n = np.prod([x.size for x in arrays])
        if out is None:
            out = np.zeros([n, len(arrays)], dtype=dtype)
        m = n / arrays[0].size
        out[:,0] = np.repeat(arrays[0], m)
        if arrays[1:]:
            self.cartesian(arrays[1:], out=out[0:m,1:])
        for j in xrange(1, arrays[0].size):
            out[j*m:(j+1)*m,1:] = out[0:m,1:]
        return out
    
    def generate_candidates(self, bounds, length):
        """
        Function to generate the input space over which the GP-routine 
        optimizes
        Currently, 1-3d inputs are supported
        """
        if len(bounds)==1:
            return np.linspace( bounds[0,0],  bounds[0,1], length)
        elif len(bounds)==2:
            return self.cartesian((np.linspace(bounds[0,0], bounds[0,1], length),
                             np.linspace(bounds[1,0],  bounds[1,1], length)))
        elif len(bounds)==3:
            return self.cartesian((np.linspace(bounds[0,0], bounds[0,1], length),
                              np.linspace(bounds[1,0], bounds[1,1], length),
                              np.linspace(bounds[2,0], bounds[2,1], length)))
                              
    def optimize(self, beta, steps):
        """
        Function to GP-UCB-optimize over the input space
        """
        #sample one point at random to begin
        mark=np.random.random_integers(low = 0,high = len(self.candidates), size = 1)
        #Get the X-matrix
        X=self.candidates[mark,:]
        #Get the y-vector by using the function supplied a priori
        y=self.function(X)
        #change to array
        y=np.array(y)
        #simple sampling to initalize
        for i in range(0,20):
            #one point at random
            mark=np.random.random_integers(low = 0, high = len(self.candidates)-1, size = 1)
            #create parameters to be tested
            testpars=self.candidates[mark,:]
            #generate new observation
            ynew=self.function(testpars)
            #stack up with old y
            y=np.vstack([y,ynew])
            #concatenate matrices together
            X=np.concatenate([X,testpars])
        
        for j in range (0,steps):
            #define Gaussian Process
            self.gausspro = GPy.core.GP(X,y, kernel=self.kernel, 
                                        likelihood=self.likelihood)
            #optimize hyper parameters
            self.gausspro.optimize()
            #get mean and variance over whole candidate set
            mean, var =self.gausspro._raw_predict(_Xnew=self.candidates)
            mean = mean.squeeze()
            std_dev = np.sqrt(var.squeeze())
            #upper confidence bound is mu+beta*sigma
            ucb = mean - beta*std_dev
            #mark the highest upper confidence point
            mark_min=np.argmin(ucb)
            self.ucb=ucb
            print(mark_min)
            #new observation point is the one with highest UCB
            testpars=self.candidates[mark_min,:]
            #transform to array
            testpars=np.array([testpars])
            #print to follow optimization routine
            print(testpars)
            #get funtion's output for that point
            ynew=self.function(testpars)   
            #to array
            ynew=np.array(ynew)
            #stack up arrays of observations
            y=np.vstack([y,ynew])
            #concatenate matrices of used candidates
            X=np.concatenate([X,testpars])
        #in the end, store all used candidate points and there function-output    
        self.X=X
        self.y=y
        self.beta=beta
        
        
    def optimizemore(self, n):
        for j in range (0,n):
            #define Gaussian Process
            self.gausspro = GPy.models.GPRegression(self.X,self.y, self.kernel)
            #optimize hyper parameters
            self.gausspro.optimize()
            #get mean and variance over whole candidate set
            mean, var =self.gausspro._raw_predict(_Xnew=self.candidates)
            mean = mean.squeeze()
            std_dev = np.sqrt(var.squeeze())
            #upper confidence bound is mu+beta*sigma
            ucb = mean - self.beta*std_dev
            #mark the highest upper confidence point
            mark_min=np.argmin(ucb)
            #new observation point is the one with highest UCB
            testpars=self.candidates[mark_min,:]
            #transform to array
            testpars=np.array([testpars])
            #print to follow optimization routine
            print(testpars)
            #get funtion's output for that point
            ynew=self.function(testpars)   
            #to array
            ynew=np.array(ynew)
            #stack up arrays of observations
            self.y=np.vstack([self.y,ynew])
            #concatenate matrices of used candidates
            self.X=np.concatenate([self.X,testpars])
        
    def optimum(self):
        """
        Function to return the points that are currently expected to maximize
        the underlying function
        """
        #get Gaussian-Process predictions
        mean, var=self.gausspro._raw_predict(_Xnew=self.candidates)
        #mark the highest mean value
        mark_best=np.argmin(mean)
        #store the points
        self.bestpoint=self.candidates[mark_best,:]

"""END"""                      