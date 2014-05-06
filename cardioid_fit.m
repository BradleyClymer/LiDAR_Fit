% This function is called by lsqnonlin.
% x is a vector which contains the coefficients of the
% equation.  X and Y are the option data sets that were
% passed to lsqnonlin.
A=x(1);
B=x(2);
C=x(3);
D=x(4);
E=x(5);
diff = A + B.*exp(C.*X) + D.*exp(E.*X) - Y;
The following script is an example of how to use fit_simp.m:

% Define the data sets that you are trying to fit the
% function to.
X=0:.01:.5;
Y=2.0.*exp(5.0.*X)+3.0.*exp(2.5.*X)+1.5.*rand(size(X));
% Initialize the coefficients of the function.
X0=[1 1 1 1 1]';
% Calculate the new coefficients using LSQNONLIN.
x=lsqnonlin(@fit_simp,X0,[],[],[],X,Y);
% Plot the original and experimental data.
Y_new = x(1) + x(2).*exp(x(3).*X)+x(4).*exp(x(5).*X);
plot(X,Y,'+r',X,Y_new,'b')