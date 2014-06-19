stuff_cell  = { raw_data, all_x_raw, all_x_med, all_scans, all_med , all_y_med } 
% suff_names  = who( stuff_cell )
figure( 'Units' , 'Normalized' , 'OuterPosition' , [ 0.1 0.1 0.8 0.8 ] )
sqrdim  = sqrt( numel( stuff_cell ) )
flat    = round( sqrdim )
if flat ^2 >= sqrdim ^2 
    d = [ flat  flat  ] 
else
    d = [ flat  ( flat + 1 ) ] 
end

for i_vars = 1 : numel( stuff_cell ) 
    subplot( d( 1 ) , d( 2 ) , i_vars )
    if length( stuff_cell{ i_vars } ) ~= numel( stuff_cell{ i_vars } )
        imagesc( stuff_cell{ i_vars } )
        colormap bone
        colorbar
    else
        plot( stuff_cell{ i_vars } , 'LineSmoothing' , 'on' )
        grid on
        axis tight
    end
    title( num2str( i_vars ) )
end