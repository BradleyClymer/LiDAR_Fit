
clear bounds
raw                 = fliplr( all_scans )                           ;   % This just flips the matrix left-to-right for visualization
raw( isnan( raw ) ) = 0                                             ;   % Due to my processing artifacts, some NaNs must be removed
med                 = medfilt2( raw , [ 3 1 ] )                     ;   % 2d median filter; three scans in time, 1 position in angle
deviations          = ( raw - med ) .^ 2                            ;   % Difference between median and raw, squared; this is a rough 
                                                                        % look, an absolute value might work better if many of the differences
                                                                        % are greater than 1
trash_threshold     = 3                                             ;   % Empirically chosen garbage threshold
trash               = deviations > trash_threshold                  ;   % Logical mask of garbage; throw these points out, or 
                                                                        % replace with median values
usable              = not( trash )                                  ;                                                                        

spoofed             = raw                                           ;
spoofed( trash )    = med( trash )                                  ;   % our spoofed data retains the high frequency content of 
                                                                        % the original data (mostly), but replaces garbage points
                                                                        % with median-filtered values.

% -----------------Algorithm ends here, the rest is just plotting

close all
figure( 'Units' , 'Normalized' , 'OuterPosition' , [ 0.1 0.1 0.8 0.8 ] , 'NumberTitle' , 'off', 'Name' , urg_file )

hh( 1 )     = subplot( 221 )                                                ;
              imagesc( raw ) 
              colormap( 'bone' ) 
              title( 'Raw' )


hh( 2 )     = subplot( 222 )                                                ;
              imagesc( med )
              colormap( 'bone' ) 
              title( 'Median Filtered' )
 
hh( 3 )     = subplot( 223 )                                                ;
              imagesc( deviations )
              colormap( 'bone' ) 
              title( 'Squared Difference' )
              set( gca , 'CLim' , [ 0 trash_threshold ] )

hh( 4 )     = subplot( 224 )                                                ;
              imagesc( trash )
              colormap( 'bone' ) 
              title( 'Binary Mask: Above Threshold' )
              
              tightfig
              set( gcf , 'OuterPosition' , [ 0.1 0.1 0.8 0.8 ] )
              
              linkaxes( hh )
              drawnow
              export_fig( 'Complete Run' )
              ylim( [ 8180 8190 ] )
              xlim( [ 650 680 ] )
              export_fig( 'Specific Problem Spot' )