#!/usr/bin/env python

#Written by Yoonchang Sung (yooncs8@vt.edu)
#Main file for extracting temperatures from all sensors on a specific data that you choose.

#Several important notes you must be aware of:
# (1) The origin of x and y coordinates is the upper right corner of the figure of Intel Lab Data (http://db.csail.mit.edu/labdata/labdata.html).
# (2) Sensor 5 doesn't have any data available.

import rospy
import os
from std_msgs.msg import String
import numpy as np

def reader():
	fileDir = os.path.dirname(os.path.realpath('__file__'))

	#Set your parameters.
	date = '02-28' #Pick a date you want to use, e.g., 2004-03-10. It should be between 2004-02-28 ~ 2004-04-05.
	delta_t = 1 #Choose your time step. (Currently, the time unit that we use is minute, e.g., 1 means 1 minute per time step.)

	filePath = np.array([])

	for i in range(0, 54):
		# print "../data/sensor_"+str(i+1)+"/"+date+".txt"
		if os.path.isdir("../data/sensor_"+str(i+1)+"/"):
			filePath = np.append(filePath, os.path.join(fileDir, "../data/sensor_"+str(i+1)+"/"+date+".txt"))

	# file = open(filePath)
	# line = file.readline().split(" ")
	print "Read Line: %s" % (filePath.size)
	# file.close()

if __name__ == '__main__':
    try:
        reader()
    except rospy.ROSInterruptException:
        pass