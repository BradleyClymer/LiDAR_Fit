clear
clc
starts  = [ 1 10 14 19 ]
ends    = [ 2 12 17 25 ]
d       = diff( [ starts ; ends ] )

n       = nan( max( d( : ) + 1 ) , size( starts , 2 ) )

sub2ind( size( n ) , starts , d )

