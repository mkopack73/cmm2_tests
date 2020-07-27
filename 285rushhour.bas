  ' 285 Rush Hour
  ' by Mike Kopack
  ' July 2020
  
  ' You are free to examine, play with and reuse any of this code as you wish. I provide it as example on how
  ' to make a simple game for the CMM2 to help others. All I ask is that you give credit in your code for anything
  ' you use of mine to me (like in a readme or something). Otherwise, have at!
  
  #include "stdsettings.inc"
  option base 1
  Mode 1,8
  
  ' show the intro title screen and play the title music,
  'showtitlescreen()
  ' ask for which controller type
  let controllertype=controllersetup()
  'stop the music
  'play stop
  
  ' set up some variables that we need to be global since they are used in different places.
  
  ' keeps track of the X position on the left side of each lane for positioning the AI elements in the lanes.
  dim integer lanes(10) = (208,246,286,326,363,409,445,486,526,565)

  ' these are related to the overpass being shown and when
  DIM integer overpass_at_score(10) = (2000,6000,9000,13500,18000,25000,35000,55000,75000,90000)
  Let overpassvisbile = 0 '0 if the overpass isn't visible, 1 if it is
  Let nextoverpass = 1 'which is the next overpass trigger score
  LET overpass_yposition = -130 ' starting position for the overpass so it's off the screen
  
  
  const numcars=10 ' number of AI cars to handle
  dim integer aicars(numcars,4) '(lane#, preferredspeed, currentyposition, active=1 inactive=0)
  'let carheight=0 'this is how tall y a car is 'this will be changed later when we have different kinds of cars
  
  CONST drag = 1 'how much to slow the player's car down if they don't give it gas
  let keeprunning = 1 ' to keep the "game" running. Once this is set to 0 we end the main loop
  let currenttime = 0 ' holds the current time at the start of the cycle
  LET starttime = 0 'this will hold the clock time at the start of the run
  let stopwatch = 0 'this will hold the diff between the current time and the start time to act as a stopwatch for the run
  Let delay = 0 ' holds the delay remaining at the end of the cycle that we need to pause for.
  dim integer targettimeperframe = 1000/30 'target 30 frames per second
  
  let score = 0 ' this will count how many many vertical lines the player has covered before collision.

  let l_count=0 ' used if keyboard control to count how many times in a row we've pressed this key
  let r_count=0 ' used in keyboard control to count how many times in a row we've pressed this key  
  let playerspeed = 0 ' the faster our speed, the farther down we draw the dashed lines each frame
  let playerx = lanes(10) ' the starting x position of the player's car
  let soundfreq = 15 'this changes with the speed
  
  
  
  
  ' Get the game screen set up
  setuproad()
  ' setup all the sprites we need.
  loadsprites()
  
  'initialize the start time so we can keep a stopwatch of the run
  starttime=time
  
  ' main rendering/game loop
  do while keeprunning
    timer=0
    
    ' handle input from the user
    handleinput()
    
    'update the road
    updateroad()
    
    'update the overpasses
    'updateoverpass()

    ' update obstacles
    'updateobstacles()

    ' update the ai cars
    handleai()
    
    ' ok, now call the command that makes all the sprites actually move at once to their new positions.
    sprite move
    
    ' this is all debugging stuff
    ' blank the area where we're writing text so we don't get leftover artifacts from last frame
    box 0,0,160,80,,RGB(0,255,0),1
    
    text 10, 26, "Xpos = "+str$(playerx), LB,,,RGB(255,255,255)
    text 10, 36,"Speed = "+str$(playerspeed), LB,,, RGB(255,255,255)
    
    
    
    'if we are done before the targettime per frame, wait the difference
    ' if this comes out negative it'll just immediately cycle to the next
    ' iteration (but that means we're not keeping up)
    delay = targettimeperframe-TIMER
    ' this is just for debugging so we can see if we're taking too long per frame
    if(delay<0) then missedframes = missedframes+1
    text 10, 14, str$(delay), LB,,, RGB(255,255,255)
    
    updatescore()
    'updatemap() ' eventually add this in so we can update the overhead map to show progress
    
    ' copy the back buffer to the front display
    page copy 1 to 0
    if(delay>0) then pause delay
  loop
  
  endgame()
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
  
  ' figure out what the ai cars should do
sub handleai()
  local integer lanefound =0 ' used to indicate if we've found a valid lane with room
  local integer templane =0 ' used in AI calcs to hold the lane #
  local integer othercarinlane=0 ' flag if we found another car in the lane that we need to slow down for
  for i=1 to numcars
    ' for each car, see if it's active
    if(aicars(i,4)=1) then
      ' it's active so we need to move it,
      ' it's yposition should move relative to the player's speed and it's own speed
      othercarinlane=0
      'see if there's another car in this lane with a lower y and within 1.5 car lenghts of this AI car
      for car = 1 to numcars
        'see if it's a different car, it's active, in the same lane, and it's y+1.5*height of the car is < this car and has a > speed than the car above it
        if(i<>car and aicars(car,4)=1 and aicars(car,1) = aicars(i,1)) then
          ' deal with the cars depending upon which side of the road they're on
          if(aicars(i,1) > 5) then
            if (aicars(car,3)+carheight+aicars(i,2))<aicars(i,3) and aicars(car,2)<=aicars(i,2) ) then
              'make this car match the ahead car's speed.
              aicars(i,2) = aicars(car,2)
              othercarinlane=1
            endif
          else
            if(aicars(car,3)<aicars(i,3)+carheight+aicars(i,2) and aicars(car,2)<aicars(i,2) ) then
              'make this car match the ahead car's speed.
              aicars(i,2) = aicars(car,2)
              othercarinlane=1
            endif
          endif
        endif
      next
      ' if we didn't find any other in the lane, go ahead and move at normal speed
      if(othercarinlane=0) then 
        if(aicars(i,1) > 5) then
          aicars(i,3) = -1*aicars(i,2)+playerspeed+aicars(i,3)
        else
          aicars(i,3) = aicars(i,2)+playerspeed+aicars(i,3) ' left lanes should always come towards you
        endif
      endif

      'update it's position
      'if it's offscreen high, don't draw it more than 1 sprite's worth above
      templane = aicars(i,1)
      'if it's below bottom, hide it and make it inactive
      if(aicars(i,3) > MM.VRES-1) then
        sprite hide i+1
        sprite close i+1
        aicars(i,4)=0
      else if(aicars(i,3) < -1*SPRITE(H,i+1)) then
        ' if it goes off the top of the screen, we have to not move the sprite any farther, but keep track of
        ' how far up the road it HAS moved.
        ' NOTE this will need to be changed because bigger cars will be longer than 44 pixels.
        sprite next i+1,lanes(templane),-1*sprite(H,i+1)
      else
        sprite next i+1,lanes(templane),aicars(i,3)
      endif
    else
      ' if it's inactive, randomly decide if it should show up and where
      if((RND)>.9) then
        lanefound =1
        
        'pick a lane
        templane = int(rnd*10)+1
        'see if any other cars are in that lane, active and within 1 car length. If so, retry
        for car=1 to numcars
          if(aicars(car,1)=templane) then
            'see if there's a car within the spawn area, if not, then this lane is ok
            if (aicars(car,3)>40) then
              lanefound=1
            else
              ' otherwise it's no good
              lanefound=0
            endif
          endif
        next car
        'if we found a valid place to put the new car, place it
        if lanefound =1 then
          aicars(i,1) = templane
          'pick a speed
          aicars(i,2) = int(rnd*12)+1
          'start it at y=-100
          ' TODO: This will have to change once we have different length cars
          aicars(i,3) = -1*sprite(H,i+1) ' can't set it more than 1 sprite's size off screen
          aicars(i,4) = 1 ' make it active
          
          'pick a color and type of AI car
          local type = rnd*5+1
          local col = rnd*5+1
          local carheight=0
          local orientation=0
          ' copy the sprite in from the sprite page (page 2)
          select case type
            case 1
              carheight= 65
            case 2
              carheight= 57
            case 3
              carheight= 66
            case 4
              carheight= 66
            case 5
              carheight= 61
          end select
          
          if(aicars(i,1)<6) then
            orientation=3
          else
            orientation=0
          endif
          sprite read i+1, col*70, type*80, 35,carheight,2
          'now set the sprite depending on the lane
          templane = aicars(i,1)
          sprite show i+1,lanes(templane),aicars(i,3),2,orientation
        endif
      endif
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
  'box 200,0,35,50,,RGB(255,255,255),0
  load png "CarBlue.png",0,0,15
  image resize 2,2,80,120,200,0,30,45
  sprite read 1,200,0,30,45,2
  
  'box 200,0,35,50,,RGB(255,255,255),0
'  load png "CarRed.png",0,0,15
'  image resize 2,2,80,120,200,0,30,45
'  sprite read 2,200,0,30,45,2
  ' put the player on layer 2 so it doesn't collide with the lane lines or the overpass
  ' and start it in the rightmost lane
  sprite show 1,lanes(10),400,2
  'sprite copy 2,3,(numcars-1) ' copy the AI car to sprite 3, numcars-1 copy.

  cls rgb(0,0,0)
  ' load in the 25 different car PNG's onto page 3
  local counter=1
  local col$ = ""
  for i = 1 to 5
    for j = 1 to 5
      select case j
        case 1
          col$="black"
        case 2
          col$="red"
        case 3
          col$="green"
        case 4
          col$="blue"
        case 5
          col$="yellow"
      end select

      load png "A:Cars/car_"+col$+"_small_"+str$(i), j*70,i*80
'      print "Loaded: ";"A:Cars/car_"+col$+"_small_"+str$(i)
      
      counter=counter+1
    next
  next
  page copy 2 to 0  
  
  ' set up to make the overpass in page 3
  page write 3
  ' ok clear the screen that we loaded the sprites from
  cls rgb(0,255,0)
  
  ' create the sprite for the overpass
  box 0,0,MM.HRES-1,130,,RGB(128,128,128),1
  ' draw the road edge lines
  line 0,3,MM.HRES-1,3,3,RGB(255,255,255)
  line 0,127,MM.HRES-1,127,3,RGB(255,255,255)
  ' draw the centerline
  Line 0,63,MM.HRES-1,63,3,RGB(127,127,0)
  Line 0,68,MM.HRES-1,68,3,RGB(127,127,0)
  'read that all into a sprite on layer 1
  sprite read 64,0,0,MM.HRES-1,130,1
  cls
'  page copy 3 to 0  
  ' switch back to page 1 so we can get things into the drawing page
  page write 1
  
  ' set up the function to handle collisions
  sprite interrupt collision
END SUB
  
  '--------------------------------------------------------------------
  
  
sub handleinput()
  ' read the value of the controllertype so we know what to read and how
  local integer leftstickx = 0
  local integer rightsticky = 0
  local integer changex = 0
  
  select case controllertype
    case 1 ' classic controller
      
      ' read the joystick and update the game state
      ' get the left/right
      leftstickx = CLASSIC(LX,3)
      ' get the throttle changes
      rightsticky = CLASSIC(RY,3)
      ' this should adjust the speed
      if(rightsticky>140) then playerspeed = playerspeed +1
      if(rightsticky<100) then playerspeed = playerspeed -1
      if(rightsticky<=140 and rightsticky>=100) then playerspeed =playerspeed - drag
      ' this SHOULD make it so the farther left/right you push the more it will change
      changex = (leftstickx-127) / 64
      
      ' see if the player hit the home button to quit
      
      buttons = classic(B,3)
      if(buttons and 4) then keeprunning = 0
    case 2 'nunchuk
      leftstickx = NUNCHUK(JX,3)
      rightsticky= NUNCHUK(Z,3) ' use the Z button for gas
      buttons = Nunchuk(C,3)
      if(buttons) then keeprunning=0
      ' this should adjust the speed
      if(rightsticky=1) then playerspeed = playerspeed +1 else playerspeed = playerspeed -drag
      ' this SHOULD make it so the farther left/right you push the more it will change
      changex = (leftstickx-127) / 64
      
    case 3 'keyboard
      local numkeys=keydown(0)
      if (numkeys <> 0) then
        ' something pressed,figure out what
        for i=1 to numkeys
          select case keydown(i)
            case 128
              'speed up
              playerspeed=playerspeed+1
        
            case 130
              'left
              l_count=l_count+1
              if l_count>4 then l_count=4
              r_count=0
              changex=-1*l_count
        
            case 131
              'right
              l_count=0
              r_count=r_count+1
              if r_count>4 then r_count=4
              changex=r_count
              
          end select
        next
      else
        'nothing pressed so slow down
        playerspeed=playerspeed-drag
      endif
  end select
  
  if(playerspeed < 0) then playerspeed = 0
  if(playerspeed > 15) then playerspeed = 15
  
  'adjust the engine sound based on the speed
  if (playerspeed+20) <> soundfreq then
    soundfreq=playerspeed+20
    play sound 1, b, w, soundfreq,25
  endif
  
  
  ' make it so you can't steer unless moving
  if(playerspeed=0) then changex =0
  
  playerx = playerx + changex
  ' make sure it stays within the limits while still allowing off-sides of the road a bit.
  if(playerx < 100) then playerx = 100
  if(playerx > 700) then playerx = 700
  
  
  ' update the positions of the player's sprite based on the player's movement
  sprite next 1, playerx,400
END SUB
  
  '--------------------------------------------------------------------
  
  
SUB updateroad()
  ' scroll the layer lines according to the players' speed
  for i =0 to 3
    sprite scrollr 238+(i*40),0,5,MM.VRes,0,-1*playerspeed
    sprite scrollr 438+(i*40),0,5,MM.VRes,0,-1*playerspeed
  next
End sub
  
  '--------------------------------------------------------------------
  
SUB endgame()
  'end game
  ' close out all the sprites
  sprite close all
  ' change to the 0 page
  page write 0
  ' stop all sound
  play stop
  ' if using the Wii classic or nunchuk, close it out
  if(controllertype=1) then wii classic close 3
  if(controllertype=2) then wii nunchuk close 3
  
  ' give the system a chance to catch up
  pause 100
  'clear the screen
  'cls RGB(0,0,0)
  ' output diag info and final score...
  print "We missed :"+str$(missedframes)+" frames during run..."
  print "Final score: "+STR$(score)
end sub
  
  '--------------------------------------------------------------------
  
  ' figure out which type of control the player is using
function controllersetup() as integer
  local returnvalue
  
  ' Prompt for which controller type to use
  input "Which input type (1=Classic, 2=Nunchuk, 3=Keyboard)"; value
  
  ' if they select classic, set controllersetup = 1
  ' if they select nunchuk set controllersetup = 2
  ' if they select keyboard set controllersetup = 3
  ' for now we'll hard code for classic, but later we'll read what they select
  returnvalue =value
  if(returnvalue = 1) then
    'Open the Wii Classic Controller
    wii classic open 3
  else if(returnvalue=2) then
    'open the wii nunchuk
    wii nunchuk open 3
  else 
      returnvalue=3
  endif
  
  controllersetup=returnvalue
  
end FUNCTION
  '--------------------------------------------------------------------
  
sub updatescore()
  'update the score based on how far the player moved
  score = score + playerspeed
  text 10, 48, "Score = "+STR$(score), LB,,, RGB(255,255,255)
  stopwatch = time-starttime
  text 10, 60, "Time = "+STR$(stopwatch)+" ms", LB,,,RGB(255,255,255)
end sub
  
  '--------------------------------------------------------------------
  
sub showtitlescreen()
  'load the graphic
  'start the music
  'pause for 5 seconds and then we're done
end sub
  
  '--------------------------------------------------------------------
  
  'update the overpasses
sub updateoverpass()
  ' first see if the overpass isn't visible. If not, see if it should be because we tripped the next score trigger
  if(overpassvisible=0) then
    'see if the score is now over the threshold of triggering the next overpass to show up
    if(score>=overpass_at_score(nextoverpass)) then
      overpass_yposition = -129
      'show the overpass, put it on layer 0
      sprite show 64,0,overpass_yposition,0
      overpassvisible=1
      nextoverpass=nextoverpass+1
    endif 
  else 'is visible
    ' update it's position
    overpass_yposition=overpass_yposition+playerspeed
    ' see if the player has moved enough to move the overpass off the bottom of the screen.
    if(overpass_yposition>=MM.VRES) then
      sprite hide 64
      overpassvisible=0
    else
      sprite next 64,0,overpass_yposition
    endif
  
  endif
end sub
  
  '--------------------------------------------------------------------
  
  ' update obstacles
sub updateobstacles()
  
end sub
