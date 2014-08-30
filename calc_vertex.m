function v = calc_vertex( p )
%   p is the polynomial describing the input data curve. The independent
%   variable is angle in RADIANS. 

if numel( p ) == 2 
v  = [ ( ( -p( 2 ) / ( 2 * p( 1 ) ) ) / 1 ) * 180 / pi ,         	...     % find vertex, -b / 2a, in radians, 
            ( polyval( p , -p( 2 ) / ( 2 * p( 1 ) ) ) ) ]           ;       % then convert to degrees; evaluate at
                                                                            % that point, in whatever the input is, 
                                                                            % in this case radians.
else
    poly_roots  = roots( polyder( p ) )                         ;
    real_inds 	=  ~imag( poly_roots )                          ;
    real_roots  = poly_roots( real_inds )                       ;
    root_vals 	= polyval( p , poly_roots( real_inds ) )        ;
    min_mag     = min( abs( root_vals ) )                       ;
    min_root    = real_roots( abs( root_vals ) == min_mag )     ;
    v           = [ min_root * 180 / pi , min_mag ]             ;
end
if abs( abs( p( 1 ) ) < 0.023 ) || abs( v( 1 ) - 90 ) > 90
    v( 1 ) = 90                                                 	;
    v( 2 ) = polyval( p , v( 1 ) * pi / 180 )                       ; 
    disp( 'Vertex Snapped' )
end