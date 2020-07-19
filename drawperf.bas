' random lines benchmark
' By Mike Kopack
' This will work through each of the CMM2 screen modes
' In each,it will randomly draw as many lines as it can in 10 seconds and keep the count.
' At the end it will report the times for each mode.

'setup
#include "stdsettings.inc"

duration = 1000 'ms = 10 sec
dim times(5,5)


'loop through the screen modes
for modenum = 1 to 5
  ' set the screen mode
  mode modenum, 16
  pause 5000 'ms
  for test = 1 to 5
  
    for count=1 to 30

      cls RGB(0,0,0) ' clear the screen to black
      ' get the width and height information for that mode
      width = MM.HRes
      height = MM.VRes
      ' pause for 5 seconds to let the monitor sync
      ' reset the timer and the counter
      counter=0
      timer=0
      do while(timer<duration)
        'generate a color
        r=RND*255
        g=RND*255
        b=RND*255
        if(test=1) then
          line RND*width,RND*height,RND*width,RND*height,1,RGB(r,g,b)
        else if (test=2) then
          box RND*width, RND*height,RND*(width/2), RND*(height/2),1,RGB(r,g,b),RGB(r,g,b)
        else if (test=3) then
          triangle Rnd*width, RND*height,RND*width,RND*height, RND*width,RND*height,RGB(r,g,b),RGB(r,g,b)
        else if (test=4) then
          circle RND*width, RND*height, RND*100,1,-.5+RND*1.5,RGB(r,g,b),RGB(r,g,b)
        else if (test=5) then
          text RND*width, RND*height, "Hello World from CMM2!","CM",1,.5+RND*5,RGB(r,g,b)
        endif
        counter=counter+1
      loop ' timer<duration

      'capture the count
      times(modenum,test)=times(modenum,test)+counter
    next
  next
next ' modenum

' get back to 800x600 and clear the screen to black background
mode 1,16
cls RGB(0,0,0)

pause 3000

for i=1 to 5
  print "Mode",i, times(i,1)/30," lines generated..."
next
for i=1 to 5
  print "Mode",i, times(i,2)/30," boxes generated..."
next
for i=1 to 5
  print "Mode",i, times(i,3)/30," triangles generated..."
next
for i=1 to 5
  print "Mode",i, times(i,4)/30," cicles generated..."
next
for i=1 to 5
  print "Mode",i, times(i,5)/30," strings generated..."
next


pause 5000
