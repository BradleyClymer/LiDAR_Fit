tic
for i_scan = 1 : size( out_t , 1 )
    this_scan   = out_t( i_scan , : )                                                                           ;
    for i_angle     = 1 : 361
        this_angle                      = this_scan( i_angle )                                                  ;
        ideal_comp                      = mod( this_angle + 180 , 360 )                                         ;
        scan_diff                       = abs( this_scan - ideal_comp )                                         ;
        best_comp( i_scan , i_angle ) 	= find( scan_diff == min( scan_diff ) )                                 ;
        diam( i_scan , i_angle )        = sum( out_c( i_scan , [ i_angle best_comp( i_scan , i_angle ) ] ) )    ;
    end
    max_diam( i_scan )      = max( diam( i_scan , : ) )                                                         ;
    ovality_pct( i_scan )   = ( max_diam( i_scan ) - pipe_diameter ) / pipe_diameter                            ;
end
toc

%%  Plotting section
close all
figure
sp( 1 ) = subplot( 211 )
plot( urg_ft , ovality_pct * 100 )
title( sprintf( 'Ovality Percentage by Distance' ) )
xlabel( 'Distance, Ft' )
ylabel( '%' )
xlim( [ min( urg_ft ) , max( urg_ft ) ] )
grid on

sp( 2 ) = subplot( 212 ) 
imagesc( urg_ft , angles_deg , out_c' ) , grid on , shading flat 
xlabel( 'Distance, Ft' )
ylabel( 'Angle, °' )
colormap( map )
% colorbar
export_fig( [ 'Ovality for ' fn ] , '-m3' )
% linkaxes( sp , 'x' )