clc
close all hidden
% figure( 'Units' , 'Normalized' , 'OuterPosition' , [ 0.05 0.05 0.4 0.9 ] )
% patch( [ 0 1 2 ] , [ 0 0.5 5 ] , 'Red' )
% patch( [ 0.2 1.2 2.2 ]-0.2 , [ 5 0.5 0 ] , 'Yellow' )
% patch( [ 0 1 2 ; 0 1 2 ]' , [ 0 0.5 5 ; 5 0.5 0 ]' , 'red' )
plot( [ 0 1 2 ; 0 1 2 ]' , [ 0 0.5 5 ; 5 0.5 0 ]' )

grid on
% axis tight
[response] = fig2plotly()