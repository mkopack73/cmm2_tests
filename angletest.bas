#import "stdsettings.inc"

for angle = 1 to 360
  radians = rad(angle)
  print angle,"degrees = ",radians,"radians  cos=",cos(radians),"sin=",sin(radians)
  pause 250
next

