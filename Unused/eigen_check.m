close all
figure( 'Units' , 'Normalized' , 'Outerposition' , [ 0.1 0.1 0.8 0.8 ] )
offset = 200

for i = ( 1 : 1000 ) + offset
    d               = all_scans( i : ( i + 1080 ) , : )             ;
    d( isnan( d ) )	= 0                                             ;
    [ v , ~ ]       = eig( d )                                      ;
    subplot( 2 , 2 , 1 )
    imagesc( abs( v ) )
    title( 'Abs of Eigenmatrix' )
    colormap( 'bone' )
    
    subplot( 2 , 2 , 2 )
    imagesc( d ) 
    title( 'Current Neighborhood' )
    colormap( 'bone' )
    
    subplot( 2 , 2 , 3 )
    imagesc( real( v ) )
    title( 'Real Part' )
    colormap( 'bone' )
    
    subplot( 2 , 2 , 4 )
    imagesc( imag( v ) )
    title( 'Imaginary Part' )
    colormap( 'bone' )
    drawnow
end