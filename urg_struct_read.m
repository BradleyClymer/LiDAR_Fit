function urg_struct = urg_struct_read( fid )
    clc
    if nargin == 0, fid = fopen( 'all' ), end                                                               ;
    header_struct       = read_urg_header( fid )                                                            ; 
    field_cell          = textscan( fid , '%s' ,'CollectOutput' , true , 'CommentStyle' , { '[' , ']' } , 'BufSize' , 100000 )   ;    
    field_string        = field_cell{ 1 }                                                                   ;
    if strcmp( field_cell{ 1 }{ 3 }( 3 ) , ':' )
        temp_cols           = reshape( field_string  , 4 , [] )'                                            ;
        temp_cols( : , 2 )  = []                                                                            ;
        cols                = temp_cols                                                                     ;
    else
        cols                = reshape( field_string  , 3 , [] )'                                         	;
    end
    
    cellnum             = @( v ) str2double( v )                                                            ;
    formatIn            = 'yyyy:m:dd:HH:MM:SS:FFF'                                                          ; 
    datefunc            = @( c ) cellfun( datenum( c , evalin( 'caller' , 'formatIn' ) ) )                  ;
    scanfunc            = @( row ) ( textscan( row , '%f' , 1081 , 'Delimiter' , ';' ) )                    ;
    date                = cols( : , 2 )                                                                     ;
    tstamp              = cellfun( cellnum  , cols( : , 1 ) , 'UniformOutput' , false )                     ;
    cellscan            = cellfun( scanfunc , cols( : , 3 ) )                                               ;
    urg_struct          = struct( 'dateString' ,    date ,                                                  ...
                                  'timeStamp' ,     tstamp ,                                                ...
                                  'scan' ,          cellscan ,                                              ...
                                  'header' ,        header_struct                                         ) ;
end