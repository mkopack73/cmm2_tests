'sprite test
' by Mike Kopack
' July 2020

#include "stdsettings.inc"

'Open the Wii Classic Controller
wii classic open 3

'load in the sprites file



Mode 1,8

'set up so we write to the background buffer
page write 1

' All this stuff will remain static so we do it outside the loop to reduce
' how much we do during the main loop.


' First, clear the screen... 
cls RGB(0,255,0)
' draw the road
' the street surface will be gray
BOX 200, 0, 400, 600,,rgb(128,128,128),1
' draw the lines on the edges of the road solid white
line 205,0, 205,600, 3, RGB(255,255,255)
Line 595,0,595,600,3,RGB(255,255,255)
' draw the double centerline in yellow
Line 394,0, 394,600,3,RGB(128,128,0)
line 406,0, 406,600,3,RGB(128,128,0)
' the lane lines will be done with sprites so we can make them roll down the screen as the player
' move

' we first draw the dashed lines
for i = 0 to 12 step 2
  for j = 1 to 4
    Line 200+(j*40), 50*i, 200+(j*40), 50*(i+1), 3, RGB(255,255,255)
    line 400+(j*40), 50*i, 400+(j*40), 50*(i+1), 3, RGB(255,255,255)
  next
next

' load the player's car sprite
sprite loadpng 1,"CarBlue.png"
' load the AI car sprite
sprite loadpng 2,"CarRed.png"
' put the player on layer 1 so it doesn't collide with the lane lines.
sprite show 1,560,400,1
sprite show 2,260,400,1

' set up the function to handle collisions
sprite interrupt collision





let keeprunning = 1 ' to keep the "game" running
let currenttime = 0 ' holds the current time at the start of the cycle
Let delay = 0 ' holds the delay remaining at the end of the cycle that we need to pause for.
dim integer targettimeperframe = 1000/30 'target 30 frames per second


let score = 0 ' this will count how many many frames * speed per frame the player has covered before collision.

let playerspeed = 0 ' the faster our speed, the farther down we draw the dashed lines each frame
let playerx = 410 ' the x position of the the player's car
LET leftstickx = 0 
LET rightsticky = 0 
dim integer changex = 0
dim integer changey = 0
' main rendering/game loop
do while keeprunning
  timer=0
  
  ' draw the screen and any display updates
  ' draw the player's sprite at the new location
  
  ' scroll the layer lines according to the players' speed
  for i =0 to 3
    sprite scrollr 238+(i*40),0,5,MM.VRes,0,-1*playerspeed
    sprite scrollr 438+(i*40),0,5,MM.VRes,0,-1*playerspeed
  next

  ' read the joystick and update the game state
  ' get the left/right
  leftstickx = CLASSIC(LX,3)
  ' get the throttle changes
  rightsticky = CLASSIC(RY,3)
  

  ' this should adjust the speed
  if(rightsticky>140) then playerspeed = playerspeed +1
  if(rightsticky<100) then playerspeed = playerspeed -1
  if(playerspeed < 0) then playerspeed = 0
  if(playerspeed > 15) then playerspeed = 15
  
  ' this SHOULD make it so the farther left/right you push the more it will change
  changex = (leftstickx-127) / 64
  
  ' make it so you can't steer unless moving
  if(playerspeed=0) then changex =0

  playerx = playerx + changex
  ' make sure it stays within the limits while still allowing off-sides of the road a bit.
  if(playerx < 100) then playerx = 100
  if(playerx > 700) then playerx = 700 
  
  ' see if the player hit the home button to quit
  buttons = classic(B,3)
  if(buttons and 4) then keeprunning = 0 
  
  ' update the positions of the sprites based on the player's movement
  sprite next 1, playerx,400 
  
  
  ' ok, now call the command that makes all the sprites actually move at once to their new positions.
  sprite move
  
  ' blank the area where we're writing text so we don't get leftover artifacts from last frame
  box 0,0,100,80,,RGB(0,255,0),1
 
  text 10, 26, "Xpos = "+str$(playerx), LB,,,RGB(255,255,255)
  text 10, 36,"Speed = "+str$(playerspeed), LB,,, RGB(255,255,255)
  
  'if we are done before the targettime per frame, wait the difference
  ' if this comes out negative it'll just immediately cycle to the next 
  ' iteration (but that means we're not keeping up)
  delay = targettimeperframe-TIMER   
  if(delay<0) then missedframes = missedframes+1
  text 10, 14, str$(delay), LB,,, RGB(255,255,255)
  
  'update the score based on how far the player moved
  score = score + playerspeed  
    
  text 10, 48, "Score = "+STR$(score), LB,,, RGB(255,255,255)

  ' copy the back buffer to the front display
  page copy 1 to 0
  if(delay>0) then pause delay
loop
page write 0
pause 10
cls RGB(0,0,0)
print "We missed :"+str$(missedframes)+" frames during run..."
print "Final score: "+STR$(score)

' define what to do when there's a collision between sprites
sub collision()
  keeprunning=false
  sprite nointerrupt
  sprite hide 1
  sprite hide 2  
  sprite close all
End sub
