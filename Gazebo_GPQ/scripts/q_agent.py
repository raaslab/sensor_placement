#!/usr/bin/python
import numpy as np
import rospy
import time
import random
import math
import std_msgs.msg
import matplotlib.pyplot as plt
import actionlib
import matplotlib.pyplot as plt
import wall_follower.msg
import q
import mavros
import pickle
#import update_transition_class
from mavros.utils import *
from mavros_msgs.msg import State
from mavros_msgs.srv import SetMode, StreamRate, StreamRateRequest, CommandBool, CommandTOL
from geometry_msgs.msg import *
from sensor_msgs.msg import Joy, LaserScan, Imu

import os
import signal
from subprocess import Popen, PIPE

record = []
q_obj = q.q_class()
np.random.seed(1)
curr_reward = 0
state = [8,8,8]
process = 0
mavros_proc = 0
isCrashed = False
justSpawned = True
def spawn():
	global process
	global mavros_proc
	global justSpawned 
	justSpawned = True
	os.system('killall -9 gzserver')
	os.system('killall -9 gzclient')
	print "Waiting"
	time.sleep(5)
	#os.system('roslaunch px4 posix_sitl.launch vehicle:=iris_rplidar est:=lpe &')
	#process = Popen(['roslaunch','px4', 'posix_sitl.launch', 'vehicle:=iris_rplidar', 'est:=lpe', '&'])
	mavros_proc = Popen("roslaunch mavros px4.launch fcu_url:=\"udp://:14540@127.0.0.1:14557\"",stdout=PIPE, stderr=PIPE,shell=True)
	time.sleep(5)
	#publisher_proc = Popen("python env.py",stdout=PIPE, stderr=PIPE,shell=True)
	#env_proc = Popen("python env.py",stdout=PIPE, stderr=PIPE,shell=True)
	print "mavros Done"

	process = Popen("roslaunch px4 posix_sitl.launch vehicle:=iris_rplidar est:=lpe ",stdout=PIPE, stderr=PIPE,shell=True)
	time.sleep(5)
	print "gazebo done"


	#time.sleep(10)
	#os.killpg(os.getpgid(process.pid), signal.SIGTERM)
def kill():
	global process
	global mavros_proc
	#os.killpg(os.getpgid(process.pid), signal.SIGTERM)
	mavros_proc.kill()
	time.sleep(5)
	process.kill()
	time.sleep(5)
	
	#env.proc.kill()
	#publisher_proc.kill()
	#time.sleep(10)
	print "process killed"
	spawn()

def agent_client():
	global record
	global curr_reward
	global state
	global isCrashed
	global justSpawned
	timestr = time.strftime("%Y%m%d-%H%M%S")
	sum_of_reward_per_epoch = 0
	epoch = 0
	i = 0
	iteration = 0
	epsilon = 0.2
	numOfActions = 4
	joyAction = [0,0,0,0]
	action_client = actionlib.SimpleActionClient('perception',wall_follower.msg.agentAction)
	action_client.wait_for_server()
	print "Connected"


	#while counter < 1000:
	'''
	joy = rospy.wait_for_message("joy",Joy)
	#if joy.axes[0] != 0 or joy.axes[1] != 0 or joy.axes[2] != 0 or joy.axes[3] != 0:
	joyList = []
	joyList.append(abs(joy.axes[0]))
	joyList.append(abs(joy.axes[1]))
	joyList.append(abs(joy.axes[2]))
	joyList.append(abs(joy.axes[3]))

	maxjoy = max(joyList)

	if maxjoy == abs(joy.axes[0]):
		joyAction[0] = joy.axes[0] #YAW #lh
		joyAction[1] = 0 #Z  #lv
		joyAction[2] = 0 #x #rh
		joyAction[3] = 0 #y #rv
	elif maxjoy == abs(joy.axes[1]):
		joyAction[0] = 0 #YAW #lh
		joyAction[1] = joy.axes[1] #Z  #lv
		joyAction[2] = 0 #x #rh
		joyAction[3] = 0 #y #rv
	elif maxjoy == abs(joy.axes[2]):
		joyAction[0] = 0 #YAW #lh
		joyAction[1] = 0 #Z  #lv
		joyAction[2] = joy.axes[2] #x #rh
		joyAction[3] = 0 #y #rv
	elif maxjoy == abs(joy.axes[3]):
		joyAction[0] = 0 #YAW #lh
		joyAction[1] = 0 #Z  #lv
		joyAction[2] = 0 #x #rh
		joyAction[3] = joy.axes[3] #y #rv
		
	else:
	'''
	for i in range(0,50):
		joyAction[0] = 0
		joyAction[1] = 1
		joyAction[2] = 0
		joyAction[3] = 0
		goal = wall_follower.msg.agentGoal(action= joyAction)
		#print goal
		action_client.send_goal(goal,done_cb= done)
		action_client.wait_for_result()
	'''
	joyAction[0] = 0
	joyAction[1] = 0
	joyAction[2] = 0
	joyAction[3] = 0
	
	goal = wall_follower.msg.agentGoal(action= joyAction)
	#print goal
	action_client.send_goal(goal,done_cb= done)
	action_client.wait_for_result()
	'''
	print "DONE!"
	'''
	with open ('gp_june9', 'rb') as fp:
		gp = pickle.load(fp)

	gp_obj.set_gp(gp)
	'''
	while epoch < 200:
		if i != 0:
			randomNumber = random.random()
			if randomNumber >= epsilon:
				action = q_obj.choose_action(state)
			else:
				action = random.randint(0, numOfActions-1)		
			#action = gp_obj.choose_action(next_state.tolist()[0])
		else:
			action = random.randint(0, 3)
		
		'''
		joyAction[0] = 0
		joyAction[1] = 0
		joyAction[2] = 0
		joyAction[3] = 1
		
		'''		
		if action == 0:
			joyAction[0] = 1
			joyAction[1] = 0
			joyAction[2] = 0
			joyAction[3] = 1
		elif action == 1:
			joyAction[0] = -1
			joyAction[1] = 0
			joyAction[2] = 0
			joyAction[3] = 1
		elif action == 2:
			joyAction[0] = 0
			joyAction[1] = 0
			joyAction[2] = 0
			joyAction[3] = 1
		elif action == 3:
			joyAction[0] = 0
			joyAction[1] = 0
			joyAction[2] = 0
			joyAction[3] = -1
		
		goal = wall_follower.msg.agentGoal(action= joyAction)
		print goal
		action_client.send_goal(goal,done_cb= done)
		action_client.wait_for_result()


		iteration = iteration + 1
		print iteration
		print epoch
		sum_of_reward_per_epoch += curr_reward

		#if (state[0] == 0 and state[1] ==0 and state[2]==0):
		msg = rospy.wait_for_message('/mavros/imu/data',Imu)
		if abs(msg.linear_acceleration.x) > 5 or abs(msg.linear_acceleration.y) > 5:
				isCrashed = True

		if isCrashed and not justSpawned:
			kill()
			iscrashed = False
			iteration = 0

		if iteration > 20:
			justSpawned = False

		if iteration % 20 == 0:
			#prev_length_of_record = len(record)
			#plt.scatter(j,sum_of_reward_per_epoch)
			with open('q_reward_1' + '_q', 'a') as fp:
				fp.write(str(sum_of_reward_per_epoch) + '\n')
				fp.flush()
				#fp.close()

			#fp.close()
			#plot_obj.plotting(record)
			print 'REWARD COLLECTED THIS EPOCH: %d' % sum_of_reward_per_epoch
			sum_of_reward_per_epoch = 0
			#j += 1
			#plot_obj.plotting(record)
			epoch += 1
		i += 1

	
	'''
	choose = random.randint(1,3)
	
	if choose == 0:
		joyAction[0] = float(random.sample([-1,1],1)[0]) #YAW #lh
		joyAction[1] = 0.0 #Z  #lv
		joyAction[2] = 0.0 #x #rh
		joyAction[3] = 0.0 #y #rv
	
	if choose == 1:
		joyAction[0] = 0.0 #YAW #lh
		joyAction[1] = float(random.sample([-1,1],1)[0]) #Z  #lv
		joyAction[2] = 0.0 #x #rh
		joyAction[3] = 0.0 #y #rv
	elif choose == 2:
		joyAction[0] = 0.0 #YAW #lh
		joyAction[1] = 0.0 #Z  #lv
		joyAction[2] = float(random.sample([-1,1],1)[0]) #x #rh
		joyAction[3] = 0.0 #y #rv
	elif choose == 3:
		joyAction[0] = 0.0 #YAW #lh
		joyAction[1] = 0.0 #Z  #lv
		joyAction[2] = 0.0 #x #rh
		joyAction[3] =float(random.sample([-1,1],1)[0]) #y #rv
	
	goal = wall_follower.msg.agentGoal(action= joyAction)
	#print goal
	action_client.send_goal(goal,done_cb= done)
	action_client.wait_for_result()

	'''

def done(returnCode,result):
	global curr_reward 
	global record 
	global state 
	rawLaserDataList = []
	l = []
	if returnCode == 3:
		print "Successful"
		rawLaserDataList = list(result.state)
		for index, value in enumerate(rawLaserDataList):
			if value == float('inf'):
				rawLaserDataList[index] = 8
			#	value = 9999	
		if curr_reward == -5:	
			curr_reward = result.reward
		else:
			l = [int(round(i)) for i in rawLaserDataList]
			curr_reward = sum(l)

		state = l
		temp = state[0]
		state[0] = state[2]
		state[2] = temp

		print state
		print curr_reward
if __name__ == '__main__':
    try:
        rospy.init_node('agent', anonymous=True)
        spawn()
        agent_client()
        #rospy.spin()
    except rospy.ROSInterruptException:
        print "program interrupted before completion"
