function hd = ipd_reader( input_file , start_date_vec )
if nargin == 0 
input_file      = 'P:\Dropbox (Future Scan)\Flyswatter (1)\Flyswatter Project Data\20130404@Fort Worth_mopac street\M00439_astrics\M00439.ipd'
start_date_vec  = [ 2014 , 3 , 3 ]          
end
fid             = fopen( input_file )                               ;
A               = fscanf( fid , '%f;%f;%f:%f:%f:%f' )               ;
B               = reshape( A , 6 , [] )'                            ;
C               = repmat( double( start_date_vec ) ,                ...
                                  size( B , 1 ) , 1 )               ;
D               = [ double( C ) B( : , 3 : 6 ) ]                	;
E               = D( : , 1:6 )                                      ;
E( : , 6 )      = E( : , 6 ) + ( D( : , 7 ) / 1000 )                ;
E               = double( E )                                       ;
F               = zeros( size( E , 1 ) , 1 )                        ;
for i = 1 : size( E , 1 ) 
    F( i ) = datenum( E( i , : ) )                                  ;
%     datestr( F( i ) - F( max( [ ( i-1 ) 1 ] ) ) , 'yyyy:mm:dd:HH:MM:SS:FFF' )
% %     datestr( F( i ) , 'yyyy:mm:dd:HH:MM:SS:FFF' )
end
hd.ft           = B( : , 1 ) / 100                                  ;
hd.clock        = F                                                 ;
hd.num_scans    = size( B , 1 )                                     ;
end