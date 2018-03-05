#!/usr/bin/python
import rospy
import mavros
from mavros.utils import *
from mavros_msgs.msg import State
from mavros_msgs.srv import SetMode, StreamRate, StreamRateRequest, CommandBool, CommandTOL
from geometry_msgs.msg import *
import time
import math
import std_msgs.msg
import actionlib
import gp_gazebo.msg
from global_var import GRID
import global_var

MAX_ACTIONS = 6
MAX_STATES = 441 # THE GRID IS 20 * 20. We take all integrak coorindates as states

# DEFINING THE OBSTACLE COORDINATES

GOAL_STATE_X = GRID
GOAL_STATE_Y = GRID


class agentAction(object):
	_feedback = gp_gazebo.msg.agentFeedback()
	_result = gp_gazebo.msg.agentResult()
	xPos = 0
	yPos = 0
	zPos = 2

	def __init__(self,name):

		self._action_name = name
		self._as = actionlib.SimpleActionServer(self._action_name,gp_gazebo.msg.agentAction,execute_cb=self.execute, auto_start = False)
		self._as.start()
		print "Action server started"
		global_var.delta_t = 4

	def execute(self,goal):
		#action_value = _as.accept_new_goal()
		oldX = 0
		oldY = 0
		oldZ = 0
		
		#self._result.reward = 1
		#self._feedback.reward = -1
		#self._as.publish_feedback(self._feedback)	
		#self._as.set_succeeded(self._result,"SUCCESS") 

		#print "==========================="
		
		localPosPub = rospy.Publisher("mavros/setpoint_position/local",PoseStamped,queue_size=10)
		pose = PoseStamped()
		
		action_value = goal.action
		print action_value
		if action_value == 0:
		    pose.pose.position.x = self.xPos
		    pose.pose.position.y = min(self.yPos + 4,GRID)
		    pose.pose.position.z = self.zPos
		  
		elif action_value == 1:
		    pose.pose.position.x = max(self.xPos - 4,-GRID)
		    pose.pose.position.y = self.yPos
		    pose.pose.position.z = self.zPos

		elif action_value == 2:
		    pose.pose.position.x = self.xPos
		    pose.pose.position.y = max(self.yPos - 4,-GRID)
		    pose.pose.position.z = self.zPos

		elif action_value == 3:
		    pose.pose.position.x = min(self.xPos + 4,GRID)
		    pose.pose.position.y = self.yPos
		    pose.pose.position.z = self.zPos

		elif action_value == -1:
		    print 'Action is GO HOME'
		    pose.pose.position.x = -GRID
		    pose.pose.position.y = -GRID
		    pose.pose.position.z = 2

		#localPosPub.publish(pose)

		self.xPos = pose.pose.position.x
		self.yPos = pose.pose.position.y
		self.zPos = pose.pose.position.z
		#time.sleep(0.5)
		#while not rospy.is_shutdown() :

		state = rospy.wait_for_message("mavros/state",State)
		if state.mode != 'OFFBOARD':
		    setModeClient(0,'OFFBOARD')
		    print "OFFBOARD ENABLED"

		if not state.armed:
		    armingClient(True)
		    #print "ARMED"

		if action_value != -1:    
			for i in range(0,10):
				localPosPub.publish(pose)
				time.sleep(0.4)
		
			currPose = rospy.wait_for_message("/mavros/local_position/pose" ,PoseStamped) 
			'''
			# X and Y of Gazebo and mavros local_positions is interchanged . THIS NEEDS TO BE FIXED
			'''
			currentX = int(round(currPose.pose.position.x))
			currentY = int(round(currPose.pose.position.y))
			currentZ = int(round(currPose.pose.position.z))

			print "CURRENT POSITION" + str(currentX) + "," + str(currentY) + "," + str(currentZ) 
			# IF UAV HITS THE OBSTACLES

			if ((GOAL_STATE_X == currentX) and (GOAL_STATE_Y == currentY) and (2 == currentZ)):
				print "********************* YOU Reached the goal ******************"
				#self._feedback.terminal = True
				self._result.reward = 50 
				self._result.terminal = False

			else: 
			#self._feedback.terminal = False
				self._result.reward= -1
				self._result.terminal = False
				print "4 unit movement"

			self._result.state.insert(0,currentX)
			self._result.state.insert(1,currentY)
			self._result.state.insert(2,currentZ)

			self._as.set_succeeded(self._result)
			self._result.state[:]=[]
		

if __name__ == '__main__':
    try:
		rospy.init_node('environment_action', anonymous=True)
		#rospy.spin()
		
		#set the publisher for sending the goals
		# initialize the subscriber node
		# subcribe to the mavros State
		
		state = rospy.wait_for_message("mavros/state",State)
		rospy.wait_for_service("mavros/cmd/arming");
		print " Arming service available"
		try:
		    armingClient = rospy.ServiceProxy('mavros/cmd/arming', CommandBool)
		except rospy.ServiceException, e:
		    print "Service call failed: %s"%e

		rospy.wait_for_service("mavros/set_mode");
		print " SetMode service available"
		try:
		    setModeClient = rospy.ServiceProxy('mavros/set_mode', SetMode)
		except rospy.ServiceException, e:
		    print "Service call failed: %s"%e

		rospy.wait_for_service("mavros/cmd/takeoff");
		print " Takeoff service available"
		try:
		    takeoffClient = rospy.ServiceProxy('mavros/cmd/takeoff', CommandTOL)
		except rospy.ServiceException, e:
		    print "Service call failed: %s"%e

		while not rospy.is_shutdown() and not state.connected:
		    state = rospy.wait_for_message("mavros/state",State)
		
		
		agentAction('env3')
		rospy.spin()
    except rospy.ROSInterruptException:
        pass
