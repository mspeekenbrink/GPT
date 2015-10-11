"""
Created on Fri Oct  2 15:47:06 2015
Class to implement Iowa Gambling Task Simulation
@author: Eric Schulz, firstandlastnamewithadotinbetween.13@ucl.ac.uk
      
    """

from __future__ import print_function, absolute_import, division

import numpy as np

class Iowa(object):
    """
Base class for Iowa Gambling Task Optimization.
Parameters:
    -----------
    alpha: float
        The updating parameter for the expectancy valence model.
    consistency: float
        Consistency of the softmax function
    weight: float
        Weight for win-loss-integration 
    """
    
    def __init__(self, alpha, consistency, weight):
        
        self.alpha=alpha
        self.consistency=consistency
        self.weight=weight
    
    def simulate(self, n):
        """
        Simulate n number of IGT-choices with initialized parameters
        
        Parameters
        ----------
        n: float
           Number of simulations
        """
        vvalues = np.zeros(4)
        valence = np.zeros(4)
        collect = np.array([np.zeros(n)]*3).T
        for i in range(0, n):
            theta = (i/10)**self.consistency
            softm = np.exp(theta*valence)
            probs = softm/sum(softm)
            deckc = np.random.choice(4, 1, p = probs)
            collect[i,0] = deckc
            if deckc == 0:
                collect[i,1] = 100
                collect[i,2] = np.random.choice([0,-250], 1, p=[0.5, 0.5])
                vvalues[0]   = (1-self.weight)*100+self.weight*collect[i,2]
                valence[0]   = valence[0]+self.alpha*(vvalues[0]-valence[0])
            elif deckc == 1:
                collect[i,1] = 100
                collect[i,2] = np.random.choice([0,-1250], 1, p=[0.9, 0.1])
                vvalues[1]   = (1-self.weight)*100+self.weight*collect[i,2]
                valence[1]   = valence[1]+self.alpha*(vvalues[1]-valence[1])
            elif deckc == 2:
                collect[i,1] = 50
                collect[i,2] = np.random.choice([0,-50], 1, p=[0.5, 0.5])
                vvalues[2]   = (1-self.weight)*50+self.weight*collect[i,2]
                valence[2]   = valence[2]+self.alpha*(vvalues[2]-valence[2])
            else:
                collect[i,1] = 50
                collect[i,2] = np.random.choice([0,-250], 1, p=[0.9, 0.1])
                vvalues[3]   = (1-self.weight)*50+self.weight*collect[i,2]
                valence[3]   = valence[3]+self.alpha*(vvalues[3]-valence[3])
        self.simulation=collect
        
    def propose(self, palpha, pconsistency, pweight):
        """
        Get probabilities for each choice given proposed-parameters
        
        Parameters
        ----------
        palpha: float
           porposed alpha
        pconsistency: float
           porposed softmax-consistency
        pweight: float
           proposed win-loss parameter
        """
        simvvalues = np.zeros(4)
        simvalence = np.zeros(4)
        simcollect = np.array([np.zeros(len(self.simulation))]*4).T
        for j in range(0, len(simcollect)):
            iota = (j/10)**pconsistency
            soft = np.exp(iota*simvalence)
            rhos = soft/sum(soft)
            simcollect[j] = rhos
            if self.simulation[j,0] == 0:
                simvvalues[0]   = (1-pweight)*self.simulation[j,1]+pweight*self.simulation[j,2]
                simvalence[0]   = simvalence[0]+palpha*(simvvalues[0]-simvalence[0])
            elif self.simulation[j,0] == 1:
                simvvalues[1]   = (1-pweight)*self.simulation[j,1]+pweight*self.simulation[j,2]
                simvalence[1]   = simvalence[1]+palpha*(simvvalues[1]-simvalence[1])
            elif self.simulation[j,0] == 2:
                simvvalues[2]   = (1-pweight)*self.simulation[j,1]+pweight*self.simulation[j,2]
                simvalence[2]   = simvalence[2]+palpha*(simvvalues[2]-simvalence[2])
            else:
                simvvalues[3]   = (1-pweight)*self.simulation[j,1]+pweight*self.simulation[j,2]
                simvalence[3]   = simvalence[3]+palpha*(simvvalues[3]-simvalence[3])
        self.proposal = simcollect
        
    def logloss(self):
         """
        Get logarithmic loss of simulation and proposals
        
         """
         markc = self.simulation[:,0].astype(int)
         truth = np.array([np.zeros(len(self.proposal))]*4).T
         for k in range(0,len(self.proposal)):
             truth[k,markc[k]] = 1
         epsilon = 1e-15
         pred = np.maximum(epsilon, self.proposal)
         pred = np.minimum(1-epsilon, pred)
         ll = sum(truth*np.log(pred) + (1-truth)*np.log(1-pred))
         ll = sum(ll)
         ll = ll * -1.0/len(truth)
         self.loss=ll