function match_indeces = vector_nearest_match( reference , objective )
%   This function takes in a reference vector - usually the smaller of the
%   two - and an objective vector. The output is the indeces of the
%   reference vector that contain the values closest to those of the
%   objective vector. 
demo        = nargin == 0                                           ;
if demo
    reference   = [   2      4.5         7.5    ]
    objective   = [ 1 2 3    4 5       6 9 10 0 ]
end

reference         	= reference( : )                                ;
objective         	= objective( : )                                ;
ref_sz            	= numel( reference )                            ;

matrix_product      = reference * objective'                        ;
obj_sq_mat          = repmat( ( objective .^2 ).' , ref_sz , 1 )    ;

difference          = abs( obj_sq_mat - matrix_product )            ;
min_diff_vec        = min( difference )                             ;
min_diff_mat        = repmat( min_diff_vec , ref_sz , 1 )           ;
truth               = min_diff_mat == difference                    ;          
[ row , col , ~ ]   = find( truth )                                 ;
uni                 = logical( [ 1 ; diff( col ) ] )                ;
match_indeces       = row( uni )                                    ;            
end