function v = calc_vertex( p )
v  = [ ( ( -p( 2 ) / ( 2 * p( 1 ) ) ) / 1 ) * 180 / pi ,         	...
            ( polyval( p , -p( 2 ) / ( 2 * p( 1 ) ) ) ) ]               
        
if abs( abs( p( 1 ) ) < 0.023 ) || abs( v( 1 ) - 90 ) > 90
    v( 1 ) = 90                                                 	;
    v( 2 ) = polyval( p , v( 1 ) * pi / 180 )                       ; 
    disp( 'Vertex Snapped' )
end