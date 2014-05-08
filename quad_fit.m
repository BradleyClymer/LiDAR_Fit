p               = polyfit( all_angles( fit_range ) ,                            ...
                           all_med( i_scan , fit_range ) ,                      ...
                           fit_order )    ;
fit_curve       = polyval( p , all_angles( : ) )'                               ;
fit_diff        = fit_curve - all_med( i_scan , : )                             ;
bad_fit         = abs( fit_diff ) > accepted_diff                               ;
vertex          = calc_vertex( p )
% fit_range       = fit_range & ~bad_fit                                          ;
if exist( 'vertex' , 'var' )
    bounds.min  = 0 - ( 90 - vertex( 1 )  ) + angle_offset                      ;                     	
    bounds.max  = 180 - ( 90 - vertex( 1 )  ) - angle_offset                 	;
    bounds.range= bounds.max - bounds.min                                       
end
fit_range       = ~isnan( all_med( i_scan , : ) ) &                             ...
                  ~bad_fit &                                                    ...
                 ( angles_deg > ( bounds.min  ) ) &               ...
                   angles_deg < ( bounds.max  )               	;   % total angle range to fit
fit_cell        = { ( ~isnan( all_med( i_scan , : ) ) +.2 ) ;
                    ( ~bad_fit +.4 ) ;
                    ( ( angles_deg > ( bounds.min  ) ) +.6 ) ;
                    ( ( angles_deg < ( bounds.max  ) ) + 0.8 ) }
set( h.logic_plot , { 'YData' } , fit_cell )               
% 
% p               = polyfit( all_angles( fit_range ) , scan( fit_range ) , fit_order )    ;
% fit_curve       = polyval( p , all_angles( : ) )'                               ;
% fit_diff        = fit_curve - scan                                           	;
% bad_fit         = abs( fit_diff ) > accepted_diff.^2                            ;
% fit_range       = fit_range & ~bad_fit                                          ;
% 
% p               = polyfit( all_angles( fit_range ) , scan( fit_range ) , fit_order )    ;
% fit_curve       = polyval( p , all_angles( : ) )'                               ;
% fit_diff        = fit_curve - scan                                           	;
% bad_fit         = abs( fit_diff ) > accepted_diff.^3                            ;
% fit_range       = fit_range & ~bad_fit                                          ;

p               = polyfit( all_angles( fit_range ) ,                            ...
                           all_med( i_scan , fit_range ) ,                      ...
                           fit_order )                                          ;
fit_curve       = polyval( p , all_angles( : ) )'                               ;
fit_diff        = fit_curve - all_med( i_scan , : )                             ;
bad_fit         = abs( fit_diff ) > accepted_diff                               ;
vertex          = calc_vertex( p )                  

%   This needs to be modified: positive 2nd degree coefficient means above
%   the centerline, negative means below; in the 'below' case, special
%   handling needs to be considered
% 
% quadrant        = round( vertex( 1 ) / 90 ) + 1                                 ;
% opposite        = round( abs( 180 - vertex( 1 ) ) )                             ;
% opposite_ind    = find( round( angles_deg ) - opposite == 0 , 1 )               ;
% if isempty( opposite_ind )
%     opposite_ind = 1080 / 2
%     pause
% end
% opposite_rad    = fit_curve( opposite_ind )                                     ;
% diam            = vertex( 2 ) + opposite_rad                                    ;
% pause( 0.3 )                