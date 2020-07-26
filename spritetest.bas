'sprite test
' by Mike Kopack
' July 2020

#include "stdsettings.inc"

'Open the Wii Classic Controller
wii classic open 3

'load in the sprites file



Mode 1,8


' All this stuff will remain static so we do it outside the loop to reduce
' how much we do during the main loop.


' get the x position for the lanes so we know where to position the AI cars
const numcars=10
dim integer lanes (10) = (208,246,286,326,363,409,445,486,526,565)
dim integer aicars(numcars,4) '(lane#, speed, yposition, active)

dim integer templane =0 ' used in AI calcs to hold the lane #
dim integer ytemp = 0 ' used in AI calcs to hold the y position



let drag = 1 'how much to slow the player's car down if they don't give it gas

let keeprunning = 1 ' to keep the "game" running
let currenttime = 0 ' holds the current time at the start of the cycle
Let delay = 0 ' holds the delay remaining at the end of the cycle that we need to pause for.
dim integer targettimeperframe = 1000/30 'target 30 frames per second


let score = 0 ' this will count how many many frames * speed per frame the player has covered before collision.

let playerspeed = 0 ' the faster our speed, the farther down we draw the dashed lines each frame
let playerx = lanes(10) ' the x position of the the player's car
LET leftstickx = 0 
LET rightsticky = 0 
dim integer changex = 0
dim integer changey = 0

dim integer soundfreq = 15 'this changes with the speed

' Get the game screen set up
setuproad()

' setup all the sprites we need.
loadsprites()

' main rendering/game loop
do while keeprunning
  timer=0
  
  ' draw the screen and any display updates
  ' draw the player's sprite at the new location

  'update the road
  updateroad()

  ' handle input from the user
  handleinput()
  ' update the ai cars
  handleai()

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

endgame()


' define what to do when there's a collision between sprites
sub collision()
  local integer i
  if(sprite(S)<>0) then
    process_collision(sprite(S))
  else
    for i=1 to sprite(C,0)
      process_collision(sprite(C,0,i))
    next i
  endif
End sub


' handle determining the collision
sub process_collision(S as integer)
  local integer i,j
  for i = 1 to sprite(C,S)
    j=sprite(C,S,i)
    ' see if it's a collision between player's car and AI car
    'if((S=1 and j>=2 and j<=numcars+1) or (S>=2 and S<=numcars+1 and j=1)) then
    if(S=1 or j=1) then
      keeprunning=0
'    print "Collision with sprites ", S,j
    endif
  next i
end sub

' figure out what the ai cars should do
sub handleai()
  for i=1 to numcars
    ' for each car, see if it's active
    if(aicars(i,4)=1) then
      ' it's active so we need to move it, 
      ' it's yposition should move relative to the player's speed and it's own speed
      if(aicars(i,1) > 5) then 
        aicars(i,3) = -1*aicars(i,2)+playerspeed+aicars(i,3)
      else 
        aicars(i,3) = aicars(i,2)+playerspeed+aicars(i,3) ' left lanes should always come towards you
      endif
      'update it's position
      'if it's offscreen high, don't draw it more than 1 sprite's worth above
      templane = aicars(i,1)
      'if it's below bottom, hide it and make it inactive
      if(aicars(i,3) > MM.VRES-1) then 
        sprite hide i+1
        aicars(i,4)=0
      else if(aicars(i,3) < -44) then 
        sprite next i+1,lanes(templane),-44 
      else 
        sprite next i+1,lanes(templane),aicars(i,3)
      endif
    else
      ' if it's inactive, randomly decide if it should show up and where
      if((RND)>.9) then 
        'pick a lane
        aicars(i,1) = int(rnd*10)+1
        'pick a speed
        aicars(i,2) = int(rnd*12)+1
        'start it at y=-100
        aicars(i,3) = -44 ' can't set it more than 1 sprite's size off screen
        aicars(i,4) = 1 ' make it active
        'now set the sprite depending on the lane
        templane = aicars(i,1)
        if(aicars(i,1)<6) then
          sprite show i+1,lanes(templane),aicars(i,3),1,3
        else
          sprite show i+1,lanes(templane),aicars(i,3),1,0
        endif
      endif
    endif
  next i 
end sub


sub setuproad()
  'set up so we write to the background buffer
  page write 1

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

end sub


SUB loadsprites()
  ' ok let's load in the sprites. We need to resize them to fit the lanes.
  ' switch over to a temp page
  page write 2
  box 200,0,35,50,,RGB(255,255,255),0
  load png "CarBlue.png",0,0,15
  image resize 2,2,80,120,200,0,30,45
  sprite read 1,200,0,30,45,2

  box 200,0,35,50,,RGB(255,255,255),0
  load png "CarRed.png",0,0,15
  image resize 2,2,80,120,200,0,30,45
  sprite read 2,200,0,30,45,2
  ' ok clear the screen that we loaded the sprites from
  cls

  page write 1
  ' put the player on layer 1 so it doesn't collide with the lane lines.
  ' and start it in the rightmost lane
  sprite show 1,lanes(10),400,1
  sprite copy 2,3,(numcars-1) ' copy the AI car to sprite 3, numcars-1 copy.

  ' set up the function to handle collisions
  sprite interrupt collision
END SUB



sub handleinput()
  ' read the joystick and update the game state
  ' get the left/right
  leftstickx = CLASSIC(LX,3)
  ' get the throttle changes
  rightsticky = CLASSIC(RY,3)
  

  ' this should adjust the speed
  if(rightsticky>140) then playerspeed = playerspeed +1
  if(rightsticky<100) then playerspeed = playerspeed -1
  if(rightsticky<=140 and rightsticky>=100) then playerspeed =playerspeed - drag
  if(playerspeed < 0) then playerspeed = 0
  if(playerspeed > 15) then playerspeed = 15

  'adjust the engine sound based on the speed
  if (playerspeed+20) <> soundfreq then
    soundfreq=playerspeed+20
    play sound 1, b, w, soundfreq,25
  endif
  
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

  
  ' update the positions of the player's sprite based on the player's movement
  sprite next 1, playerx,400 


END SUB



SUB updateroad()
  ' scroll the layer lines according to the players' speed
  for i =0 to 3
    sprite scrollr 238+(i*40),0,5,MM.VRes,0,-1*playerspeed
    sprite scrollr 438+(i*40),0,5,MM.VRes,0,-1*playerspeed
  next
End sub


SUB endgame()
  'end game
  ' close out all the sprites
  sprite close all
  ' change to the 0 page
  page write 0
  ' stop all sound
  play stop
  ' give the system a chance to catch up
  pause 100
  'clear the screen
  cls RGB(0,0,0)
  ' output diag info and final score...
  print "We missed :"+str$(missedframes)+" frames during run..."
  print "Final score: "+STR$(score)
end sub