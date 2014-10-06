clc
close all hidden
colordef black
profile off
old_folder      = pwd 
data_folder     = old_folder
data_folder     = 'P:\Dropbox (Future Scan)\Flyswatter (1)\DATA Flyswatter Project\tra_rjn_ef3_carrollton\1690E_1680E'

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

%   Quick interpolation of distance information; the ipd file's time
%   resolution is very coarse, so a cubic split is used to infer samples in
%   between. Result is far more smooth, and more accurate than a previously
%   tried 30-sample moving average.
tic
urg_ft              = spline( ipd_ts , ipd_struct.ft , urg_ts )             ;
toc
% tic
% uf                  = ipd_struct.ft( vector_nearest_match( ipd_ts , urg_ts ) )  ;
% toc
return
figure
h.urg_distance      = plot( urg_ts - min( urg_ts ) ,                        ...
                            urg_ft( 1 : numel( urg_ts ) ) ,                 ...
                            'LineSmoothing' , 'on' ,                        ...
                            'LineWidth' , 3 )                               ;
grid on                         
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
t_start         = tic                                                       ;

%%  Constants and settings
%   Here we set overall parameters for the processing. 

plot_parabola   = false                                                     ;
add_parab_fig   = false                                                     ;
run_calculations= true                                                      ;
disp_plots      = false                                                     ;
fit_order    	= 6                                                         ;  
add_legends     = false                                                     ;
find_edges      = false                                                     ;

mm_conversion   = 1 / 25.4                                                  ;   % 1mm in inches

% angles_deg  	= linspace( -45 , 225 , numel( urg_struct( 20 ).scan ) )    ;   % angles of LiDAR scan, in as many
                                                                                % points as one scan has  

% Angles_deg now mapped to a fixed 1081 points; this is because the size of a scan is unreliable, and produces unexpected results.                                                                                            
angles_deg      = linspace( -45 , 225 , 1081 )                              ;
x_weight        = cosd( angles_deg )                                        ;   % pre-calculate the weights of the angles
y_weight        = sind( angles_deg )                                        ;

angles_rad      = angles_deg  * pi / 180                                    ;   % -45 : 225 in radians
angle_offset    = +10                                                       ;

pipe_diameter   = 45                                                        ;
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
% struct_size_vec = cell2mat( arrayfun( @( x ) size( x.scan ) , urg_struct ,  ...
%                            'UniformOutput' , false ) )                      ;   % size of scans. ex: 1081x1 
% bad_scans       = struct_size_vec( : , 1 ) ~= 1081                          ;   % find non-conforming scans
% urg_struct( bad_scans ) = []                                                ;   % remove bad scans
% urg_struct( 501 : end ) = []                                                ;
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
%     [ x_s , y_s ]   = pol2cart( angle_mat , raw_data )                          ;
    disp( 'Estimating pipe fit' )
    circle.x        = pipe_in * x_weight                                        ;
    circle.y        = pipe_in * y_weight                                        ;
%     data.x          = x_s * mm_conversion                                       ;
%     data.y          = y_s * mm_conversion - initial_offset + pipe_in            ;
%     data.r          = sqrt( data.x .^2 + data.y .^2 )                           ;
%     data.noise      = abs( data.r - pipe_in ) > ( .2 * pipe_in )                ; 
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
    x_guess         = mean( nanmedian( all_x_raw ) )                            ;
    
    y_guess         = initial_offset - pipe_in                                  ;
    R_guess         = pipe_in                                                   ;
    par_rec         = repmat( [ x_guess y_guess R_guess ] ,                     ...
                      size( filter_mat , 1 ) , 1 )                              ;   % initialize record of circle parameters
    med_scan        = nanmedian( all_scans )                                	;
    x_scan          = zeros( size( all_x_med )  )                               ;
    y_scan          = zeros( size( all_y_med )  )                               ;
    out_c           = zeros( size( all_x_med )  )                               ;
    out_t           = zeros( size( all_x_med )  )                               ;
    fit_range       = true(  size( all_x_med )  )                               ;
    diff_c          = zeros( size( all_x_med )  )                               ;

    
    disp( 'Calculating Quantiles for Y-Limits' )
    quant_tol       = 0.2  
    if ~exist( 'quants' , 'var' )
        quants   	= quantile( all_scans( : ) , [ quant_tol 1-quant_tol ] )
    end
    clear data
    disp( 'Pre-Processing of LiDAR Data Complete' )    
end
clear fars fit_range infs %all_x_raw all_y_raw
%%  Visuals
%   Here we generate all of the initial figures which will be updated on
%   each cycle of the display. The long MATLAB figure and object generation
%   format has been moved to generate_initial_figures for conciseness. 

generate_initial_figures                                                                ;

desired_scans   = 800 : size( all_scans , 1 )                                           ;
% desired_scans   = 1000 : 1500                                                               ;
parab_order     = 2                                                                     ;
fit_to_all      = false                                                                 ;
minmax          = @( x ) [ min( x( : ) ) max( x( : ) ) ]                                ;
time_format     = 'yyyy-mm-dd, HH:MM:SS.FFF'
toggle( h.circle ) 
h.wait          = waitbar(0,'Processing scans') 
%%
for i_scan = desired_scans
        urg_struct( i_scan ).timeStamp
        raw_scan 	= all_scans( i_scan , : )                                           ;
        try
        pipe_fit                                                                        ;
        title( sprintf( [ '%s\nScan %d of %d, %0.2f ft \nAverage Diameter: %0.2fin',    ...
               '\nMaximum Corrosion: %0.2fin' ] ,                                       ...
               datestr( urg_struct( i_scan ).timeStamp , time_format ) ,                ...
               i_scan ,                                                                 ...
               num_scans ,                                                              ...
               urg_ft( i_scan ) ,                                                       ...
               2*par( i_scan , 3 ) ,                                                    ...
               max_corrosion( i_scan ) ) )                                              ;
        
        diam_rec( parab_order , i_scan )    = par( i_scan , 3 )                         ;
        
        if disp_plots
            drawnow
            update_plots
            if add_parab_fig
                separate_parabola_update
            end
            corrosion_history
            find_corners
        end
        
        catch big_loop_error
            disp( 'Kicked out.' )
            
            disp( big_loop_error )
            return
        end
        if ~mod( i_scan , 100 )
        progress_frac       = ( i_scan - min( desired_scans ) ) / numel( desired_scans )    ;
        time_so_far         = ( toc( t_start ) )                                            ;
        time_per_scan       = time_so_far / ( i_scan - min( desired_scans ) )               ;
        time_remain         = ( 1 - progress_frac ) * time_so_far / progress_frac           ;
        time_string         = sprintf( '%0.2f mins remain, %0.1f msec per scan ' ,       	...
                                          time_remain / 60 , time_per_scan * 100 )          ;
        waitbar( progress_frac , h.wait , time_string )
        end
        drawnow
end
%%  Saving of files

toc( t_start )
save( 'distance_and_corrosion.mat' , 'urg_ft' , 'corrosion' , 'max_ corrosion' )


%%  Final Figure Output
close all
figure( 'Units' , 'Normalized' , 'Position' , [ 0.31302      0.25278      0.38906      0.56852 ] )

sp( 1 ) = subplot( 211 ) 
plot( urg_ft , max_corrosion , '-r' , 'MarkerEdgeColor' , [ 0.9 0.1 0.1 ] , 'MarkerFaceColor' , [ 1 1 1 ] )
title( 'Max Corrosion by Foot' )
xlabel( 'Feet' )
ylabel( 'Inches' )
grid on
axis tight
ylim( [ 0 3 ] )

sp( 2 ) = subplot( 212 )
plot( urg_ft , corrosion , '-k' ) 
title( 'Corrosion Area by Foot'  )
xlabel( 'Feet' )
ylabel( 'Square Inches' )
grid on
axis tight
ylim( [ 0 3 ] )

linkaxes( sp , 'x' )

output_folder    	= 'P:\Dropbox (Future Scan)\Screenshots\Corrosion Pictures'     ;
these_indeces       = 1                                                             ;

for distance = 50 : 50 : urg_ft( end )
    last_indeces    = these_indeces                             ;
    difference      = abs( distance-urg_ft )                    ;
    these_indeces   = find( difference == min( difference ) )   ;
    start_index     = last_indeces( end )                       ;
    finish_index    = these_indeces( 1 )                        ;
    limits          = urg_ft( [ start_index finish_index ] )    ;
    axis tight
    xlim( limits )
    this_range      = start_index : finish_index                ;
    this_std( 1 )   = std( max_corrosion( this_range ) )        ;
    this_std( 2 )   = std( corrosion( this_range ) )            ;
    this_mean( 1 )  = mean( max_corrosion( this_range ) )       ;
    this_mean( 2 )  = mean( corrosion( this_range ) )           ;
    y_range( 1,: )  = this_mean( 1 ) + 5*this_std( 1 ) * [-0.5,1.2] ;
    y_range( 2,: )  = this_mean( 2 ) + 5*this_std( 2 ) * [-0.5,1.2] ;
    ylim( sp( 1 ) , y_range( 1 , : ) )                          ;
    ylim( sp( 2 ) , y_range( 2 , : ) )                          ;
    drawnow
    this_title      = sprintf( '%s Corrosion %0.0fft to %0.0fft' , fn( 1:(end-4) ) , limits( 1 ) , limits( 2 ) )
    this_file       = fullfile( output_folder , this_title )    ;
    export_fig( this_file , '-m2' , '-nocrop' , '-transparent' ) 
end