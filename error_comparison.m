close all
all_scans   = all_scans( ~isnan( all_scans ) )                                                                  ;
for i = 1 : 50
filtered    = medfilt2( all_scans , [ 2 * i - 1 , 1 ] )                                                       	;
top         = subplot( 2 , 1 , 1 ) , imagesc( filtered )                                                        ;
ave         = repmat( nanmean( all_scans ) , size( all_scans , 1 ) , 1 )                                        ;
bot         = subplot( 2 , 1 , 2 ) , imagesc( ave )
error       = nanmean( filtered - ave )                                                                                    
ove         = axes( 'Position' , get( bot , 'Position' ) , 'Layer' , 'top' , 'YAxisLocation','right','Color','none','XTickLabel',[])
              plot( error )
              axis( ove , 'off' , 'tight' )
%               set( ove , )
drawnow
end