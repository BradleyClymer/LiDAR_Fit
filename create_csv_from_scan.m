i_scan          = 1
i_angle         = 1
% for i_scan = 1:5
%     for i_angle = 1 : 1081 
% x               = x_scan( i_scan , i_angle )                    ;
% y               = urg_ft( i_scan ) * 12                         ;
% z               = y_scan( i_scan , i_angle )                    ;
%                   fprintf( '%0.2f,%0.2f,%0.2f\n' , x , y , z )  
%     end
% end
urg_rep         = repmat( urg_ft , 1 , 1081 )                       ;
full_scan = [ x_scan( : ) , urg_rep( : ) , y_scan( : ) ]            ;

filename    = [ fn 'XYZ.csv' ]
tic
csvwrite( filename , full_scan )
toc
winopen( filename )