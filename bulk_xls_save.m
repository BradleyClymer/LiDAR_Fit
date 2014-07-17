function bulk_xls_save( urg_file , varargin )
[ pp , ff , ee ]    = fileparts( urg_file )
nargin
varargin
out_file            = fullfile( pwd , ff )
for i = 1 : numel( varargin )
    this_name   = inputname( nargin - numel( varargin ) + i ) 
    this_size   = size( varargin{ i } )
    this_out    = reshape( varargin{ i } , [] , min( this_size ) )      ;
    xlswrite( out_file , this_out , this_name )                         ;
end

winopen( [ out_file '.xls' ] )