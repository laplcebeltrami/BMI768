function coord = graph_arc(center,radius, arc, n, sigma)
%function coord = graph_arc(center,radius, arc, n, sigma)
%
%Draw a circle at center with radius between arc


theta = linspace(arc(1),arc(2),n); %sample n points along circle

x=radius*(cos(theta)+center(1));
y=radius*(sin(theta)+center(2));
coord=[x ; y]'; %2 x n matrix

coord=coord + normrnd(0,sigma,n,2);