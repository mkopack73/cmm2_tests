' CubeDraw.bas
' by Mike Kopack, July 2020
' Draws a 3D cube with perspective


#include "stdsettings.inc"

' start out by testing how to do 2D geometric transformations

' first, let's set the vertecies for the 2D object
' set the coordinates of the x and y for the verticies
' assume the first point is always at the origin

mode 2,16

dim float tx = MM.HRES/2
dim float ty = MM.VRES/2
dim float sx = 100
dim float sy = 100

dim integer size = 4
dim float objectx(size)=(-.5,-.5,.5,.5)
dim float objecty(size)=(-.5,.5,.5,-.5)
dim float rx(size) 'holds the rotated x
dim float ry(size) 'holds the rotated y
dim float point(3) = (1,1,1) 'holds the pre-transformed point
dim float scalept(3) =(1,1,1)' holds the scaled point
dim float rotpt(3) = (1,1,1)'hold the rotated point
dim float transpt(3) =(1,1,1)'holds the post translated point

dim float rotmatrix(3,3) = (0,0,0,0,0,0,0,0,1) ' rotation matrix
dim float transmatrix(3,3) =(1,0,tx,0,1,ty,0,0,1) ' translate to final location
dim float scalematrix(3,3) =(sx,0,0,0,sy,0,0,0,1) ' scale matrix

dim float radians

for angle = 0 to 359 step 1
  radians = rad(angle)
  rotmatrix(1,1) = cos(radians)
  rotmatrix(2,1) = -1*sin(radians)
  rotmatrix(1,2) = sin(radians)
  rotmatrix(2,2) = cos(radians)
  
  'cycle through the vertecies and transform them
  for vertex=1 to size
    point(1)=objectx(vertex)
    point(2)=objecty(vertex)
    
    amount$ = "Angle="+str$(angle)+" Scale (x/y)=("+str$(sx)+"/"+str$(sy)+") Translation (x/y)=("+str$(tx)+"/"+str$(ty)+")"
    text MM.HRES/2,MM.VRES-12,amount$,"CT"
    
    math v_mult scalematrix(),point(),scalept()
    math v_mult rotmatrix(),scalept(),rotpt()
    math v_mult transmatrix(),rotpt(),transpt()
    rx(vertex)=transpt(1)
    ry(vertex)=transpt(2)
  next 'vertex
  ' how many verticies, the arrays of x and y coords, the outline color and the fill color
  polygon size,rx(),ry(),RGB(255,255,255),RGB(100,0,200)
  pause 100
  cls
next ' angle

