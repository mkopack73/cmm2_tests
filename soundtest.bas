' ok this is a test. These all can be played together because they are the same sample rate


play modfile "thrash_that_beat.mod"

pause 4000

play effect "car-horn-honk.wav"

pause 4000

play effect "crash.wav"

pause 4000

play stop

' these two can not be done at the same time as a mod file playing in the background.
PLAY TONE 15,15,1000

pause 4000

PLAY SOUND 1,B,W,15,25

pause 2000

play stop
