function toggle( handle )
visible     = strcmpi( get( handle , 'Visible' ) , 'on' )    ;
if visible
    set( handle , 'Visible' , 'off' )
else
    set( handle , 'Visible' , 'on' ) 
end