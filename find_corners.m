median_order    = 40                                                    ;
current_med     = all_med( i_scan , : )                                 ;
cm              = current_med                                           ;
cm( isnan( cm ) ) = 0                                                   ;
lp              = [ 0 diff( sign( [ 0 diff( filtfilt( df , cm ) ) ] ) ) ];

% top_peaks       = find( lp == -2 )   
% top_peaks       = find( lp )
% top_peaks       = find( lp == 2 ) 
med_tol         = 3                                                     ;
double_median   = [ diff( medfilt2( [ stdfilt( diff( diff( lp ) ) ,     ...
                                               ones( 1 , med_tol )  	...
                                             ) 0 0                      ...
                                    ] ,                                 ...
                                    [ 1 2*med_tol ]                     ...
                                  )                                     ...
                         ) 0                                            ...
                  ]                                                     ;
              
lp_dm           = ( lp < 0 ) & ( double_median < 0 )                    ;
lpdm_locs     	= find( lp_dm )                                         ;
top_peaks     	= lpdm_locs( [ 2 , end-1 ] )                            ;
evaluation      = false                                                 ;

if evaluation
    close all
    if ( ~isfield( h , 'corner_fig' ) || ~ishandle( h.corner_fig ) )
        h.corner_fig  = figure( 'Units' , 'Normalized' , 'OuterPosition' , [ 0.2 0.2 0.8 0.8 ] )
    end
    edged_out       = medfilt2( current_med , [ 1 , median_order ] )        ;   % get rid of noise
    edge_diff       = [ 0 diff( edged_out ) ]                               ;   % get slopes
    edge_sign       = sign( edge_diff )                                     ;   % get sign of slopes 
    sign_diff       = [ 0 diff( edge_sign ) ]                               ;
    flat            = ( edge_sign == 0 ) & ( sign_diff == 0 )           	;
    a               = angles_deg                                            ;
    edge_sign( isnan( edge_sign ) ) = 0                                     ;
    sign_sum        = cumsum( edge_sign )                                   ;
    edge_scale      = 3 / max( edged_out )                                  ;
    sign_scale      = 3 / max( sign_sum )                                   ;
    raw_sum         = cumsum( cm )                                          ;
    xc              = xcorr( sign_sum , sign_sum )                          ;
    st              = stdfilt( lp , ones( 1 , 127 ) )                       ;
    flat_spots      = [ 0 diff( ~[ 0 diff( medfilt2( cm , [ 1 , median_order ] ) ) ] ) ] ;
    med_tol         = 3                                                     ;
    double_median   = [ diff( medfilt2( [ stdfilt( diff( diff( lp ) )  ,    ...
                        ones( 1 , med_tol ) ) 0 0 ]  , [ 1 2*med_tol ] ) ) 0 ]
    single_median   = [ medfilt2( [ stdfilt( diff( diff( edged_out ) ) ,    ...
                        ones( 1 , med_tol ) ) 0 0 ]  , [ 1 2*med_tol ] ) ]
    med_thresh      = 5 * std( double_median )                              ;
    doub_thresh     = double_median > med_thresh                            ;
    log_con         = stdfilt( ( ones( 1 , 2161 ) ./ ( 1 + stdfilt( ( xcorr( flat_spots*1 , double_median ) .^ 4 ) , ones( 1 , med_tol ) ) ) ) .^ 3 , ones( 1 , med_tol ) )              ;
    lp_dm           = ( lp < 0 ) & ( double_median < 0 )                                ;
    figure( 'Units' , 'Normalized' , 'OuterPosition' , [ 1.2 0.2 0.8 0.8 ] ) , plot( log_con , 'LineSmoothing' , 'on' )
    figure( h.corner_fig )
    plot( a , edge_sign+2 ,                         ...
          a , edged_out * edge_scale - 5,           ...
          a , cm * edge_scale - 8 ,              	...
          a , lp-1 ,                             	...
          a , st *2  ,                             	...
          a , 1*double_median ,                   	...
          a , log_con( 1 : 2 : end )*1 - 4 ,     	...
          a , lp_dm ,                               ...
        'LineSmoothing' , 'on' )
    set( gca , 'XDir' , 'reverse' ) 
    hold on
    % scatter( big_changes , edged_out( big_changes ) )
%     exes            = minmax( a( top_peaks( [ 2 , end-1 ] ) ) )                             ;
    lpdm_locs     	= a( lp_dm )                                                            ;
    exes            = lpdm_locs( [ 1 , end ] )                                            ;
    h.bound_markers = plot( [ exes( [ 1 1 ] ) nan exes( [ 2 2 ] ) ] ,                         ...
                              [ -8 4 nan -8 4  ] , '-or' , 'LineWidth' , 5 , 'LineSmoothing' , 'on' )
%     set( h.corner , 'YData' , edged_out )               ;
    hold off
%     grid on
    legend( { 'edge sign' , 'median filt' , 'curr med' , 'lowpass DSD' , 'st' , 'double median' , 'log con' , 'lp & dm' } , 'Location' , 'NorthEastOutside' )
    ylim( [ -9 4 ] )
end
