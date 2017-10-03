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
	
	def predict_maxq(self, state):	
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
	sum_of_reward_per_epoch = 0
	curr_state = [2, 2, 2]
	curr_state = np.array(curr_state)
	timestr = time.strftime("%Y%m%d-%H%M%S")
	sum_of_reward_per_epoch = 0
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
		newRecord = curr_state.tolist() + [action] + [curr_reward + round(gamma * gp_obj.predict_maxq(next_state), 2)]
		sum_of_reward_per_epoch += curr_reward
		if i % 5 == 0:
			print sum_of_reward_per_epoch
			sum_of_reward_per_epoch = 0
		record.append(newRecord)
		input_ = [item[:-1] for item in record]
		output_ = [item[-1] for item in record]
		eig_values = np.linalg.eig(gp_obj.gp.fit(input_, output_).K)[0]

		# Check the condition number of the matrix
		if np.max(eig_values)/np.min(eig_values) > 10:
			record = record[:-1]
		# time.sleep(0.5)
		curr_state = next_state[0]
		i += 1
