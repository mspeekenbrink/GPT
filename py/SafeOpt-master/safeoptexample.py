# -*- coding: utf-8 -*-
"""
Created on Wed Oct  7 21:30:10 2015

@author: hanshalbe
"""
import safeopt
import GPy
import numpy as np
import pandas as pd



noise_var = 0.05 ** 2

# Set fixed Gaussian measurement noise
likelihood = GPy.likelihoods.gaussian.Gaussian(variance=noise_var)
likelihood.constrain_fixed(warning=False);

# Bounds on the inputs variable
bounds = [(-5., 5.), (-5., 5.)]

# set of parameters
parameter_set = safeopt.linearly_spaced_combinations(bounds, 1000)

# Define Kernel
kernel = GPy.kern.RBF(input_dim=len(bounds), variance=2., lengthscale=1.0,
                      ARD=True)

# Initial safe point
x0 = np.zeros((1, len(bounds)))

# Generate function with safe initial point at x=0
def sample_safe_fun():
    while True:
        fun = safeopt.sample_gp_function(kernel, bounds, noise_var, 10)
        if fun([0,0], noise=False) > 0.5:
            break
    return fun
fun=sample_safe_fun()
truth= np.zeros(len(parameter_set))
for i in range(0,len(parameter_set)):
    truth[i]=fun(parameter_set[i,:])

truthdata=pd.DataFrame({'x1':parameter_set[:,0], 'x2':parameter_set[:,1], 'y':truth})
truthdata.to_csv('/home/hanshalbe/Desktop/GPT/data/truth.csv')


gp = GPy.core.GP(x0, fun(x0), kernel, likelihood)
gp_opt = safeopt.SafeOpt(fun, gp, parameter_set, 0.)


for i in range(1,10):
    gp_opt.gp.optimize()
    gp_opt.optimize()
    print(gp_opt.gp.X)

safeopt10=pd.DataFrame({'x1':gp_opt.gp.X[:,0].flatten(), 'x2':gp_opt.gp.X[:,1].flatten(), 'y':gp_opt.gp.Y.flatten()})
safeopt10.to_csv('/home/hanshalbe/Desktop/GPT/data/safeopt10.csv')

for i in range(11,50):
    gp_opt.gp.optimize()
    gp_opt.optimize()
    print(gp_opt.gp.X)

safeopt50=pd.DataFrame({'x1':gp_opt.gp.X[:,0].flatten(), 'x2':gp_opt.gp.X[:,1].flatten(), 'y':gp_opt.gp.Y.flatten()})
safeopt50.to_csv('/home/hanshalbe/Desktop/GPT/data/safeopt50.csv')


for i in range(51,100):
    gp_opt.gp.optimize()
    gp_opt.optimize()
    print(gp_opt.gp.X)

safeopt100=pd.DataFrame({'x1':gp_opt.gp.X[:,0].flatten(), 'x2':gp_opt.gp.X[:,1].flatten(), 'y':gp_opt.gp.Y.flatten()})
safeopt100.to_csv('/home/hanshalbe/Desktop/GPT/data/safeopt100.csv')



