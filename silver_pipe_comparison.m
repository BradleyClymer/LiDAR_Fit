if isfield( h , 'med_check' )
    close( h.med_check )
end
h.med_check     = figure( 'Units' , 'Normalized' , 'OuterPosition' , [ 0.2 0.04 0.6 0.96 ] )

plot( mean( all_x_raw ) , mean( all_y_raw ) , mean( all_x_med ) , mean( all_y_med ) , 'LineSmoothing' , 'on' ) , grid on , axis equal
legend( { 'Raw' , 'Averaged' } )