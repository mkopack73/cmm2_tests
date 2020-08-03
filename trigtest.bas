' TrigTest
' By Mike Kopack
' July 2020

' quick speed comparison between usin the built in trig functions
' vs a lookup table

#include "stdsettings.inc"

dim float rads=0.0
dim float tempcos=0.0
dim float tempsin=0.0
dim float timetook=0.0

timer=0
for angle = 0 to 90
  rads = rad(angle)
  tempcos = cos(rads)
  tempsin = sin(rads)
next
timetook = timer
print "Built in Math Functions took: "+str$(timetook)+" ms for 90 degrees"

' now repeat the calculations and store them into a 2D table
dim float values(2,91)
for angle = 0 to 90
  rads = rad(angle)
  values(1,angle+1) = cos(rads)
  values(2,angle+1) = sin(rads)
next

'now loop through the table to get the values and time it
timer=0
for angle=0 to 90
  tempcos=values(1,angle+1)
  tempsin=values(2,angle+1)  
next
timetook=timer
print "Lookup table took: "+str$(timetook)+" ms for 90 degrees"


