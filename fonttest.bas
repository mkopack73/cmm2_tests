fontnum = 1
scaling = 2
fontheight = 10 *scaling

text mm.hres/2, (mm.vres/2)-(fontheight+10), "Congrats!!!","CM",fontnum, scaling
scaling =1
fontheight = 10 * scaling
text mm.hres/2, (mm.vres/2)+fontheight, "Enter your name:","CM",fontnum, scaling
dim as string name = ""
on key handleinput()
hold = 1
do while hold
  pause 10
loop



sub handleinput()
  ' this approach doesnt handle backspace
  'name=name+inkey$
  'text mm.hres/2, (mm.vres/2)+fontheight*2, name,"CM",fontnum, scaling

  local integer key =keydown(1)
  ' if it's not a special key
  if (key<128) then
    select case key
      case 8 'backspace
        if(len(name)>0) then
          name=left$(name,len(name)-1) 
        endif
        text mm.hres/2, (mm.vres/2)+fontheight*3, name,"CM",fontnum, scaling

      case 10 'enter
        hold=0 ' stop scanning keyboard
      case else
        name=name+chr$(key)
        text mm.hres/2, (mm.vres/2)+fontheight*3, name,"CM",fontnum, scaling
    end select
  endif
end sub


