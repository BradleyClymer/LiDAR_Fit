set( h.fit_p , 'Visible' , 'off' )
clc
delete( findobj( allchild( gcf ) , 'type' , 'patch' ) )
 
verts       = ( [ shape_x( : ) shape_y( : ) ] )
faces       = nan( size( shape_x( : ) ) )                           ;
faces( ~isnan( shape_x( : ) ) ) = find( ~isnan( shape_x( : ) ) ) 
h.p         = patch('Faces',faces,'Vertices',verts,'FaceColor','b');
% delete( findobj( allchild( gcf ) , 'type' , 'patch' ) )
% h.p2        = patch( x_p( : , 2 ) , y_p( : , 2 ) , 'blue' )
set( h.p  , 'EdgeColor' , [ 1   1   0   ] )
% set( h.p2 , 'EdgeColor' , [ 0   0   1   ] )
% comet( x_p( : , 1 ) , y_p( : , 1 ) )
