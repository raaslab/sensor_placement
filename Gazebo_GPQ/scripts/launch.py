#!/usr/bin/python
import os
import signal
import time
from subprocess import Popen, PIPE

if __name__ == '__main__':
	while True:
		os.system('killall -9 gzserver')
		os.system('killall -9 gzclient')
		print "Waiting"
		#time.sleep(5)
		#os.system('roslaunch px4 posix_sitl.launch vehicle:=iris_rplidar est:=lpe &')
		#process = Popen(['roslaunch','px4', 'posix_sitl.launch', 'vehicle:=iris_rplidar', 'est:=lpe', '&'])
		process = Popen("roslaunch px4 posix_sitl.launch vehicle:=iris_rplidar est:=lpe &",stdout=PIPE, stderr=PIPE,shell=True)
		print process	
		print "Done"
		time.sleep(10)
		process.kill()
		#os.killpg(os.getpgid(process.pid), signal.SIGTERM)
		#time.sleep(10)
		#process = Popen("roslaunch px4 posix_sitl.launch vehicle:=iris_rplidar est:=lpe &",stdout=PIPE, stderr=PIPE,shell=True)
