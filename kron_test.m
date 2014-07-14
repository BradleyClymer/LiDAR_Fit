close all
% k1 = kron( ipd_ts , urg_ts )        ;
% k2 = kron( urg_ts , ipd_ts )        ;

k1  = repmat( ipd_ts    , [ size( urg_ts , 1 ) 1 ] )        ;
k2  = repmat( urg_ts'   , [ 1 size( ipd_ts , 2 ) ] )        ;


subplot( 121 )
imagesc( k1 )
axis equal tight
subplot( 122 )
imagesc( k2 )
axis equal tight
