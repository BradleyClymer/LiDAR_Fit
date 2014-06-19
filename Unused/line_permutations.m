clc
clear
close all hidden
try close( h.match ), catch err, end
global key_is_pressed
key_is_pressed  = 0                                     	;
offset          = 0                                         ;
lin_offset      = 0                                         ;

h.match         = figure( 'Units' , 'Normalized' ,          ...
                          'Position' , .1*[ 2 1 6 8 ] )     ;
% kp              = @( hObject, event ) ( @kp_script )
set(gcf, 'KeyPressFcn', @kp_script )                      
offset          = 1                                         ;
x.range         =  -45 : 225                                ;
x.range         = x.range * pi / 180                        ;
x.calc          = linspace( -45 , 225 , numel( x.range ) ) ;

                  subplot( 5 , 1 , 1 ) 
rad             = zeros( size( x.range ) ) + offset         ;
ax( 1 )         = plot( rad )                                                 ;
ylim( [ 0 95 ] ) 
% axis normal tight
grid on


y.flat          = rad .* sin( x.range )                     ;
                  subplot( 5 , 2 , [ 4 6 ] )    
ax( 3 )         = plot( x.range , y.flat )                  ;
                  title( 'y_{flat}' )
                  grid on 
                  axis tight
                  ylim( 95*[ -1 1 ] )
                  xlim( [ -1 , 4 ] )              
                  

                  xlim( [ -1 , 4 ] )
            	  subplot( 5 , 2 , [ 3 5 ] )   
x.flat          = rad .* cos( x.range )                     ; 
ax( 4 )         = plot( x.range , x.flat )                  ;
                  title( 'x_{flat}' )
                  grid on 
%                   axis tight
                  ylim( 95*[ -1 1 ] )
                  xlim( [ -1 , 4 ] )                        

                  
                  subplot( 5 , 1 , 4:5 )                      
ax( 2 )         = plot( x.flat , y.flat ,                   ...
                       'LineSmoothing' , 'on' )             ;
                  ylim( 95 * [ -1 1 ] )                     ;
                  xlim( 95 * [ -1 1 ] )                     ;
                  axis equal

% axis normal equal
grid on
% xlim( [ -2 2 ] )
while ~isempty( key_is_pressed )
    
for i = 1 : 90
%     offset          = +i                                        ;
%     lin_offset      = i / 90 .* x.calc / 180 * 2                ;
    parab_offset    = ( ( x.calc - median( x.calc ) ) / i ) .^2 ;
    rad             = zeros( size( x.range ) ) + offset         ...
                                               + lin_offset     ...
                                               + parab_offset 	;
                                           
    try
    set( ax( 1 ) , 'YData' , rad )
    catch err
        key_is_pressed  = []                                    ;
        break
    end
    ylim( [ -i , i ] )
    y.flat          = rad .* sin( x.range )                     ;
    x.flat          = rad .* cos( x.range )                     ;
    set( ax( 3 ) , 'YData' , y.flat )        ;
    set( ax( 4 ) , 'YData' , x.flat )        ;
    set( ax( 2 ) , 'XData' , x.flat , 'YData' , y.flat )        ;
%     axis equal
%     ylim( [ -2.5 1.5 ] )
%     xlim( [ -2.5 1.5 ] )
    pause( 0.1 )
    drawnow
    
end
end