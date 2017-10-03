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
import gameEngine

record = []
plt.ion()

class gp_prediction():
	def __init__(self):
		self.rbf_init_length_scale = 10 * np.array([1, 1, 1, 1])
		self.kernel = C(10.0, (1e-3, 1e3)) * RBF(self.rbf_init_length_scale, (1e-3, 1e3))	
		self.gp = GaussianProcessRegressor(kernel=self.kernel, n_restarts_optimizer=9, alpha = 1e-2)
		self.gamma = 0.9

	# def gpq(self, record):
	# 	record = np.array(record)
	# 	input_ = record[:, 0 : 4]
	# 	output_ = record[:, 4]
	# 	print self.gp.fit(input_, output_).L_.shape
	
	def predict_maxq(self, state, record):	
		# if len(record) > 0:
		# 	self.gpq(record)
		all_actions = []
		for action in range(0, 4):
			test_input = state[0].tolist() + [action]
			all_actions.append(test_input)
		all_actions = np.array(all_actions)
		q_pred, q_pred_var = self.gp.predict(all_actions, return_std = True, return_cov=False) 		
		list_q = list(q_pred)
		maxq  = max(list_q)
		return maxq

	def choose_action(self, curr_state):
		all_actions = []
		for action in range(0, 4):
			test_input = curr_state.tolist() + [action]
			all_actions.append(test_input)
		
		all_actions = np.array(all_actions)
		q_pred, q_pred_var = self.gp.predict(all_actions, return_std = True, return_cov=False) 
		list_q = list(q_pred)
		maxIndex  = list_q.index( max(list_q) )
		return maxIndex

if __name__ == "__main__":
	i = 0
	j = 0
	gamma = 0.9
	epsilon = 0.1
	game_obj = gameEngine.GameState()
	gp_obj = gp_prediction()
	# plot_obj = plotting.plot_class()
	sum_of_reward_per_epoch = 0
	curr_state = [2, 2, 2]
	curr_state = np.array(curr_state)
	# next_state = [[20,20,20,20,20,20]]
	timestr = time.strftime("%Y%m%d-%H%M%S")
	
	while True:
		if i != 0:
			randomNumber = random.random()
			if randomNumber >= epsilon:
				action = gp_obj.choose_action(curr_state)
			else:
				action = random.randint(0, 3)		
		elif i == 0:
			action = random.randint(0, 3)
		
		curr_reward, next_state = game_obj.frame_step(action)
		newRecord = curr_state.tolist() + [action] + [curr_reward + round(gamma * gp_obj.predict_maxq(next_state, record), 2)]
		record.append(newRecord)
		record = np.array(record)
		input_ = record[:, 0 : 4]
		output_ = record[:, 4]
		gp_obj.gp.fit(input_, output_)
		print '+++++++++'
		curr_state = next_state[0]
		i += 1
