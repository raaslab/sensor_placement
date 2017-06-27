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

if __name__ == "__main__":
	epsilon = 0.1
	i = 0
	j = 0
	itr = 0
	#states = [(1,1,1),(1,1,2),(1,2,1),(2,1,1),(1,2,2),(2,2,1),(2,1,2),(2,2,2)]
	prev_length_of_record = 0
	game_obj = gameEngine.GameState()
	q_obj = q_class()
	#plot_obj = plotting.plot_class()
	sum_of_reward_per_epoch = 0
	prev_state = [LASER_MAX_VAL,LASER_MAX_VAL,LASER_MAX_VAL]
	prev_state = np.array([prev_state])
	next_state = [[LASER_MAX_VAL,LASER_MAX_VAL,LASER_MAX_VAL]]
	timestr = time.strftime("%Y%m%d-%H%M%S")
	heat = np.zeros((8, numOfActions))
	while epoch < 1000:
		if i != 0:
			randomNumber = random.random()
			if randomNumber >= epsilon:
				action = q_obj.choose_action(next_state.tolist()[0])
				#print action
			else:
				action = random.randint(0, numOfActions-1)		
		elif i == 0:
			action = random.randint(0, numOfActions-1)

		curr_reward, next_state = game_obj.frame_step(action)		
		iteration = iteration + 1
		q_obj.updateQ(prev_state.tolist()[0],action,curr_reward,next_state.tolist()[0])
		prev_state = next_state

		'''
		if i%200 == 0:
			for s in states:
				for a in range(0,numOfActions):
					heat[itr][a] = Q.get((tuple(s),a),0)
				itr+=1
			itr = 0
			plt.imshow(heat, cmap='coolwarm', interpolation='nearest')
			plt.pause(0.5)
		'''
		'''
		print Q
		print "========="
		print "========="
		print count
		print "\n\n\n"

		for s in states:
			for a in range(0,3):
				heat[itr][a] = Q.get((tuple(s),a),0)
			itr+=1
		itr = 0
		plt.imshow(heat, cmap='coolwarm', interpolation='nearest')
		plt.pause(0.05)
		'''
		
		sum_of_reward_per_epoch += curr_reward
		
		if iteration % 200 == 0:
			#prev_length_of_record = len(record)
			
			#plt.scatter(epoch,sum_of_reward_per_epoch)
			
			with open(timestr + '_q', 'a') as fp:
				fp.write(str(sum_of_reward_per_epoch) + '\n')
				fp.flush()
			fp.close()
			
			#plot_obj.plotting(record)
			
			#print 'REWARD COLLECTED THIS EPOCH: %d' % sum_of_reward_per_epoch
			
			sum_of_reward_per_epoch = 0
			epoch += 1
		i+= 1
		#plt.pause(0.05)
		