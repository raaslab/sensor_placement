#!/usr/bin/env python
import rospy
import os
from std_msgs.msg import String

#2004-03-31 03:38:15.757551 2 1 122.153 -3.91901 11.04 2.03397

#Pick a date you want to use, e.g., 2004-03-10. It should be between 2004-02-28 ~ 2004-04-05.
date = '2004-02-28'

#Choose your time step. (Currently, the time unit that we use is minute, e.g., 1 means 1 minute per time step.)
delta_t = 1

def reader():
	fileDir = os.path.dirname(os.path.realpath('__file__'))
	filePath = os.path.join(fileDir, '../data/data.txt')
	file = open(filePath)
	line = file.readline().split(" ")
	print "Read Line: %s" % (line[0])
	file.close()

if __name__ == '__main__':
    try:
        reader()
    except rospy.ROSInterruptException:
        pass