function h = rough_plot( varargin )
h( 1 )  = figure( 'Units' , 'Normalized' , 'Position' , [ 0.1 0.1 0.8 0.8 ] )   ;
root    = sqrt( nargin )                                        ;
pow     = nextpow2( nargin )                                    ;
% twos    = numel( factor( 2 ^ nextpow2( nargin ) ) )             
twos    = log2( 2 ^ nextpow2( nargin ) )                        ;               
rows    = 2 ^ floor( twos / 2 )                                 ;
cols    = rows + 1                                              ;

for i = 1 : nargin
    h( i+1 )= subplot( rows , cols , i )                        ;
              plot( varargin{ i } , 'LineSmoothing' , 'on' )    ;
    s       = mean( std( varargin{ i } ) )                      ;
    m       = mean( mean( varargin{ i } ) )                     ;
    axis tight
    ylim( [ m - 1*s , m + 1*s ] )
    grid on
    title( inputname( i ) , 'Interpreter' , 'none' )
end
    