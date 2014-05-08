function header_struct = read_urg_header( fid )
clc
if nargin == 0 , fid = fopen( 'all' ), end
%%
clc
frewind( fid )

num_tests   = 40                                                                            ;

test_cell   = textscan( fid , '%s %*s' , num_tests ,                                        ...
                        'BufSize' , 100000 ,                                                ...
                        'TreatAsEmpty', ' ' )                                               ;
test_cell   = test_cell{ 1 }                                                                ;
i           = 2                                                                             ;
while i <= numel( test_cell )
    if test_cell{ i }( 1 ) == '[' && test_cell{ i-1 }( 1 ) == '['
        test_cell = [ test_cell( 1 : i-1 ) ; { NaN } ; test_cell( i : end ) ]               ;
        num_tests = num_tests + 1                                                           ;
        disp( '같같같같Value inserted같같같같같' )
    end
    i   = i+1                                                               ;
end
begin_cell      = repmat( { '[timestamp]' } , num_tests , 1 )           	;
first_scan      = find( strcmpi( test_cell , begin_cell ) , 1 , 'first' )   ;               
                  frewind( fid )                                            ;
header_cell     = deal( textscan( fid , '%s %*s' , first_scan - 1 ) )       ;
header_cell     = header_cell{ 1 }                                          ;

for i_fields = 1 : first_scan/2
    raw_field                       = test_cell{ 2 * i_fields - 1 }         ;
    curr_field                      = raw_field( 2 : end-1 )                ;
    dashes                          = curr_field == '-'                     ;
    curr_field( dashes )            = '_'                                   ;
    header_struct.( curr_field )    = test_cell{ 2 * i_fields }             ;
end
end