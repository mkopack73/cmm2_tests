'JoyTest.bas
'Mike Kopack - July 2020
' This program tests a Wii Classic Controller in port 3 (front port)


#include "stdsettings.inc"
dim string txt
dim integer buttons
wii classic open 3 ' the front port

const buttonr = 1
const buttonl = 16
const buttonstart = 2
const buttonhome = 4
const buttonselect = 8
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

cls
  
do
  cls
  txt="Left Stick X/Y="+str$(classic(LX,3))+"/"+str$(classic(LY,3))
  text 10,10,txt,"LT" 
  txt="Right Stick X/Y="+str$(classic(RX,3))+"/" + str$(classic(RY,3))
  text 10,24,txt,"LT"
  txt="Analog Buttons X/Y="+str$(classic(L,3))+"/" + str$(classic(R,3))
  text 10,36,txt,"LT"

  buttons=classic(B,3)
  txt=""

  if(buttons and buttonr) then
    txt=txt+"Right "
  endif
  if(buttons and buttonl) then
    txt=txt+"Left "
  endif
  text 10,48,txt,"LT"
  txt=""

  if(buttons and buttonstart) then
    txt=txt+"Start "
  endif
  if(buttons and buttonhome) then
    txt=txt+"Home "
  endif
  if(buttons and buttonselect) then
    txt=txt+"Select "
  endif
  text 10,60,txt,"LT"
  txt=""

  if(buttons and buttondown) then
    txt=txt+"DPad-Down "
  endif
  if(buttons and buttonright) then
    txt=txt+"DPad-Right "
  endif
  if(buttons and buttonup) then
    txt=txt+"DPad-Up "
  endif
  if(buttons and buttonleft) then
    txt=txt+"DPad-Left "
  endif
  text 10,72,txt,"LT"
  txt=""

  if(buttons and buttonzr) then
    txt=txt+"ZR "
  endif
  if(buttons and buttonzl) then
    txt=txt+"ZL "
  endif
  text 10,84,txt,"LT"
  txt=""

  if(buttons and buttonx) then
    txt=txt+"X "
  endif
  if(buttons and buttona) then
    txt=txt+"A "
  endif
  if(buttons and buttony) then
    txt=txt+"Y "
  endif
  if(buttons and buttonb) then
    txt=txt+"B "
  endif
  text 10,96,txt,"LT"
  txt=""

  pause 50  


loop
