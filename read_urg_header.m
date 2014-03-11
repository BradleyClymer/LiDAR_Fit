function header_struct = read_urg_header( fid )
clc
if nargin == 0 , fid = fopen( 'all' ), end
frewind( fid )

header_cell = deal( textscan( fid , '%s %*s' , 22 ) )

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