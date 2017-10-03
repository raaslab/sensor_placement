#!/usr/bin/python
import numpy as np
import math
import random
from sklearn.gaussian_process import GaussianProcessRegressor
from sklearn.gaussian_process.kernels import RBF, ConstantKernel as C
from scipy.stats import multivariate_normal
from scipy.integrate import dblquad
import matplotlib.pyplot as plt
import pickle
import time
import gameEngine
# import plotting

# action = random.randint(0, 2)
# game_obj = gameEngine.GameState()
# curr_reward, next_state = game_obj.frame_step(action)

# print action
# print curr_reward
# print next_state

# exit()

record = []
plt.ion()

class gp_prediction():
	def __init__(self):
		self.rbf_init_length_scale = np.array([1,1,1,1,1,1,1])
		self.kernel = C(1.0, (1e-3, 1e3)) * RBF(self.rbf_init_length_scale.shape, (1e-3, 1e3))
		
		self.gp = GaussianProcessRegressor(kernel=self.kernel,n_restarts_optimizer=9,alpha=1e-2)
		self.gamma = 0.8

	def set_gp(self,gp):
		self.gp = gp
	#@profile
	def findMax(self,next_state):
		arrayList = []
		for x in (0,2):
			test = next_state + [x]
			arrayList.append(test)
		arrayList = np.array(arrayList)
		tempMu,sigma = self.gp.predict(arrayList, return_std=True, return_cov=False) 
		return max(tempMu)

	#@profile
	def gpq(self,record):
		inputX = []
		outputY = []
		
		for elements in record:
			#for element in range (0,len(record)):
			inputX.append(elements[0] + [elements[1]])
			outputY.append((elements[2] + self.gamma * self.findMax(elements[3])))
			#print inputX

		dX = np.array(inputX)
		#print outputY
		tX = np.array(outputY)
		#st = time.time()
		print "DOING GP FIT"
		self.gp.fit(dX,tX)
		with open('gp', 'wb') as fp:
			pickle.dump(self.gp, fp)
		fp.close()
	#@profile
	
	def choose_action(self,next_state):
		tempMu = 0
		arrayList = []
		listMu = []
		action_value = 0
		for x in (0, 2):
			test = next_state + [x]
			arrayList.append(test)
		arrayList = np.array(arrayList)
		tempMu,sigma = self.gp.predict(arrayList, return_std=True, return_cov=False) 
		listMu = list(tempMu)
		maxIndex  = listMu.index(max(listMu))
		tempList = arrayList[maxIndex]
		#print tempList
		action_value = tempList[6]
		#print action_value 
		return action_value

if __name__ == "__main__":
	i = 0
	j = 0
	epsilon = 0.1
	prev_length_of_record = 0
	game_obj = gameEngine.GameState()
	gp_obj = gp_prediction()
	# plot_obj = plotting.plot_class()
	sum_of_reward_per_epoch = 0
	prev_state = [2, 2, 2]
	prev_state = np.array([prev_state])
	# next_state = [[20,20,20,20,20,20]]
	timestr = time.strftime("%Y%m%d-%H%M%S")
	
	while True:

		if i != 0:
			randomNumber = random.random()
			if randomNumber >= epsilon:
				action = gp_obj.choose_action(next_state.tolist()[0])
			else:
				action = random.randint(0, 2)		
		elif i == 0:
			action = random.randint(0, 2)
		

		action = 1	
		curr_reward, next_state = game_obj.frame_step(action)
		#time.sleep(0.2)
		newRecord = [prev_state.tolist()[0], action, curr_reward, next_state.tolist()[0]]
		if newRecord not in record:
			record.append(newRecord)
		#record.append([prev_state.tolist()[0],action,curr_reward,next_state.tolist()[0]])
		
		prev_state = next_state
		sum_of_reward_per_epoch += curr_reward
		time.sleep(01)
		# if abs(len(record) - prev_length_of_record) > 100:
		# 	prev_length_of_record = len(record)
		# 	plt.scatter(j,sum_of_reward_per_epoch) 
		# 	with open(timestr, 'w') as fp:
		# 		fp.write(str(sum_of_reward_per_epoch) + '\n')
		# 		fp.flush()
		# 	fp.close()
		# 	gp_obj.gpq(record)
		# 	#plot_obj.plotting(record)
		# 	print 'REWARD COLLECTED THIS EPOCH: %d' % sum_of_reward_per_epoch
		# 	sum_of_reward_per_epoch = 0
		# 	j += 1
		# 	#plot_obj.plotting(record)
		# i += 1
		# plt.pause(0.05)
		