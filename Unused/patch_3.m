
clc
delete( findobj( allchild( gcf ) , 'type' , 'patch' ) )
x_p         = [ [ 0  0  5  2.5 nan  nan  ]' [ 0  0 2.5 5  5  0  ]' ] + 1
y_p         = [ [ 20 15 15 20  nan nan  ]' [ 10 5 7.5 5  10 10  ]' ]    
verts       = ( [ x_p( : ) y_p( : ) ] )
faces       = ( [ [ 1 2 3 4 nan  ] ; [ 7 8 9 10 11  ] ] )
% cdata       = repmat( [ 1 -1 1 -1 1 ]' , 1, size( x_p , 2 ) )
% h.p         = patch( x_p , y_p , [ 0 1 ; 1 0 ; 0 0 ; 0 0 ; 0 0 ; 0 0 ] )
h.p         = patch('Faces',faces,'Vertices',verts,'FaceColor','b');
% delete( findobj( allchild( gcf ) , 'type' , 'patch' ) )
% h.p2        = patch( x_p( : , 2 ) , y_p( : , 2 ) , 'blue' )
set( h.p  , 'EdgeColor' , [ 1   1   0   ] )
% set( h.p2 , 'EdgeColor' , [ 0   0   1   ] )
% comet( x_p( : , 1 ) , y_p( : , 1 ) )
