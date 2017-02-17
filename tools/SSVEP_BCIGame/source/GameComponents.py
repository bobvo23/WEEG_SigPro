class Game():
    """docstring for Game"""
    def isCollision(self, x1, y1, x2, y2, bsize):
        if x1 >= x2 and x1 <= x2 + bsize:
            if y1 >= y2 and y1 <= y2 + bsize:
                return True
        return False
        
class Maze:
    def __init__(self):
        self.WIDTH = 10
        self.HEIGHT = 8
        self.game = Game()
        self.bsize = 64         # assume each block is a square
        self.maze1 = [ 1,1,1,1,1,1,1,1,1,1,
                     1,0,0,0,0,0,0,0,0,1,
                     1,0,0,0,0,0,0,0,0,1,
                     1,0,1,1,1,1,1,1,0,1,
                     1,0,1,0,0,0,0,0,0,1,
                     1,0,1,0,1,1,1,1,0,1,
                     1,0,0,0,0,0,0,0,0,1,
                     1,1,1,1,1,1,1,1,1,1,]

        self.maze = [ 1,1,1,1,1,1,1,1,1,1,
                     1,0,0,0,1,0,0,0,0,1,
                     1,0,0,0,0,0,1,0,0,1,
                     1,0,1,1,0,1,1,1,0,1,
                     1,0,0,0,0,0,0,1,0,1,
                     1,1,1,0,1,1,0,1,0,1,
                     1,0,0,0,0,0,0,0,0,1,
                     1,1,1,1,1,1,1,1,1,1,]

    def draw(self, display_surf, image_surf):
        bx = 0
        by = 0
        for i in range(0, self.WIDTH*self.HEIGHT):
            idx = bx + (by*self.WIDTH)
            if idx  >= self.WIDTH*self.HEIGHT:
                break

            if self.maze[ idx] == 1:
                display_surf.blit(image_surf, (bx * self.bsize, by * self.bsize))

            bx = bx + 1
            if bx  > self.WIDTH-1:
                bx = 0
                by = by + 1

    def printMazePix(self):
        for i in range(0, self.WIDTH*self.HEIGHT):
        #for i in range(0, 2):
            if self.maze[i]:
                #print "i = %d " % i, 
                yblock = (i)/self.WIDTH
                #print "yblock = %d " % yblock,
                xblock =  i - yblock*self.WIDTH
                #print "xblock = %d " % xblock,
                yblockpix = yblock * self.bsize - 1
                xblockpix = xblock * self.bsize - 1
                print '(%d,%d)\t\t\t' % (xblockpix, yblockpix),
            else:
                print '(0,0)\t\t\t',

            if not ((i+1)%self.WIDTH): print "\n"

    def isCollisionToMaze(self, x, y):
        """test if a point (x, y) collides with the maze."""
        for i in range(0, self.WIDTH*self.HEIGHT):
            if self.maze[i]:
                yblock = i / self.WIDTH
                xblock =  i - yblock*self.WIDTH
                yblockpix = yblock * self.bsize - 1
                xblockpix = xblock * self.bsize - 1
                # Check collision
                if x >= xblockpix and x <= xblockpix + self.bsize:
                    if y >= yblockpix and y <= yblockpix + self.bsize:
                        print "Collide"
                        return True
        return False

class Bar:
    speed = 64
    def __init__(self):
        self.x = 64
        self.y = 64
        self.maze = Maze()

    def moveRight(self):
        print "current loc: (%d,%d)" % (self.x, self.y)
        xnew = self.x + self.speed
        if not self.maze.isCollisionToMaze(xnew + 64 - self.speed, self.y) and \
            not self.maze.isCollisionToMaze(xnew + 64 - self.speed, self.y + 64 - self.speed): 
            self.x = xnew
        else: pass

    def moveLeft(self):
        xnew = self.x - self.speed
        if not self.maze.isCollisionToMaze(xnew, self.y) and \
            not self.maze.isCollisionToMaze(xnew, self.y + 64 - self.speed): 
            self.x = xnew
        else: pass

    def moveUp(self):
        ynew = self.y - self.speed
        if not self.maze.isCollisionToMaze(self.x, ynew) and \
            not self.maze.isCollisionToMaze(self.x + 64 - self.speed, ynew):
            self.y = ynew
        else: pass


    def moveDown(self):
        ynew = self.y + self.speed
        if not self.maze.isCollisionToMaze(self.x, ynew + 64 - self.speed) and \
            not self.maze.isCollisionToMaze(self.x + 64 - self.speed, ynew + 64 - self.speed):
            self.y = ynew
        else: pass


    def draw(self, surface, image):
        surface.blit(image,(self.x, self.y))