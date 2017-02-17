"""
Note:
To shut down the old tcpip process

sudo netstat -anp | grep 55000

sudo kill -9 <id>
"""

import pygame
import time
import socket
import random
from threading import Thread
from pygame.locals import *

import sys
sys.path.insert(0, './source')
from GameComponents import *


outData = 0
_debug = 1
_running = True

_theadUDPrunning = 1

# Echo server program
class UDPRecv:
    # =========================================================================
    # Input the client ip address here
    HOST = ''                 # Symbolic name meaning all available interfaces
    PORT = 55000              # Arbitrary non-privileged port
    # =========================================================================

    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    # s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    s.bind((HOST, PORT))
    s.listen(1)
    def __init__(self):
        self.lastresult = 0

        print 'Waiting for connection ...'
        self.conn, self.addr = self.s.accept()
        print 'Connected by', self.addr

    def getCommand(self):
        global outData, _debug, _running
        while _running:
            # Get data from socket
            self.data = self.conn.recv(2) # expect to recieve char '1' or '2' or '3' or '4'

            if self.data:
                result = int(self.data[0])

                #  # Check if a command should be sent
                # if self.lastresult == result: # the first time result code appears
                #     continue
                # else:
                outData = result

                # Update last result
                self.lastresult = result


class App:
    ''' Define components of the game '''
    windowWidth = 630
    windowHeight = 510
    player = 0

    score = 0
    highestScore = 0
    highestScoreText = 0
    myfont = 0
    text = 0
    timer = 0
    timerText = 0
    timerStep = 20/1000.0

    xtarget = 64*8
    ytarget = 64*6

    def __init__(self):
        self._running = True
        self._display_surf = None
        self._image_surf = None
        self._block_surf = None
        self._target_surf = None

        self.game = Game()
        self.player = Bar()

        self.maze = Maze()

        #self.maze.printMazePix()
        #self.udp = UDPRecv()

    def on_init(self):
        '''Init game components'''
        pygame.init()
        self._display_surf = pygame.display.set_mode((self.windowWidth,self.windowHeight), pygame.HWSURFACE)
        pygame.display.set_caption('Euphoria')
        self._running = True
        self._image_surf = pygame.image.load("source/mario.png").convert()
        self._block_surf = pygame.image.load("source/wall.jpg").convert()
        self._target_surf = pygame.image.load("source/peach.png").convert()
        self._reward_surf = pygame.image.load("source/reward.png").convert()
        self.myfont = pygame.font.SysFont("None", 30)

    def on_event(self, event):
        if event.type == QUIT:
            self._running = False

    def on_loop(self):
        '''doctring.'''
        # self.text = self.myfont.render("Score: " + str(self.score), 0, (255,255,255))
        # self.highestScoreText = self.myfont.render("Highest Score: " + str(self.highestScore), 0, (255,255,255))
        # self.timerText = self.myfont.render("Time elapsed: " + str(self.timer) + " " + "seconds", 0, (255,255,255))

    def on_render(self):
        '''doctring.'''
        self._display_surf.fill((0,0,0))
        # self._display_surf.blit(self.text, (self.windowWidth/2 - 120,self.windowHeight*0.1)) # Score
        # self._display_surf.blit(self.timerText, (self.windowWidth/2 - 120,self.windowHeight*0.140)) # Timer
        # self._display_surf.blit(self.highestScoreText, (self.windowWidth/2,self.windowHeight*0.1)) # High score
        # self.player.draw(self._display_surf, self._image_surf )
        self._display_surf.blit(self._image_surf, (self.player.x, self.player.y))
        self._display_surf.blit(self._target_surf, (self.xtarget, self.ytarget))
        self.maze.draw(self._display_surf, self._block_surf)

        # Game ends here
        if self.game.isCollision(self.player.x, self.player.y, self.xtarget, self.ytarget, 64):
            self._display_surf.blit(self._reward_surf, (self.xtarget, self.ytarget))

        pygame.display.flip()

    def on_cleanup(self):
        #self.udp.sock.close()
        pygame.quit()

    def on_execute(self):
        global outData, _running
        if self.on_init() == False:
            _running = False

        while( _running ):
            print '--- Outdata:'
            print outData
            pygame.event.pump()
            keys = pygame.key.get_pressed()

            if outData == 1 or (keys[K_UP]):
                self.player.moveUp()
                time.sleep(1)

            if outData == 2 or (keys[K_RIGHT]):
                self.player.moveRight()
                time.sleep(1)

            if outData == 3 or (keys[K_DOWN]):
                self.player.moveDown()
                time.sleep(1)

            if outData == 4 or (keys[K_LEFT]):
                self.player.moveLeft()
                time.sleep(1)

            if (keys[K_ESCAPE]):
                _running = False

            outData = 0

            for event in pygame.event.get():
                if event.type == pygame.QUIT:
                    _running = False

            self.on_loop()
            self.on_render()

            time.sleep(self.timerStep)

        self.on_cleanup()



if __name__ == "__main__":
    theApp = App()
    udp = UDPRecv()
    t1 = Thread(target=theApp.on_execute)
    t2 = Thread(target=udp.getCommand)
    t1.start()
    t2.start()
    t1.join()
    t2.join()
