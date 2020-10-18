'System Information Dump
' By Mike Kopack
' July 2020
' Just a little program to dump out various pieces of info about your CMM2 system.


#include "stdsettings.inc"

print "This machine is a "+MM.DEVICE$
print "Running at "+str$((MM.INFO(CPUSPEED)/1000000))+" MHz"
print "Firmware version "+str$(MM.INFO$(VERSION))
print ""

currentmode! = MM.INFO(MODE)
modenum = fix(currentmode!)
bits = (currentmode!-modenum)*10
print "Currently operating in mode "+str$(modenum)+" with "+str$(bits)+" bit color"
print "with a resolution of "+str$(MM.HRES)+"x"+str$(MM.VRES)+" pixels"
print "with "+str$(MM.INFO(MAX PAGES)+1)+" pages available"
print
print "Keyboard is "+MM.INFO$(KEYBOARD)
on error skip 8
wii classic open 3
deviceid = classic(T,3)
select case deviceid
  case &HA4200101
    print "Wii Classic controller detected!"
  case &HA4200000
    print "Wii Nunchuk controller detected!"
  case &HA4200402
    print "Wii Balance controller detected!"
  case 0
    print "No device detected in joystick port."
  case else
    print "Unknown device detected in joystick port."
end select
wii classic close 3

sdcard:

print
print "SD card is "+MM.INFO$(SDCARD)
if(MM.INFO$(SDCARD)="Ready") then
  print "Card capacity is "+str$(MM.INFO(DISK SIZE))+" bytes"
  print "with "+str$(MM.INFO(FREE SPACE))+" bytes available"
  full = (1.0-(MM.INFO(FREE SPACE)/MM.INFO(DISK SIZE)))*100.0
  print "("+str$(full)+"% full)"
endif

print
print "Sound is currently "+MM.INFO$(SOUND)
print "Current track is "+MM.INFO$(TRACK)
print
print "Memory Info:"
memory
