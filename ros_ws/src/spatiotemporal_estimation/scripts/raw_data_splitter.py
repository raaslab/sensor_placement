#!/usr/bin/env python
import rospy
import os
from std_msgs.msg import String



def splitter():
	fileDir = os.path.dirname(os.path.realpath('__file__'))
	filePath = os.path.join(fileDir, '../data/data.txt')
	file = open(filePath)
	line = file.readline().split(" ")
	print "Read Line: %s" % (line[0])
	file.close()

if __name__ == '__main__':
    try:
        splitter()
    except rospy.ROSInterruptException:
        pass