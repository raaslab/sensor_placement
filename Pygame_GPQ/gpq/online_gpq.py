#!/usr/bin/python
import numpy as np
import math
import random
from sklearn.gaussian_process import GaussianProcessRegressor
from sklearn.gaussian_process.kernels import RBF, ConstantKernel as C, WhiteKernel
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
		self.rbf_init_length_scale = np.array([1, 1, 1, 1, 1, 1, 1, 1, 5])
		self.kernel = C(134.0, (1e-3, 1e8)) * RBF(self.rbf_init_length_scale, (1e-3, 1e3)) + WhiteKernel(noise_level = 1.0, noise_level_bounds = (1, 10.0)) 	
		self.gp = GaussianProcessRegressor(kernel=self.kernel, n_restarts_optimizer=9)
		self.gamma = 0.9
	
	def predict_maxq(self, state):	
		# if len(record) > 0:
		# 	self.gpq(record)
		all_actions = []
		for action in range(-9, 10):
			test_input = state[0].tolist() + [action * math.pi/18]
			all_actions.append(test_input)
		all_actions = np.array(all_actions)
		q_pred, q_pred_var = self.gp.predict(all_actions, return_std = True, return_cov=False) 		
		list_q = list(q_pred)
		maxq  = max(list_q)
		return maxq

	def choose_action(self, curr_state):
		all_actions = []
		#print curr_state
		for action in range(-9, 10):
			test_input = curr_state.tolist() + [action * math.pi/18]
			all_actions.append(test_input)		
		all_actions = np.array(all_actions)
		# print all_actions
		q_pred, q_pred_var = self.gp.predict(all_actions, return_std = True)
		return random.choice(list(np.where(q_pred == np.max(q_pred))[0]))


if __name__ == "__main__":
	num_of_steps = 1
	j = 0
	actions = range(-9, 10)
	condition_number = 100
	gamma = 0.9
	epsilon = 0.8
	game_obj = gameEngine.GameState()
	gp_obj = gp_prediction()
	sum_of_reward_per_epoch = 0
	curr_state = [10, 10, 10, 10, 10, 10, 10, 10]
	curr_state = np.array(curr_state)
	timestr = time.strftime("%Y%m%d-%H%M%S")
	sum_of_reward_per_epoch = 0
	plot_reward_ = []
	f = open("learned.txt","w+")
	# g = open("condition_10_comp_time.txt","w+")
	hyperparam = np.zeros((1, 11))
	while num_of_steps <= 2000:
		epsilon = epsilon/1.001
		print num_of_steps
		if num_of_steps != 1:
			randomNumber = random.random()
			if randomNumber >= epsilon:
				action = actions[gp_obj.choose_action(curr_state)]
			else:
				action = random.randint(-9, 9)		
		elif num_of_steps == 1:
			action = random.randint(-9, 9)
			


		curr_reward, next_state = game_obj.frame_step(action)
		game_obj.frame_step(action)
		# start_comp_time = time.time()
		# Add reward+gamma*max(Q) as target value for current transition

		
		newRecord = curr_state.tolist() + [action * math.pi/18] + [curr_reward +  round(gamma * gp_obj.predict_maxq(next_state), 2)]	
		record.append(newRecord)

		input_ = [item[:-1] for item in record]
		output_ = [item[-1] for item in record]
		
		if num_of_steps % 80 == 0:
			hyperparam = np.concatenate((hyperparam , [np.exp(gp_obj.gp.fit(input_, output_).kernel_.theta)]), axis=0)
			np.savetxt('hyperparam.txt', hyperparam, fmt='%.4f',)
		# Instance of self.fit function
		# instance = gp_obj.gp.fit(input_, output_)
		# eig_values = np.linalg.eig(instance.K)[0]
		# print np.exp(instance.kernel_.theta)
		# g.write("%s\n" % (time.time() - start_comp_time))
		# Check the condition number of the matrix
		# if np.max(eig_values)/np.min(eig_values) > condition_number:
		# 	record = record
		# Go to next state
		curr_state = next_state[0]
		# sum_of_reward_per_epoch += curr_reward
		# if num_of_steps % 5 == 0:
			# f.write("%d\n" % sum_of_reward_per_epoch)
			# print sum_of_reward_per_epoch
			# plot_reward_.append(sum_of_reward_per_epoch)
			# sum_of_reward_per_epoch = 0
		num_of_steps += 1

# print record
		
# all_actions = []

# input_ = [item[:-1] for item in record]
# output_ = [item[-1] for item in record]
		# Instance of self.fit function
# instance = np.exp(gp_obj.gp.fit(input_, output_).kernel_.theta)
# print instance


	for statex in range(0, 1300, 50):
		for statey in range(0, 1000, 50):
			all_actions = []
			for action in range(-9, 10):
				test_input = [statex, statey] + [1, 0] + [5, 5, 5, 5] + [action * math.pi/18]
				all_actions.append(test_input)
			all_actions = np.array(all_actions)
			q_pred, q_pred_var = gp_obj.gp.predict(all_actions, return_std = True, return_cov=False) 		
			list_q = list(q_pred)
			maxq  = max(list_q)		
			f.write("%d \t %d \t %f \n" % (statex, statey, maxq))


# # for item in record:
# # 	f.write("%d \t %d\n" %  np.array(item[:-1]))
# f.close()

# g.close()
# print plot_reward_
# plt.plot(plot_reward_)
# plt.show()	
# time.sleep(15)