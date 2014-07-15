h2.figure = figure( 'Units' , 'Normalized' , 'OuterPosition' , [ 1.2 .2 0.6 0.6 ] ,     ...
                    'NumberTitle' , 'off' , 'Name' , 'Parabola Squeeze Graph' )
h2.fit      = subplot( 1 , 1 , 1 )                
h2.bad_filt  = plot( 0 , 0 , 'bx' ,	'LineSmoothing' , 'on' ,                            ...
                                            'MarkerSize' , 3 ,                          ...
                                            'LineWidth' , 2 )                           ;     
                      set( h2.bad_filt ,    'MarkerEdgeColor' , 1/255 * [ 119 136 193 ] ...
                                       ,    'MarkerFaceColor' , 1/255 * [ 198 226 255 ] )
        hold on                              
        h2.red_filt = plot( 0 , 0 , 'r+' , 	'LineSmoothing' , 'on' ,                 	...
                                            'MarkerSize' , 3 ,                          ...
                                            'LineWidth' , 2 )                           ;
                       set( h2.red_filt ,   'MarkerEdgeColor' , 1/255 * [ 255 54 64 ]   ...
                                      ,     'MarkerFaceColor' , 1/395 * [ 139 35 35 ] )



        hold on 
        h2.parab     = plot( 0 , 0 , 'y' , 'LineSmoothing' , 'on' , 'LineWidth' , 2 )	;
%         h2.corner    = plot( angles_deg , pipe_diameter / 2 * ones( 1 , 1081 ) , 'g' ,   ...
%                                           'LineSmoothing' , 'on' , 'LineWidth' , 2 )    ;
        set( gca , 'Color' , [0.0500    0.0750    0.0750] )

        h2.fit_axes  = ancestor( h2.red_filt , 'Axes' )                                 ;
        h2.min_mark  = scatter( 0 , 0 , 'o', 'MarkerEdgeColor' , 'b' ,                  ...
                                            'MarkerFaceColor' , [ 0 0.5 0.5 ] ,         ...
                                            'LineWidth' , 3 )                           ;

        h2.bounds    = plot( [ 0         0       nan     180     180 ] ,                ...
                             [-100  	 100 	 nan    -100  	 100        ] )         ;
        set( h2.fit , 'XDir' , 'reverse' )                                
      	set( h2.fit , 'YLim' , [ 0 pipe_diameter ] )
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
        set( h2.fit_axes , 'XTick' , -60 : 30 : 255 )
%         set( h2.singlefig , 'OuterPosition' , [ 1.014    0.1037    0.8708    1.0000 ] )
        if add_legends
        legend( { 'Included Points' , 'Excluded Points' , 'Parabolic Fit Curve' , 'Parabola Vertex' } )
        end

        drawnow
        last_time       = tic                                                           ;
        ifp             = urg_struct(1).header.scanMsec * 1e-3                          ;
        num_scans       = numel( urg_struct )                                           ;
        fixed_scan      = 79770                                                         ;  
        generate_polynomial_title                                                       ;