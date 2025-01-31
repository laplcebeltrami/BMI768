function coord = graph_circle(center,radius, n, sigma)
%function coord = graph_circle(center,radius)
%
%Draw a circle at center with radius



theta = linspace(0,2*pi,n); %sample n points along circle

x=radius*(cos(theta)+center(1));
y=radius*(sin(theta)+center(2));
coord=[x ; y]'; %2 x n matrix

coord=coord + normrnd(0,sigma,n,2);