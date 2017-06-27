#!/usr/bin/python

import numpy as np
import math
import random
from sklearn.gaussian_process import GaussianProcessRegressor
from sklearn.gaussian_process.kernels import RBF, ConstantKernel as C
from scipy.stats import multivariate_normal
from scipy.integrate import dblquad
import matplotlib.pyplot as plt
import pickle
import time

LASER_MAX_VAL = 10
numOfActions = 4
MAX_INIT_Q = -float("inf")
Q = {((LASER_MAX_VAL,LASER_MAX_VAL,LASER_MAX_VAL),0):0}
count = {((LASER_MAX_VAL,LASER_MAX_VAL,LASER_MAX_VAL),0):0}
plt.ion()
record = []
epoch = 0
iteration = 0

class q_class():
	def __init__(self):
		self.alpha = 0.0
		self.gamma = 1
	#@profile
	def updateQ(self,state_x,action,reward,state_y):
		q_sa = Q.get((tuple(state_x),action), 0)
		max_q = MAX_INIT_Q
		for a in range(0,numOfActions):
			val = Q.get((tuple(state_y),a),0)
			if val > max_q:
				max_q = val
		count[(tuple(state_x),action)] = count.get((tuple(state_x),action),0) + 1
		alpha = 1/count[(tuple(state_x),action)]
		newQ = q_sa + alpha * (reward + self.gamma * max_q - q_sa)
		Q[(tuple(state_x),action)] = newQ

	#@profile
	def choose_action(self,state_x):
		max_q = MAX_INIT_Q
		max_action = 0
		for a in range(0,numOfActions):
			val = Q.get((tuple(state_x),a),float("inf"))
			if val > max_q:
				max_q = val
				max_action = a
		return max_action
