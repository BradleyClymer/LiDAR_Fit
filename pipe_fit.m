clc
raw_x           = raw_scan .* x_weight                                       	;
raw_y           = raw_scan .* y_weight                                      	;
accepted_diff   = 0.5                                                           ;   % inches
all_angles      = angles_deg  * pi / 180                                    	;   % -45 : 225 in radians
bounds.min      = 0                                                             ;
bounds.max      = 180                                                           ;
angle_offset    = -10                                                           ;   % angles to consider outside of top hemisphere
fit_range       = ~isnan( scan ) &                                              ...
                   angles_deg > bounds.min + angle_offset &                 	...
                   angles_deg < bounds.max - angle_offset                       ;   % total angle range to fit

fit_order       = 2                                                             ;               
quad_fit                                                                            % parabolic fit
min_fit         = vertex( 2 )                                                   ;   
rem             = diam - min_fit                                                ;
fit_new_deg   	= vertex( 1 ) - 90                                              ;   % mean( all_angles( fit_curve == min_fit ) ) + 0*pi/2           ;
fit_rad         = fit_new_deg * pi / 180                                     	;
x_offset        = cos( fit_rad ) * rem                                          ;
y_offset        = sin( fit_rad ) * rem                                          ;
scan_fix        = scan                                                          ;         
x_weight_new 	= cosd( angles_deg + fit_new_deg )                              ;
y_weight_new  	= sind( angles_deg + fit_new_deg )                              ;

x_fit           = scan_fix .* x_weight_new + 1*x_offset                       	;
y_fit           = scan_fix .* y_weight_new - 1*y_offset                      	;

fit_rad         = -fit_rad                                                      ;
fit_deg         = fit_rad * 180 / pi                                            ;
% rot_mat         = [ cos( fit_rad ) , sin( fit_rad ) ;                           ...
%                    -sin( fit_rad ) , cos( fit_rad ) ]                           ;
try
    par_rec( 1 , : )= CircleFitByTaubin( [  raw_x( fit_range )'                     ...
                                            raw_y( fit_range )' ] )                  % [ x y R ] output
    par_rec         = circshift( par_rec , [ +1 0 ] )                               ;
    par             = sum( par_rec .* filter_mat )                                  ;
                      axes( h.scan )                                                ;
    circle_x        = [ 0 par( 3 ) * cosd( 90 : 90+360 ) 0 ] + par( 1 )          	;  
%     circle_y        = [ 0 par( 3 ) * sind( 90 : 90+360 ) 0 ] + par( 2 )          	;
    if ~exist( 'fit_center' , 'var' ) || ~ishandle( fit_center )                 
        fit_center      = scatter( -par( 1 ) , -par( 2 ) )                       	;
%         fit_circle      = plot( circle_x , circle_y , 'c--' )                     	;
    else 
        set( fit_center , 'XData' , -par( 1 ) , 'YData' , -par( 2 ) )               ;
%         set( fit_circle , 'XData' , circle_x , 'YData' , circle_y )                 ;
    end
catch err
    disp( 'Error, Dawg.' )
    disp( err )
end
               
% rotated         = [ x_fit ; y_fit ]' * rot_mat                                  ;
% x_fit           = rotated( : , 1 )' - 0*par( 1 )                                ;
% y_fit           = rotated( : , 2 )' - 0*par( 2 )                                ;

% x_fit           = x_fit - 1*x_offset                                            ;
% y_fit           = y_fit + 1*y_offset                                            ;                                    
                                    
[ a , b , R ]   = deal( par( 1 ) , par( 2 ) , par( 3 ) )                    	;


                 
med_x           = fit_curve .* x_weight - 0*par( 1 )                                ;
med_y           = fit_curve .* y_weight - 0*par( 2 )                                ;
	

flat_fit        = fit_curve - min( fit_curve )                                      ;
shift_deg       = ( 90 - vertex( 1 ) )                                              ;
shift_ind       = round( shift_deg * 4 )                                            ;
circ_shift      = circshift( scan , -0 , 2 )                                        ;
shift_angles    = circshift( aux_deg , 0 , 2 )                                      ;
shift_angles( 1082:end ) = []                                                       ;
curr_avg        = sprintf( 'Raw Average: %0.2f' , nanmean( raw_scan ) )           

% circ_shift( [ 1 end ] ) = 0                                                         ;
% x_scan          = circ_shift .* cosd( shift_angles ) - par( 1 )                     ;
% y_scan          = circ_shift .* sind( shift_angles ) - par( 2 )                     ;
x_scan          = scan .* x_weight - par( 1 )                                       ;
y_scan          = scan .* y_weight - par( 2 )                                       ;
fit_title       = sprintf( [ 'Fit Polynomial: %0.3f*\\theta^2 + %0.2f*\\theta + %0.2f'  ...
                             '\nVertex: %0.2f°, %0.2f"' ] ,                         ...
                             p , vertex - [ 90 0 ] ) 
                  set( get( h.fit, 'Title' ) , 'String' , fit_title )
                  
% x_fit           = x_scan - par_rec( 1 )                                             ;
% y_fit           = y_scan - par_rec( 2 )                                             ;
% toggle( h.med )
    set( h.med ,    'XData' , med_x , 'YData' , med_y )                          	;   %   Cyan Fat Partial Circle
    set( h.raw_p,   'XData' , raw_x , 'YData' , raw_y  )                        	;   %   Red Fat Line
    set( h.fit_p ,  'XData' , x_scan ,'YData' , y_scan  )                           ;   %   Green Fat Line
    set( h.circle , 'XData' , par( 3 ) * cosd( 0 : 360 ) ,                          ...
                    'YData' , par( 3 ) * sind( 0 : 360 ) )                          ;   %   Yellow Centered Best-Fit Circle

    set( h.red_filt, 'XData' , angles_deg( fit_range ) , 'YData' , scan( fit_range )  )	;   %   Red fit scatter
    set( h.bad_filt, 'XData' , angles_deg( ~fit_range ) , 'YData' , scan( ~fit_range )  )	;   %   Red fit scatter
    set( h.min_mark,'XData' , vertex( 1 ) , 'YData' , vertex( 2 ) )                     ;   %   Parabola Vertex
 	set( h.plot4 ,  'XData' , angles_deg( : ) ,   'YData' , fit_curve )                 ;   %   Fit Parabola