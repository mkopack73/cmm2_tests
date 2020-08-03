' high score library
' by Mike Kopack, July/Aug 2020
' Library of functions for handling a high score file, display and name capture
' Deals with both time and score based setups, and either low or high = best setups.

' NOTE, this expects that you're using "OPTION ORDER 1" for the arrays

' these are variables needed through the High Score system. We prefix them so there (hopefully) isn't a name collision
dim as string hs_filename
dim as integer hs_scoretype
dim as integer hs_highbetter
dim as string hs_scores (10,2)
dim as string hs_name
dim as integer hs_hold

' use this to load in the high score data from the given filename. Also sets up the type of scoring system.
' scoretype = 0 for integer scores, 1 for time based (in MS),
' highbetter = 0 for lower is better, 1 for higher is better
sub loadhighscores (filename as String, scoretype as integer, highbetter as integer)
  hs_filename= filename
  hs_scoretype=scoretype
  hs_highbetter = highbetter
  local as string scoreline
  local as integer linenum
  ' open the high score file for read
  on error skip
  open hs_filename FOR INPUT as #1
  if(MM.Errno<>0) then
    ' file not found so we'll just create a new empty array
    for i = 1 to 10
      hs_scores(i,1)=""
      hs_scores(i,2)="" ' might need to change this to 0, but that could be problematic lower=better
    next
  else
    ' file found so read in the data
    linenum=1
    do while not eof(#1)
      input #1,scoreline
      ' ok, now split the line on the ,
      hs_scores(linenum,1)= FIELD$(scoreline, 1, ",")
      hs_scores(linenum,2)= FIELD$(scoreline, 2, ",")
    loop
    close #1
  endif
end sub
  
  
' call this to show the high scores. Set the font, scale, color and page BEFORE calling this function
sub displayscores ()
  local width = MM.HRES
  local height = MM.VRES
  hs_color = col
  font fontnum,scaling
  local as integer lineheight = MM.info(FONTHEIGHT) 
  
  text MM.HRES/2, 10, "HIGH SCORES","CM"
  for i=1 to 10
    text MM.HRES/4,lineheight*2+(lineheight*i)+2,hs_scores(i,1),"CM"
    if(hs_scoretype=0)
      text mm.HRES*3/4, lineheight*2+(lineheight*i)+2,hs_scores(i,2),"CM"
    else
      ' it's a time based score so we need to parse things
      local integer tscore
      if(hs_scores(i,2) ="") then
        tscore=0
      else
        tscore=str$(val(hs_scores(i,2),8)
      local integer tpartial = tscore - (tscore/1000)
      tscore = tscore / 1000
      local integer tsec = tscore - (tscore/60)
      tscore = tscore/ 60
      local integer tmin = tscore - (tscore/60)
      local integer thour = tscore / 60
      local as string tstr = str$(thour,5)+":"+str$(tmin,2)+":"+str$(tsec,2)+"."+STR$(tpartial,3)
      text mm.HRES*3/4, lineheight*2+(lineheight*i)+2,tstr,"CM"
    endif
  next
  
end sub
  
  
  
  
' call this with the score to see if it's in the top 10 list
' returns position if it is a high score, 0 if it's not
function checkishigh as integer (score as integer)
  local as integer retval = 0
  if(hs_highbetter) then
    for(i=1 to 10)
      if(score >= val(hs_scores(10,2)) then
        retval=i
        exit for
      endif
    next
  else
    for(i=1 to 10)
      if(score <= val(hs_scores(10,2)) then
        retval=i
        exit for
      endif
    next
  endif
  checkishigh=retval
end function
  
  
' shows text for capturing the player's name. Once entered the updated top-10 is saved to disk
' set the font, scale, color and page BEFORE calling this function.
' score is the new score data
' position is the slot for the new score
sub capturename (score as string, position as integer)
  ' first let's shift all the scores from that position down
  for i= 10 to position step -1
    hs_scores(i,1) = hs_scores(i-1,1)
    hs_scores(i,2) = hs_scores(i-1,2)
  next
  local center = MM.VRES / 2

  local lineheight = mm.info(FONTHEIGHT)
  text MM.HRES/2, center-lineheight,"Congratulations!","CM"
  text mm.HRES/2, center+lineheight, "Enter your name", "CM"
  hs_name=""
  hs_hold=1
  on key handleinput()
  do while hs_hold
    pause 10
  loop

  hs_scores(position,1)=hs_name
  hs_scores(position,2)=score
  ' save the table
  open hs_filename for output as #1
  for int i=1 to 10
    print hs_scores(i,1);",";hs_scores(i,2)
  next
  close #1
end sub
  
' handles the keyboard input of the player's name when they get a high score  
sub hs_input()
  local LINEHEIGHT=mm.info(FONTHEIGHT)
  local integer key = keydown(1)
  'if it's not a special key
  if(key<128) then
    select case key
      case 8 ' backspace
        if (len(hs_name)>0) then
          hs_name-left$(name,len(hs_name)-1)
        endif
        text mm.hres/2, (mm.vres/2)+lineheight*3, hs_name, "CM"
      case 10 ' enter
        hs_hold=0
      case else
        hs_name=hs_name+chr$(key)
        text mm.hres/2,(mm.vres/2)+lineheight*3,hs_name,"CM"
    end select
  end if
 end sub

'Ok, this will test the functions
sub testhsfunctions()
  mode 1,8
  screen write 1
  cls black,yellow
  loadhighscores("highscoretest.txt",0,1)
  font 2,2
  displayscores()
  screen copy 1 to 0

  pause 3000
  screen write 0
  cls
  let position = checkishigh(1000)
  if(line>0) then
    capturename ("1000", position)
  endif
  screen write 1
  cls
  displayscores
  screen copy 1 to 0
  pause 3000
  screen write 0
end sub