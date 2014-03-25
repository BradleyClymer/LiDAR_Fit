% figure( h.fit ) 
clc
pipe_ft         = 4                                                             ;
pipe_in         = pipe_ft * 12                                                  ;
pipe_mm         = pipe_in * 25.4                                                ;
mm_rad          = pipe_mm / 2                                                   ;
accepted_diff   = 0.5                                                           ; % inches
all_angles      = angles * pi / 180                                             ;
scan_diff       = [ 0 diff( scan ) ]                                            ;
diff_med        = median( scan_diff )                                           ;
diff_std        = std( scan_diff )                                              ;
angle_offset    = 0                                                             ;
fit_range       = ~isnan( scan ) &                                              ...
                   scan > 12 &                                                  ...
                   angles > 0 + angle_offset &                                  ...
                   angles < 180 - angle_offset                                  ;

fit_order       = 2                                                             ;               
quad_fit 
min_fit         = min( fit_curve )                                              ;
rem             = pipe_in / 2 - min_fit                                         ;
fit_new         = mean( all_angles( fit_curve == min_fit ) ) + 0*pi/2           ;
min_rec( end )  = fit_new                                                       ;
min_rec         = circshift( min_rec , 1 )                                      ;
fit_angle       = fit_new * pi / 180%* filter_new                                         ;
x_offset        = sin( fit_angle ) * rem                                        ;
y_offset        = cos( fit_angle ) * rem                                        ;


scan_fix        = scan                                                          ;
                  set( h.min_mark ,                                             ...
                       'XData' , ( fit_angle + pi/2 ) * 180/pi ,                ...
                       'YData' , min_fit )                                      ;
scan_fix( [ 1 end ] ) = 0                                                       ;                 

               
x_weight        = cosd( angles + fit_new )                                      ;
y_weight        = sind( angles + fit_new )                                      ;

x_fit           = scan_fix .* x_weight + 0*x_offset                           	;
y_fit           = scan_fix .* y_weight + 0*y_offset                             ;

fit_angle       = -fit_angle                                                    ;
fit_deg         = fit_angle * 180 / pi                                          ;
rot_mat         = [ cos( fit_angle ) , sin( fit_angle ) ;                       ...
                   -sin( fit_angle ) , cos( fit_angle ) ]                       ;
try
par_rec( 1 , : )= CircleFitByTaubin( [  x_fit( fit_range )'                     ...
                                        y_fit( fit_range )' ] )                 ;
par_rec         = circshift( par_rec , [ +1 0 ] )                               ;
par             = sum( par_rec .* filter_mat )                                  ;
catch err
end
               
rotated         = [ x_fit ; y_fit ]' * rot_mat                                  ;
x_fit           = rotated( : , 1 )' - 0*par( 1 )                                ;
y_fit           = rotated( : , 2 )' - 0*par( 2 )                                ;

x_fit           = x_fit + 1*x_offset                                            ;
y_fit           = y_fit + 1*y_offset                                            ;                                    
                                    
[ a , b , R ]   = deal( par( 1 ) , par( 2 ) , par( 3 ) )                    	;

set( h.fit_p ,  'XData' , x_fit ,    'YData' , y_fit  )                         ;
set( h.plot4 ,  'XData' , angles( fit_range ) ,   'YData' , fit_curve )         ;
set( h.circle , 'XData' , par( 3 ) * cosd( 0 : 360 ) ,                          ...
                'YData' , par( 3 ) * sind( 0 : 360 ) )                          ;