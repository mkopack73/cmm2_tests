' scroll comparison test
' By Mike Kopack, July 2020
' Speed test comparing using sprites for the lane lines vs scrolling the whole screen in a loop

#include "stdsettings.inc"
  
option base 1
Mode 1,8

  
' set up some variables that we need to be global since they are used in different places.
  
' keeps track of the X position on the left side of each lane for positioning the AI elements in the lanes.
dim integer lanes(10) = (208,246,286,326,363,409,445,486,526,565)

let keeprunning = 0 ' to keep the "game" running. Once this is set to 0 we end the main loop
  
let currenttime = 0 ' holds the current time at the start of the cycle
LET starttime = 0 'this will hold the clock time at the start of the run
let stopwatch = 0 'this will hold the diff between the current time and the start time to act as a stopwatch for the run
Let delay = 0 ' holds the delay remaining at the end of the cycle that we need to pause for.
dim integer targettimeperframe = 1000/30 'target 30 frames per second

let freetime=0 ' total free time for 1000 frames moving at 15 lines per frame

let playerspeed = 15 ' the faster our speed, the farther down we draw the dashed lines each frame

' Get the game screen set up
  setuproad()
  ' setup all the sprites we need.
  loadsprites()
  
  'initialize the start time so we can keep a stopwatch of the run
  starttime=time
  
  ' main rendering/game loop
  do while keeprunning <=15000
    timer=0
    
    
    'update the road
    updateroad()
    
    ' ok, now call the command that makes all the sprites actually move at once to their new positions.
    sprite move
    
    'if we are done before the targettime per frame, wait the difference
    ' if this comes out negative it'll just immediately cycle to the next
    ' iteration (but that means we're not keeping up)
    delay = targettimeperframe-TIMER
    freetime=freetime+delay
    
    ' copy the back buffer to the front display
    page copy 1 to 0
    if(delay>0) then pause delay
  loop

  
  print "total free time for 1000 frames of 15 scrolls = ";freetime
end

  '--------------------------------------------------------------------
  
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


 
  '--------------------------------------------------------------------
  
  ' handle determining who caused the collision
sub process_collision(S as integer)
  local integer i,j
  for i = 1 to sprite(C,S)
    j=sprite(C,S,i)
    ' see if it's a collision between player's car and AI car
    if(S=1 or j=1) then
      'we only stop if the player's car was in a collision with an AI Car (or something else on the road)
      keeprunning=0
    endif
  next i
end sub
  '--------------------------------------------------------------------


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
  '--------------------------------------------------------------------

  
SUB loadsprites()
  ' ok let's load in the sprites. We need to resize them to fit the lanes.
  ' switch over to a temp page
  page write 2
  load png "CarBlue.png",0,0,15
  image resize 2,2,80,120,200,0,30,45
  sprite read 1,200,0,30,45,2
  
  page write 1
  ' set up the function to handle collisions
  sprite interrupt collision
END SUB
  
  '--------------------------------------------------------------------

SUB updateroad()
  ' scroll the layer lines according to the players' speed
  for i =0 to 3
    sprite scrollr 238+(i*40),0,5,MM.VRes,0,-1*playerspeed
    sprite scrollr 438+(i*40),0,5,MM.VRes,0,-1*playerspeed
  next
End sub
