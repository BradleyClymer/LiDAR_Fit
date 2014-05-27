function urg_struct = urg_struct_read( fid )
tic
    if nargin == 0, fid = fopen( 'all' ); end                                                               ;
    header_struct       = read_urg_header( fid )                                                            ; 
    disp( 'Grabbing raw field data.' )
    field_cell          = textscan( fid , '%s' ,                                                            ...
                                          'CollectOutput' ,     true ,                                      ...
                                          'CommentStyle' ,      { '[' , ']' } ,                             ...
                                          'BufSize' ,           100000 )                                    ;    
    disp( 'Raw data acquired.' )
    field_string        = field_cell{ 1 }                                                                   ;
    if strcmp( field_cell{ 1 }{ 3 }( 3 ) , ':' )
        temp_cols           = reshape( field_string  , 4 , [] )'                                            ;
        temp_cols( : , 2 )  = []                                                                            ;
        cols                = temp_cols                                                                     ;
    else
        cols                = reshape( field_string  , 3 , [] )'                                         	;
    end
    
    cellnum             = @( v ) str2double( v )                                                            ;
    formatIn            = 'yyyy:mm:dd:HH:MM:SS:FFF'                                                          ; 
    datefunc            = @( c ) cellfun( datenum( c , evalin( 'caller' , 'formatIn' ) ) )                  ;
    scanfunc            = @( row ) ( textscan( row , '%f' , 1081 , 'Delimiter' , ';' ) )                    ;
    disp( 'Extracting date cell from strings.' )
    date                = cols( : , 2 )                                                                     ;
    date_cell           = cellfun( @( x ) textscan( x , '%d:%d:%d:%d:%d:%d:%d' , 1 , 'CollectOutput' , true ) , cols( : , 2 ) , 'UniformOutput' , true )    ;
    d_a                 = double( reshape( [ date_cell{ : } ]' , 7 , [] )' )                                ;
    clear d_v
    disp( 'Converting Serial Date.' )
    for i = 1 : numel( date_cell )
        d_v( i )    = datenum( d_a( i , 1:6 ) + [ 0 0 0 0 0 d_a( i , 7 )/1000 ] )                           ;
    end
    disp( 'Converting scan text to vectors.' )
    cellscan            = cellfun( scanfunc , cols( : , 3 ) )                                               ;
    disp( 'Assembling Scan Structure.' )
    urg_struct          = struct( 'dateString' ,    date ,                                                  ...
                                  'scan' ,          cellscan ,                                              ...
                                  'timeStamp' ,     num2cell( d_v )' ) ;
	urg_struct( 1 ).header   = header_struct                                                           	;
    urg_struct( 1 ).date_vec = date_cell{ 1 }( 1 : 3 )
    disp( 'Structure assembled.' )
toc
end
%     tstamp              = cellfun( cellnum  , cols( : , 1 ) , 'UniformOutput' , false )                     ;
%     tstamp              = cellfun( @( d ) datenum( d , formatIn ) , date )                                  ;