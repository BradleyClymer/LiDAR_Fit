% figure( h.fit ) 
clc
pipe_ft         = 3                                                             ;
pipe_in         = pipe_ft * 12                                                  ;
accepted_diff   = 0.5                                                           ; % inches
all_angles      = angles * pi / 180                                             ;
% good_range      = scan( ~isnan( scan ) )                                ;
% good_angles     = angles( good_range )                                  ;
% good_scan       = scan( good_range )                                    ;
scan_diff       = [ 0 diff( scan ) ]                                            ;
diff_med        = median( scan_diff )                                           ;
diff_std        = std( scan_diff )                                              ;
% cutoffs         = find( scan_diff > accepted_diff )'                     
% reshape( cutoffs, [] , 2 )
% fit_range       = abs( scan_diff ) < accepted_diff                      ;
angle_offset    = 0                                                            ;
fit_range       = ~isnan( scan ) &                                              ...
                   scan > 12 &                                                  ...
                   angles > 0 + angle_offset &                                ...
                   angles < 180 - angle_offset                                  ;

fit_order       = 5                                                             ;               
p               = polyfit( all_angles( fit_range ) , scan( fit_range ) , fit_order )    ;
fit_curve       = polyval( p , all_angles( : ) )'                               ;
fit_diff        = fit_curve - scan                                           	;
bad_fit         = abs( fit_diff ) > accepted_diff                               ;
fit_range       = fit_range & ~bad_fit                                          ;
p               = polyfit( all_angles( fit_range ) , scan( fit_range ) , fit_order )    ;
fit_curve       = polyval( p , all_angles( : ) )'                               ;
fit_diff        = fit_curve - scan                                           	;
bad_fit         = abs( fit_diff ) > accepted_diff.^2                            ;
fit_range       = fit_range & ~bad_fit                                          ;
p               = polyfit( all_angles( fit_range ) , scan( fit_range ) , fit_order )    ;
fit_curve       = polyval( p , all_angles( : ) )'                               ;
fit_diff        = fit_curve - scan                                           	;
bad_fit         = abs( fit_diff ) > accepted_diff.^3                            ;
fit_range       = fit_range & ~bad_fit                                          ;
p               = polyfit( all_angles( fit_range ) , scan( fit_range ) , fit_order )    ;
fit_curve       = polyval( p , all_angles( fit_range ) )'                       ;

min_fit         = min( fit_curve )                                              ;
fit_new         = mean( all_angles( fit_curve == min_fit ) ) + 0*pi/2             ;
min_rec( end )  = fit_new                                                       ;
min_rec         = circshift( min_rec , 1 )                                      ;
fit_angle       = fit_new * pi / 180%* filter_new                                         ;

% fprintf( 'Fit Angle is %i\n' , fit_angle )
% angle_fix       = fit_curve - polyval( p , all_angles( : ) + fit_angle )'        ;
% fprintf( 'Mean of the angle fix is %i\n' ,  mean( angle_fix ) )

scan_fix        = scan                                                          ;
                  set( h.min_mark ,                                             ...
                       'XData' , ( fit_angle + pi/2 ) * 180/pi ,                ...
                       'YData' , min_fit )                                      ;
% fit_angle       = -fit_angle                                                    ;
rot_mat         = [ cos( fit_angle ) , sin( fit_angle ) ;                       ...
                   -sin( fit_angle ) , cos( fit_angle ) ]                       ;
               
x_weight        = cosd( angles + fit_angle )                                    ;
y_weight        = sind( angles + fit_angle )                                    ;
               
x_fit           = scan_fix .* x_weight                                          ;
y_fit           = scan_fix .* y_weight                                          ;
par_rec( 1 , : )= CircleFitByTaubin( [  x_fit( fit_range )'                     ...
                                        y_fit( fit_range )' ] )                 ;
par_rec         = circshift( par_rec , [ +1 0 ] )                               ;
par             = sum( par_rec .* filter_mat )                                  ;
                                    
                                    
[ a , b , R ]   = deal( par( 1 ) , par( 2 ) , par( 3 ) )                    	;
x_fit           = x_fit - 0                                                     ;
y_fit           = y_fit - 0                                                     ;

rotated         = [ x_fit ; y_fit ]' * rot_mat                                   ;
x_fit           = rotated( : , 1 )' - 1*par( 1 )                                ;
y_fit           = rotated( : , 2 )' - 1*par( 2 )                                ;


set( h.fit_p ,  'XData' , x_fit ,    'YData' , y_fit  )                         ;
set( h.plot4 ,  'XData' , angles( fit_range ) ,   'YData' , fit_curve )         ;
set( h.circle , 'XData' , par( 3 ) * cosd( 0 : 360 ) ,                          ...
                'YData' , par( 3 ) * sind( 0 : 360 ) )                          ;