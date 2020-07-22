' transforms.bas
' by Mike Kopack, July 2020
' control the drawing of a 2D object from a joystick


#include "stdsettings.inc"


' define some constants for the classic controller buttons
const buttonr = 1
const buttonstart = 2
const buttonhome = 4
const buttonselect = 8
const buttonl = 16
const buttondown = 32
const buttonright = 64
const buttonup= 128
const buttonleft=256
const buttonzr = 512
const buttonx = 1024
const buttona = 2048
const buttony = 4096
const buttonb = 8192
const buttonzl = 16384


mode 1,8

' open the wii classic controller
wii classic open 3

page write 1

' here's the starting values (puts the object in the center of the screen to start
dim float tx = MM.HRES/2
dim float ty = MM.VRES/2
dim float sx = 100
dim float sy = 100
DIM FLOAT angle = 0 ' start out with no rotation
dim float radians ' what we convert the angle into

' first, let's set the vertecies for the 2D object
' set the coordinates of the x and y for the verticies
' drawing this around the origin (we will move it after applying the transforms

dim integer size = 4
dim float objectx(size)=(-.5,-.5,.5,.5)
dim float objecty(size)=(-.5,.5,.5,-.5)

' let's set up a few temp arrays to do the matrix math with
dim float rx(size) 'holds the rotated x
dim float ry(size) 'holds the rotated y
dim float point(3) = (1,1,1) 'holds the pre-transformed point
dim float scalept(3) =(1,1,1)' holds the scaled point
dim float rotpt(3) = (1,1,1)'hold the rotated point
dim float transpt(3) =(1,1,1)'holds the post translated point

' here's the initial matricies
dim float rotmatrix(3,3) = (0,0,0,0,0,0,0,0,1) ' rotation matrix
dim float transmatrix(3,3) =(1,0,tx,0,1,ty,0,0,1) ' translate to final location
dim float scalematrix(3,3) =(sx,0,0,0,sy,0,0,0,1) ' scale matrix

let keeprunning=1 'true

do 
  ' adjust the matricies based on the values
  radians = rad(angle)
  rotmatrix(1,1) = cos(radians)
  rotmatrix(2,1) = -1*sin(radians)
  rotmatrix(1,2) = sin(radians)
  rotmatrix(2,2) = cos(radians)
  
  transmatrix(3,1)=tx
  transmatrix(3,2)=ty
  
  scalematrix(1,1)=sx
  scalematrix(2,2)=sy
  
  
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
  ' now draw the polygon
  ' how many verticies, the arrays of x and y coords, the outline color and the fill color
  polygon size,rx(),ry(),RGB(255,255,255),RGB(100,0,200)
    
  ' read the joystick and adjust the transform values based on it for the next cycle
  if(classic(LX,3)<100)) then  
    'translate left
    tx=tx-1
  endif
  if(classic(LX,3)>160)) then
    'translate right
    tx=tx+1
  endif
  if(classic(LY,3)<100)) then
    'translate down
    ty=ty+1
   endif
  if(classic(LY,3)>160)) then
   'translate up
    ty=ty-1
  endif
  
  if(classic(RX,3)<100)) then  
    'shrink X
    sx=sx-.5
  endif
  if(classic(RX,3)>160)) then
    'grow X
    sx=sx+.5
  endif
  if(classic(RY,3)<100)) then
    'shrink Y
    sy=sy-.5
  endif
  if(classic(RY,3)>160)) then
    'grow Y  
    sy=sy+.5
  endif
  
  if(classic(L,3)>100)) then
    'rotate counterclockwise
    angle=angle-1
  endif
  if(classic(R,3)>100)) then
    'rotate clockwise
    angle=angle+1
  endif
  
  buttons=classic(B,3)

  if(buttons and buttonhome) then
    keeprunning=0 ' quit
  endif  
  
  pause 50
  page copy 1 to 0
  cls
loop until keeprunning=0
page write 0
'close the connection to the game pad
wii classic close 3
