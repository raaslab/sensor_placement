#!/usr/bin/python
import random
import math
import numpy as np
import time
import pygame
from pygame.color import THECOLORS
import pymunk
from pymunk.vec2d import Vec2d
#from pymunk.pygame_util import draw
import pymunk.pygame_util
# PyGame init
width = 1500
height = 1000
pygame.init()
screen = pygame.display.set_mode((width, height))
clock = pygame.time.Clock()

screenA = pygame.display.set_mode((500,480), 0, 32)
screenB = pygame.display.set_mode((500,480), 0, 32)

screenA.blit(background, (0,0))
screenB.blit(player, (100,100))


time.sleep(30)
# Turn off alpha since we don't use it.
screen.set_alpha(None)

# Showing sensors and redrawing slows things down.
show_sensors = True
draw_screen = True

class GameState:
    def __init__(self):
        # Global-ish.
        self.crashed = False
        self.car_velocity = 100
        self.numOflasersData = 10
        self.spread = 10
        self.distance = 10
        
        # Physics stuff.
        self.space = pymunk.Space()
        self.space.gravity = pymunk.Vec2d(0., 0.)

        # Create the car.
        self.create_car(750, 250, 0)

        # Record steps.
        self.num_steps = 0

        # Create walls.
        static = [
            pymunk.Segment(
                self.space.static_body,
                (0, 1), (0, height), 1),
            pymunk.Segment(
                self.space.static_body,
                (1, height), (width, height), 1),
            pymunk.Segment(
                self.space.static_body,
                (width-1, height), (width-1, 1), 1),
            pymunk.Segment(
                self.space.static_body,
                (1, 1), (width, 1), 1)
        ]
        for s in static:
            s.friction = 1.
            s.group = 1
            s.collision_type = 1
            s.color = THECOLORS['white']
        self.space.add(static)
        self.env3()

        # Create a moving cat
        #self.create_cat()
        '''
        self.create_incentive()
        '''
        
    def env1(self):

        a1 = 50
        b1 = 50
        a2 = 1450
        b2 = 50
        a3 = 1450
        b3 = 950
        a4 = 50
        b4 = 950
        self.obstacles = []
        self.obstacles.append(self.create_obstacle(a4,b4 ,a1,b1, 10)) #left vertical
        self.obstacles.append(self.create_obstacle(a1,b1 ,a2,b2, 10)) #bottom horizontal
        self.obstacles.append(self.create_obstacle(a2,b2 ,a3,b3, 10)) #right vertical
        self.obstacles.append(self.create_obstacle(a3,b3 ,a4,b4, 10)) #top horizontal
        gap = 150
        self.obstacles.append(self.create_obstacle(a4+gap,b4-gap ,a1+gap,b1+gap, 10)) #left vertical
        self.obstacles.append(self.create_obstacle(a2-gap,b2+gap ,a3-gap,b3-gap, 10)) #right vertical

        self.obstacles.append(self.create_obstacle(a1+gap,b1+gap ,a1+gap+200,b2+gap, 10)) #bottom horizontal left
        self.obstacles.append(self.create_obstacle(a1+gap+400,b1+gap ,a2-gap,b2+gap, 10)) #bottom horizontal right

        self.obstacles.append(self.create_obstacle(a1+gap,b4-gap ,a1+gap+200,b3-gap, 10)) #top horizontal left
        self.obstacles.append(self.create_obstacle(a1+gap+400,b4-gap ,a2-gap,b3-gap, 10)) #top horizontal right

        self.obstacles.append(self.create_obstacle(a1+gap+200,b2+gap ,a1+gap+200,b4-gap, 10)) #verticle mid left
        self.obstacles.append(self.create_obstacle(a1+gap+400,b2+gap ,a1+gap+400,b3-gap, 10)) #verticle mid right
        self.obstacles.append(self.create_obstacle(a1+gap+200,b2+gap,a1+gap+400,b2, 10)) #verticle mid right

    def env2(self):

        self.obstacles = []
        self.obstacles.append(self.create_circular_obstacle(200,600, 100))
        self.obstacles.append(self.create_circular_obstacle(600,300 ,75)) 
        self.obstacles.append(self.create_circular_obstacle(1200,100 ,25))
        self.obstacles.append(self.create_circular_obstacle(100,800 ,100)) 
        self.obstacles.append(self.create_circular_obstacle(700,700 ,200))
        self.obstacles.append(self.create_circular_obstacle(1000,300 ,50)) 
        self.obstacles.append(self.create_circular_obstacle(1300,500 ,20)) 
        self.obstacles.append(self.create_circular_obstacle(800,400 ,150))  
        self.obstacles.append(self.create_circular_obstacle(100,200 ,30)) 
        self.obstacles.append(self.create_circular_obstacle(100,400 ,50))    
        self.obstacles.append(self.create_circular_obstacle(1400,100 ,50)) 
        self.obstacles.append(self.create_circular_obstacle(400,100 ,30)) 
        self.obstacles.append(self.create_circular_obstacle(500,150 ,50)) 

        self.obstacles.append(self.create_circular_obstacle(150,1500 ,25)) 
        self.obstacles.append(self.create_circular_obstacle(50,50 ,10)) 
        self.obstacles.append(self.create_circular_obstacle(250,50 ,20)) 


    def env3(self):
        self.obstacles = []
        # self.obstacles.append(self.create_obstacle(0,50,1000,50,10))

        # self.obstacles.append(self.create_obstacle(200,200,1400,200,10))
        # self.obstacles.append(self.create_obstacle(300,300,1300,300,10))

        # self.obstacles.append(self.create_obstacle(200,200,1400,200,10))
        # self.obstacles.append(self.create_obstacle(200,200,1400,200,10))



        # self.obstacles.append(self.create_obstacle(50,200,50,400,10))
        # self.obstacles.append(self.create_obstacle(0,400,50,400,10))

        # self.obstacles.append(self.create_obstacle(1000,50,1400,400,10)) 
        # self.obstacles.append(self.create_obstacle(1000,200,1200,375,10)) 

        # self.obstacles.append(self.create_obstacle(1400,400,1400,800,10)) 
        # self.obstacles.append(self.create_obstacle(1200,375,1200,700,10)) 

        # self.obstacles.append(self.create_obstacle(1400,800,800,800,10)) 
        # self.obstacles.append(self.create_obstacle(1200,700,800,400,10)) 

        # self.obstacles.append(self.create_obstacle(800,800,800,500,10))

        # self.obstacles.append(self.create_obstacle(800,400,300,400,10))

        # self.obstacles.append(self.create_obstacle(800,650,100,650,10))
        # self.obstacles.append(self.create_obstacle(400,500,300,500,10))

        # self.obstacles.append(self.create_obstacle(400,500,400,800,10))
        # self.obstacles.append(self.create_obstacle(600,500,600,800,10))

        # self.obstacles.append(self.create_obstacle(400,900,600,900,10))

        # self.obstacles.append(self.create_circular_obstacle(500,800,100))
        # self.obstacles.append(self.create_circular_obstacle(450, 400, 5))


        # self.obstacles.append(self.create_obstacle(300,500,300,600,10))
        # self.obstacles.append(self.create_obstacle(300,400,300,300,10))

        # self.obstacles.append(self.create_obstacle(300,300,100,450,10))
        # self.obstacles.append(self.create_obstacle(300,600,100,450,10))

    def env4(self):
        self.obstacles = []
        self.obstacles.append(self.create_obstacle(50,500,200,50,10))

        self.obstacles.append(self.create_obstacle(200,50,750,300,10))
        self.obstacles.append(self.create_obstacle(750,300,1300,50,10))

        self.obstacles.append(self.create_obstacle(1300,50,1450,500,10))
        self.obstacles.append(self.create_obstacle(1450,500,1300,950,10))

        self.obstacles.append(self.create_obstacle(1300,950,750,700,10))
        self.obstacles.append(self.create_obstacle(750,700,200,950,10))


        self.obstacles.append(self.create_obstacle(750,300,750,600,10))
        self.obstacles.append(self.create_obstacle(750,700,750,650,10))


        self.obstacles.append(self.create_obstacle(750,600,1100,500,10))
        self.obstacles.append(self.create_obstacle(750,650,1200,600,10))

        self.obstacles.append(self.create_obstacle(1100,500,900,400,10))
        self.obstacles.append(self.create_obstacle(1200,600,1250,450,10))
        self.obstacles.append(self.create_obstacle(1250,450,900,350,10))

        self.obstacles.append(self.create_obstacle(200,950,50,500,10))

        self.obstacles.append(self.create_circular_obstacle(400,500,250))
        #self.obstacles.append(self.create_circular_obstacle(1100,500,250))

    def create_obstacle(self, x1,y1, x2,y2, r):
        cp = pymunk.body.Body()
        # STATIC OBSTACLE, IGNORE MASS AND MOMENT
        c_body = pymunk.Body(10000, pymunk.inf,body_type=cp.STATIC)
        #vertices = [(200.0,200.0),(700.0,200.0),(700.0,600.0),(200.0,600.0)]
        c_shape = pymunk.Segment(c_body,(x1,y1),(x2,y2), radius=r)
        c_shape.elasticity = 0.0
        #c_body.position = x, y
        c_shape.color = THECOLORS["white"]
        self.space.add(c_body, c_shape)
        return c_body


    def create_circular_obstacle(self, x,y,r):
        #c_body = pymunk.Body(pymunk.inf, pymunk.inf)
        cp = pymunk.body.Body()
        c_body = pymunk.Body(1000, pymunk.inf,body_type=cp.STATIC)
        c_shape = pymunk.Circle(c_body, r)
        c_shape.elasticity = 0.0
        c_body.position = x, y
        c_shape.color = THECOLORS["white"]
        self.space.add(c_body, c_shape)
        return c_body

    '''
    def create_cat(self):
        inertia = pymunk.moment_for_circle(1, 0, 14, (0, 0))
        self.cat_body = pymunk.Body(1, inertia)
        self.cat_body.position = 50, height - 100
        self.cat_shape = pymunk.Circle(self.cat_body, 30)
        self.cat_shape.color = THECOLORS["orange"]
        self.cat_shape.elasticity = 1.0
        self.cat_shape.angle = 0.5
        direction = Vec2d(1, 0).rotated(self.cat_body.angle)
        self.space.add(self.cat_body, self.cat_shape)
    '''
    '''
    def create_incentive(self):
        inertia = pymunk.moment_for_circle(1, 0, 14, (0, 0))
        self.incentive_body = pymunk.Body(1, inertia)
        self.incentive_body.position = 100, height - 200
        self.incentive_shape = pymunk.Circle(self.incentive_body, 10)
        self.incentive_shape.color = THECOLORS["blue"]
        self.incentive_shape.elasticity = 1.0
        self.incentive_shape.angle = 0.5
        direction = Vec2d(1, 0).rotated(self.incentive_body.angle)
        self.space.add(self.incentive_body, self.incentive_shape)
    '''

    def create_car(self, x, y, r):
        inertia = pymunk.moment_for_circle(1, 0, 14, (0, 0))
        self.car_body = pymunk.Body(1, inertia)
        self.car_body.position = x, y
        self.car_shape = pymunk.Circle(self.car_body, 10)
        self.car_shape.color = THECOLORS["green"]
        self.car_shape.elasticity = 0.0
        self.car_body.angle = r
        driving_direction = Vec2d(1, 0).rotated(self.car_body.angle)
        #self.car_body.apply_impulse(driving_direction)
        self.space.add(self.car_body, self.car_shape)

    def frame_step(self, action):
        # Get the current location and the readings there.
        if action == 0:  
            self.car_body.angle -= math.pi/2
            self.car_velocity = 100
        elif action == 2:  
            self.car_body.angle += math.pi/2
            self.car_velocity = 100
        if action == 1:  # Go straight.
            self.car_body.angle += 0.0
            self.car_velocity = 100
        elif action == 3:
            self.car_velocity = 100
            self.car_body.angle += math.pi
        '''
        # Move obstacles.
        if self.num_steps % 100 == 0:
            self.move_obstacles()
        '''
        # Move cat
        '''
        if self.num_steps % 5 == 0:
            self.move_cat()
        '''
        
        driving_direction = Vec2d(1, 0).rotated(self.car_body.angle)
        self.car_body.angle = 0
        #self.car_body.velocity = 100 * driving_direction
        self.car_body.velocity = self.car_velocity * driving_direction
        
        # Get the current location and the readings there.
        x, y = self.car_body.position

        # Update the screen and stuff.  
        screen.fill(THECOLORS["black"])
        # pymunk.pygame_util.draw(screen, self.space)
        options = pymunk.pygame_util.DrawOptions(screen)
        
        self.space.debug_draw(options)
        self.space.step(1./10)
        if draw_screen:
            pygame.display.flip()
        clock.tick()

        
        readings = self.get_sonar_readings(x, y, self.car_body.angle)
        # print readings
        
        state = np.array( [ readings])

        # Set the reward.
        # Car crashed when any reading == 1
        if self.car_is_crashed(readings):
            self.crashed = True
            #reward = -500
            reward = -5000
            self.recover_from_crash(driving_direction)
        else:
            # Higher readings are better, so return the sum.
            #reward = -5 + int(self.sum_readings(readings) / 10)
            reward = int(self.sum_readings(readings))  
            #reward = 1
        self.num_steps += 1

        return reward, state

    '''
    def move_obstacles(self):
        # Randomly move obstacles around.
        for obstacle in self.obstacles:
            speed = random.randint(1, 5)
            #speed = 0
            direction = Vec2d(1, 0).rotated(self.car_body.angle + random.randint(-2, 2))
            obstacle.velocity = speed * direction
    '''
    '''
    def move_cat(self):
        speed = random.randint(20, 200)
        #speed = random.randint(0, 10)
        #speed = 0 
        self.cat_body.angle -= random.randint(-1, 1)
        direction = Vec2d(1, 0).rotated(self.cat_body.angle)
        self.cat_body.velocity = speed * direction
    '''
    def car_is_crashed(self, readings):
        if readings[0] == 1 or readings[1] == 1 or readings[2] == 1 or readings[3] == 1 or readings[4] == 1 or readings[5] == 1 or readings[6] == 1 or readings[7] == 1:
            return True
        else:
            return False

    def recover_from_crash(self, driving_direction):
        """
        We hit something, so recover.
        """
        while self.crashed:
            # Go backwards.
            self.car_body.velocity = 100 * driving_direction
            # self.car_body.velocity = -self.car_velocity * driving_direction
            self.car_body.position = 750, 250
            self.crashed = False
            
            # for i in range(10):
            #     #self.car_body.angle += .2  # Turn a little.
            #     screen.fill(THECOLORS["red"])  # Red is scary!
            #     #draw(screen, self.space)
            #     options = pymunk.pygame_util.DrawOptions(screen)
            #     self.space.debug_draw(options)
            #     self.space.step(1./10)
            #     #if draw_screen:
            #        #pygame.display.flip()
            #     clock.tick()
            

    def sum_readings(self, readings):
        """Sum the number of non-zero readings."""
        tot = 0
        for i in readings:
            tot += i
        return tot

    def get_sonar_readings(self, x, y, angle):
        readings = []
        """
        Instead of using a grid of boolean(ish) sensors, sonar readings
        simply return N "distance" readings, one for each sonar
        we're simulating. The distance is a count of the first non-zero
        reading starting at the object. For instance, if the fifth sensor
        in a sonar "arm" is non-zero, then that arm returns a distance of 5.
        """
        # Make our arms.
        arm_left = self.make_sonar_arm(x, y)
        arm_forward = self.make_sonar_arm(x, y)
        arm_middle1 = arm_left
        arm_middle2 = arm_middle1
        arm_middle3 = arm_middle2
        arm_middle4 = arm_middle3
        arm_right = arm_forward
        arm_back = arm_right
        # Rotate them and get readings.
        
        readings.append(self.get_arm_distance(arm_forward, x, y, angle, 0))
        readings.append(self.get_arm_distance(arm_middle1, x, y, angle, math.pi/4))
        readings.append(self.get_arm_distance(arm_left, x, y, angle, math.pi/2))
        readings.append(self.get_arm_distance(arm_middle2, x, y, angle, 3 * math.pi/4))
        readings.append(self.get_arm_distance(arm_back, x, y, angle, math.pi))
        readings.append(self.get_arm_distance(arm_middle3, x, y, angle, 5 * math.pi/4))
        readings.append(self.get_arm_distance(arm_right, x, y, angle, -math.pi/2))
        readings.append(self.get_arm_distance(arm_middle4, x, y, angle, -math.pi/4))
        if show_sensors:
            pygame.display.update()

        return readings

    def get_arm_distance(self, arm, x, y, angle, offset):
        # Used to count the distance.
        i = 0

        # Look at each point and see if we've hit something.
        for point in arm:
            i += 1
            # Move the point to the right spot.
            rotated_p = self.get_rotated_point(
                x, y, point[0], point[1], angle + offset
            )

            # Check if we've hit something. Return the current i (distance)
            # if we did.
            if rotated_p[0] <= 0 or rotated_p[1] <= 0 \
                    or rotated_p[0] >= width or rotated_p[1] >= height:
                return i  # Sensor is off the screen.
            else:
                obs = screen.get_at(rotated_p)
                if obs == THECOLORS['white']:
                    return i

            if show_sensors:
                pygame.draw.circle(screen, (254, 254, 254), (rotated_p), 2)

        # Return the distance for the arm.
        return i

    def make_sonar_arm(self, x, y):
        spread = self.spread  # Default spread.
        distance = self.distance  # Gap before first sensor.
        arm_points = [] 
        # Make an arm. We build it flat because we'll rotate it about the
        # center later.
        for i in range(0, self.numOflasersData):
            arm_points.append((distance + x + (spread * i), y))

        return arm_points

    def get_rotated_point(self, x_1, y_1, x_2, y_2, radians):
        # Rotate x_2, y_2 around x_1, y_1 by angle.
        x_change = (x_2 - x_1) * math.cos(radians) + \
            (y_2 - y_1) * math.sin(radians)
        y_change = (y_1 - y_2) * math.cos(radians) - \
            (x_1 - x_2) * math.sin(radians)
        new_x = x_change + x_1
        new_y = height - (y_change + y_1)
        return int(new_x), int(new_y)

    def get_track_or_not(self, reading):
        if reading == THECOLORS['black']:
            return 0
        else:
            return 1

if __name__ == "__main__":
    game_state = GameState()
    prev_state = [[2, 2, 2, 2]]
    while True:
        currReward, state = game_state.frame_step((random.randint(0, 3)))
        # time.sleep(0.25)
        print "prev State"
        print prev_state
        print "current_state:"
        print state
        print "------"
        
        prev_state = state

