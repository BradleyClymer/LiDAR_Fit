clc
if run_calculations
bounds( i_scan , : ).min 	= 0 - angle_offset                                                      ;
bounds( i_scan , : ).max	= 180 + angle_offset                                                    ;
fit_range( i_scan , : ) 	= ~isnan( all_med( i_scan , : ) ) &                                     ...
                                      angles_deg > bounds( i_scan , : ).min &                       ...
                                      angles_deg < bounds( i_scan , : ).max                         ;   % total angle range to fit

% clear p vertex           
p( i_scan , : )                   = polyfit( angles_rad( fit_range( i_scan , : ) ) ,                ...
                                             all_med( i_scan , fit_range( i_scan , : ) ) ,          ...
                                             fit_order )                                            ;
vertex( i_scan , : )              = calc_vertex( p( i_scan , : ) )                                  ;                       
quad_fit                                                                                                % parabolic fit
min_fit                 = vertex( i_scan, 2 )                                                       ;   
fit_new_deg             = vertex( i_scan, 1 ) - 90                                                  ;   % mean( all_angles( fit_curve == min_fit ) ) + 0*pi/2           ;       
par_rec                 = circshift( par_rec , [ -1 0 ] )                                           ;
curr_fit_range          = fit_range( i_scan , : )                                                   ;

if fit_to_all
    curr_fit_range =  true( size( curr_fit_range ) )                                                ;
end

par_rec( end , : )      = CircleFitByTaubin( [  all_x_med( i_scan , curr_fit_range )'               ...
                                                all_y_med( i_scan , curr_fit_range )' ] )           ;   % [ x y R ] output
par( i_scan, : )        = sum( par_rec .* filter_mat )                                              ;
                          axes( h.scan )                                                            ;

x_scan( i_scan , : )    = all_x_med( i_scan , : ) - par( i_scan , 1 )                               ;%- par( i_scan, 1 )                                ;
y_scan( i_scan , : )    = all_y_med( i_scan , : ) - par( i_scan , 2 ) + pipe_in - par( i_scan ,3)	;
sign_correction         = 180 * ( x_scan( i_scan , : ) < 0 )                                        ;
out_c( i_scan , : )     = ( ( x_scan( i_scan , : ) ) .^2 + ( y_scan( i_scan, : ) ) .^2 ) .^0.5      ;
out_t( i_scan , : )     = atand( ( y_scan( i_scan, : ) ) ./ ( x_scan( i_scan , : ) ) ) +            ...
                          sign_correction                                                           ;
d_t                     = diff( vertcat( circshift( out_t( i_scan , : ) , +1 , 2 ) ,              	...
                                         circshift( out_t( i_scan , : ) , -1 , 2 ) ) ) / 360        ;                
diff_c( i_scan , : )    = out_c( i_scan , : ) - pipe_in                                             ;
pos_patch               = [ 0 sign( diff_c( i_scan , 2 : ( end ) ) ) ] > 0                          ;
pos_patch( end )        = 0                                                                         ;
diff_locs               = diff( [ pos_patch( 1 ) , pos_patch ] )                                    ;
starts                  = ( pos_patch & ~circshift( pos_patch , 1 , 2 ) )                           ;
ends                    = ( pos_patch & ~circshift( pos_patch , -1 , 2 ) )                          ;
start_inds              = find( starts ) +0                                                         ;
end_inds                = find( ends ) -0                                                           ;

valid_inds              = ( end_inds - start_inds ) > 0                                             ;
diff_inds               = vertcat( start_inds( valid_inds ) , end_inds( valid_inds ) )              ;
valid_inds              = diff_inds > 0                                                             ;
diffs                   = diff( diff_inds )                                                         ;
m                       = max( diffs )                                                              ;
[ shape_x , shape_y ]   = deal( nan( 2*( m + 1 ) , numel( diffs ) ) )                               ;
corrosion( i_scan )     = nansum( .5 * d_t(          pos_patch ) .*                                 ...
                            	(    out_c( i_scan , pos_patch ) .^2 - pipe_in_sq ) )               ;
corr_bounds           	= [ max( i_scan-30 , 1 ) , min( i_scan+30 , numel( corrosion ) ) ]       	;
corr_range              = corr_bounds( 1 ) : round( corr_bounds( 2 ) - 5 )                          ;
% cmap                    = flipud( jet( numel( diffs ) ) )                                           ;
% current_ticks           = get( h.corrosion , 'XTicks'

try
    delete( findobj( gca , 'type' , 'patch' ) )
    disp( 'Bottom Deleted.' )
catch
    disp( 'failed.' )
end 

for i_shape = 1 : numel( diffs )
    shape_x( 1 : ( 2*( diffs( i_shape )+1 ) ) , i_shape ) =     vertcat( x_scan( i_scan, ( diff_inds( 1 , i_shape ) : diff_inds( 2 , i_shape ) ) )' ,                   ...
                                                            flipud( cosd( out_t( i_scan, ( diff_inds( 1 , i_shape ) : diff_inds( 2 , i_shape ) ) )' ) ) * pipe_in )     ;
    shape_y( 1 : ( 2*( diffs( i_shape )+1 ) ) , i_shape ) =     vertcat( y_scan( i_scan, ( diff_inds( 1 , i_shape ) : diff_inds( 2 , i_shape ) ) )' ,                   ...            
                                                            flipud( sind( out_t( i_scan, ( diff_inds( 1 , i_shape ) : diff_inds( 2 , i_shape ) ) )' ) ) * pipe_in )     ;
    if disp_plots
	p_s( i_shape )                                        = patch( shape_x( 1 : ( 2*( diffs( i_shape )+1 ) ) , i_shape ) ,                                              ...
                                                                   shape_y( 1 : ( 2*( diffs( i_shape )+1 ) ) , i_shape ) , [ 1 0 0 ] , 'EdgeColor' , 'none' )           ;
    end
end

fit_title{ i_scan }     = sprintf( fit_title_string ,                                                   ...
                                     p( i_scan , : ) , vertex( i_scan , : ) - [ 90 0 ] )                ;
end                     