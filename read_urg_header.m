function header_struct = read_urg_header( fid )
clc
if nargin == 0 , fid = fopen( 'all' ), end
frewind( fid )

num_tests   = 40
test_cell   = deal( textscan( fid , '%s %*s' , num_tests , 'BufSize' , 100000 ) )
begin_cell  = repmat( { '[timestamp]' } , num_tests , 1 )
first_scan  = min( find( strcmpi( test_cell{ 1 } , begin_cell ) ) )
frewind( fid )
header_cell = deal( textscan( fid , '%s %*s' , first_scan - 1 ) )
if first_scan > 23 , 
    header_cell{ 1 }( 1 :  ( first_scan - 23 ) ) = []
end

for i_fields = [ 1 7 11 ]
    raw_field                       = header_cell{1}{ 2 * i_fields - 1 }    ;
    curr_field                      = raw_field( 2 : end-1 )                ;
    header_struct.( curr_field )    = header_cell{1}{ 2 * i_fields }        ;
end

for i_fields = [ 2:6 8:10 ]
    raw_field                       = header_cell{1}{ 2 * i_fields - 1 }        ;
    curr_field                      = raw_field( 2 : end-1 )                    ;
    header_struct.( curr_field )    = str2num( header_cell{1}{ 2 * i_fields } ) ;
end

end