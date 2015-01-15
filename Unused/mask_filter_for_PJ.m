clc, close all hidden
raw                 = fliplr( all_scans )                           ;   % This just flips the matrix left-to-right for visualization
raw( isnan( raw ) ) = 0                                             ;   % Due to my processing artifacts, some NaNs must be removed
med                 = medfilt2( raw , [ 15 1 ] )                    ;   % 2d median filter; 15 scans in time, 1 position in angle
med_s               = med                                           ;
rad                 = 12                                            ;   % Number of points around bad mask to use in fit
bad_min             = 665                                           ;   % start of line
bad_max             = 677                                           ;   % end of line
fit_range        	= horzcat( ( bad_min - rad ) : ( bad_min - 1 ) ,...
                               ( bad_max + 1 )   : ( bad_max + rad ) )  % this is the range of good datapoints around our bad area
                                                                        % to fix; 12 below and 12 above
whole_range         = ( bad_min - rad ) : ( bad_max + rad )         ;                                                              
spoof_range         = bad_min-1 : bad_max+1                         	% these are the points we'll spoof with a polynomial
% spoof_range         = whole_range
num_scans           = size( raw , 1 )                               ;   % total number of scans
spoofed             = raw                                           ;

for i_scan = 1 : num_scans
    x_input                             = fit_range                                         ;
    y_input                             = med( i_scan , fit_range )                         ;
    p_new                            	= polyfit( x_input , y_input , 4 )               	;
    fit_data                            = polyval( p_new , spoof_range )                 	;
    spoofed( i_scan , spoof_range )     = fit_data                                          ;
    med_s( i_scan , spoof_range )       = fit_data                                          ;
end

% -----------------Algorithm ends here, the rest is just plotting

% close all
figure( 'Units' , 'Normalized' , 'OuterPosition' , [ 0.1 0.1 0.8 0.8 ] , 'NumberTitle' , 'off', 'Name' , urg_file )

hh( 1 )     = subplot( 221 )                                                ;
              imagesc( raw ) 
              colormap( 'bone' ) 
              title( 'Raw' )


hh( 2 )     = subplot( 222 )                                                ;
              imagesc( spoofed )
              colormap( 'bone' ) 
              title( 'Raw Data + Spoofed Line' )
              
hh( 3 )     = subplot( 223 )                                                ;
              imagesc( med )
              colormap( 'bone' ) 
              title( 'Median Filtered' )              

hh( 4 )     = subplot( 224 )                                                ;
              imagesc( med_s )
              colormap( 'bone' ) 
              title( 'Median Spoofed' )                            
 
              linkaxes( hh )
              drawnow