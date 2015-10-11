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
            #consistency determines softmax theta
            theta = (i/10)**self.consistency
            #softmax of valence
            softm = np.exp(theta*valence)
            #probabilities
            probs = softm/sum(softm)
            #choic in dependency of probabilities
            deckc = np.random.choice(4, 1, p = probs)
            #get the chosen deck
            collect[i,0] = deckc
            #deck 1, win 100, loss p(0.5)=250
            if deckc == 0:
                collect[i,1] = 100
                collect[i,2] = np.random.choice([0,-250], 1, p=[0.5, 0.5])
                vvalues[0]   = (1-self.weight)*100+self.weight*collect[i,2]
                valence[0]   = valence[0]+self.alpha*(vvalues[0]-valence[0])
                #deck 2, win 100, loss p(0.1)=1250
            elif deckc == 1:
                collect[i,1] = 100
                collect[i,2] = np.random.choice([0,-1250], 1, p=[0.9, 0.1])
                vvalues[1]   = (1-self.weight)*100+self.weight*collect[i,2]
                valence[1]   = valence[1]+self.alpha*(vvalues[1]-valence[1])
                #deck 3, win 50, loss p(0.5)=50
            elif deckc == 2:
                collect[i,1] = 50
                collect[i,2] = np.random.choice([0,-50], 1, p=[0.5, 0.5])
                vvalues[2]   = (1-self.weight)*50+self.weight*collect[i,2]
                valence[2]   = valence[2]+self.alpha*(vvalues[2]-valence[2])
            else:
                #deck 4, win 50, loss p(0.1)=250
                collect[i,1] = 50
                collect[i,2] = np.random.choice([0,-250], 1, p=[0.9, 0.1])
                vvalues[3]   = (1-self.weight)*50+self.weight*collect[i,2]
                valence[3]   = valence[3]+self.alpha*(vvalues[3]-valence[3])
                #create a simulated data set
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
        #initialize values and valence
        simvvalues = np.zeros(4)
        simvalence = np.zeros(4)
        #initialize collector frame
        simcollect = np.array([np.zeros(len(self.simulation))]*4).T
        #loop through the simulated set
        for j in range(0, len(simcollect)):
            #softmax parameter determined by proposed consistency
            iota = (j/10)**pconsistency
            #softmax calculation
            soft = np.exp(iota*simvalence)
            #get probabilities
            rhos = soft/sum(soft)
            #probabilities are stored for output
            simcollect[j] = rhos
            #if simulated participant chose deck 1: update its valence
            if self.simulation[j,0] == 0:
                simvvalues[0]   = (1-pweight)*self.simulation[j,1]+pweight*self.simulation[j,2]
                simvalence[0]   = simvalence[0]+palpha*(simvvalues[0]-simvalence[0])
                #if simulated participant chose deck 2: update its valence            
            elif self.simulation[j,0] == 1:
                simvvalues[1]   = (1-pweight)*self.simulation[j,1]+pweight*self.simulation[j,2]
                simvalence[1]   = simvalence[1]+palpha*(simvvalues[1]-simvalence[1])
                #if simulated participant chose deck 3: update its valence
            elif self.simulation[j,0] == 2:
                simvvalues[2]   = (1-pweight)*self.simulation[j,1]+pweight*self.simulation[j,2]
                simvalence[2]   = simvalence[2]+palpha*(simvvalues[2]-simvalence[2])
                #if simulated participant chose deck 4: update its valence
            else:
                simvvalues[3]   = (1-pweight)*self.simulation[j,1]+pweight*self.simulation[j,2]
                simvalence[3]   = simvalence[3]+palpha*(simvvalues[3]-simvalence[3])
        #create the collected probabilities as proposal
        self.proposal = simcollect
        
    def logloss(self):
         """
        Get logarithmic loss of simulation and proposals
        
         """
         #chosen decks
         markc = self.simulation[:,0].astype(int)
         #truth matrix
         truth = np.array([np.zeros(len(self.proposal))]*4).T
         #loop through proposal
         for k in range(0,len(self.proposal)):
             truth[k,markc[k]] = 1
         #0s and 1s can occur, but would mess up log-loss, therefore define tolerance
         epsilon = 1e-15
         #predictions
         pred = np.maximum(epsilon, self.proposal)
         #predictions with tolerance-adjusted
         pred = np.minimum(1-epsilon, pred)
         #log loss
         ll = sum(truth*np.log(pred) + (1-truth)*np.log(1-pred))
         #sum it up
         ll = sum(ll)
         #divide it by number of cases
         ll = ll * -1.0/len(truth)
         #assign loss
         self.loss=ll