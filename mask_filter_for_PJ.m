clc
clear bounds
clear hh 
close all hidden

raw                 = fliplr( all_scans )                           ;   % This just flips the matrix left-to-right for visualization
raw( isnan( raw ) ) = 0                                             ;   % Due to my processing artifacts, some NaNs must be removed
raw( 3001 : end , : ) = []                                          ;
med                 = medfilt2( raw , [ 15 1 ] )                     ;   % 2d median filter; 15 scans in time, 1 position in angle
med_s               = med                                           ;
rad                 = 12                                            ;   % Number of points around bad mask to use in fit
bad_min             = 665                                           ;   % start of line
bad_max             = 677                                           ;   % end of line
fit_range        	= horzcat( ( bad_min - rad ) : ( bad_min - 1 ) ,    	...
                             ( bad_max + 1 ) : ( bad_max + rad ) )        	% this is the range of good datapoints around our bad area
                                                                        % to fix; ten below and ten above
whole_range         = ( bad_min - rad ) : ( bad_max + rad )         ;                                                              
spoof_range         = bad_min-1 : bad_max+1                         	% these are the points we'll spoof with a cubic spline
% spoof_range         = whole_range
num_scans           = size( raw , 1 )                               ;   % total number of scans
spoofed             = raw                                           ;
h_fit_fig           = figure( 'Units' , 'Normalized' , 'OuterPosition' , [ 0.1 0.1 0.8 0.8 ] , 'NumberTitle' , 'off', 'Name' , urg_file )
figure( h_fit_fig )
i_scan              = 30                                            ;
h_given_pts         = scatter( whole_range , raw( whole_range ) ) 
hold on
h_fit_line          = plot( whole_range , polyval( p_new , whole_range ) , 'r-' , 'LineSmoothing' , 'on'  )
drawnow
legend( { 'Points Fit To' ; 'Points Fitted' } )
grid on

% h_four_figs         = figure
% figure( h_four_figs )
for i_scan = 1 : num_scans
    x_input                             = fit_range                                         ;
    y_input                             = med( i_scan , fit_range )                         ;
    p_new                            	= polyfit( x_input , y_input , 4 )               	;
    fit_data                            = polyval( p_new , spoof_range )                 	;
    spoofed( i_scan , spoof_range )     = fit_data                                          ;
    med_s( i_scan , spoof_range )       = fit_data                                          ;
    if ~mod( i_scan , 100 )
        disp( ' ' )
        disp( i_scan )
        disp( fit_data )
        disp( raw( i_scan , spoof_range ) )
    end
%     set( h_given_pts , 'XData' , x_input , 'YData' , y_input )
%     set( h_fit_line , 'XData' , spoof_range , 'YData' , fit_data )
%     ylim( [ 15 21 ] )
%     drawnow
%     pause( 0.1 )
% return
end
% export_fig( 'Fit Function' )

% 
% deviations          = ( raw - med ) .^ 2                            ;   % Difference between median and raw, squared; this is a rough 
%                                                                         % look, an absolute value might work better if many of the differences
%                                                                         % are greater than 1
% trash_threshold     = 3                                             ;   % Empirically chosen garbage threshold
% trash               = deviations > trash_threshold                  ;   % Logical mask of garbage; throw these points out, or 
%                                                                         % replace with median values
% usable              = not( trash )                                  ;                                                                        
% 
% spoofed             = raw                                           ;
% spoofed( trash )    = med( trash )                                  ;   % our spoofed data retains the high frequency content of 
%                                                                         % the original data (mostly), but replaces garbage points
%                                                                         % with median-filtered values.

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
              title( 'Splined' )
              
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
%               export_fig( 'Complete Run' )
%               ylim( [ 8180 8190 ] )
%               xlim( [ 650 680 ] )
%               export_fig( 'Specific Problem Spot' )