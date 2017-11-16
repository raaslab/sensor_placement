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


rbf_init_length_scale = np.array([5.50, 8.50, 3.50, 8.50, 8.50, 3.0, 5.0, 1.10])
kernel = C(22000, (1e-3, 1e8)) * RBF(rbf_init_length_scale, (1e-3, 1e3)) + WhiteKernel(noise_level = 35.0, noise_level_bounds = (1, 1000.0)) 	
gp = GaussianProcessRegressor(kernel = kernel, optimizer = None, n_restarts_optimizer=9)
gamma = 0.1

def predict_maxq(state):	
	# if len(record) > 0:
	# 	self.gpq(record)
	all_actions = []
	for action in range(-9, 10):
		test_input = state + [action * math.pi/18]
		all_actions.append(test_input)
	all_actions = np.array(all_actions)
	q_pred, q_pred_var = gp.predict(all_actions, return_std = True, return_cov=False) 		
	list_q = list(q_pred)
	maxq  = max(list_q)
	return maxq

def choose_action(curr_state):
	all_actions = []
	#print curr_state
	for action in range(-9, 10):
		test_input = curr_state.tolist() + [action * math.pi/18]
		all_actions.append(test_input)		
	all_actions = np.array(all_actions)
	# print all_actions
	q_pred, q_pred_var = gp.predict(all_actions, return_std = True)
	return random.choice(list(np.where(q_pred == np.max(q_pred))[0]))


	
actions = range(-9, 10)
epsilon = 0.10
game_obj = gameEngine.GameState()
sum_of_reward_per_epoch = 0
timestr = time.strftime("%Y%m%d-%H%M%S")
sum_of_reward_per_epoch = 0
plot_reward_ = []
hyperparam = np.zeros((1, 10))

action = random.randint(-9, 9)
curr_reward, curr_state = game_obj.frame_step(action)
curr_state = curr_state[0]
for epoch in range(1, 100):
	epoch_reward = 0
	num_of_steps = 1
	print 'epoch' + '\t'+ str(epoch)
	while num_of_steps <= 200:
		if num_of_steps != 1:
			randomNumber = random.random()
			if randomNumber >= epsilon:
				action = actions[choose_action(curr_state)]
			else:
				action = random.randint(-9, 9)		
				
		curr_reward, next_state = game_obj.frame_step(action)
		newRecord = [curr_state.tolist()] + [action * math.pi/18] + [next_state[0].tolist()] + [curr_reward]
		record.append(newRecord)
		curr_state = next_state[0]
		num_of_steps += 1
		epoch_reward += curr_reward
	record_updated = []
	print 'reward' + '\t' + str(epoch_reward)
	if epoch < 5:
		for item in record:
			y = item[3] + gamma * predict_maxq(item[2])
			record_updated.append(item[0] + [item[1]] + [y])	
		# start_comp_time = time.time()
		# Add reward+gamma*max(Q) as target value for current transition	
		
		# newRecord = curr_state.tolist() + [action * math.pi/18] + [curr_reward +  round(gamma * gp_obj.predict_maxq(next_state), 2)]
		
		input_ = [item[:-1] for item in record_updated]
		output_ = [item[-1] for item in record_updated]
	
		instance = gp.fit(input_, output_)	
		# if num_of_steps % 80 == 0:
		hyperparam = np.concatenate((hyperparam , [np.exp(instance.kernel_.theta)]), axis=0)
		np.savetxt('hyperparam.txt', hyperparam, fmt='%.4f',)
			# Instance of self.fit function
			# instance = gp_obj.gp.fit(input_, output_)
		# eig_values = np.linalg.eig(instance.observ)[0]
			# g.write("%s\n" % (time.time() - start_comp_time))
			# Check the condition number of the matrix
			# if np.max(eig_values)/np.min(eig_values) > condition_number:
			# 	record = record
			# Go to next state
			# sum_of_reward_per_epoch += curr_reward
			# if num_of_steps % 5 == 0:
				# f.write("%d\n" % sum_of_reward_per_epoch)
				# print sum_of_reward_per_epoch
				# plot_reward_.append(sum_of_reward_per_epoch)
				# sum_of_reward_per_epoch = 0
			

