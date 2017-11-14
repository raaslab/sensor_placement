#!/usr/bin/env python
import rospy
import os
from std_msgs.msg import String

def reader():
	fileDir = os.path.dirname(os.path.realpath('__file__'))
	file = open(os.path.join(fileDir, '../data/data.txt'), ”r”)
	line = file.readline(1)
	print "Read Line: %s" % (line)
	file.close()

if __name__ == '__main__':
    try:
        reader()
    except rospy.ROSInterruptException:
        pass