'JoyTest.bas
'Mike Kopack - July 2020
' This program tests a Wii Nunchuk Controller in port 3 (front)


#include "stdsettings.inc"
dim string txt
dim integer buttons
wii nunchuk open 3 ' the front port
dim float x
dim float y

pause 1000
cls
  
do
  cls
  txt="Stick X/Y="+str$(nunchuk(JX,3))+"/"+str$(nunchuk(JY,3))
  text 10,10,txt,"LT" 
  txt="Accel X/Y/Z="+str$(nunchuk(AX,3))+"/" + str$(nunchuk(AY,3))+"/"+str$(nunchuk(AZ,3))
  text 10,22,txt,"LT"
  txt="Buttons Z/C="+str$(nunchuk(Z,3))+"/" + str$(nunchuk(C,3))
  text 10,32,txt,"LT"
  pause 50
loop
