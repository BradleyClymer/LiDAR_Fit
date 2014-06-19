close all hidden
% clear
% load mesh_chunk.mat
c_map           = 'bone' 

desired_scans = 1000 : 1550                                                      ;
x_range       = 300 : 800                                                       ;
bottom        = 6                                                               ;
top           = 14                                                              ;
x_s           = all_x_med( desired_scans , x_range )                            ;
y_s           = meshgrid( ( 1 : numel( desired_scans ) ) /15 , x_range  )'      ;
z_s           = all_y_med( desired_scans , x_range  )                           ;

v = surf( x_s ,                                                             ...
          y_s ,                                                             ...
          z_s ,                                                             ...
          'FaceColor' , 0.8 * ones( 1 , 3 )  ,                          	...
          'EdgeColor' , 'none' ,                                            ...
          'Clipping' , 'off' )
camlight headlight; lighting phong      
colormap( c_map )
set( gca , 'Clim' , [ bottom top ] )
set( gca , 'ZLim' , [ bottom top ] )
colormap( c_map ) 
axis equal
colorbar
figure
% imagesc( all_scans( desired_scans , x_range  ) .* all_y_weight( desired_scans , x_range  ) )
imagesc( min( x_s( : ) ) : max( x_s( : ) ) , min( y_s( : ) ) : max( y_s( : ) ) , z_s )
axis image
set( gca , 'Clim' , [ bottom top ] )
colormap( c_map ) 
colorbar
get( gcf  )

% figure('Colormap', bone( 64 ) )
% Ds = smooth3(z_s);
% hiso = patch(isosurface(Ds,5),...
% 	'FaceColor',[1,.75,.65],...
% 	'EdgeColor','none');
% 	isonormals(Ds,hiso)
% % The isonormals function to renders the isosurface using vertex normals obtained from the smoothed data, improving the quality of the isosurface. The isosurface uses a single color to represent its isovalue.
% % 
% % Adding Isocaps Show Cut-Away Surface
% % 
% % Use isocaps to calculate the data for another patch that is displayed at the same isovalue (5) as the isosurface. Use the unsmoothed data (D) to show details of the interior. You can see this as the sliced-away top of the head. The lower isocap is not visible in the final view.
% 
% hcap = patch(isocaps(D,5),...
% 	'FaceColor','interp',...
% 	'EdgeColor','none');