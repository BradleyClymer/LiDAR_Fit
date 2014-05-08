clc
raw_x           = raw_scan .* x_weight                                       	;
raw_y           = raw_scan .* y_weight                                      	;
accepted_diff   = 0.5                                                           ;   % inches
all_angles      = angles_deg  * pi / 180                                    	;   % -45 : 225 in radians
bounds.min      = 0 + angle_offset                                          	;
bounds.max      = 180 - angle_offset                                        	;
angle_offset    = -10                                                           ;   % angles to consider outside of top hemisphere
fit_range       = ~isnan( all_med( i_scan , : ) ) &                             ...
                   angles_deg > bounds.min &                                    ...
                   angles_deg < bounds.max                                      ;   % total angle range to fit

fit_order       = 2                                                             ;               
quad_fit                                                                            % parabolic fit
min_fit         = vertex( 2 )                                                   ;   
fit_new_deg   	= vertex( 1 ) - 90                                              ;   % mean( all_angles( fit_curve == min_fit ) ) + 0*pi/2           ;       
try
    par_rec( 1 , : )= CircleFitByTaubin( [  all_x_med( i_scan , fit_range )'      	...
                                            all_y_med( i_scan , fit_range )' ] )                  % [ x y R ] output
    par_rec         = circshift( par_rec , [ -1 0 ] )                               ;
    par             = sum( par_rec .* filter_mat )                                  ;
                      axes( h.scan )                                                ;
    if ~exist( 'fit_center' , 'var' ) || ~ishandle( fit_center )                 
        fit_center      = scatter( -par( 1 ) , -par( 2 ) )                       	;
%         fit_circle      = plot( circle_x , circle_y , 'c--' )                     	;
    else 
        set( fit_center , 'XData' , -par( 1 ) , 'YData' , -par( 2 ) )               ;
%         set( fit_circle , 'XData' , circle_x , 'YData' , circle_y )                 ;
    end
catch err
    clear
    disp( 'Error, Dawg.' )
    disp( err )
    pause
end                              
                                    
[ a , b , R ]   = deal( par( 1 ) , par( 2 ) , par( 3 ) )                            ;
                 
med_x           = fit_curve .* x_weight - 0*par( 1 )                                ;
med_y           = fit_curve .* y_weight - 0*par( 2 )                                ;
flat_fit        = fit_curve - min( fit_curve )                                      ;
shift_deg       = ( 90 - vertex( 1 ) )                                              ;
shift_ind       = round( shift_deg * 4 )                                            ;
circ_shift      = circshift(all_med( i_scan ), -0 , 2 )                                        ;
shift_angles    = circshift( aux_deg , 0 , 2 )                                      ;
shift_angles( 1082:end ) = []                                                       ;
curr_avg        = sprintf( 'Raw Average: %0.2f' , nanmean( raw_scan ) )           

% circ_shift( [ 1 end ] ) = 0                                                         ;
% x_scan          = circ_shift .* cosd( shift_angles ) - par( 1 )                     ;
% y_scan          = circ_shift .* sind( shift_angles ) - par( 2 )                     ;
x_scan          = all_x_med( i_scan , : ) - par( 1 )                                ;
y_scan          = all_y_med( i_scan , : ) - par( 2 )                                ;
[ th( i_scan , : ) , rho( i_scan , : ) ] =                                      	...
                  cart2pol( x_scan , y_scan )                                       ;
fit_title       = sprintf( [ 'Fit Polynomial: %0.3f*\\theta^2 + %0.2f*\\theta + %0.2f'  ...
                             '\nVertex: %0.2f°, %0.2f"' ] ,                         ...
                             p , vertex - [ 90 0 ] ) 
                  set( get( h.fit, 'Title' ) , 'String' , fit_title )
                  
% x_fit           = x_scan - par_rec( 1 )                                             ;
% y_fit           = y_scan - par_rec( 2 )                                             ;
% toggle( h.med )
%     set( h.med ,    'XData' , med_x , 'YData' , med_y )                                 ;   %   Cyan Fat Partial Circle
    set( h.raw_p,   'XData' , raw_x , 'YData' , raw_y  )                                ;   %   Red Fat Line
    set( h.fit_p ,  'XData' , x_scan ,'YData' , y_scan  )                               ;   %   Green Fat Line
    set( h.circle , 'XData' , par( 3 ) * cosd( 0 : 360 ) ,                              ...
                    'YData' , par( 3 ) * sind( 0 : 360 ) )                              ;   %   Yellow Centered Best-Fit Circle
    
    set( h.red_filt, 'XData' , angles_deg( fit_range ) ,                                ...
                     'YData' , all_med( i_scan , fit_range )  )                         ;   %   Red fit scatter
    set( h.bad_filt, 'XData' , angles_deg( ~fit_range ) ,                               ...
                     'YData' , all_med( i_scan , ~fit_range )  )                        ;   %   Bad fit scatter
    set( h.min_mark,'XData' , vertex( 1 ) , 'YData' , vertex( 2 ) )                     ;   %   Parabola Vertex
 	set( h.plot4 ,  'XData' , angles_deg( : ) ,   'YData' , fit_curve )                 ;   %   Fit Parabola
    set( h.bounds , 'XData' , [ bounds.min bounds.min nan bounds.max bounds.max ] ,     ...
                    'YData' , [ -100       100        nan -100       100        ] )   	;