h.singlefig = figure( 'NumberTitle' , 'off' , 'Name' , 'Fit of Lidar to Pipe' )
    h.scan      = subplot( 1 , 4 , 1:3 )
        hold on  
        set( gca , 'Color' , [0.0500    0.0750    0.0750] )                        
        hold on 
        h.fit_p     = plot( 0 , 0 , 'w' , 'LineSmoothing' , 'on' , 'LineWidth' , 2 )	;
        h.circle    = plot( 0 , 0 , 'y' , 'LineSmoothing' , 'on' , 'LineWidth' , 2 ,    ...
                                          'Marker' , '.' , 'LineStyle' , 'none' )       ;
                                      
        circle_template.x     = pipe_in * x_weight                                      ;
        circle_template.y     = pipe_in * y_weight                                      ;
        h.template  = plot( circle_template.x ,                                         ...
                            circle_template.y ,                                         ...
                            'Color' , 0.6 * [ 1 0.8 1 ] ,                               ...
                            'LineStyle' , 'none' ,                                    	...
                            'LineSmoothing' , 'on' ,                                    ...
                            'LineWidth' , 3 ,                                           ...
                            'Marker' , '.' ,                                        	...
                            'LineStyle' , '-' )                                         ;
        set( h.template , 'ZData' , -1 * ones( size( get( h.template , 'XData' ) ) ) )  ;
        plot( 100 * [ -1 1 ] , [ 0 0 ] , 'Color' , [ 0 0 1 ] , 'LineSmoothing' , 'on' )
        plot( [ 0 0 ] , 100 * [ -1 1 ] , 'Color' , [ 0 0 1 ] , 'LineSmoothing' , 'on' )
        axis equal
        grid on
        xlabel( 'Inches' )
        ylabel( 'Inches' )
        file_title  = urg_file                  ;
        % file_title( file_title == '_' ) = '-'   ;
        strrep( file_title , '\' , '\\' )
        title( file_title  )

        set( gcf, 'Units' , 'Normalized' , 'Numbertitle' , 'Off' , 'Name' , [ 'Fit of Lidar to Pipe ' urg_file ] )
        xlim( 1.2 * pipe_in * [ -1 1 ] + [ -2 2 ] )
        ylim_offset                                     = 4
        ylim( pipe_in * [ -1 1 ] + ylim_offset )
        if add_legends

        legend( { 'Raw Noisy Data' ,            ...
                  'Median Filtered' ,           ...
                  'Shifted',                    ...
                  'Pipe Fit' ,                  ...
                  'Pipe Template' } ,           ...
                  'Location' ,                  ...
                  'Best' )          ;
        end
            
    h.fit       = subplot( 2 , 4 , 4 )                                                  ;
        h.bad_filt  = plot( 0 , 0 , 'bx' ,	'LineSmoothing' , 'on' ,                 	...
                                            'MarkerSize' , 3 ,                          ...
                                            'LineWidth' , 2 )                           ;     
                      set( h.bad_filt ,     'MarkerEdgeColor' , 1/255 * [ 119 136 193 ] ...
                                      ,     'MarkerFaceColor' , 1/255 * [ 198 226 255 ] )
        hold on                              
        h.red_filt 	= plot( 0 , 0 , 'r+' , 	'LineSmoothing' , 'on' ,                 	...
                                            'MarkerSize' , 3 ,                          ...
                                            'LineWidth' , 2 )                           ;
                      set( h.red_filt ,     'MarkerEdgeColor' , 1/255 * [ 255 54 64 ]   ...
                                      ,     'MarkerFaceColor' , 1/395 * [ 139 35 35 ] )



        hold on 
        h.parab     = plot( 0 , 0 , 'y' , 'LineSmoothing' , 'on' , 'LineWidth' , 2 )    ;
%         h.corner    = plot( angles_deg , pipe_diameter / 2 * ones( 1 , 1081 ) , 'g' ,   ...
%                                           'LineSmoothing' , 'on' , 'LineWidth' , 2 )    ;
        set( gca , 'Color' , [0.0500    0.0750    0.0750] )

        h.fit_axes  = ancestor( h.red_filt , 'Axes' )                                   ;
        h.min_mark  = scatter( 0 , 0 , 'o', 'MarkerEdgeColor' , 'b' ,                   ...
                                            'MarkerFaceColor' , [ 0 0.5 0.5 ] ,         ...
                                            'LineWidth' , 3 )                           ;

        h.bounds    = plot( [ 0         0       nan     180     180 ] ,                 ...
                            [ -100  	100 	nan     -100  	100        ] )          ;
        set( h.fit , 'XDir' , 'reverse' )                                
      	set( h.fit , 'YLim' , [ 0 pipe_diameter ] )
        % axis equal
        grid on
        xlabel( '\theta, Degrees, -45 : 225' )
        ylabel( '\rho, Inches' )
        set( gcf, 'Units' , 'Normalized' )
        xlim( [ -45 225 ] )
        disp( 'Quantiles Calculated.' )
        % ylim( quants + [ -0.5 0.5 ] )
        ylim( [ 8 ( pipe_diameter - ( float_width/2 ) ) ] )
        % all_args        = { all_x , all_y , z_grid , 'EdgeColor' , 'none' }         ;
        set( h.fit_axes , 'XTick' , -60 : 30 : 255 )
        set( h.singlefig , 'OuterPosition' , [ 1.014    0.1037    0.8708    1.0000 ] )
        if add_legends
        legend( { 'Included Points' , 'Excluded Points' , 'Parabolic Fit Curve' , 'Parabola Vertex' } )
        end

        drawnow
        last_time       = tic                                                       ;
        ifp             = urg_struct(1).header.scanMsec * 1e-3                      ;
        num_scans       = numel( urg_struct )                                       ;
        fixed_scan      = 79770                                                     ;
        generate_polynomial_title
        old_axes        = gca                                                       ;
        if add_parab_fig
            generate_parabola_separately
        end
        axes( old_axes ) 
h.corrosion         = subplot( 2 , 4 , 8 )                                          ;
    h.corr              = plot( 1 , 1 , 'Color' , 'r' , 'LineSmoothing' , 'on' , 'MarkerFaceColor' , [ 1 .8 .8 ] , 'MarkerEdgeColor' , 'none' , 'LineStyle' , '-' , 'Marker' , 'o' , 'LineWidth' , 3 )     ;
    ylim( [ 0 round( pipe_diameter / 4 ) ] )
    grid on        
    title( 'Corrosion Area, in^2' )

    inner_ring_x            = pipe_in * x_weight                                        ;
    inner_ring_y            = pipe_in * y_weight                                        ;           
axes( h.scan )
    hold on