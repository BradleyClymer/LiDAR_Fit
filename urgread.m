clc
close all hidden
colordef black
% clear
profile on
if ~exist( 'urg_file' , 'var' )
    [ f , p ]   = uigetfile( '*.ubh' , 'Select UrgBenri LiDAR data file' )
    urg_file    = fullfile( p , f )
end
                  fclose( 'all' )
fid             = fopen( urg_file )

if ~exist( 'urg_struct' , 'var' ) 
    disp( 'Reading Raw UrgBenri File' )
    urg_struct      = urg_struct_read( fid ) 
    disp( 'Raw File Read' )
end

plot_parabola   = true                                                      ;
add_legends     = false                                                     ;

mm_conversion   = 1 / 25.4                                                  ;   % 1mm in inches

angles_deg  	= linspace( -45 , 225 , numel( urg_struct( 1 ).scan ) )     ;   % angles of LiDAR scan, in as many
                                                                                % points as one scan has
aux_deg         = linspace( -45 , 315 , numel( angles_deg ) + 90*4 )        ;
                                                                                
x_weight        = cosd( angles_deg )                                        ;   % pre-calculate the weights of the angles
y_weight        = sind( angles_deg )                                        ;

aux_x_w         = cosd( aux_deg )                                           ;   % extra angles for compensation
aux_y_w         = sind( aux_deg )                                           ;   

bounds.min      = 0                                                         ;
bounds.max      = 180                                                       ;
accepted_diff   = .5                                                        ;   % inches
all_angles      = angles_deg  * pi / 180                                    ;   % -45 : 225 in radians                                                   ;
angle_offset    = 10                                                        ;

pipe_in         = 48/2                                                      ;   % pipe radius in inches

pipe_mm         = pipe_in / mm_conversion                                   ;   %  '      '     '  mm
inner_tol       = .6 * pipe_in                                              ;
mm_rad          = pipe_mm / 2                                               ;   % pipe radius in mm

filter_order    = 5                                                         ;   % order of the median filter
filter_roll     = 3                                                         ;   % filter roll-off rate
filter_raw      = exp( filter_roll * ( filter_order : -1 : 1 )' /filter_order  )       ;   % generate some filter coefficients
filter_new      = filter_raw / ( sum( filter_raw' )' / 1 )                  ;   % normalize coefficients
filter_mat      = repmat( filter_new , 1 , 3 )                                 % matrix of coefficients
min_rec         = zeros( numel( filter_order ) , 1 )                        ;   % initialize record of minima
struct_size_vec = cell2mat( arrayfun( @( x ) size( x.scan ) , urg_struct ,  ...
                           'UniformOutput' , false ) )                      ;   % size of scans. ex: 1081x1 
bad_scans       = struct_size_vec( : , 1 ) ~= 1081                          ;   % find non-conforming scans
urg_struct( bad_scans ) = []                                                ;   % remove bad scans

if ~exist( 'all_x_med' , 'var' )
    disp( 'Pre-Processing Data' )
    struct_size_vec = cell2mat( arrayfun( @( x ) size( x.scan ) , urg_struct ,  ...
                      'UniformOutput' , false ) )                               ;
	raw_data        = double( horzcat( urg_struct.scan )' ) * mm_conversion     ;
    all_scans       = raw_data                                                  ;
    disp( 'De-noising' )
    all_scans( all_scans > 3500 * mm_conversion ) = 0                           ;
    nan_value       = 60000 * mm_conversion                                     ;
    all_scans( all_scans < inner_tol  ) = nan_value                             ;
    all_scans( all_scans == 0 ) = nan_value                                  	;
    all_x_weight    = repmat( x_weight , size( all_scans , 1 ) , 1 )            ;
    all_y_weight    = repmat( y_weight , size( all_scans , 1 ) , 1 )            ;
    all_x_raw       = all_scans .* all_x_weight                                 ;
    all_y_raw       = all_scans .* all_y_weight                                 ;
    med_rad         = 7                                                         ;
    med_range       = -med_rad : med_rad                                        ;
    disp( 'Median Filtering Data (longest portion of pre-processing)' )          
    all_med         = medfilt2( all_scans , [ 2 * med_rad + 1 , 1 ] )           ;
    disp( 'Median Filtering Complete.' )
    all_med( all_med == nan_value ) = nan                                       ;
    all_scans( all_scans == nan_value ) = nan                                   ;
    all_x_med       = all_med .* all_x_weight                                   ;
    all_y_med       = all_med .* all_y_weight                                   ;
    x_guess         = nanmedian( nanmedian( all_x_med ) )
    y_guess         = nanmedian( nanmedian( all_y_med ) )
    R_guess         = norm( [ x_guess y_guess ] )
    par_rec         = repmat( [ x_guess y_guess R_guess ] ,                     ...
                      size( filter_mat , 1 ) , 1 )                              ;   % initialize record of circle parameters
    
%     xlims           = 1.2 * [ mode( min( all_x_raw , [] , 2 ) )             	...
%                               mode( max( all_x_raw , [] , 2 ) ) ]             	;
%     xlims           = 1.1 * mode( max( abs( all_x_raw ) , [] , 2 ) ) * [ -1 1 ]	;
%     ylims           = [ 1.5 1.7 ] .* [ mode( min( all_y_raw , [] , 2 ) )      	...
%                                        mode( max( all_y_raw , [] , 2 ) ) ]     	;
%     ylims           = pipe_in * 1.5 * [ -1 1 ]                                  ;
    
    disp( 'Calculating Quantiles for Y-Limits' )
    quant_tol       = 0.2  
    if ~exist( 'quants' , 'var' )
        quants   	= quantile( all_scans( : ) , [ quant_tol 1-quant_tol ] )
    end
    disp( 'Pre-Processing of Data Complete' )    
end

z_grid      = meshgrid( 1:size( all_x_med , 1 ) , 1:size( all_x_med , 2 ) )' 	;

h.singlefig = figure( 'NumberTitle' , 'off' , 'Name' , 'Fit of Lidar to Pipe' )
h.scan      = subplot( 4 , 1 , 1:3 )
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
h.fit_p     = plot( 0 , 0 , 'g' , 'LineSmoothing' , 'on' , 'LineWidth' , 2 )    ;
h.circle    = plot( 0 , 0 , 'y' , 'LineSmoothing' , 'on' , 'LineWidth' , 2 ,    ...
                                  'Marker' , '.' , 'LineStyle' , 'none' )       ;
h.template  = plot( pipe_in*cosd( 0 : 5 : 360 ) ,                               ...
                    pipe_in*sind( 0 : 5 : 360 ),                             	...
                    'Color' , 'm' ,                                             ...
                    'LineStyle' , '.' ,                                         ...
                    'LineSmoothing' , 'on' ,                                    ...
                    'LineWidth' , 1 ,                                           ...
                    'Marker' , 'o' ,                                            ...
                    'LineStyle' , 'none' )                                      ;
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
xlim( pipe_in * [ -1 1 ] + [ -2 2 ] )
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
h.fit       = subplot( 4 , 1 , 4 )                                              ;


h.red_filt 	= plot( 0 , 0 , 'r+' , 	'LineSmoothing' , 'on' ,                 	...
                                    'MarkerSize' , 3 ,                          ...
                                    'LineWidth' , 2 )                           ;
              set( h.red_filt ,     'MarkerEdgeColor' , 1/255 * [ 255 54 64 ]   ...
                              ,     'MarkerFaceColor' , 1/395 * [ 139 35 35 ] )
hold on                                
h.bad_filt  = plot( 0 , 0 , 'bx' ,	'LineSmoothing' , 'on' ,                 	...
                                    'MarkerSize' , 3 ,                          ...
                                    'LineWidth' , 2 )                           ;     
              set( h.bad_filt ,     'MarkerEdgeColor' , 1/255 * [ 119 136 193 ] ...
                              ,     'MarkerFaceColor' , 1/255 * [ 198 226 255 ] )
                  
hold on 
h.plot4     = plot( 0 , 0 , 'y' , 'LineSmoothing' , 'on' , 'LineWidth' , 2 )    ;
set( gca , 'Color' , [0.0500    0.0750    0.0750] )

h.fit_axes  = ancestor( h.red_filt , 'Axes' )                                   ;
h.min_mark  = scatter( 0 , 0 , 'o', 'MarkerEdgeColor' , 'b' ,                   ...
                                    'MarkerFaceColor' , [ 0 0.5 0.5 ] ,         ...
                                    'LineWidth' , 3 )                           ;
h.bounds    = plot( [ bounds.min bounds.min nan bounds.max bounds.max ] ,       ...
                    [ -100       100        nan -100       100        ] )       ;
set( h.fit , 'XDir' , 'reverse' )                                
                                                               
% axis equal
grid on
xlabel( '\theta, Degrees, -45 : 225' )
ylabel( '\rho, Inches' )
set( gcf, 'Units' , 'Normalized' )
xlim( [ -45 225 ] )
disp( 'Quantiles Calculated.' )
% ylim( quants + [ -0.5 0.5 ] )
ylim( [ 5 28 ] )
% all_args        = { all_x , all_y , z_grid , 'EdgeColor' , 'none' }         ;
set( h.fit_axes , 'XTick' , -60 : 30 : 255 )
set( h.singlefig , 'OuterPosition' , [ 995.8333e-003  -158.3333e-003   570.8333e-003     1.7926e+000 ] )
if add_legends
legend( { 'Included Points' , 'Excluded Points' , 'Parabolic Fit Curve' , 'Parabola Vertex' } )
end

drawnow
last_time       = tic                                                       ;
ifp             = urg_struct(1).header.scanMsec * 1e-3                      ;
num_scans       = numel( urg_struct )                                       ;
fixed_scan      = 79770         
% desired_scans   = fixed_scan - 50 : fixed_scan                              ;
desired_scans   = 5800 : 5860                                               ;

% toggle( h.raw_p )
toggle( h.med )
% vert            = @() [ ( ( -p( 2 ) / ( 2 * p( 1 ) ) ) / 1 ) * 180 / pi ,       ...
%                            ( polyval( p , -p( 2 ) / ( 2 * p( 1 ) ) ) ) ]        ;

h.logic           = figure( 'Position' , [ 316   353   576   512 ] )            ;
h.logic_plot      = plot( angles_deg , repmat( x_weight , 4 , 1 ) , '.' )
legend( { '~isnan' ; 'Not Bad Parabola' ; 'Above Min' ; 'Below Max' } )

for parab_order = 1 : 5
    if parab_order
        filter_order    = parab_order*2                                          	;   % order of the median filter
        filter_roll     = 3                                                         ;   % filter roll-off rate
        filter_raw      = exp( filter_roll * ( 1 : 1 : filter_order )' /filter_order  )       ;   % generate some filter coefficients
        filter_new      = filter_raw / ( sum( filter_raw' )' / 1 )                  ;   % normalize coefficients
        filter_mat      = repmat( filter_new , 1 , 3 )                                 % matrix of coefficients
        min_rec         = zeros( numel( filter_order ) , 1 )                        ;   % initialize record of minima
        par_rec         = repmat( [ x_guess y_guess R_guess ] ,                     ...
            size( filter_mat , 1 ) , 1 )
    end
for i_scan = desired_scans

        raw_scan 	= all_scans( i_scan , : )                               	;
        pipe_fit                                                                ;
        title( sprintf( 'Timestamp %d, %s, scan %d of %d\nAverage Diameter: %0.2f' ,                     ...
               urg_struct( i_scan ).timeStamp ,                                 ...
               urg_struct( i_scan ).dateString ,                                ...
               i_scan ,                                                         ...
               num_scans ,                                                      ...
               par( 3 ) ) )                                                    ;

        drawnow
        diam_rec( parab_order , i_scan )    = par( 3 )                            ;
%         frame           = getframe
%         writeVideo( writerObj , frame ) 
%         pause( 0.2 )

end
% pause( 1 )
end
figure
plot( diam_rec( : , desired_scans )' , 'LineSmoothing' , 'on' )
grid on
legend( { '1' , '2' , '3', '4' , '5' , '6' , '7' } )

% 

% profile viewer
