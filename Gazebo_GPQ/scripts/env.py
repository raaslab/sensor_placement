#!/usr/bin/python
import rospy
import mavros
from mavros.utils import *
from mavros_msgs.msg import State, PositionTarget
from mavros_msgs.srv import SetMode, StreamRate, StreamRateRequest, CommandBool, CommandTOL
from geometry_msgs.msg import *
import time
import math
from std_msgs.msg import String
import actionlib
import wall_follower.msg
from sensor_msgs.msg import Joy, LaserScan

class environment(object):
	_feedback = wall_follower.msg.agentFeedback()
	_result = wall_follower.msg.agentResult()
	print "HERE"
	def __init__(self,name):
		self._action_name = name
		self._as = actionlib.SimpleActionServer(self._action_name,wall_follower.msg.agentAction,execute_cb=self.execute, auto_start = False)
		self._as.start()
		print "Action server started"
		

	def execute(self,goal):
		local_pos_pub = rospy.Publisher("mavros/setpoint_position/local",PoseStamped,queue_size=10)
		'''
		local_vel_pub = rospy.Publisher("mavros/setpoint_velocity/cmd_vel",TwistStamped,queue_size=10)
		vel_pub = rospy.Publisher("mavros/setpoint_raw/local",PositionTarget,queue_size=10)
		print "GOT NEW GOAL"
		raw = PositionTarget()
		raw.header.stamp = rospy.get_rostime()
		raw.header.frame_id = "quad_frame"
		raw.coordinate_frame = 8 #FRAME_BODY_OFFSET_NED
		#raw.type_mask = int('0000101011000111',2)
		#raw.type_mask = 3011
		
		raw.type_mask = 1735 #1991 #519 
		pose = PoseStamped()
		vel = TwistStamped()

		LINEAR_X_MUL_FACTOR = 0.2
		LINEAR_Y_MUL_FACTOR = 0.2
		LINEAR_Z_MUL_FACTOR = 0.5
		ANGULAR_Z_MUL_FACTOR = 0.2

		raw.velocity.x = 0
		raw.velocity.y = 0
		raw.velocity.z = 0
		#raw.yaw = yaw * ANGULAR_Z_MUL_FACTOR
		raw.yaw_rate = 0
		vel_pub.publish(raw)
		'''

		'''
		state = rospy.wait_for_message("mavros/state",State)
		if state.mode != 'OFFBOARD':
		    setModeClient(0,'OFFBOARD')
		    print "OFFBOARD ENABLED"

		if not state.armed:
		    armingClient(True)
		    #print "ARMED"
		'''

		actionValue = goal.action
		actionString = str(actionValue[0]) + "," + str(actionValue[1]) + "," + str(actionValue[2]) + "," + str(actionValue[3])
		

		pub = rospy.Publisher("action_topic", String, queue_size=10)
		pub.publish(actionString)
		
		'''
		yaw = actionValue[0]
		z = actionValue[1]
		x = actionValue[2]
		y = actionValue[3]

		#if goal[0] != 0 or goal[1] != 0 or goal[2] != 0 or goal[3] != 0:
		if yaw != 0.0 or z != 0.0 or x !=0.0 or y !=0.0:
			#vel.twist.linear.x = x * LINEAR_X_MUL_FACTOR
			#vel.twist.linear.y = y * LINEAR_Y_MUL_FACTOR
			#vel.twist.linear.z = z * LINEAR_Z_MUL_FACTOR
			#vel.twist.angular.z = yaw * ANGULAR_Z_MUL_FACTOR
			#raw.position.x = 0
			#raw.position.y = 0
			raw.velocity.x = x * LINEAR_X_MUL_FACTOR
			raw.velocity.y = y * LINEAR_Y_MUL_FACTOR
			raw.velocity.z = z * LINEAR_Z_MUL_FACTOR
			#raw.yaw = yaw * ANGULAR_Z_MUL_FACTOR
			raw.yaw_rate = yaw * ANGULAR_Z_MUL_FACTOR

			for i in range(0,10):
				#local_vel_pub.publish(vel)
				vel_pub.publish(raw)
		
				time.sleep(0.1)
		'''
		'''
		else:
			curr_pose = rospy.wait_for_message("/mavros/local_position/pose" ,PoseStamped)
			for i in range(0,10):
				local_pos_pub.publish(curr_pose)
				time.sleep(0.1)
		'''
		

		laserRawData = rospy.wait_for_message("laser/scan",LaserScan)
		
		curr_pose = rospy.wait_for_message("/mavros/local_position/pose" ,PoseStamped)
		
		laservalues = laserRawData.ranges
		print laservalues
		if min(laservalues) > 0.25 and min(laservalues) <= 1:
			self._result.reward= -5
		else:
			self._result.reward = 10
		
		self._result.state = laserRawData.ranges
		self._as.set_succeeded(self._result)

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

		while not rospy.is_shutdown() and not state.connected:
		    state = rospy.wait_for_message("mavros/state",State)
		
		
		environment('perception')
		#rospy.spin()
    except rospy.ROSInterruptException:
        pass