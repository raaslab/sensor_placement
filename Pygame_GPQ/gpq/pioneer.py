# imports for pioneer integration
import rospy
from geometry_msgs.msg import Twist
from geometry_msgs.msg import Vector3
from nav_msgs.msg import Odometry
from sensor_msgs.msg import LaserScan
from rosaria.msg import BumperState

# Import Gaussian Process Library
from sklearn.gaussian_process import GaussianProcessRegressor
from sklearn.gaussian_process.kernels import RBF, ConstantKernel as C



# Code part for approximate-Q learning
import numpy as np
import math
import random
import matplotlib.pyplot as plt
import pickle
import time
# import gameEngine
import tf
from tf.transformations import euler_from_quaternion


# Initialize kernel
rbf_init_length_scale = np.array([5.50, 8.50, 3.50, 8.50, 8.50, 3.0, 5.0, 1.10])
kernel = C(22000, (1e-3, 1e8)) * RBF(self.rbf_init_length_scale, (1e-3, 1e3)) + WhiteKernel(noise_level = 35.0, noise_level_bounds = (1, 1000.0)) 	
gp = GaussianProcessRegressor(kernel=self.kernel, optimizer = None, n_restarts_optimizer=9)


# Initialize parameters for algorithm 

actions = range(-9, 10)
gamma = 0.1
epsilon = 0.1

curr_state = []
curr_state = np.array(curr_state)
record = []
eta = 0.005

def quater_to_euler(quaternion):
	euler = tf.transformations.euler_from_quaternion((quaternion.x, quaternion.y, quaternion.z, quaternion.w))
	return euler[2]
	
def predict_maxq(state):	
		all_actions = []
		for action in range(-9, 10):
			test_input = state + [action * math.pi/18]
			all_actions.append(test_input)
		all_actions = np.array(all_actions)
		q_pred, q_pred_var = gp.predict(all_actions, return_std = True) 		
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


pioneer0_cmd_vel = '/cmd_vel'
rospy.init_node('navigation')

rate = rospy.Rate(10)

pioneer0_vel_lin = 0.2 # [m/s]
pioneer0_vel_ang = 0.0 # [rad/s]

pioneer0_pub = rospy.Publisher(pioneer0_cmd_vel, Twist, queue_size = 2)



# Code for recovery
# curr_time =time.time()
# while time.time() - curr_time <= 10: 
# 	pioneer0_pub.publish(Twist(Vector3(-.0, 0, 0), Vector3(0, 0, -0.1)))
# exit()

# next_state_position_data = rospy.wait_for_message('/odom', Odometry).pose.pose.position
# next_state_orientation_data = rospy.wait_for_message('/odom', Odometry).pose.pose.orientation

next_state_laser_data = list(rospy.wait_for_message('/scan', LaserScan).ranges)
		
# Replace inf readings with maximum range of laser
for index, reading in enumerate(next_state_laser_data): 
	if reading == 'inf' : next_state_laser_data[index] = 5 
curr_state = next_state_laser_data



for epoch in range(1, 20):
	num_of_steps = 1
	epoch_reward = 0
	num_of_steps = 1
	print 'epoch' + '\t'+ str(epoch)
	while num_of_steps <= 200:
		randomNumber = random.random()
		if randomNumber >= epsilon:
			action = actions[choose_action(curr_state)] 
		else:
			action = random.randint(-9, 9) 		
	
		curr_time = time.time()
		while time.time() - curr_time <= 1: 
			pioneer0_pub.publish(Twist(Vector3(0, 0, 0), Vector3(0, 0, action * math.pi/18)))
		time.sleep(1)
		
		curr_time = time.time()
		while time.time() - curr_time <= 1: 
			pioneer0_pub.publish(Twist(Vector3(pioneer0_vel_lin, 0, 0), Vector3(0, 0, 0)))
		time.sleep(1)	

		next_state_laser_data = list(rospy.wait_for_message('/scan', LaserScan).ranges)

		'''front_bumper = list(rospy.wait_for_message('/RosAria/bumper_state', BumperState).front_bumpers)
		rear_bumper = list(rospy.wait_for_message('/RosAria/bumper_state', BumperState).rear_bumpers)	

		curr_time = time.time()
		if True in front_bumper:
			while time.time() - curr_time <= 4: 
				pioneer0_pub.publish(Twist(Vector3(-0.1, 0, 0), Vector3(0, 0, 0)))

		if True in rear_bumper:
			while time.time() - curr_time <= 4: 
				pioneer0_pub.publish(Twist(Vector3(0.1, 0, 0), Vector3(0, 0, 0)))'''		
		
		next_state = next_state_laser_data

		curr_reward =  5 * sum(next_state) 
		
		newRecord = [curr_state.tolist()] + [action * math.pi/18] + [next_state[0].tolist()] + [curr_reward]
		record.append(newRecord)
		curr_state = next_state[0]
		num_of_steps += 1
		epoch_reward += curr_reward
	
	record_updated = []
	print 'reward' + '\t' + str(epoch_reward)
	
	if epoch < 4:
		for item in record:
			y = item[3] + gamma * predict_maxq(item[2])
			record_updated.append(item[0] + [item[1]] + [y])	
		# start_comp_time = time.time()
		# Add reward+gamma*max(Q) as target value for current transition	
		
		# newRecord = curr_state.tolist() + [action * math.pi/18] + [curr_reward +  round(gamma * gp_obj.predict_maxq(next_state), 2)]
		
		input_ = [item[:-1] for item in record_updated]
		output_ = [item[-1] for item in record_updated]
	
		instance = gp_obj.gp.fit(input_, output_)	
		# if num_of_steps % 80 == 0:
		hyperparam = np.concatenate((hyperparam , [np.exp(instance.kernel_.theta)]), axis=0)
		np.savetxt('hyperparam.txt', hyperparam, fmt='%.4f',)
			


