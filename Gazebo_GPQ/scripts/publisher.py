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


def publish():
	while not rospy.is_shutdown():
		state = rospy.wait_for_message("mavros/state",State)
		if state.mode != 'OFFBOARD':
		    setModeClient(0,'OFFBOARD')
		    print "OFFBOARD ENABLED"

		if not state.armed:
		    armingClient(True)

		vel_pub = rospy.Publisher("mavros/setpoint_raw/local",PositionTarget,queue_size=10)
		raw = PositionTarget()
		raw.header.stamp = rospy.get_rostime()
		raw.header.frame_id = "quad_frame"
		raw.coordinate_frame = 8 #FRAME_BODY_OFFSET_NED
		#raw.type_mask = int('0000101011000111',2)
		#raw.type_mask = 3011		
		raw.type_mask = 1735 #1991 #519 
		LINEAR_X_MUL_FACTOR = 0.2
		LINEAR_Y_MUL_FACTOR = 0.2
		LINEAR_Z_MUL_FACTOR = 1
		ANGULAR_Z_MUL_FACTOR = 0.2
		try:
			data = rospy.wait_for_message("action_topic",String, timeout=0.3)

			actionValue = []
			actionValue = data.data.split(',')
			yaw = float(actionValue[0])
			z = float(actionValue[1])
			x = float(actionValue[2])
			y = float(actionValue[3])
			raw.velocity.x = x * LINEAR_X_MUL_FACTOR
			raw.velocity.y = y * LINEAR_Y_MUL_FACTOR
			raw.velocity.z = z * LINEAR_Z_MUL_FACTOR
			#raw.yaw = yaw * ANGULAR_Z_MUL_FACTOR
			raw.yaw_rate = yaw * ANGULAR_Z_MUL_FACTOR
			for i in range(0,10):
				#local_vel_pub.publish(vel)
				vel_pub.publish(raw)	
				time.sleep(0.1)

		except rospy.exceptions.ROSException:
			print "DID NOT GET THE VALUE"
			raw.velocity.x = 0
			raw.velocity.y = 0
			raw.velocity.z = 0
			#raw.yaw = yaw * ANGULAR_Z_MUL_FACTOR
			raw.yaw_rate = 0
			for i in range(0,10):
				#local_vel_pub.publish(vel)
				vel_pub.publish(raw)		
				time.sleep(0.1)


if __name__ == '__main__':
	rospy.init_node('velocity_publisher', anonymous=True)
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
	publish()