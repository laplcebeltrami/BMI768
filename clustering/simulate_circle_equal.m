function g=simulate_cirlce_equal(sigma, npoints)
% g=simulate_cirlce_equal(sigma, npoints)
%simulate topologically equivalent circular patterns with noise level sigma

nGroup1 = 5;
nGroup2 = 5;
nGroup3 = 5;
nGroup4 = 5;
g1 = cell(nGroup1, 1);
g2 = cell(nGroup2, 1);
g3 = cell(nGroup3, 1);
g4 = cell(nGroup4, 1);


for i=1:nGroup1
    circle1 = graph_circle([1.5 0],1, npoints, sigma);
    circle2 = graph_circle([-1 0],1.5, npoints, sigma);

    obs =[circle1; circle2];
    %figure; imagesc(C); colorbar
    g1{i}=obs;
end

for i=1:nGroup2
    circle1 = graph_circle([-1.5 0],1, npoints, sigma);
    circle2 = graph_circle([1 0],1.5, npoints, sigma);
    obs =[circle1; circle2];
    g2{i}=obs;
end

for i=1:nGroup3
    %circle1 = graph_circle([0 2],1, 60, sigma);
    %circle2 = graph_circle([0 -1],1.5, 60, sigma);

    circle1 = graph_circle([-1.5 0],1, npoints, sigma);
    circle2 = graph_circle([1 0],1.5, npoints, sigma);
    obs =[circle1; circle2];
    g3{i}=obs;
end

for i=1:nGroup4
    %circle1 = graph_circle([0 1],1.5, 60, sigma);
    %circle2 = graph_circle([0 -2],1, 60, sigma);

     circle1 = graph_circle([0 1.5],1, npoints, sigma);
    circle2 = graph_circle([0 -1],1.5, npoints, sigma);

    obs =[circle1; circle2];
    g4{i}=obs;
end

g=[g1 g2 g3 g4];