clc
close all hidden
colordef black
% clear
profile on
% urg_file        = 'test.ubh'
if ~exist( 'urg_file' , 'var' )
    [ fn , pn ]	= uigetfile( '*.ubh' , 'Select UrgBenri LiDAR data file' )
    urg_file    = fullfile( pn , fn )
end
                  fclose( 'all' )
fid             = fopen( urg_file )

if ~exist( 'urg_struct' , 'var' ) 
    disp( 'Reading Raw UrgBenri File' )
    urg_struct      = urg_struct_read( fid ) 
    disp( 'Raw File Read' )
end

plot_parabola   = true                                                      ;
run_calculations= true                                                      ;
disp_plots      = true                                                      ;
fit_order    	= 2                                                         ;  
add_legends     = false                                                     ;

mm_conversion   = 1 / 25.4                                                  ;   % 1mm in inches

angles_deg  	= linspace( -45 , 225 , numel( urg_struct( 1 ).scan ) )     ;   % angles of LiDAR scan, in as many
                                                                                % points as one scan has                                                                             
x_weight        = cosd( angles_deg )                                        ;   % pre-calculate the weights of the angles
y_weight        = sind( angles_deg )                                        ;

% bounds( i_scan ).min      = 0                                             ;
% bounds.max      = 180                                                     ;

angles_rad      = angles_deg  * pi / 180                                    ;   % -45 : 225 in radians
angle_offset    = +20                                                       ;

pipe_diameter   = 26                                                        ;
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
struct_size_vec = cell2mat( arrayfun( @( x ) size( x.scan ) , urg_struct ,  ...
                           'UniformOutput' , false ) )                      ;   % size of scans. ex: 1081x1 
bad_scans       = struct_size_vec( : , 1 ) ~= 1081                          ;   % find non-conforming scans
urg_struct( bad_scans ) = []                                                ;   % remove bad scans
num_scans       = size( urg_struct , 1  )

%   initialize stuff
p               = zeros( num_scans , 3 )                    ;
fit_curve       = zeros( num_scans, 1081 )                  ;
vertex          = zeros( num_scans, 2 )                     ;
fit_range       = logical( zeros( num_scans, 1081 ) )       ;

if ~exist( 'all_x_med' , 'var' )
    disp( 'Pre-Processing Data' )
    all_x_weight    = repmat( x_weight , num_scans , 1 )                        ;   % cos( -45 : 0.25 : 1081 )
    all_y_weight    = repmat( y_weight , num_scans , 1 )                        ;   % sin(  '       '     '  )
    sz              = size( all_x_weight )                                      ;   
	raw_data        = double( horzcat( urg_struct.scan )' )                     ;
    infs            = ( raw_data == 60000 )                                     ;
%     zeros           = ( raw_data == 0 )                                         ;
    raw_data( infs )= 0                                                         ;
    middle_halo     = ( -20 : 20 ) + 1082/2                                     ;
    initial_offset  = median( median( raw_data( : , middle_halo ) ) ) *         ...
                      mm_conversion                                             ;
	angle_mat       = repmat( angles_rad , sz( 1 ) , 1 )                        ;
    disp( 'Converting to Polar' )
    [ x_s , y_s ]   = pol2cart( angle_mat , raw_data )                          ;
    disp( 'Estimating pipe fit' )
    circle.x        = pipe_in * all_x_weight                                    ;
    circle.y        = pipe_in * all_y_weight                                    ;
    data.x          = x_s * mm_conversion                                       ;
    data.y          = y_s * mm_conversion - initial_offset + pipe_in            ;
    data.r          = sqrt( data.x .^2 + data.y .^2 )                           ;
    data.noise      = abs( data.r - pipe_in ) > ( .2 * pipe_in )                ; 
    all_scans       = double( raw_data ) * mm_conversion                        ;
    disp( 'De-noising' )
    
    nan_value       = 60000 * mm_conversion                                     ;
    all_scans( infs ) = nan_value                                               ;
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
    all_med( data.noise ) = nan                                                 ;
    all_x_med       = all_med .* all_x_weight                                   ;
    all_y_med       = all_med .* all_y_weight                                   ;
    x_guess         = mean( nanmedian( data.x ) )
    y_guess         = initial_offset - pipe_in
    R_guess         = pipe_in 
    par_rec         = repmat( [ x_guess y_guess R_guess ] ,                     ...
                      size( filter_mat , 1 ) , 1 )                              ;   % initialize record of circle parameters
    
    disp( 'Calculating Quantiles for Y-Limits' )
    quant_tol       = 0.2  
    if ~exist( 'quants' , 'var' )
        quants   	= quantile( all_scans( : ) , [ quant_tol 1-quant_tol ] )
    end
    disp( 'Pre-Processing of Data Complete' )    
end

z_grid      = meshgrid( 1:size( all_x_med , 1 ) , 1:size( all_x_med , 2 ) )' 	;

h.singlefig = figure( 'NumberTitle' , 'off' , 'Name' , 'Fit of Lidar to Pipe' )
    h.scan      = subplot( 1 , 4 , 1:3 )
    
        h.raw_p     = plot( 0 , 0 , 'r' ,                                               ...
                                    'LineSmoothing' , 'on' ,                            ...
                                    'LineWidth' , 2 )                                   ;
        set( gca , 'Color' , [0.0500    0.0750    0.0750] )                        

        hold on  
        med_scan    = nanmedian( all_scans )                                            ;
        h.med       = plot( med_scan .* x_weight  , med_scan .* y_weight , 'c--' ,   	...
                                    'LineSmoothing' , 'on' ,                            ...
                                    'LineWidth' , 5 ,                                   ...
                                    'Marker' , '.' ,                                    ...
                                    'LineStyle' , '-' )                                 ;

        hold on 
        h.fit_p     = plot( 0 , 0 , 'g' , 'LineSmoothing' , 'on' , 'LineWidth' , 2 )	;
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
        ylim( pipe_in * [ -1 1 ] + [ -2 2 ] )
        if add_legends

        legend( { 'Raw Noisy Data' ,            ...
                  'Median Filtered' ,           ...
                  'Shifted',                    ...
                  'Pipe Fit' ,                  ...
                  'Pipe Template' } ,           ...
                  'Location' ,                  ...
                  'Best' )          ;
        end
        
    h.fit       = subplot( 2 , 4 , 4 )                                              ;

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
        h.plot4     = plot( 0 , 0 , 'y' , 'LineSmoothing' , 'on' , 'LineWidth' , 2 )    ;
        set( gca , 'Color' , [0.0500    0.0750    0.0750] )

        h.fit_axes  = ancestor( h.red_filt , 'Axes' )                                   ;
        h.min_mark  = scatter( 0 , 0 , 'o', 'MarkerEdgeColor' , 'b' ,                   ...
                                            'MarkerFaceColor' , [ 0 0.5 0.5 ] ,         ...
                                            'LineWidth' , 3 )                           ;

        h.bounds    = plot( [ 0         0       nan     180     180 ] ,                 ...
                            [ -100  	100 	nan     -100  	100        ] )          ;
        set( h.fit , 'XDir' , 'reverse' )                                

        % axis equal
        grid on
        xlabel( '\theta, Degrees, -45 : 225' )
        ylabel( '\rho, Inches' )
        set( gcf, 'Units' , 'Normalized' )
        xlim( [ -45 225 ] )
        disp( 'Quantiles Calculated.' )
        % ylim( quants + [ -0.5 0.5 ] )
        ylim( [ 8 26 ] )
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
        % desired_scans   = fixed_scan - 50 : fixed_scan                              ;


        toggle( h.raw_p )
        toggle( h.med )
        toggle( h.circle ) 
        % vert            = @() [ ( ( -p( 2 ) / ( 2 * p( 1 ) ) ) / 1 ) * 180 / pi ,       ...
        %                            ( polyval( p , -p( 2 ) / ( 2 * p( 1 ) ) ) ) ]        ;
h.corrosion         = subplot( 2 , 4 , 8 )                                          ;
h.corr              = plot( 1 , 1 , 'Color' , 'r' , 'LineSmoothing' , 'on' , 'MarkerFaceColor' , [ 1 .8 .8 ] , 'MarkerEdgeColor' , 'none' , 'LineStyle' , '-' , 'Marker' , 'o' , 'LineWidth' , 3 )     ;
ylim( [ 0 5 ] )
grid on        
title( 'Corrosion Area, in^2' )
% h.logic             = figure( 'Position' , [ 316   353   576   512 ] )              ;
%     h.logic_plot        = plot( angles_deg , repmat( x_weight , 4 , 1 ) , '.'  )        ;
%     % set( h.logic_plot , { 'Color' } , { 'none' , 'none' , 'none' , 'none' }' )
% 
%     set( gca , 'XDir' , 'reverse' )
%     ylim( [ 0 2 ] )
%     hold on
%     grid on
%     h.range             = plot( [ 0 0 nan 1 1 nan 2 2 ] , [ 0 0 nan 1 1 nan 1 1 ] , 'Color' , 0.4 * [ 1 .8 1 ] , 'LineSmoothing' , 'on' )
% 
%     legend( { '~isnan' ; 'Not Bad Parabola' ; 'Above Min' ; 'Below Max' } )
    inner_ring_x            = pipe_in * x_weight                                        ;
    inner_ring_y            = pipe_in * y_weight                                        ;           
axes( h.scan )
    hold on
%     h.patch                 = patch( inner_ring_x , inner_ring_y , [ 1 1 0 ] )    ;
%     set( h.patch , 'EdgeColor' , 'none' )

desired_scans   = ( 1016 : 1674 ) + 3000                                                   ;
% desired_scans   = 1360


for i_scan = desired_scans

        raw_scan 	= all_scans( i_scan , : )                               	;
        pipe_fit                                                                ;
        title( sprintf( 'Timestamp %d, %s, scan %d of %d -- Average Diameter: %0.2f' ,                     ...
               urg_struct( i_scan ).timeStamp ,                                 ...
               urg_struct( i_scan ).dateString ,                                ...
               i_scan ,                                                         ...
               num_scans ,                                                      ...
               2*par( i_scan , 3 ) ) )                                          ;

        drawnow
        diam_rec( parab_order , i_scan )    = par( i_scan , 3 )                 ;
%         frame           = getframe
%         writeVideo( writerObj , frame ) 
%         pause( 0.2 )

end