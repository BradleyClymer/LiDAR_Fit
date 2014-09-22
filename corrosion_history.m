his.radius          = 120                                        ;
his.num_stds        = 5                                         ;
his.error_tol       = 3                                         ;
his.start           = max( [ 1 , ( i_scan-his.radius ) ] )      ;
his.end             = i_scan                                    ;
his.range           = his.start : his.end                       ;
his.area            = corrosion( his.range )                    ;
his.max             = max_corrosion( his.range )                ;
his.maxstd          = std( his.area )                        	;
his.maxmean         = mean( his.area )                       	;
his.areamedian      = median( his.area )                        ;
his.iqr             = iqr( his.area ) / 2                       ;
his.oldlims         = get( h.corrosion , 'YLim' )               ;
his.std_range       = his.iqr * ( his.num_stds * [ 1 -1 ] )     ; 
his.newlims         = ( his.areamedian - his.std_range )
his.error           = his.oldlims - his.newlims                 ;
if any( abs( his.error ) > his.maxstd ) && any( his.newlims )
    set( h.corrosion , 'YLim' , his.newlims )
end

