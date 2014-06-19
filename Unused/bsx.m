fun = @(A,B) A : B ;
A = 1:7';
B = pi*[0 1/4 1/3 1/2 2/3 3/4 1]';
C = bsxfun(fun,A,B)