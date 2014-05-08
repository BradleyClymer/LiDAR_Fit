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
    urg_struct      = urg_struct_read( fid )                                
end

mm_conversion   = 1 / 25.4                                                  ;   % 1mm in inches

angles_deg  	= linspace( -45 , 225 , numel( urg_struct( 1 ).scan ) )     ;   % angles of LiDAR scan, in as many
                                                                                % points as one scan has
aux_deg         = linspace( -45 , 315 , numel( angles_deg ) + 90*4 )        ;
                                                                                
x_weight        = cosd( angles_deg )                                        ;   % pre-calculate the weights of the angles
y_weight        = sind( angles_deg )                                        ;

aux_x_w         = cosd( aux_deg )                                           ;   % extra angles for compensation
aux_y_w         = sind( aux_deg )                                           ;   

pipe_in         = 27/2                                                      ;   % pipe radius in inches
pipe_mm         = pipe_in / mm_conversion                                   ;   %  '      '     '  mm
mm_rad          = pipe_mm / 2                                               ;   % pipe radius in mm

filter_order    = 10                                                        ;   % order of the median filter
filter_roll     = 1                                                         ;   % filter roll-off rate
filter_raw      = exp( filter_roll * ( 1 : filter_order )' /filter_order  ) ;   % generate some filter coefficients
filter_new      = filter_raw / ( sum( filter_raw' )' / 1 )                  ;   % normalize coefficients
filter_mat      = repmat( filter_new , 1 , 3 )                              ;   % matrix of coefficients
par_rec         = repmat( [ -2 -10 24 ] , size( filter_mat , 1 ) , 1 )      ;   % initialize record of circle parameters
min_rec         = zeros( numel( filter_order ) , 1 )                        ;   % initialize record of minima
struct_size_vec = cell2mat( arrayfun( @( x ) size( x.scan ) , urg_struct ,  ...
                           'UniformOutput' , false ) )                      ;   % size of scans. ex: 1081x1 
bad_scans       = struct_size_vec( : , 1 ) ~= 1081                          ;   % find non-conforming scans
urg_struct( bad_scans ) = []                                                ;   % remove bad scans

if ~exist( 'xlims' , 'var' )
    struct_size_vec = cell2mat( arrayfun( @( x ) size( x.scan ) , urg_struct , 'UniformOutput' , false ) )
    all_scans       = double( horzcat( urg_struct.scan )' ) * mm_conversion     ;
%     all_scans( all_scans > 20500 * mm_conversion ) = 0                           ;
    all_scans( all_scans < 6  ) = 0                                             ;
    all_scans( all_scans == 0 ) = NaN                                           ;
    all_x_weight    = repmat( x_weight , size( all_scans , 1 ) , 1 )            ;
    all_y_weight    = repmat( y_weight , size( all_scans , 1 ) , 1 )            ;
    all_x           = all_scans .* all_x_weight                                 ;
    all_y           = all_scans .* all_y_weight                                 ;
    
    xlims           = 1.2 * [ mode( min( all_x , [] , 2 ) )                     ...
                              mode( max( all_x , [] , 2 ) ) ]                   ;
    xlims           = 1.1 * mode( max( abs( all_x ) , [] , 2 ) ) * [ -1 1 ]     ;
    ylims           = [ 1.5 1.7 ] .* [ mode( min( all_y , [] , 2 ) )            ...
                                       mode( max( all_y , [] , 2 ) ) ]          ;
    ylims           = pipe_in * 1.5 * [ -1 1 ]                                  ;
end

% z_grid      = meshgrid( 1:size( all_x , 1 ) , 1:size( all_x , 2 ) )'            ;

h.singlefig = figure( 'NumberTitle' , 'off' , 'Name' , 'Fit of Lidar to Pipe' )
h.scan      = subplot( 4 , 1 , 1:3 )
h.raw_p     = plot( 0 , 0 , 'r^' ,                                               ...
                            'LineSmoothing' , 'on' ,                            ...
                            'LineWidth' , 2                                     )
set( gca , 'Color' , [0.0500    0.0750    0.0750] )                        
                        
hold on  
med_scan    = nanmedian( all_scans )                                            ;
h.med       = plot( med_scan .* x_weight  , med_scan .* y_weight , 'c--' ,   	...
                            'LineSmoothing' , 'on' ,                            ...
                            'LineWidth' , 5 ,                                   ...
                            'Marker' , '.' ,                                    ...
                            'LineStyle' , '-' )                         
                        
hold on 
h.fit_p     = plot( 0 , 0 , 'g' , 'LineSmoothing' , 'on' , 'LineWidth' , 2 )    ;
h.circle    = plot( 0 , 0 , 'y' , 'LineSmoothing' , 'on' , 'LineWidth' , 2 , 'Marker' , '.' , 'LineStyle' , 'none' ) 
h.template  = plot( pipe_in*cosd( 0 : 5 : 360 ) ,                               ...
                    pipe_in*sind( 0 : 5 : 360 ),                             	...
                    'Color' , 'm' ,                                             ...
                    'LineStyle' , '-.' ,                                    	...
                    'LineSmoothing' , 'on' ,                                    ...
                    'LineWidth' , 2 ,                                           ...
                    'Marker' , 'o' ,                                            ...
                    'LineStyle' , 'none' )    
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
legend( { 'Median-Filtered Data'  } , 	...
          'Location' ,                  ...
          'SouthEast' )          ;

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
set( h.fit , 'XDir' , 'reverse' )                                
                                                               
% axis equal
grid on
xlabel( '\theta, Degrees, -45 : 225' )
ylabel( '\rho, Inches' )
set( gcf, 'Units' , 'Normalized' )
xlim( [ -45 225 ] )
disp( 'Calculating Quantiles for Y-Limits' )
quant_tol       = 0.06  
if ~exist( 'quants' , 'var' )
quants          = quantile( all_scans( : ) , [ quant_tol 1-quant_tol ] )    
end
disp( 'Quantiles Calculated.' )
ylim( quants + [ -0.5 0.5 ] )
% all_args        = { all_x , all_y , z_grid , 'EdgeColor' , 'none' }         ;
set( h.fit_axes , 'XTick' , -60 : 30 : 255 )
set( h.singlefig , 'OuterPosition' , 0.7*[ 0.0036    0.0352    0.5526    1.3991 ] )
legend( { 'Included Points' , 'Excluded Points' , 'Parabolic Fit Curve' , 'Parabola Vertex' } )
drawnow
last_time       = tic                                                       ;
ifp             = urg_struct(1).header.scanMsec * 1e-3                      ;
num_scans       = numel( urg_struct )                                       ;
fixed_scan      = 79770         
% desired_scans   = fixed_scan - 50 : fixed_scan                              ;
desired_scans   = 12060 : 13060                                              ;
med_rad         = 7                                                         ;
med_range       = -med_rad : med_rad                                        ;
% toggle( h.raw_p )
toggle( h.med )
vert            = @() [ ( ( -p( 2 ) / ( 2 * p( 1 ) ) ) / 1 ) * 180 / pi ,       ...
                           ( polyval( p , -p( 2 ) / ( 2 * p( 1 ) ) ) ) ]        ;
%%
writerObj       = VideoWriter('HDPE Quick Visualization.avi')                   ;
writerObj.FrameRate = 20                                                        ; 
                  open( writerObj )                                             ;    
                  set( gcf , 'Renderer' , 'zbuffer' )                           ;
toggle( h.circle ) 
toggle( h.template )
dist            = 0     ;
hold on 
% h.arrow         = annotation( 'textArrow' , [ 0.3 , 0.5 ], [ 0.5 0.6 ] , 'String' , sprintf( '%0.2f"' , dist ) )
set( h.raw_p , 'LineStyle' , '-' , 'Marker' , 'o' , 'MarkerEdgeColor' , 'y' , 'MarkerFaceColor' , 'b' , 'MarkerSize' , 8 )                 
for i_scan = med_rad + 1 : 800
%     try
%        scan      	= all_scans( i_scan , : )                                   ;
        raw_scan 	= all_scans( i_scan , : )                               	;
        dist        = nanmean( raw_scan( 535 : 545 ) )                       	;
        med_data    = all_scans( med_range + i_scan , : )                       ;
        med_scan    = nanmedian( med_data )                                     ;                      
        scan        = med_scan                                                  ;
        all_x( i_scan , : ) = med_scan .* x_weight                              ;
        all_y( i_scan , : ) = med_scan .* y_weight                              ;
%         pipe_fit                                                                ;
        last_time   = tic                                                       ;
        title( sprintf( 'Timestamp %d, %s, scan %d of %d\nAverage Diameter:%0.2f' ,                     ...
               urg_struct( i_scan ).timeStamp ,                                 ...
               urg_struct( i_scan ).dateString ,                                ...
               i_scan ,                                                         ...
               num_scans ,                                                      ...
               p( 3 ) ) )                                                    ;
%         set( h.arrow , 'String' , sprintf( '%0.2f"' , dist ) )
%         if isfield( h , 'polar')
%             try
%             delete( h.polar )
%             catch err2
%             end
%         end
%         h.polar     = polar( all_angles , scan )                                ;
        axes( h.scan )
        ylim( [ -12 12 ] + dist )
        set( h.raw_p , 'XData' , all_x( i_scan , : ) , 'YData' , all_y( i_scan , : ) )
        hold on
%         h.arrow         = annotation( 'textArrow' , [ 0.3 , 0.5 ], [ 0.5 0.6 ] , 'String' , sprintf( '%0.2f"' , dist ) )
        drawnow
        frame           = getframe( 1 , [ 5 353 723 475 ] )
        writeVideo( writerObj , frame ) 
%         pause( 0.05 )

%     catch err
%         break
%         rethrow( err )
%     end
end
close( writerObj )

winopen( 'Coachella Quick Visualization.avi' )