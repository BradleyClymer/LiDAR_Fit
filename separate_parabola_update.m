fit_title{ i_scan }     = sprintf( fit_title_string ,                                    	...
                                     p( i_scan , : ) , vertex( i_scan , : ) - [ 90 0 ] ) 	;
generate_polynomial_title
% set( h2.range , 'XData' , patch_x , 'YData' , patch_y , 'ZData' , patch_z )
set( get( h2.fit,    'Title' ) , 'String' , fit_title{ i_scan } )                            ;   %   Parabola Subplot Title

set( h2.bad_filt,    'XData' , angles_deg( ~fit_range( i_scan , : ) ) ,                      ...
                    'YData' , all_med( i_scan , ~fit_range( i_scan , : ) )  )           	;   %   Bad fit scatter
                    
set( h2.red_filt,    'XData' , angles_deg( fit_range( i_scan , : ) ) ,                       ...
                    'YData' , all_med( i_scan , fit_range( i_scan , : ) )  )                ;   %   Red fit scatter
try
set( h2.min_mark,    'XData' , vertex( i_scan, 1 ) , 'YData' , vertex( i_scan, 2 ) )         ;   %   Parabola Vertex
catch
end
set( h2.parab ,      'XData' , angles_deg( : ) ,   'YData' , fit_curve( i_scan , : ) )       ;   %   Fit Parabola
set( h2.bounds ,     'XData' , [ bounds( i_scan ).min bounds( i_scan ).min nan bounds( i_scan ).max bounds( i_scan ).max ] ,         ...
                    'YData' , [ -100       100        nan -100       100        ] )         ;    