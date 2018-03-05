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
import gp
import gp_predict
import mavros
import pickle
#import update_transition_class
from mavros.utils import *
from mavros_msgs.msg import State
from mavros_msgs.srv import SetMode, StreamRate, StreamRateRequest, CommandBool, CommandTOL
from geometry_msgs.msg import *
from sensor_msgs.msg import Joy, LaserScan

record = []
training_record = []
gp_obj = gp.update_gp_class()
gp_predict_obj = gp_predict.gp_predict_class()
np.random.seed(1)
counter = 0
current_state = [8,8,8,8,8,8,8,8]
new_state = [8,8,8,8,8,8,8,8]
joyAction = [0,0,0,0]
rewardSum = 0

def agent_client():
	global record
	global counter
	global current_state
	global new_state
	global joyAction
	action_client = actionlib.SimpleActionClient('perception',wall_follower.msg.agentAction)
	action_client.wait_for_server()
	print "Connected"
	'''
	#TODO: Add a button to stay in place.  
	'''
	#while not rospy.is_shutdown():
	while counter < 100:
		joyAction = [0,0,0,0]
		joy = rospy.wait_for_message("joy",Joy)
		if joy.axes[0] != 0 or joy.axes[1] != 0 or joy.axes[2] != 0 or joy.axes[3] != 0:
			joyAction[0] = joy.axes[0] #YAW #lh

			joyAction[1] = joy.axes[1] #Z  #lv
			joyAction[2] = joy.axes[2] #x #rh
			joyAction[3] = joy.axes[3]#y #rv
			
		else:
			joyAction[0] = float(random.uniform(-0.5,0.5)) #YAW #lh
			joyAction[1] = float(random.uniform(-0.5,0.5)) #Z  #lv
			joyAction[2] = float(random.uniform(-0.5,0.5)) #x #rh
			joyAction[3] = float(random.uniform(-0.5,0.5)) #y #rv
		
		current_state_laser_data = rospy.wait_for_message("laser/scan",LaserScan)
		current_state = list(current_state_laser_data.ranges)

		for index, value in enumerate(current_state):
			if value == float('inf'):
				current_state[index] = 8

		goal = wall_follower.msg.agentGoal(action= joyAction)
		#print goal
		action_client.send_goal(goal,done_cb= done)
		action_client.wait_for_result()
	
	print "---------- DONE ----------"
	print record
	print "=================="
	print "                  "
	timestr = time.strftime("%Y%m%d-%H%M%S")
	with open(timestr, 'wb') as fp:
		pickle.dump(record, fp)
	fp.close()


def done(returnCode,result): 
	global record  
	global counter
	global current_state
	global new_state
	global joyAction

	rawLaserDataList = []
	if returnCode == 3:
		print "Successful"
		rawLaserDataList = list(result.state)
		for index, value in enumerate(rawLaserDataList):
			if value == float('inf'):
				rawLaserDataList[index] = 8
			#	value = 9999
		new_state = rawLaserDataList
		record.append([current_state,[joyAction[2],joyAction[3],joyAction[1]],result.reward,new_state])
		counter = counter + 1 
		print counter
		print result.reward

def agent_optimal():
	global counter
	global current_state
	global new_state
	global joyAction
	global rewardSum
	action_client = actionlib.SimpleActionClient('perception',wall_follower.msg.agentAction)
	action_client.wait_for_server()
	print "Connected"
	'''
	#TODO: Add a button to stay in place.  
	'''
	#while not rospy.is_shutdown():
	while counter < 100:
		joyAction = [0,0,0,0]
		current_state = new_state
		joy = rospy.wait_for_message("joy",Joy)
		if joy.axes[0] != 0 or joy.axes[1] != 0 or joy.axes[2] != 0 or joy.axes[3] != 0:
			joyAction[0] = joy.axes[0] #YAW #lh

			joyAction[1] = joy.axes[1] #Z  #lv
			joyAction[2] = joy.axes[2] #x #rh
			joyAction[3] = joy.axes[3]#y #rv
			
		else:
			optimal_action = gp_predict_obj.choose_action(current_state)
			print optimal_action
			joyAction[0] = 0 #YAW #lh
			joyAction[1] = optimal_action[2] #Z  #lv
			joyAction[2] = optimal_action[0] #x #rh
			joyAction[3] = optimal_action[1]#y #rv


		goal = wall_follower.msg.agentGoal(action= joyAction)
		#print goal
		action_client.send_goal(goal,done_cb= done_optimal)
		action_client.wait_for_result()
	print rewardSum

def done_optimal(returnCode,result): 
	global counter
	global current_state
	global new_state
	global joyAction
	global rewardSum

	rawLaserDataList = []
	if returnCode == 3:
		print "Successful"
		rawLaserDataList = list(result.state)
		for index, value in enumerate(rawLaserDataList):
			if value == float('inf'):
				rawLaserDataList[index] = 8
			#	value = 9999
		new_state = rawLaserDataList
		counter = counter + 1 
		print counter
		print result.reward
		rewardSum += result.reward	


if __name__ == '__main__':
    try:
        rospy.init_node('agent', anonymous=True)
        agent_optimal()
        #rospy.spin()
    except rospy.ROSInterruptException:
    	print "program interrupted before completion"