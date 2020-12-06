'CMM2 RDS Map
'using 0 indexed arrays (so 0-lastindex)
OPTION EXPLICIT ON
OPTION DEFAULT NONE  
  
'define the global variables
  
dim hlm_width%=7  'how many cells wide is the track map (0-7)
dim hlm_height%=7 'how many cells high is the track map (0-7)
  
' set up some names for the layers so they're easier to interact with
const piecelayer%=0
const rotationlayer%=1
const surfacelayer%=2

'set up constants for the different drawing pages so we can reference them by name
const displaypage%=0
const bufferpage%=1  ' this is where we build up the next frame
const mappage%=2 ' this is where we build up the map
const tilesetpage%=3 ' this holds the map tileset
const carspritepage%=4 ' this holds the car sprites

const tilesize%=80 'the height and width of each track tile piece

  
' ok, this is a 3d array that holds the track tile type in the piecelayer and the surface type
' in the surfacelayer.
dim hl_map%(hlm_width%,hlm_height%,3)

dim tilesetfile$ ' holds the filename of the map tileset
dim cartilesetfile$ ' holds the filename of the car sprite tileset

dim mapfilename$="testtrack.trk"  ' for now we'll hard code the name of the track file to read in




' subroutine that handles reading in the track data from a file  
SUB readmapfile (filename$)
  ' open the map file
  ' note we really should double check that the file exists first, but we'll skip that for now
  open filename$ for input as #1
  
  'make a pair of temp variables that we'll put the size of the map into from the file
  local width%,height%
  local line$
  'first, read in the file name for the tileset to use
  line input #1,tilesetfile$
  ' read in the first 2 values on the next line. Those are the width and height of the map
  line input #1,line$
  height% = val(field$(line$,1,","))
  width% = val(field$(line$,2,","))
  ' check that the dimensions of the map in the file match what we made our array to hold
  if width%<>hlm_width% or height%<>hlm_height% then
    print "Map file size does not match array created to hold it!"
    end
  end if
  
  'ok, now for each cell of the map, read in a number representing the kind of map piece
  ' 0=unused cell
  ' 1=straight
  ' 2=turn
  ' 3=criss cross
  ' 4=start/finish
  
  local row%
  local column%
  local temp$
  local tempnum%
  for row% = 0 to height%
    'read in a line of text from the file
    line input #1,line$
    'chop it up by the "," character
    for column% = 0 to width%
      ' grab the nth value off the line 
      temp$ = field$(line$,column%+1,",") 
      ' covert the string to a number
      tempnum%=val(temp$)
      hl_map%(row%,column%,piecelayer%)=tempnum%
    next column%
  next row%

  'ok, now do it again to read in the layer of the map array with the rotation for each piece
  '0=unrotated
  '1=rotated clockwise 90 degrees
  '2=rotated 180 degrees
  '3=rotated clockwise 270 degrees

  for row% = 0 to height%
    'read in the line of text
    line input #1, line$
    for column% = 0 to width%
      'chop it up by , and grab the nth value and store it
      'we need to add 1 to the column because the field command starts with 1 but the array starts with 0
      temp$=field$(line$,column%+1,",")
      tempnum%=val(temp$)
      hl_map%(row%,column%,rotationlayer%)=tempnum%
    next column%
  next row%

  'ok, now do it again to read in the layer that has the surface type where:
  '0=unused
  '1=asphalt
  '2=sand
  '3=ice
  ' notice how we change which layer of the map array we put it into
  for row% = 0 to height%
    'read in the line of text
    line input #1, line$
    for column% = 0 to width%
      'chop it up by , and grab the nth value and store it
      'we need to add 1 to the column because the field command starts with 1 but the array starts with 0
      temp$=field$(line$,column%+1,",")
      tempnum%=val(temp$)
      hl_map%(row%,column%,surfacelayer%)=tempnum%
    next column%
  next row%

  
  ' ok close the file
  close #1
end sub



'------------------
' ok this function draws the map
sub displaymap
  ' just a couple temp variables to copy the cell data into
  local piecenum%
  local colornum%
  local drawcolor%
  'this one will hold the character we will draw
  Local piecegfx$
  local row%
  local column%
 
  for row% = 0 to hlm_height%
    for column% = 0 to hlm_width%
      'don't HAVE to do this copying, but it makes things easier
      piecenum%=hl_map%(row%,column%,piecelayer%)
      colornum%=hl_map%(row%,column%,surfacelayer%)
      
      'see if it's an empty cell we don't do anything since it's already a green background
      'see if it's a Horizontal straight
      select CASE piecenum%
        case 0
          piecegfx$=" " ' empty cell so print a space
        case 1
          piecegfx$="-" ' horizontal straight
        case 2
          piecegfx$="|" ' vertical straight
        case 3
          piecegfx$=")" ' 3=left turn
        case 4
          piecegfx$="(" ' 4=right turn
        case 5
          piecegfx$="+" ' 5=criss cross
        case 6
          piecegfx$="S" ' 6=horizontal start/finish
        case 7
          piecegfx$="T" ' 7=vertical start/finish
      end select
      
      'figure out which color to print it with
      select case colornum%
        case 0
          drawcolor%= rgb(0,255,0) ' green off track area
        case 1
          drawcolor%= rgb(10,10,10) ' dark gray asphalt
        case 2
          drawcolor%= rgb(235,183,52) ' tan sand
        case 3
          drawcolor%= rgb(255,255,255) ' white ice
      end select
      
      'ok, now we know what to print and in what color, so now print it
      ' so we find out how wide and tall a character in the current font is, and then
      ' based on which row and column we're at, we move that far. We need to add 1 to the row
      ' since we need to be at the bottom of the font (so if the font is 8 pixels high we need
      ' to set it to 8 instead of 0 for the first row to print on the screen..
      text MM.INFO(FONTWIDTH)*column%,MM.INFO(FONTHEIGHT)*(row%+1),piecegfx$,,,,drawcolor%,rgb(0,128,0)
      
    next column%
  next row%
  
end sub
  

'------------------
sub loadtileset()
  'check that the file exists
  'load it into the tilesetpage%
end sub

'------------------

sub loadcars()
  'check that the file exists
  'load it into the carspritepage%
end sub

'------------------
' this takes the track data from the file and builds up the track graphics from the tileset
sub buildmap()
  'loop through the track array cell by cell
  'get the tile number and the rotation info
  'copy and rotate the tile as needed from the tilesetpage% and paste into the proper spot on the mappage%
end sub
'------------------





  
' main program
  
' read in the map
readmapfile(mapfilename$)
' load in the map graphics tileset
loadtileset()
' build the map
buildmap()
' display it
displaymap()

pause 5000
end
  
