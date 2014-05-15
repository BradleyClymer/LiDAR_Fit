clear
close all hidden
[x y z v] = flow;
uv          = unique( v( : ) )'                 ;
map         = jet( numel( uv ) )                ;


for i_v     = unique( v( : ) )'
    p = patch(isosurface(x,y,z,v,i_v));
   
    isonormals(x,y,z,v,p);
    set(p,'facecolor','red','edgecolor','none');
    daspect(0.1*[1 1 1]);
    view(3); axis tight; grid on;
    camlight; lighting gouraud;
    alpha( 0.5 )
    axis tight
    set( gca , 'CameraPosition' , [ -53.6929   14.1788   12.9101 ] )
    drawnow
    delete( p )
end