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
fit_curve       = polyval( p , all_angles( : ) )'                               ;
