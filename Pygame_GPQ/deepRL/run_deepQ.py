"""
Once a model is learned, use this to play it.
"""

import gameEngine
import numpy as np
from nn import neural_net
import matplotlib.pyplot as plt
import time
import random
NUM_SENSORS = 3
plt.ion()

def play(model):
    iteration = 0
    numOfActions = 4
    epoch = 0
    epsilon = 0.1
    sum_of_reward_per_epoch = 0
    game_state = gameEngine.GameState()
    timestr = time.strftime("%Y%m%d-%H%M%S")
    # Do nothing to get initial.
    _, state = game_state.frame_step((2))

    # Move.
    while epoch < 1000:
        randomNumber = random.random()
        if randomNumber >= epsilon:
            action = (np.argmax(model.predict(state, batch_size=1)))
                #print action
        else:
            action = random.randint(0, numOfActions-1)

        # Choose action.
       
        # Take action.
        curr_reward, state = game_state.frame_step(action)
        iteration += 1
        sum_of_reward_per_epoch += curr_reward
        

        if iteration % 200 == 0:
            #plt.scatter(epoch,sum_of_reward_per_epoch)
            with open(timestr + '_deepQ', 'a') as fp:
                fp.write(str(sum_of_reward_per_epoch) + '\n')
                fp.flush()
            #fp.close()
            sum_of_reward_per_epoch = 0
            epoch += 1
        #plt.pause(0.05)
    fp.close()

if __name__ == "__main__":
    saved_model = '164-150-100-50000-50000.h5'
    model = neural_net(NUM_SENSORS, [164, 150], saved_model)
    play(model)