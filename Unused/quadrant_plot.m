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
points          = [ 1 , 1 ; -1 , 1 ; -1 , -1 ; 1 , -1 ] * radius / 2;
dx              = radius / 15                                        ;
dy              = dx                                                ;
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
text( points( : , 1 ) + dx , points( : , 2 ) + dy , num2str( ( 1:4 )' ) )
line_names = { [] } 
set( gcf , 'Units' , 'Normalized' , 'OuterPosition' , [ 1.05 0.15 0.89 0.9 ] )
for s = 1 : 4
    subplot( 420 + 2*s )
    for i_fit  = [ 2 6 7 ]
        p       = polyfit( angles , dist( s , : ) , i_fit )         ;
        fit_ord{ 2 * i_fit - 1 }    = angles                        ;
        fit_ord{ 2 * i_fit     }    = polyval( p , angles )         ;
        line_names{ end + 1 }     	= sprintf( 'Order %d' , i_fit ) ;
    end
    line_names{ 1 }  = 'Actual Data' 
    h( s , : )  = plot( angles , dist( s , : ) , fit_ord{ : } , 'LineSmoothing' , 'on' )
    get( h( s ) )
%     set( h( s , 2:( i_fit-1 ) ) , 'Visible' , 'off' ) 
%     axis tight
    xlim( [ 0 360 ] )
    legend( { line_names{ : } } , 'Location' , 'NorthEastOutside' )
    grid on
    
    title( [ 'Quadrant ' num2str( s ) ] )
    set( gca, 'XDir' , 'reverse' )
    set( gca, 'XTick' , ticks , 'XTickLabel' , ( num2str( ticks' ) ) )
    curr_pos = get( gca , 'Position' )
    set( gca , 'Position' , get( gca , 'OuterPosition' ) .* [ 1 1 1 0.8 ] )
end
polyfit( angles * pi / 180 , dist( end , : ) , 6 )
polyfit( x_diff , y_diff , 6 )
tightfig
set( gcf , 'Units' , 'Normalized' , 'OuterPosition' , [ 1.05 0.15 0.89 0.9 ] )
figure
h.polar = polar( angles * pi / 180 , dist( 4 , : ) )
get( h.polar )