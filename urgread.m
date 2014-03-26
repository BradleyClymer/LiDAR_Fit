clc
close all hidden
colordef black
% clear

if ~exist( 'urg_file' , 'var' )
    [ f , p ]   = uigetfile( '*.ubh' , 'Select UrgBenri LiDAR data file' )
    urg_file    = fullfile( p , f )
end
                  fclose( 'all' )
fid             = fopen( urg_file )

if ~exist( 'urg_struct' , 'var' ) 
    urg_struct      = urg_struct_read( fid )
end

mm_conversion   = 0.0393701                                                 ;

angles          = linspace( -45 , 225 , numel( urg_struct( 1 ).scan ) )     ;
x_weight        = cosd( angles )                                           	;
y_weight        = sind( angles )                                            ;

filter_order    = 10                                                        ;
filter_roll     = 1                                                         ;
filter_raw      = exp( filter_roll * ( 1 : filter_order )' /filter_order  ) ;        
filter_new      = filter_raw / ( sum( filter_raw' )' / 1 )                  ;
filter_mat      = repmat( filter_new , 1 , 3 )                   
par_rec         = repmat( [ -2 -10 24 ] , size( filter_mat , 1 ) , 1 )      ;
min_rec         = zeros( numel( filter_order ) , 1 )                        ;

if ~exist( 'xlims' , 'var' )
    all_scans       = double( horzcat( urg_struct.scan )' ) * mm_conversion     ;
    all_scans( all_scans > 3500 * mm_conversion ) = 0                           ;
    all_scans( all_scans < 6  ) = 0                                             ;
    all_scans( all_scans == 0 ) = NaN                                           ;
    all_x_weight    = repmat( x_weight , size( all_scans , 1 ) , 1 )            ;
    all_y_weight    = repmat( y_weight , size( all_scans , 1 ) , 1 )            ;
    all_x           = all_scans .* all_x_weight                                 ;
    all_y           = all_scans .* all_y_weight                                 ;
    
    xlims           = 1.2 * [ mode( min( all_x , [] , 2 ) )                     ...
        mode( max( all_x , [] , 2 ) ) ]
    xlims           = 1.1 * mode( max( abs( all_x ) , [] , 2 ) ) * [ -1 1 ]
    ylims           = [ 1.5 1.7 ] .* [ mode( min( all_y , [] , 2 ) )            ...
        mode( max( all_y , [] , 2 ) ) ]
    ylims           = [ -24 24 ]                                                ;
end

z_grid      = meshgrid( 1:size( all_x , 1 ) , 1:size( all_x , 2 ) )'            ;

h.singlefig = figure( 'NumberTitle' , 'off' , 'Name' , 'Fit of Lidar to Pipe' )
h.scan      = subplot( 1 , 4 , 1:2 )
h.raw_p     = plot( 0 , 0 , 'r' ,                                               ...
                            'LineSmoothing' , 'on' ,                            ...
                            'LineWidth' , 2                                     )
hold on  
med_scan    = nanmedian( all_scans )                                            ;
h.med       = plot( med_scan .* x_weight  , med_scan .* y_weight , 'c--' ,   	...
                            'LineSmoothing' , 'on' ,                            ...
                            'LineWidth' , 2                                     )                        
                        
hold on 
h.fit_p     = plot( 0 , 0 , 'g' , 'LineSmoothing' , 'on' , 'LineWidth' , 2 )    ;
h.circle    = plot( 0 , 0 , 'y' , 'LineSmoothing' , 'on' , 'LineWidth' , 2 )    ;
h.template  = plot( 24*cosd( 0:360 ) ,                                          ...
                    24*sind( 0:360 ),                                           ...
                    'Color' , 0.6 * [ 1 1 1 ] ,                                 ...
                    'LineStyle' , '-.' ,                                    	...
                    'LineSmoothing' , 'on' ,                                    ...
                    'LineWidth' , 2 )    
plot( 100 * [ -1 1 ] , [ 0 0 ] , 'Color' , [ 0 0 1 ] , 'LineSmoothing' , 'on' )
plot( [ 0 0 ] , 100 * [ -1 1 ] , 'Color' , [ 0 0 1 ] , 'LineSmoothing' , 'on' )
axis equal
grid on
xlabel( 'Inches' )
ylabel( 'Inches' )
set( gcf, 'Units' , 'Normalized' )
xlim( xlims )
ylim( [ -26 26  ] ) 
legend( { 'Raw Noisy Data' ,            ...
          'Median Filtered' ,           ...
          'Shifted',                    ...
          'Pipe Fit' ,                  ...
          'Pipe Template' } )           ;

h.fit       = subplot( 1 , 4 , 3:4 )                                              ;
h.red_filt 	= plot( 0 , 0 , 'r+' ,   'LineSmoothing' , 'on' ,                 	...
                                    'MarkerSize' , 3 ,                          ...
                                    'LineWidth' , 2 )                           ;
hold on 
h.plot4     = plot( 0 , 0 , 'y' , 'LineSmoothing' , 'on' , 'LineWidth' , 2 )    ;

h.fit_axes  = ancestor( h.red_filt , 'Axes' )                                   ;
h.min_mark  = scatter( 0 , 0 , 'o', 'MarkerEdgeColor' , 'b' ,                   ...
                                    'MarkerFaceColor' , [ 0 0.5 0.5 ] ,         ...
                                    'LineWidth' , 3 )                           ;
                                                               
% axis equal
grid on
xlabel( 'Degrees, -45 : 225' )
ylabel( 'Inches' )
set( gcf, 'Units' , 'Normalized' )
xlim( [ -45 225 ] )
ylim( [ 10 22 ] )
all_args        = { all_x , all_y , z_grid , 'EdgeColor' , 'none' }         ;
set( h.fit_axes , 'XTick' , -60 : 30 : 255 )
set( h.singlefig , 'OuterPosition' ,  [ 0.5000     0.0    0.5000    1 ] )

drawnow
last_time       = tic                                                       ;
ifp             = urg_struct(1).header.scanMsec * 1e-3                      ;
num_scans       = numel( urg_struct )                                       ;
desired_scans   = 17000 : 18000                                             ;
med_rad         = 7                                                         ;
med_range       = -med_rad : med_rad                                        ;


for i_scan = desired_scans
    try
        med_data    = all_scans( med_range + i_scan , : )                       ;
        med_scan    = nanmedian( med_data )                                     ;
        med_x       = med_scan .* x_weight                                      ;
        med_y       = med_scan .* y_weight                                      ;
        set( h.med , 'XData' , med_x , 'YData' , med_y )                        ;
        
        %     scan       	= all_scans( i_scan , : )                                   ;
        scan        = all_scans( i_scan , : )                               	;
        pipe_fit                                                                ;
        flat_fit    = fit_curve - min( fit_curve )                              ;
        x_scan      = scan .* x_weight                                          ;
        y_scan      = scan .* y_weight                                          ;
        set( h.raw_p, 'XData' , x_scan , 'YData' , y_scan  )                    ;
        set( h.red_filt, 'XData' , angles( fit_range ) , 'YData' , scan( fit_range )  )                      ;
        last_time   = tic                                                       ;
        title( sprintf( 'Timestamp %d, %s, scan %d of %d' ,                     ...
               urg_struct( i_scan ).timeStamp ,                                 ...
               urg_struct( i_scan ).dateString ,                                ...
               i_scan ,                                                         ...
               num_scans ) )
        drawnow
    catch err
        rethrow( err )
    end
end
