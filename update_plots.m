  
if ~exist( 'fit_center' , 'var' ) || ~ishandle( fit_center )                 
fit_center      = scatter( -par( i_scan , 1 ) , -par( i_scan , 2 ) )                    ;
else 
    set( fit_center , 'XData' , -par( i_scan , 1 ) , 'YData' , -par( i_scan , 2 ) )     ;
end

set( h.corr ,             'XData' , urg_ft( 1 : max( corr_range ) ) ,                              ...
                          'YData' , corrosion( 1 : max( corr_range ) ) )                 	;
get( h.corrosion , 'XTick' )                      
% set( h.corrosion , 'XLim' , corr_bounds ,                                                   ...
%                    'XTick' , corr_range ,                                                   ...
%                    'XTickLabel' , num2str( fliplr( urg_ft( corr_range ) ) , '%3.2f') )  
axes( h.corrosion )
% curr_xl             = [ urg_ft( min( corr_range ) ) urg_ft( max( corr_range ) ) ]           ;
curr_xl             = mean( minmax( urg_ft( corr_range ) ) ) + [ -0.4 0.2 ] 
if isempty( curr_xl ) || ~any( curr_xl )
    curr_xl = [ 0 1 ]       
end
xlim( curr_xl )
% set( h.range , 'XData' , patch_x , 'YData' , patch_y , 'ZData' , patch_z )
set( get( h.fit,    'Title' ) , 'String' , fit_title{ i_scan } )                            ;   %   Parabola Subplot Title
%   set( h.med ,    'XData' , med_x , 'YData' , med_y )                                     ;   %   Cyan Fat Partial Circle
% set( h.raw_p,       'XData' , data.x( i_scan , : ) , 'YData' , data.y( i_scan , : )  )      ;   %   Red Fat Line
set( h.fit_p ,      'XData' , x_scan( i_scan , :  ) ,'YData' , y_scan( i_scan , : )  )  	;   %   White Fat Line
set( h.circle ,     'XData' , par( i_scan, 3 ) * cosd( 0 : 360 ) ,                          ...
                    'YData' , par( i_scan, 3 ) * sind( 0 : 360 ) )                          ;   %   Yellow Centered Best-Fit Circle

set( h.bad_filt,    'XData' , angles_deg( ~fit_range( i_scan , : ) ) ,                      ...
                    'YData' , all_med( i_scan , ~fit_range( i_scan , : ) )  )           	;   %   Bad fit scatter
                    
set( h.red_filt,    'XData' , angles_deg( fit_range( i_scan , : ) ) ,                       ...
                    'YData' , all_med( i_scan , fit_range( i_scan , : ) )  )                ;   %   Red fit scatter
try
set( h.min_mark,    'XData' , vertex( i_scan, 1 ) , 'YData' , vertex( i_scan, 2 ) )         ;   %   Parabola Vertex
catch
end
set( h.parab ,      'XData' , angles_deg( : ) ,   'YData' , fit_curve( i_scan , : ) )       ;   %   Fit Parabola
set( h.bounds ,     'XData' , [ bounds( i_scan ).min bounds( i_scan ).min nan bounds( i_scan ).max bounds( i_scan ).max ] ,         ...
                    'YData' , [ -100       100        nan -100       100        ] )         ;    