clc
n           = 2 
a           = randi( 20 , n )
b           = flipud( fliplr( diag( 1 : 3 ) ) )
kron( a , b ) 
kron( b , a ) 
