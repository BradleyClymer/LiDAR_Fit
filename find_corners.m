median_order    = 40                                                    ;
current_med     = all_med( i_scan , : )                                 ;
cm              = current_med                                           ;
cm( isnan( cm ) ) = 0                                                   ;
lp              = [ 0 diff( sign( [ 0 diff( filtfilt( df , cm ) ) ] ) ) ];
top_peaks       = find( lp == -2 )                                        

evaluation      = false                                                 ;
if evaluation
    figure
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
    flat_spots      = [ 0 diff( ~[ 0 diff( medfilt2( cm , [ 1 , median_order ] )) ] ) ] ;
    
    
    plot( a , edge_sign+2 ,                         ...
        a , edged_out * edge_scale - 5,             ...
        a , cm * edge_scale - 8 ,                   ...
        a , lp-1 ,                                  ...
        a , st ,                                    ...
        'LineSmoothing' , 'on' )
    set( gca , 'XDir' , 'reverse' )
    hold on
    % scatter( big_changes , edged_out( big_changes ) )
    exes            = [ 200 -15.5 ]
    plot( [ exes( [ 1 1 ] ) nan exes( [ 2 2 ] ) ] ,                         ...
        [ -8 4 nan -8 4  ]                                                )
    set( h.corner , 'YData' , edged_out )               ;
    hold off
    grid on
    legend( { 'edge sign' , 'edged out ' , 'cm' , 'lowpass' , 'st' } , 'Location' , 'NorthEastOutside' )
end
