p               = polyfit( all_angles( fit_range ) , scan( fit_range ) , fit_order )    ;
fit_curve       = polyval( p , all_angles( : ) )'                               ;
fit_diff        = fit_curve - scan                                           	;
bad_fit         = abs( fit_diff ) > accepted_diff                               ;
vertex          = calc_vertex( p )
% fit_range       = fit_range & ~bad_fit                                          ;
if exist( 'vertex' , 'var' )
    bounds.min  = bounds.min - ( 90 - vertex( 1 )  )                         	;
    bounds.max  = bounds.max - ( 90 - vertex( 1 )  )                            ;
end
bounds
bounds.max - bounds.min
fit_range       = ~isnan( scan ) &                                              ...
                  ~bad_fit &                                                    ...
                 ( angles_deg > ( bounds.min + angle_offset ) ) &               ...
                   angles_deg < ( bounds.max - angle_offset )               	;   % total angle range to fit
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

p               = polyfit( all_angles( fit_range ) , scan( fit_range ) , fit_order )    ;
fit_curve       = polyval( p , all_angles( : ) )'                               ;
vertex          = calc_vertex( p )                  
% [ x , y ]       = pol2cart( all_angles( fit_range ) , scan( fit_range ) )       ;
% mean( x )       

                
% v1              = find( fit_curve == min( fit_curve ) )        
%   This needs to be modified: positive 2nd degree coefficient means above
%   the centerline, negative means below; in the 'below' case, special
%   handling needs to be considered

quadrant        = round( vertex( 1 ) / 90 ) + 1                                 ;
opposite        = round( abs( 180 - vertex( 1 ) ) )                             ;
opposite_ind    = find( round( angles_deg ) - opposite == 0 , 1 )               ;
if isempty( opposite_ind )
    opposite_ind = 1080 / 2
    pause
end
opposite_rad    = fit_curve( opposite_ind )                                     ;
diam            = vertex( 2 ) + opposite_rad                                    ;
% pause( 0.3 )                