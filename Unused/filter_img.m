
if ~exist( 'subscan' , 'var' ) 
    subscan     = all_scans( 1 : 300 , : ) ;
    subscan( isnan( subscan ) ) = nanmean( subscan( : ) )
end
close all
h.filt      = figure( 'Numbertitle' , 'off' , 'Units' , 'Normalized' , 'Position' , [ 1.0 0 1 1 ] ) 

for i = 1 : 300
set( h.filt , 'Name' , num2str( i ) )
med         = medfilt2( subscan, 1*[ 6 i ] )                                      ;

size( med ) 
% plot( med( i ,
subplot( 2 , 2 , 1 )
imagesc( med )   
if i == 2
    subplot( 2 , 2 , 3 )
    imagesc(  med  )
end
colormap( 'jet' )
% pause

subplot( 2 , 2, [ 2 4 ] )
scan            = med( 225 , : ) 
x_scan          = scan( : ) .* x_weight( : )                    ;
y_scan          = scan( : ) .* y_weight( : )                 	;
plot( x_scan , y_scan , 'LineSmoothing' , 'on' )
grid on, axis square
drawnow

pause( 1.5 )
end

scan            = med( 225 , : ) 
x_scan          = scan( : ) .* x_weight( : )                    ;
y_scan          = scan( : ) .* y_weight( : )                 	;
figure 
plot( scan )


