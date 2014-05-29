function quadrant_plot
close all hidden
clc
ang_offset      = -135
angles          = ( 225 : -1 : -135 ) - ang_offset                  ;
ticks           = min( angles ) : 45 : max( angles )                
radius          = 1                                                 ;
circle.x        = radius * cosd( angles )                           ;
circle.y        = radius * sind( angles )                           ;
q               = sqrt( 2 )
points          = [ 1 , 1 ; -1 , 1 ; -1 , -1 ; 1 , -1 ] * radius / 2   ;
for i = 1 : size( points , 1 ) 
    x               = points( i , 1 )                       ;
    y               = points( i , 2 )                       ;
    x_diff          = circle.x - x                          ;
    y_diff          = circle.y - y                          ;
    dist( i , : )   = sqrt( x_diff .^2 + y_diff .^2 )       ;
    sum( dist( i , : ) - radius ) / numel( angles ) 
end

subplot( 121 )
plot( circle.x , circle.y , 'LineSmoothing' , 'on' )
grid on
axis equal
hold on
scatter( points( : , 1 ) , points( : , 2 ) ) 
hold on
title( [ 'Circle of Radius ' num2str( radius ) ] )

for s = 1 : 4
    subplot( 420 + 2*s )
    for i_fit  = 1 : 2
        p       = polyfit( angles , dist( s , : ) , i_fit )         ;
        fit_ord{ 2 * i_fit - 1 }    = angles                        ;
        fit_ord{ 2 * i_fit     }    = polyval( p , angles )         ;
        names{ i_fit + 1 }          = sprintf( 'Order %d' , i_fit ) ;
    end
    names{ 1 }  = 'Actual Data' 
    h( s , : )  = plot( angles , dist( s , : ) , fit_ord{ : } , 'LineSmoothing' , 'on' )
    get( h( s ) )
    set( h( s , 2:( i_fit-1 ) ) , 'Visible' , 'off' ) 
    legend( { names{ : } } )
    grid on
    axis tight
    title( [ 'Quadrant ' num2str( s ) ] )
    set( gca, 'XDir' , 'reverse' )
    set( gca, 'XTick' , ticks , 'XTickLabel' , ( num2str( ticks' ) ) )
end
polyfit( angles * pi / 180 , dist( end , : ) , 20 )
polyfit( x_diff , y_diff , 20 )

set( gcf , 'Units' , 'Normalized' , 'OuterPosition' , [ 1.05 0.05 0.49 0.9 ] )
figure
polar( angles * pi / 180 , dist( 4 , : ) )