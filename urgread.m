clc
close all hidden
colordef black
% clear ipd_struct
clear
profile off
% urg_file        = 'test.ubh'
old_folder      = pwd 
data_folder     = 'C:\Users\bclymer\Downloads'
data_folder     = 'P:\Dropbox (Future Scan)\Flyswatter (1)\Testing'
% data_folder     = old_folder

%%  Input Parsing Block. 
%   Asks for UrgBenri file, passes it to the file pre-processor, 
%   'urg_struct_read'. This returns a struct containing date
%   in text format and serial date number, the 1x1081 scan itself, the 
%   header information, and a single date vector.
%
%   After that is returned, an IPD file is prompted. This is the timestamp
%   from DPM, which is used to correlate URG time with transporter
%   distance.

if ~exist( 'urg_file' , 'var' )
    cd( data_folder )
    [ fn , pn ]	= uigetfile( '*.ubh' , 'Select UrgBenri LiDAR data file' )                  ;
    urg_file    = fullfile( pn , fn )                                                       ;
    fprintf( 'Urg file is:\n\t\t%s' , urg_file )
end
                  fclose( 'all' )                                                           ;
fid             = fopen( urg_file )                                                         ;

if ~exist( 'urg_struct' , 'var' ) 
    disp( 'Reading Raw UrgBenri File' )                                                     
    cd( old_folder )                                                                        ;
    urg_struct      = urg_struct_read( fid )                                                ;

end
% 
if ~exist( 'ipd_file' , 'var' )
    cd( data_folder )
    [ fu , pu , iu ]	= uigetfile( fullfile( pn , '*.ipd' ) , 'Select HD index file' )    ;
    ipd_file            = fullfile( pu , fu )                                               ;
    fprintf( 'IPD file is:\n\t\t%s' , ipd_file )                        
end

if fu
    ipd_fid         = fopen( ipd_file )
    
    if ~exist( 'ipd_struct' , 'var' )
        disp( 'Reading Raw IPD File' )
        cd( old_folder )
        ipd_struct   = ipd_reader( ipd_file , urg_struct( 1 ).date_vec )
        disp( 'Raw IPD file has been read' )
    end
else
    spoofed.ft  = ( 0 : ( numel( urg_struct ) -1 ) ) / 80                   ;
    ipd_struct	= struct( 'ft' ,  spoofed.ft  , 'clock' , [ urg_struct.timeStamp ] , 'num_scans' , size( urg_struct , 1 ) )	;
    disp( 'IPD struct spoofed.' )
    cd( old_folder )
end

                  fclose( 'all' )

%%  Time and Distance correlation
%   In this block, the timestamp in the urg file is correlated with that in
%   the IPD file, from which an index is produced which generates a
%   distance for each URG scan. The match is found in a least-squares
%   sense. 

urg_ts          = [ urg_struct.timeStamp ]'                                 ;
ipd_ts          = [ ipd_struct.clock ]                                      ;
disp( 'Matching distance indeces' )                             

%   For a single value of the urg timestamp - 'urg_ts( i )' - subtract it
%   from the IPD timestamp at all values. 

for i = 1 : numel( urg_ts )
    abs_diff        = ( ipd_ts - urg_ts( i ) ) .^2                          ;
    ipd_index( i )  = mean( find( abs_diff == min( abs_diff ) , 1 ) )       ;
end 

urg_ft              = ipd_struct.ft( ipd_index )                            ;
figure
h.urg_distance      = plot( urg_ts - min( urg_ts ) , urg_ft ,               ...
                            'LineSmoothing' , 'on' ,                        ...
                            'LineWidth' , 3 )                               ;
title( urg_struct( 1 ).dateString )
xt                  = get( get( h.urg_distance , 'Parent' ) , 'XTick' )     ;
xtl                 = datestr( xt , 'MM:SS' )                               ;
set( get( h.urg_distance , 'Parent' ) , 'XTickLabel' , xtl )                ;
xlabel( 'Time, minutes:seconds' )
ylabel( 'Distance, feet ' )
axis tight
grid on
force_filter_gen    = false                                                 ;

%%  Generate or load low-pass FIR filter for corner detection.
%   Low-pass filtering an individual scan takes out almost all features,
%   except the hard corner where water reflection begins. 

if ~exist( 'df.mat' , 'file' ) || force_filter_gen
disp( 'Generating Spacial Filter' )
df               = designfilt(   'lowpassfir' ,                             ...
                                 'DesignMethod' ,           'equiripple' ,	...
                                 'PassbandFrequency' ,       0.15 ,         ...
                                 'StopbandFrequency' ,       0.2 ,          ...
                                 'PassbandRipple' ,          1 ,            ...
                                 'StopbandAttenuation' ,     60 ,           ...
                                 'SampleRate' ,              9 )            ;
else
    load( 'df.mat' ) 
end

%%  Constants and settings
%   Here we set overall parameters for the processing. 

plot_parabola   = true                                                      ;
run_calculations= true                                                      ;
disp_plots      = true                                                      ;
fit_order    	= 6                                                         ;  
add_legends     = false                                                     ;
find_edges      = false                                                     ;

mm_conversion   = 1 / 25.4                                                  ;   % 1mm in inches

angles_deg  	= linspace( -45 , 225 , numel( urg_struct( 1 ).scan ) )     ;   % angles of LiDAR scan, in as many
                                                                                % points as one scan has                                                                             
x_weight        = cosd( angles_deg )                                        ;   % pre-calculate the weights of the angles
y_weight        = sind( angles_deg )                                        ;

angles_rad      = angles_deg  * pi / 180                                    ;   % -45 : 225 in radians
angle_offset    = +30                                                       ;

pipe_diameter   = 24.9                                                      ;
float_width     = 13                                                        ;
pipe_in         = pipe_diameter / 2                                         ;   % pipe radius in inches
pipe_in_sq      = pipe_in ^ 2                                               ;
accepted_diff   = .025 * pipe_diameter                                      ;   % inches

pipe_mm         = pipe_in / mm_conversion                                   ;   %  '      '     '  mm
inner_tol       = .95 * pipe_in                                             ;
mm_rad          = pipe_mm / 2                                               ;   % pipe radius in mm
vertex( 1 )     = 90                                                        ;
vertex( 2 )     = pipe_in                                                   ;


filter_order    = 5                                                        ;   % order of the median filter
filter_roll     = -3                                                         ;   % filter roll-off rate
filter_raw      = exp( filter_roll * ( filter_order : -1 : 1 )' /filter_order  )       ;   % generate some filter coefficients
filter_new      = filter_raw / ( sum( filter_raw , 1 ) / 1 )                ;   % normalize coefficients
filter_mat      = repmat( filter_new , 1 , 3 )                              ;   % matrix of coefficients
min_rec         = zeros( numel( filter_order ) , 1 )                        ;   % initialize record of minima


%%  Begin pre-processing of data.
%   Nothing too novel. Remove scans with weird sizes first, initialize the
%   filter block - to smooth the motion of centering, not the FIR filter
%   above which finds corners in find_corners.m - as well as the curve
%   which gets fit to the data and the record of vertices 
struct_size_vec = cell2mat( arrayfun( @( x ) size( x.scan ) , urg_struct ,  ...
                           'UniformOutput' , false ) )                      ;   % size of scans. ex: 1081x1 
bad_scans       = struct_size_vec( : , 1 ) ~= 1081                          ;   % find non-conforming scans
urg_struct( bad_scans ) = []                                                ;   % remove bad scans
num_scans       = size( urg_struct , 1  )                                   ;

%   initialize stuff
p               = zeros( num_scans , fit_order+1  )         ;
fit_curve       = zeros( num_scans, 1081 )                  ;
vertex          = zeros( num_scans, 2 )                     ;
fit_range       = false( num_scans, 1081 )                  ;


%%  Median filtering, outlier removal, geometric pre-pro
%   Since the data is served up in vectors which always represent the same
%   angles, a vector of the cosines of the corresponding angles gives the
%   point-by-point weight of each value in the vector on the abscissa.
%   Likewise, a vector of the sines of ( -45 : 0.25 : 225 ) gives the
%   weight of each data vector in the ordinate axis. Here we have opted to
%   pre-process the whole input data matrix by using repmat on the weight
%   vectors, thereby taking advantage of MATLAB's often-faster-than-raw-C
%   elementwise matrix multiplication speed, and cutdown on overhead during
%   display.
%
%   In addition, here we strip out the noisy data points out at 60000mm ,
%   and too far away to make sense. We also find the "initial offset," a
%   guess of where the top of the pipe is from the middle 51 points of the
%   input data.
if ~exist( 'all_x_med' , 'var' )
    disp( 'Pre-Processing Data' )
    all_x_weight    = repmat( x_weight , num_scans , 1 )                        ;   % cos( -45 : 0.25 : 225 )
    all_y_weight    = repmat( y_weight , num_scans , 1 )                        ;   % sin(  '      '     '  )
    sz              = size( all_x_weight )                                      ;   
	raw_data        = double( horzcat( urg_struct.scan )' )                     ;
    infs            = ( raw_data == 60000 )                                     ;
    fars            = ( raw_data > ( 2 * pipe_diameter / mm_conversion ) )      ; 
    raw_data( infs )= 0                                                         ;
    raw_data( fars )= 0                                                         ;
    middle_halo     = ( -20 : 20 ) + 1082/2                                     ;
    initial_offset  = median( median( raw_data( : , middle_halo ) ) ) *         ...
                      mm_conversion                                             ;
	angle_mat       = repmat( angles_rad , sz( 1 ) , 1 )                        ;
    disp( 'Converting to Polar' )
    [ x_s , y_s ]   = pol2cart( angle_mat , raw_data )                          ;
    disp( 'Estimating pipe fit' )
    circle.x        = pipe_in * x_weight                                        ;
    circle.y        = pipe_in * y_weight                                        ;
    data.x          = x_s * mm_conversion                                       ;
    data.y          = y_s * mm_conversion - initial_offset + pipe_in            ;
    data.r          = sqrt( data.x .^2 + data.y .^2 )                           ;
    data.noise      = abs( data.r - pipe_in ) > ( .2 * pipe_in )                ; 
    all_scans       = double( raw_data ) * mm_conversion                        ;
    disp( 'De-noising' )
    
    nan_value       = 60000 * mm_conversion                                     ;
    all_scans( infs )= nan_value                                                ;
    all_scans( fars )= nan_value                                                ;
    all_scans( all_scans == 0 ) = nan_value                                  	;
    
    all_x_raw       = all_scans .* all_x_weight                                 ;
    all_y_raw       = all_scans .* all_y_weight                                 ;
    med_rad         = 7                                                         ;
    med_range       = -med_rad : med_rad                                        ;
    disp( 'Median Filtering Data (longest portion of pre-processing)' )          
    all_med         = medfilt2( all_scans , [ 2 * med_rad + 1 , 1 ] )           ;
    disp( 'Median Filtering Complete.' )
    all_med( all_med == nan_value ) = nan                                       ;
    all_scans( all_scans == nan_value ) = nan                                   ;
%     all_med( data.noise ) = nan                                           	;
    all_x_med       = all_med .* all_x_weight                                   ;
    all_y_med       = all_med .* all_y_weight                                   ;
    x_guess         = mean( nanmedian( data.x ) )                               ;
    y_guess         = initial_offset - pipe_in                                  ;
    R_guess         = pipe_in                                                   ;
    par_rec         = repmat( [ x_guess y_guess R_guess ] ,                     ...
                      size( filter_mat , 1 ) , 1 )                              ;   % initialize record of circle parameters
    
    disp( 'Calculating Quantiles for Y-Limits' )
    quant_tol       = 0.2  
    if ~exist( 'quants' , 'var' )
        quants   	= quantile( all_scans( : ) , [ quant_tol 1-quant_tol ] )
    end
    disp( 'Pre-Processing of LiDAR Data Complete' )    
end

z_grid      = meshgrid( 1:size( all_x_med , 1 ) , 1:size( all_x_med , 2 ) )' 	;

h.singlefig = figure( 'NumberTitle' , 'off' , 'Name' , 'Fit of Lidar to Pipe' )
    h.scan      = subplot( 1 , 4 , 1:3 )
        hold on  
        med_scan    = nanmedian( all_scans )                                            ;
        set( gca , 'Color' , [0.0500    0.0750    0.0750] )                        
        hold on 
        h.fit_p     = plot( 0 , 0 , 'w' , 'LineSmoothing' , 'on' , 'LineWidth' , 2 )	;
        h.circle    = plot( 0 , 0 , 'y' , 'LineSmoothing' , 'on' , 'LineWidth' , 2 ,    ...
                                          'Marker' , '.' , 'LineStyle' , 'none' )       ;
                                      
        circle_template.x     = pipe_in * x_weight                                      ;
        circle_template.y     = pipe_in * y_weight                                      ;
        h.template  = plot( circle_template.x ,                                         ...
                            circle_template.y ,                                         ...
                            'Color' , 0.6 * [ 1 1 1 ] ,                                 ...
                            'LineStyle' , '.' ,                                         ...
                            'LineSmoothing' , 'on' ,                                    ...
                            'LineWidth' , 2 ,                                           ...
                            'Marker' , 'none' ,                                        	...
                            'LineStyle' , '-' )                                         ;
        plot( 100 * [ -1 1 ] , [ 0 0 ] , 'Color' , [ 0 0 1 ] , 'LineSmoothing' , 'on' )
        plot( [ 0 0 ] , 100 * [ -1 1 ] , 'Color' , [ 0 0 1 ] , 'LineSmoothing' , 'on' )
        axis equal
        grid on
        xlabel( 'Inches' )
        ylabel( 'Inches' )
        file_title  = urg_file                  ;
        % file_title( file_title == '_' ) = '-'   ;
        strrep( file_title , '\' , '\\' )
        title( file_title  )

        set( gcf, 'Units' , 'Normalized' , 'Numbertitle' , 'Off' , 'Name' , [ 'Fit of Lidar to Pipe ' urg_file ] )
        xlim( 1.2 * pipe_in * [ -1 1 ] + [ -2 2 ] )
        ylim_offset                                     = 1
        ylim( pipe_in * [ -1 1 ] + ylim_offset )
        if add_legends

        legend( { 'Raw Noisy Data' ,            ...
                  'Median Filtered' ,           ...
                  'Shifted',                    ...
                  'Pipe Fit' ,                  ...
                  'Pipe Template' } ,           ...
                  'Location' ,                  ...
                  'Best' )          ;
        end
        
    h.fit       = subplot( 2 , 4 , 4 )                                                  ;
        h.bad_filt  = plot( 0 , 0 , 'bx' ,	'LineSmoothing' , 'on' ,                 	...
                                            'MarkerSize' , 3 ,                          ...
                                            'LineWidth' , 2 )                           ;     
                      set( h.bad_filt ,     'MarkerEdgeColor' , 1/255 * [ 119 136 193 ] ...
                                      ,     'MarkerFaceColor' , 1/255 * [ 198 226 255 ] )
        hold on                              
        h.red_filt 	= plot( 0 , 0 , 'r+' , 	'LineSmoothing' , 'on' ,                 	...
                                            'MarkerSize' , 3 ,                          ...
                                            'LineWidth' , 2 )                           ;
                      set( h.red_filt ,     'MarkerEdgeColor' , 1/255 * [ 255 54 64 ]   ...
                                      ,     'MarkerFaceColor' , 1/395 * [ 139 35 35 ] )



        hold on 
        h.parab     = plot( 0 , 0 , 'y' , 'LineSmoothing' , 'on' , 'LineWidth' , 2 )    ;
%         h.corner    = plot( angles_deg , pipe_diameter / 2 * ones( 1 , 1081 ) , 'g' ,   ...
%                                           'LineSmoothing' , 'on' , 'LineWidth' , 2 )    ;
        set( gca , 'Color' , [0.0500    0.0750    0.0750] )

        h.fit_axes  = ancestor( h.red_filt , 'Axes' )                                   ;
        h.min_mark  = scatter( 0 , 0 , 'o', 'MarkerEdgeColor' , 'b' ,                   ...
                                            'MarkerFaceColor' , [ 0 0.5 0.5 ] ,         ...
                                            'LineWidth' , 3 )                           ;

        h.bounds    = plot( [ 0         0       nan     180     180 ] ,                 ...
                            [ -100  	100 	nan     -100  	100        ] )          ;
        set( h.fit , 'XDir' , 'reverse' )                                
      	set( h.fit , 'YLim' , [ 0 pipe_diameter ] )
        % axis equal
        grid on
        xlabel( '\theta, Degrees, -45 : 225' )
        ylabel( '\rho, Inches' )
        set( gcf, 'Units' , 'Normalized' )
        xlim( [ -45 225 ] )
        disp( 'Quantiles Calculated.' )
        % ylim( quants + [ -0.5 0.5 ] )
        ylim( [ 8 ( pipe_diameter - ( float_width/2 ) ) ] )
        % all_args        = { all_x , all_y , z_grid , 'EdgeColor' , 'none' }         ;
        set( h.fit_axes , 'XTick' , -60 : 30 : 255 )
        set( h.singlefig , 'OuterPosition' , [ 1.014    0.1037    0.8708    1.0000 ] )
        if add_legends
        legend( { 'Included Points' , 'Excluded Points' , 'Parabolic Fit Curve' , 'Parabola Vertex' } )
        end

        drawnow
        last_time       = tic                                                       ;
        ifp             = urg_struct(1).header.scanMsec * 1e-3                      ;
        num_scans       = numel( urg_struct )                                       ;
        fixed_scan      = 79770  
        generate_polynomial_title
        
h.corrosion         = subplot( 2 , 4 , 8 )                                          ;
    h.corr              = plot( 1 , 1 , 'Color' , 'r' , 'LineSmoothing' , 'on' , 'MarkerFaceColor' , [ 1 .8 .8 ] , 'MarkerEdgeColor' , 'none' , 'LineStyle' , '-' , 'Marker' , 'o' , 'LineWidth' , 3 )     ;
    ylim( [ 0 8 ] )
    grid on        
    title( 'Corrosion Area, in^2' )

    inner_ring_x            = pipe_in * x_weight                                        ;
    inner_ring_y            = pipe_in * y_weight                                        ;           
axes( h.scan )
    hold on

desired_scans   = 1 : size( all_scans , 1 )                                     	;
parab_order     = 2                                                                     ;
fit_to_all      = false                                                                 ;
minmax          = @( x ) [ min( x( : ) ) max( x( : ) ) ]                                ;
time_format     = 'yyyy-mm-dd, HH:MM:SS.FFF'
toggle( h.circle ) 
for i_scan = desired_scans
        urg_struct( i_scan ).timeStamp
        raw_scan 	= all_scans( i_scan , : )                               	;
        try
        pipe_fit                                                                ;
        title( sprintf( '%s\nScan %d of %d, %0.2f ft \nAverage Diameter: %0.2fin',   ...
               datestr( urg_struct( i_scan ).timeStamp , time_format ) ,            ...
               i_scan ,                                                             ...
               num_scans ,                                                          ...
               urg_ft( i_scan ) ,                                                   ...
               2*par( i_scan , 3 ) ) )                                            	;
        
        diam_rec( parab_order , i_scan )    = par( i_scan , 3 )                 ;
        
        if disp_plots
            drawnow
            update_plots
%             find_corners
        end
        
        catch big_loop_error
            disp( 'Kicked out.' )
            disp( big_loop_error )
%             pause
        end
end
save( 'distance_and_corrosion.mat' , 'urg_ft' , 'corrosion' )
% profile viewer