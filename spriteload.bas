'spriteload.bas by Mike Kopack, July 2020
' demonstrates how to load in a set of graphics to a hidden screen
' then grabbing areas of that screen to populate a series of sprites and show them on the visible page
 

#import "../stdsettings.inc"
page write 3
cls RGB(0,0,0)

let counter=1
Let carheight = 0

let col$ = ""
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
    select case i
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

    load png "a:Cars/car_"+col$+"_small_"+str$(i), j*70,i*80
    box j*70-1,i*80-1,37,carheight+2,1,rgb(255,255,255)
  next
next

page write 0

counter=0
snum = 1
for i=1 to 5
  for j=1 to 5
    select case i
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
    sprite read snum, j*70, i*80,35,carheight,3
    sprite show snum, j*70, i*80,0,3
    counter=counter+1
    snum=snum+1
  next
next

for i=1 to 25
  print "sprite #";i;": "; sprite(W,i);" x ";sprite(H,i)
next 
