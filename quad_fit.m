diff_sign       = -sign( accepted_diff - 1 )                                                ;
if exist( 'vertex' , 'var' )
    cv                          = vertex( i_scan , 1 )                                      ;
    bounds( i_scan , : ).min  = 0 - ( 90 - cv  ) - angle_offset                             ;                     	
    bounds( i_scan , : ).max  = 180 - ( 90 - cv  ) + angle_offset                           ;
    bounds( i_scan , : ).range= bounds( i_scan , : ).max - bounds( i_scan , : ).min         ; 
    fprintf( 'Bound Range: %i°\n' , bounds( i_scan , : ).range )                            ;
end

for i_squeeze = 1 : parab_order
    p( i_scan , : )             = polyfit( angles_rad( fit_range( i_scan , : ) ) ,           	...
                                           all_med( i_scan , fit_range( i_scan , : ) ) ,        ...
                                           fit_order )                                          ;
    fit_curve( i_scan , : )  	= polyval( p( i_scan , : ) , angles_rad( : ) )'                 ;
    fx                          = all_x_weight( i_scan , : ) .* fit_curve( i_scan , : )      	;
    xd                          = all_x_med( i_scan , : ) - fx                                  ;
    fy                          = all_y_weight( i_scan , : ) .* fit_curve( i_scan , : )         ;
    yd                          = all_y_med( i_scan , : ) - fy + 0.24                           ;             
    fit_diff                    = ( xd .^ 2 + yd .^ 2 ) .^ 0.5                              	;
    bad_fit                     = abs( fit_diff ) > accepted_diff / i_squeeze                   ;
    in_bounds                   = ( angles_deg > ( bounds( i_scan ).min ) &                     ...
                                  ( angles_deg < ( bounds( i_scan ).max ) ) )                   ;
    vertex( i_scan , : )        = calc_vertex( p( i_scan , : ) )                                ;
    fit_range( i_scan , : ) 	= fit_range( i_scan , : ) & ~bad_fit & in_bounds                ;
    fit_num                     = find( fit_range( i_scan , : ) ) /4                            ;
end
                
fit_cell{ i_scan }          = { ( ~isnan( all_med( i_scan , : ) ) +.2 ) ;
                                ( ~bad_fit +.4 ) ;
                                ( ( angles_deg > ( bounds( i_scan , : ).min  ) ) +.6 ) ;
                                ( ( angles_deg < ( bounds( i_scan , : ).max  ) ) + 0.8 ) }      ;