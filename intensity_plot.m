close all hidden
h.intensity_fig     = figure( 'Units' , 'Normalized' , 'NumberTitle' , 'off' , 'OuterPosition' , [ 0.1 0.1 .8 0.8 ] )          ;
scan_range          = 1 : 4213                                                          ; 
scan_lim            = 400                                                               ;
scan_min            = 150                                                               ;
int_lim             = 3500                                                              ;
mm_to_ft            = 1 / ( 25.4 * 12 )                                                 ;
% h.scan              = subplot( 121 )
a                   = transpose( horzcat( urg_struct( scan_range ).scan ) )             ;
a( : , [ 1 : 19 , 1051 : 1081 ] ) = nan                                                 ;
% a( ( a > scan_lim ) | ( a < scan_min ) )   = nan                                                ;
a( ( a > scan_lim ) )   = nan                                                           ;
% a                   = medfilt2( a , [ 15 3 ] )                                          ;
% imagesc( a )

% h.intensity         = subplot( 122 )
b                   = transpose( horzcat( urg_struct( scan_range ).intensity ) )      	;
% b                   = medfilt2( b , [ 15 15 ] )                                         ;
bad_int             = ( b > int_lim ) | ( b < 800 )                                     ;
b( bad_int )        = nan                                                           ;
imagesc( b )
distance            = repmat( urg_ft( scan_range )' , [ 1 1081 ] ) / mm_to_ft         	;
h.surface_fig       = surf( all_x_weight( scan_range , : ) .* a ,                    	...
                            distance ,                                                  ...
                            all_y_weight( scan_range , : ) .* a ,                     	...
                            b ,                                                         ...
                            'EdgeColor' , 'none' )
colormap copper       
axis equal

% figure
% h.mesh_fig          = mesh( distance ,                                                  ...
%                             all_x_weight( scan_range , : ) .* a ,                       ...
%                             all_y_weight( scan_range , : ) .* a ,                   	...
%                             b )                     
% axis equal
tightfig                    ;
y_halo              = 500 ;
% f                   = 
writerObj           = VideoWriter( 'pipe_frame_video.avi' );
open( writerObj ) 
set(gca,'nextplot','replacechildren');
set(gcf,'Renderer','zbuffer');
drawnow
for i_distance = 2000 : 1 : 16000
    fprintf( 'frame %d' , i_distance )
    ylim( i_distance*[ 1 1 ] + y_halo*[ -1 1 ] )
    drawnow
    frame           = getframe                      ;
    writeVideo(writerObj,frame);
end

close(writerObj)


                        