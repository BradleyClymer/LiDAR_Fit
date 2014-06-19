function urg_struct = urg_struct_read( fid )
tic
    if nargin == 0, fid = fopen( 'all' ); end                                                               ;
    header_struct       = read_urg_header( fid )                                                            ; 
    disp( 'Grabbing raw field data.' )
    field_cell          = textscan( fid , '%s' ,                                                            ...
                                          'CollectOutput' ,     true ,                                      ...
                                          'CommentStyle' ,      { '[' , ']' } ,                             ...
                                          'BufSize' ,           100000 )                                    ;    
    fprintf( 'Raw data acquired.\n\n' )
    field_string        = field_cell{ 1 }                                                                   ;
    disp( 'Converting date to serial number.' )
    if strcmp( field_cell{ 1 }{ 2 }( 5 ) , '-' )
        temp_cols           = reshape( field_string  , 4 , [] )'                                            ;
        cols                = temp_cols                                                                     ;
        num_cells           = size( cols , 1 )                                                              ;
        formatIn            = 'yyyy-mm-dd HH:MM:SS.FFF'                                                     ;
        cell_func           = @( d , t ) datevec( [ d , ' ' , t ] , formatIn )                              ;
        d_c                 = cellfun( cell_func , cols( : , 2 ) , cols( : , 3 ) , 'UniformOutput' , false );
        d_a                 = num2cell( datenum( cell2mat( d_c ) ), 2 )                                     ;
        scan_column         = 4                                                                             ;
    else
        temp_cols           = reshape( field_string  , 3 , [] )'                                            ;
        cols                = temp_cols                                                                     ;
        num_cells           = size( cols , 1 )                                                              ;
        formatIn            = 'yyyy:mm:dd:HH:MM:SS:FFF'                                                     ;
        cell_func           = @( d ) datevec( d , formatIn )                                                ;
        d_c                 = cellfun( cell_func , cols( : , 2 ) , 'UniformOutput' , false )                ;
        d_a                 = num2cell( datenum( cell2mat( d_c ) ), 2 )                                     ;
        scan_column         = 3                                                                             ;
    end
    fprintf( 'Date information parsed.\n\n' )
    scanfunc            = @( row ) ( textscan( row , '%f' , 1081 , 'Delimiter' , ';' ) )                    ;
    disp( 'Converting scan text to vectors.' )
    cellscan            = cellfun( scanfunc , cols( : , scan_column ) )                                     ;
    disp( 'Assembling Scan Structure.' )
    urg_struct          = struct( 'dateString' ,    date ,                                                  ...
                                  'scan' ,          cellscan ,                                              ...
                                  'timeStamp' ,     d_a ) ;
	urg_struct( 1 ).header   = header_struct                                                              	;
    urg_struct( 1 ).date_vec = d_c{ 1 }( 1 : 3 )                                                            ;
    disp( 'Structure assembled.' )
toc
end