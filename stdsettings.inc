'Standard Settings that all my programs use
' by Mike Kopack
' July 2020



'perform a version check
if((MM.DEVICE$<>"Colour Maximite 2") or (MM.INFO(VERSION) < 5.0504)) then
  print "Sorry, but this code requires a CMM2 with at least version 5.5.4 firmware to run."
  print "Please update your firmware to a newer version."  
  end
endif

option base 1          ' all arrays are 1 indexed
option default integer ' all variables that are non-specified are ints
option legacy off      ' no legacy support, don't need since I'm writing all new stuff for the CMM2
option milliseconds on ' turn on ms level timing
  
