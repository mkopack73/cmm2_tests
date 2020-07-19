#include "stdsettings.inc"

option base 1
dim matrix(3,3) = (1,2,3,4,5,6,7,8,9)

matrix(1,1) = 1
matrix(2,1) = 2
matrix(3,1) = 3
matrix(1,2) = 4
matrix(2,2) = 5
matrix(3,2) = 6
matrix(1,3) = 7
matrix(2,3) = 8
matrix(3,3) = 9


math m_print matrix()

