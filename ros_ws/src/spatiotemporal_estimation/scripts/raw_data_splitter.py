#!/usr/bin/env python

#Written by Yoonchang Sung (yooncs8@vt.edu)
#This splits the raw dataset into multiple text files corresponding to each sensor.
#This filters out outliers as well.

import rospy
import os
from std_msgs.msg import String

#From the dataset, authors mentioned that they used 54 sensors in the environment.
num_sensor = 54
sensor_id = 1

def splitter():
	fileDir = os.path.dirname(os.path.realpath('__file__'))
	filePath = os.path.join(fileDir, '../data/data.txt')
	with open(filePath) as file:
		for line in file:
			word = line.split(" ")
			print "Read word: %s" % (word[3])
			if word[3] == sensor_id:
				#Filter out outliers.
			else:
				sensor_id = sensor_id + 1

	#file = open(filePath)
	#while 
	#line = file.readline().split(" ")
	#print "Read Line: %s" % (line[3])

	file.close()

if __name__ == '__main__':
    try:
        splitter()
    except rospy.ROSInterruptException:
        pass