h.film_check     = figure( 'Units' , 'Normalized' , 'OuterPosition' , [ 0.2 0.04 0.6 0.96 ] )
load( 'With_film_raw.mat' )
all_with_film       = all_scans                 ;
mean_with_film      = mean( all_scans )         ;
median_with_film    = median( all_scans )       ;
load( 'No_film_raw.mat' )
all_no_film         = all_scans                 ;
mean_no_film        = mean( all_scans )         ;
median_no_film      = median( all_scans )       ;

% subplot( 311 )
% % Surface
% surf( all_x_weight * all_with_film , y

% subplot( 121 )
% means
plot( x_weight .* mean_with_film  , y_weight .* mean_with_film , x_weight .* mean_no_film  , y_weight .* mean_no_film , 'LineSmoothing' , 'on' , 'LineWidth' , 4 )
axis equal square
grid on
legend( { 'Mean with film' , 'Mean without Film' } )
tightfig
set( h.film_check , 'OuterPosition' , [ 0.04 0.04 0.96 0.96 ] )
export_fig LiDAR_error_mean -m2
close all hidden

h.film_check     = figure( 'Units' , 'Normalized' , 'OuterPosition' , [ 0.2 0.04 0.6 0.96 ] )
% means
plot( x_weight .* median_with_film  , y_weight .* median_with_film , x_weight .* median_no_film  , y_weight .* median_no_film , 'LineSmoothing' , 'on' , 'LineWidth' , 4 )
axis equal square
grid on
legend( { 'Median with Film' , 'Median without Film' } )

tightfig
set( h.film_check , 'OuterPosition' , [ 0.04 0.04 0.96 0.96 ] )
export_fig LiDAR_error_median -m2

