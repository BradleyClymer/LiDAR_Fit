if isfield( h , 'med_check' )
    close( h.med_check )
end

if ~exist( 'all_x_raw' , 'var' )
    all_x_raw   = all_scans .* all_x_weight             ;
    all_y_raw   = all_scans .* all_y_weight             ;
end
h.med_check     = figure( 'Units' , 'Normalized' , 'OuterPosition' , [ 0.2 0.04 0.6 0.96 ] )

plot( mean( all_x_raw ) , mean( all_y_raw ) , '-y' , 'LineSmoothing' , 'on' ,  'LineWidth' , 5 ) , grid on , axis equal
hold on
plot( mean( all_x_med ) , mean( all_y_med ) , 'm' , 'LineSmoothing' , 'on' ,  'LineWidth' , 3  ) , grid on , axis equal
legend( { 'Raw' , 'Median Filtered' } )
[ fp, fn, fe ]          = fileparts( urg_file )                     ; 
export_name             = [ fn 'Comparison Figure' ]                ;
export_fig( export_name , '-m2' , '-Painters' )
winopen( [ export_name '.png' ] )