' scroll comparison test
' By Mike Kopack, July 2020
' Speed test comparing using sprites for the lane lines vs scrolling the whole screen in a loop

#include "stdsettings.inc"
  
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
let firsttime=0
let secondtime=0
let playerspeed = 15 ' the faster our speed, the farther down we draw the dashed lines each frame

' setup all the sprites we need.

loadsprites()
' Get the game screen set up
setuproad()
  'initialize the start time so we can keep a stopwatch of the run
  starttime=time
  page write 1  
  ' main rendering/game loop
  do while keeprunning <=1000
    timer=0
    updateroad()
    
    sprite move
    delay = targettimeperframe-TIMER
    freetime=freetime+delay
    keeprunning=keeprunning+1
    page copy 1 to 0
    if(delay>0) then pause delay
  loop
  firsttime= freetime
  
  ' close all sprites
  sprite close all
  'set up the background
  setuproad()  
  loadsprites()

  freetime=0
  currenttime=0
  keeprunning=0
  page write 1
  ' main rendering/game loop
  do while keeprunning <=1000
    timer=0
    sprite hide 1
    updateroad2()
    sprite show 1,lanes(10),400,1
    delay = targettimeperframe-TIMER
    freetime=freetime+delay
    keeprunning=keeprunning+1
    page copy 1 to 0
   
    sprite move
    
    if(delay>0) then pause delay
  loop
  page write 0  
  cls rgb(0,0,0)
  secondtime= freetime
    

  print "total free time using sprites = ";firsttime
  print "total free time using background = ";secondtime



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
  load bmp "roadway.bmp",0,0
  page copy 1 to 0
end sub
  '--------------------------------------------------------------------

  
SUB loadsprites()
  ' ok let's load in the sprites. We need to resize them to fit the lanes.
  ' switch over to a temp page
  page write 2
  cls black
  load png "CarBlue.png",0,0,15
  image resize 2,2,80,120,200,0,30,62
  sprite read 1,200,0,30,62,2
  cls
  page write 0
  sprite show 1,lanes(10),400,1
  cls
  ' set up the function to handle collisions
  sprite interrupt collision
END SUB
  
  '--------------------------------------------------------------------

SUB updateroad()
  ' scroll the layer lines according to the players' speed
'  page write 1
  local y=-1*playerspeed
  for i =0 to 3
    sprite scrollr 238+(i*40),0,5,MM.VRes,0,y
    sprite scrollr 438+(i*40),0,5,MM.VRes,0,y
  next
End sub


sub updateroad2()
'  page write 1
'  sprite hide 1
  local y=-1*playerspeed
  sprite scroll 0,y
'  sprite show 1,lanes(10),400,1
'  page scroll 1,0,y
end sub

