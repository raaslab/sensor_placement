#!/usr/bin/python
import rospy
from geometry_msgs.msg import Twist
from geometry_msgs.msg import Vector3
from nav_msgs.msg import Odometry
from sensor_msgs.msg import LaserScan
from rosaria.msg import BumperState

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
from collections import deque

import tf
from tf.transformations import euler_from_quaternion

record = []
plt.ion()


rbf_init_length_scale = np.array([2.1, 5.1, 14.0, 6.2, 15.0, 2.0, 2.0, 1.0])
kernel = C(10557, (1e-3, 1e8)) * RBF(rbf_init_length_scale, (1e-3, 1e3)) + WhiteKernel(noise_level = 20.0, noise_level_bounds = (1, 1000.0)) 	
gp = GaussianProcessRegressor(kernel = kernel, optimizer = None, n_restarts_optimizer=9)
gamma = 0.1

def quater_to_euler(quaternion):
	euler = tf.transformations.euler_from_quaternion((quaternion.x, quaternion.y, quaternion.z, quaternion.w))
	return euler[2]

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
	return random.choice(list(np.where(q_pred == np.max(q_pred))[0])), q_pred_var


total_switch = 0

pioneer0_cmd_vel = '/cmd_vel'
rospy.init_node('navigation')	

rate = rospy.Rate(10)	
pioneer0_vel_lin = .2 # [m/s]
pioneer0_vel_ang = 0.0 # [rad/s]	
pioneer0_pub = rospy.Publisher(pioneer0_cmd_vel, Twist, queue_size = 2)
actions = range(-9, 10)

list_var = deque([], maxlen = 5)
game_obj = gameEngine.GameState()


while total_switch <= 50000	:	
	### THIS CODE IS FOR SAMPLE GATHERING IN PYGAME ###
	epsilon = 0.1
	# sum_of_reward_per_epoch = 0
	# timestr = time.strftime("%Y%m%d-%H%M%S")
	# sum_of_reward_per_epoch = 0
	# plot_reward_ = []
	# hyperparam = np.zeros((1, 10))	
	action = random.randint(-9, 9)
	curr_reward, curr_state = game_obj.frame_step(action)
	curr_state = curr_state[0]	
	
	num_of_steps = 1
	while num_of_steps <= 10000:
		
		randomNumber = random.random()
		if randomNumber >= epsilon:
			action, var = choose_action(curr_state) 		
			list_var.append(list(var)[action])
			action = actions[action]
		else:
			action = random.randint(-9, 9)	
			q_pred, var = gp.predict(np.array([curr_state.tolist() + [action*math.pi/18]]), return_std = True)	
			list_var.append(var[0])	
			
		if sum(list_var) <= 60 : 
			print 'Control Shifting to Pioneer'
			total_switch += 1
			break	
				
		curr_reward, next_state = game_obj.frame_step(action)
		newRecord = [curr_state.tolist()] + [action * math.pi/18] + [next_state[0].tolist()] + [curr_reward]
		record.append(newRecord)
		curr_state = next_state[0]
		num_of_steps += 1
		record_updated = []
		
		for item in record:
			y = item[3] + gamma * predict_maxq(item[2])
			record_updated.append(item[0] + [item[1]] + [y])	
		# start_comp_time = time.time()
		# Add reward+gamma*max(Q) as target value for current transition	
		
		# newRecord = curr_state.tolist() + [action * math.pi/18] + [curr_reward +  round(gamma * gp_obj.predict_maxq(next_state), 2)]
		
		input_ = [item[:-1] for item in record_updated]
		output_ = [item[-1] for item in record_updated]
	
		gp.fit(input_, output_)	
		# if num_of_steps % 80 == 0:
		# hyperparam = np.concatenate((hyperparam , [np.exp(instance.kernel_.theta)]), axis=0)
		# np.savetxt('hyperparam.txt', hyperparam, fmt='%.4f',)	
	
	


	### THIS CODE IS FOR SAMPLE GATHERING IN REAL WORLD ###
	next_state_laser_data = list(rospy.wait_for_message('/scan', LaserScan).ranges)
	
	next_state_laser_data = [round(rounded) for rounded in next_state_laser_data]		
	# Replace inf readings with maximum range of laser
	for index in range(0, len(next_state_laser_data)): 
		if next_state_laser_data[index] == float('inf') or next_state_laser_data[index] == float('nan'): 
			next_state_laser_data[index] = 5 	
	
	curr_state = np.array(next_state_laser_data)	
	print curr_state
	num_of_steps = 1
	while num_of_steps <= 10000:
		randomNumber = random.random()
		if randomNumber >= epsilon:
			action, var = choose_action(np.array(curr_state)) 
			action = actions[action]
			# print list(var)[action]
			if list(var)[action] > 50:
				print 'Going back to PyGame\n'
				total_switch += 1
				break
		else:
			action = random.randint(-9, 9) 
			q_pred, var = gp.predict(np.array([curr_state.tolist() + [action*math.pi/18]]), return_std = True)	
			# print var
			if var[0] > 50 : 
				print 'Going back to PyGame\n'
				total_switch += 1
				break		

		curr_time = time.time()
		while time.time() - curr_time <= abs(action)/4: 
			pioneer0_pub.publish(Twist(Vector3(0, 0, 0), Vector3(0, 0, np.sign(action) * math.pi/9)))
		time.sleep(1)
		
		curr_time = time.time()
		while time.time() - curr_time <= 1: 
			pioneer0_pub.publish(Twist(Vector3(pioneer0_vel_lin, 0, 0), Vector3(0, 0, 0)))
		time.sleep(1)		
		next_state_laser_data = list(rospy.wait_for_message('/scan', LaserScan).ranges)	
		next_state_laser_data = [round(rounded) for rounded in next_state_laser_data]
		# Replace inf readings with maximum range of laser
		for index in range(0, len(next_state_laser_data)): 
			if next_state_laser_data[index] == float('inf') or next_state_laser_data[index] == float('nan'): 
				next_state_laser_data[index] = 5 	
		# front_bumper = list(rospy.wait_for_message('/RosAria/bumper_state', BumperState).front_bumpers)
		# rear_bumper = list(rospy.wait_for_message('/RosAria/bumper_state', BumperState).rear_bumpers)		
		# curr_time = time.time()
		# if True in front_bumper:
		# 	while time.time() - curr_time <= 3: 
		# 		pioneer0_pub.publish(Twist(Vector3(-0.1, 0, 0), Vector3(0, 0, 0)))	
		# if True in rear_bumper:
		# 	while time.time() - curr_time <= 3: 
		# 		pioneer0_pub.publish(Twist(Vector3(0.1, 0, 0), Vector3(0, 0, 0)))		
		
		next_state = np.array(next_state_laser_data)
		curr_reward =  5 * sum(next_state) 
		
		newRecord = [curr_state.tolist()] + [action * math.pi/18] + [next_state.tolist()] + [curr_reward]
		record.append(newRecord)
		curr_state = next_state
		num_of_steps += 1
	
		record_updated = []
	
		for item in record:
			y = item[3] + gamma * predict_maxq(item[2])
			record_updated.append(item[0] + [item[1]] + [y])	
		# start_comp_time = time.time()
		# Add reward+gamma*max(Q) as target value for current transition	
		
		# newRecord = curr_state.tolist() + [action * math.pi/18] + [curr_reward +  round(gamma * gp_obj.predict_maxq(next_state), 2)]
		
		input_ = [item[:-1] for item in record_updated]
		output_ = [item[-1] for item in record_updated]
	
		instance = gp.fit(input_, output_)	
	# 	# if num_of_steps % 80 == 0:
	# 	hyperparam = np.concatenate((hyperparam , [np.exp(instance.kernel_.theta)]), axis=0)
	# 	np.savetxt('hyperparam.txt', hyperparam, fmt='%.4f',)
		
