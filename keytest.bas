#include "stdsettings.inc"
let numkeys = 0
do
  numkeys=keydown(0)
  if numkeys <>0 then
    for i=1 to numkeys 
      select case keydown(i)
        case 128
          print " up";
        case 129
          print " down";
        case 130
          print " left";
        case 131
          print " right";
      end select
    next
    print
 endif

loop while 1
