function y=spline_function(x)
x=x*2;%modifined
y=(x<=-2).*(zeros(size(x)))+...
    (-2<x & x<=-1).*(2+2*x+1/2*x.^2)+...
    (-1<x & x<=0).*(-2*x-3/2*x.^2)+...
    (0<x & x<=1).*(-2*x+3/2*x.^2)+...
    (1<x & x<=2).*(-2+2*x-1/2*x.^2)+...
    (2<x).*(zeros(size(x)));
y=y*4;%modifined