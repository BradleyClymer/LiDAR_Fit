clc
if run_calculations
bounds( i_scan , : ).min 	= 0 - angle_offset                                                      ;
bounds( i_scan , : ).max	= 180 + angle_offset                                                    ;
fit_range( i_scan , : ) 	= ~isnan( all_med( i_scan , : ) ) &                                     ...
                                      angles_deg > bounds( i_scan , : ).min &                       ...
                                      angles_deg < bounds( i_scan , : ).max                         ;   % total angle range to fit

             
p( i_scan , : )                   = polyfit( angles_rad( fit_range( i_scan , : ) ) ,                ...
                                             all_med( i_scan , fit_range( i_scan , : ) ) ,          ...
                                             fit_order )                                            ;
vertex( i_scan , : )              = calc_vertex( p( i_scan , : ) )                                  ;                       
quad_fit                                                                                                % parabolic fit
min_fit                 = vertex( i_scan, 2 )                                                       ;   
fit_new_deg             = vertex( i_scan, 1 ) - 90                                                  ;   % mean( all_angles( fit_curve == min_fit ) ) + 0*pi/2           ;       
par_rec                 = circshift( par_rec , [ -1 0 ] )                                           ;
par_rec( end , : )      = CircleFitByTaubin( [  all_x_med( i_scan , fit_range( i_scan , : ) )'      ...
                                                all_y_med( i_scan , fit_range( i_scan , : ) )' ] )	; % [ x y R ] output
par( i_scan, : )        = sum( par_rec .* filter_mat )                                              ;
                          axes( h.scan )                                                            ;

x_scan( i_scan , : )    = all_x_med( i_scan , : ) - par( i_scan, 1 )                                ;
y_scan( i_scan , : )    = all_y_med( i_scan , : ) - par( i_scan, 2 ) + pipe_in - par( i_scan ,3)    ;
out_c( i_scan , : )     = ( ( x_scan( i_scan , : ) ) .^2 + ( y_scan( i_scan, : ) ) .^2 ) .^0.5      ;
diff_c( i_scan , : )    = out_c( i_scan , : ) - pipe_in                                             ;
pos_patch               = sign( diff_c( i_scan , : ) ) > 0                                          ;
% figure( 4 )
diff_locs               = diff( [ pos_patch( 1 ) , pos_patch ] )                                    ;
starts                  = diff_locs == 1                                                            ;
start_inds              = find( starts )                                                            ;
ends                    = diff_locs == -1                                                           ;
end_inds                = find( ends )                                                              ;
                        [ diff_c( i_scan , : )' ( 1 : 1081 )' ]                                     ;
valid_inds              = ( end_inds - start_inds > 2 )                                             ;
diff_inds               = vertcat( start_inds( valid_inds ) , end_inds( valid_inds ) )              ;
diffs                   = diff( diff_inds )                                                         ;
% diff_inds( [ diffs < 2 ; diffs < 2 ] ) = []
m                       = max( diffs )                                                              ;
[ shape_x , shape_y ]   = deal( nan( 2*( m + 1 ) , numel( diffs ) ) )                               ;

for i_shape = 1 : numel( diffs )
    shape_x( 1 : ( 2*( diffs( i_shape )+1 ) ) , i_shape ) = vertcat( x_scan( i_scan, ( diff_inds( 1 , i_shape ) : diff_inds( 2 , i_shape ) ) )' ,    ...
                                                                     fliplr( circle_template.x( diff_inds( 1 , i_shape ) : diff_inds( 2 , i_shape ) )' ) ) 
    shape_y( 1 : ( 2*( diffs( i_shape )+1 ) ) , i_shape ) = vertcat( y_scan( i_scan, ( diff_inds( 1 , i_shape ) : diff_inds( 2 , i_shape ) ) )' ,    ...
                                                                     fliplr( circle_template.y( diff_inds( 1 , i_shape ) : diff_inds( 2 , i_shape ) )' ) )
end
% shape_x 
% fun                     = @( s , e , m ) vertcat( linspace( e , s , e - s + 1 )' , nan( m - e + s , 1 ) )
% m = 10
% bsxfun( fun , start_inds , end_inds )
% fun( start_inds , end_inds )
% diff_c( i_scan , find( starts ) : find( ends ) )'
% plot( [ ( pos_patch' + 0.2 ) , ( diff_locs' - 0.0 ) , ( starts' -0.6 ) , ( ends' - 0.8 )  ] , 'LineSmoothing' , 'on' )
% legend( { 'pos patch' , 'diff locs' , 'starts' , 'ends' } )

% patch_x_cart            = [ x_scan( i_scan , pos_patch ) fliplr( inner_ring_x( pos_patch ) ) ]      ;
% patch_y_cart            = [ y_scan( i_scan , pos_patch ) fliplr( inner_ring_y( pos_patch ) ) ]      ;
patch_x_cart            = shape_x      ;
patch_y_cart            = shape_y      ;
fit_title{ i_scan }     = sprintf( [ 'Fit Polynomial: %0.3f*\\theta^2 + %0.2f*\\theta + %0.2f'      ...
                                     ' -- Vertex: %0.2f°, %0.2f"' ] ,                                 ...
                                     p( i_scan , : ) , vertex( i_scan , : ) - [ 90 0 ] )            ;
                                 
yes_angles              = angles_deg( fit_range( i_scan , : ) )                                     ;
patch_x                 = reshape( [ nan( 1 , numel( yes_angles ) ) ;                               ...
                                                     yes_angles ;                                   ...
                                                     yes_angles ] ,                                 ...
                                    1 , [] )                                                        ;
                                
patch_y                 = repmat( [ nan 0 2 ] , 1 , numel( yes_angles )  )                          ;
patch_z                 = -1 * ones( size( patch_y ) )                                              ;
end

if disp_plots
	update_plots
end                