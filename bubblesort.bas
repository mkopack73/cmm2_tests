' A simple bubble sort "benchmark" to compare to other computers.
' By Mike Kopack
option default integer
option milliseconds on

iterations = 10
size = 20
dim numbers(size)
dim times(size)

Print "Performing ",iterations," against array size of ",size

for ct = 1 to iterations
  starttime=timer
  print "Start time=",starttime
  ' first lets fill the array with random numbers from 1 to size
  print "Generating..."
  
  for i=1 to size
    numbers(i)=RND*size
  next
  print "Sorting..."  
  do
    swapped = 0 'false
    for i=2 to size
      if numbers(i-1)>numbers(i) then
        temp=numbers(i-1) : numbers(i-1)=numbers(i) : numbers(i) = temp ' swap them
        swapped =1
      endif
    next
  loop until swapped=0 
  
  times(ct)=timer-starttime
  print ct," took: ",times(ct)," ms"
next
