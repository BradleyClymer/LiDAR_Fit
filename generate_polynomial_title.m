fit_title_string    = [ 'Fit Polynomial: %0.2f*\\theta^' num2str( fit_order ) ' +']             ;
for i = ( fit_order - 1 ) : -1 : 2
    fit_title_string = [ fit_title_string sprintf( ' %%0.2f*\\\\theta^%i +' , i ) ]             ;
end
fit_title_string = [ fit_title_string ' %0.2f*\\theta + %0.2f -- Vertex: %0.1f°, %0.2f"' ]