#!/usr/bin/env python

#Written by Yoonchang Sung (yooncs8@vt.edu)
#This splits the raw dataset into multiple text files corresponding to each sensor.
#This filters out outliers as well.

import rospy
import os
from std_msgs.msg import String
import numpy as np

#2004-03-31 03:38:15.757551 2 1 122.153 -3.91901 11.04 2.03397

def splitter():
	#From the dataset, authors mentioned that they used 54 sensors in the environment.
	num_sensor = 54
	sensor_id = 1
	day = 28

	time = np.array([])
	epoch = np.array([])
	temperature = np.array([])

	fileDir = os.path.dirname(os.path.realpath('__file__'))
	filePath = os.path.join(fileDir, '../data/data.txt')
	with open(filePath) as file:

		for line in file:
			word = line.split(" ")

			if not len(word) == 8:
				continue

			if int(word[3]) == sensor_id:
				#Filter out outliers.
				cur_day = int(word[0][8:])
				if (cur_day - day) > 1:
					if not (cur_day == 1 and day == 29) or (cur_day == 1 and day == 31):
						continue
				if len(word[4]) == 0:
					continue
				#if float(word[4]) > 100:
				#	continue
				print "Date (%s): time (%s): epoch(%s): sensor %s: temperature %s" % (word[0], word[1], word[2], word[3], word[4])

				if not cur_day == day:
					try:
						directory = "../data/sensor_"+str(sensor_id)+"/"
						if not os.path.exists(directory):
							os.makedirs(directory)
					except OSError:
						print ('Error: Creating directory. ' +  directory)

					genFile = open(os.path.join(fileDir, "../data/sensor_"+str(sensor_id)+"/"+str_day+".txt"),"w+")
					for i in range(len(time)-1):
						genFile.write("%s %s %s\n" % (time[i], epoch[i], temperature[i]))
	 				genFile.close()

	 				time = np.array([])
					epoch = np.array([])
					temperature = np.array([])
				else:
					time = np.append(time, word[1])
					epoch = np.append(epoch, word[2])
					temperature = np.append(temperature, word[4])

				str_day = word[0][5:]
				day = cur_day

			else:
				sensor_id = sensor_id + 1
				if sensor_id > num_sensor:
					break

	file.close()

if __name__ == '__main__':
    try:
        splitter()
    except rospy.ROSInterruptException:
        pass