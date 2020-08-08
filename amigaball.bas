  'Amiga Bouncing Ball for CMM2
  ' By Mike Kopack - August 2020
  ' Demonstrates palette cycling tricks
  
  
  #include "stdsettings.inc"
  option explicit 1  

  mode 1,8
  const background = 1
  CONST ballscreen = 2
  CONST mergescreen = 3
  const displayscreen= 0
  CONST leftedge = MM.HRES/8
  CONST rightedge = MM.HRES-leftedge
  const topedge = MM.VRES/5
  const bottomedge = MM.VRES-topedge
  CONST purple = RGB(128,0,255)
  const gray = RGB(128,128,128)  
  const red = RGB(255,0,0)
  const white = RGB(255,255,255)  
  
  dim as integer frametime = 1000/60
  
  'draw backgound 16x16 grid
  page write background
  cls gray
  dim as integer vspacing = MM.VRES/6*4/16
  dim as integer hspacing = MM.HRES/6*4/16
  dim i as integer
  for i = 0 to 16
    line MM.HRES/6,MM.VRES/6+i*vspacing,5*MM.HRES/6,MM.VRES/6+i*vspacing,2,purple
    LINE MM.HRES/6+i*hspacing,MM.VRES/6,MM.HRES/6+i*hspacing,5*MM.VRES/6,2,purple
  next
  
  'loop
  dim as integer delay = 0
  dim as integer x_pos = MM.HRES/2 'center of ball
  dim as integer y_pos = MM.VRES/2
  dim as integer x_scroll = 2
  dim as integer y_scroll = 2
  dim as integer adjusted_y_scroll=0
  dim as integer playsound = 0

  dim as integer cyclecount=0
  dim as integer maxcount=10 'how many frames to wait to cycle the colors
  dim as integer colorcount=1 'which circle draw set to draw
'page write displayscreen
'print "Left=";leftedge
'print "Right=";rightedge
'print "Top=";topedge
'print "Bottom=";bottomedge
'end

  
  do
    timer=0
    playsound=0 ' reset the play sound flag
    'see if contacting floor or side walls
    'if so, play bong sound and change spin and velocity vectors as needed
    'calculate the position and spin
    'shift the color palette based on the spin
    'drawball
    'page scroll the ball page
    'page scroll ballpage, hvelocity,0
    page copy background to mergescreen
    drawball()
    
    'wait for the time window
    delay = frametime-timer
    if delay>0 then
      pause delay
    end if
    page copy mergescreen to displayscreen
    if(playsound) then
      PLAY STOP
      play wav "energy-bounce-1.wav"
    end if
    'end loop
    cyclecount=cyclecount+1
    if(cyclecount=maxcount) then
      cyclecount=0
      colorcount=colorcount*-1
    end if
  loop
  
  page write displayscreen
end
  
  
sub drawball()
  x_pos=x_pos+x_scroll
  if(x_pos<=leftedge OR x_pos>=rightedge) then
    x_scroll=-1*x_scroll ' change direction
    playsound =1
  end if
  
  adjusted_y_scroll= y_scroll
  if(y_pos<MM.VRES/4) then
    adjusted_y_scroll=adjusted_y_scroll*1
  else
    if(y_pos<MM.vres/3) then
      adjusted_y_scroll=adjusted_y_scroll*2
    else
      if (y_pos<MM.VRES/4) then
        adjusted_y_scroll=adjusted_y_scroll*3
      else
        adjusted_y_scroll=adjusted_y_scroll*5
      end if
    end if
  end if
  y_pos=y_pos+adjusted_y_scroll
  
  ' see if it's hitting the top or bottom edge
  if(y_pos>bottomedge OR y_pos<topedge) then
    y_scroll = -1*y_scroll
    if(y_pos>bottomedge) then
      playsound=1
    end if
  end if
  
  ' draw the ball
  page write mergescreen
if(colorcount=1) then
  circle x_pos,y_pos,MM.HRES/10,1,1,RED,RED
  circle x_pos,y_pos,MM.HRES/10,1,0.75,WHITE,WHITE
  circle x_pos,y_pos,MM.HRES/10,1,0.5,RED,RED
  circle x_pos,y_pos,MM.HRES/10,1,0.25,WHITE,WHITE
  circle x_pos,y_pos,MM.HRES/10,1,0.1,RED,RED
else
  circle x_pos,y_pos,MM.HRES/10,1,1,white,white
  circle x_pos,y_pos,MM.HRES/10,1,0.85,red,red
  circle x_pos,y_pos,MM.HRES/10,1,0.65,white,white
  circle x_pos,y_pos,MM.HRES/10,1,0.45,red,red
  circle x_pos,y_pos,MM.HRES/10,1,0.15,white,white
end if
  
end sub
  
  
 
