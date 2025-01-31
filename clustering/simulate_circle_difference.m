function g=simulate_cirlce_difference(sigma,npoints)

% (C) 2024 Moo K. Chung
% University of Wisonsin-Madison

% g=simulate_cirlce_difference(sigma)
%simulate topologically different circular patterns with noise level sigma

nGroup1 = 5;
nGroup2 = 5;
nGroup3 = 5;
nGroup4 = 5;
g1 = cell(nGroup1, 1);
g2 = cell(nGroup2, 1);
g3 = cell(nGroup3, 1);
g4 = cell(nGroup4, 1);

%two circles horizontally
for i=1:nGroup1
    circle1 = graph_circle([-1 0],1.5, npoints, sigma);
    circle2 = graph_circle([1.5 0],1, npoints, sigma);

    %circle1 = graph_arc([-0.5 0],1.5, [0 2*pi], npoints, sigma);
    %circle2 = graph_arc([1 0],1, [0 2*pi], npoints, sigma);

    g1{i}=[circle1; circle2];
end

%two circles translated to right
for i=1:nGroup2
    circle1 = graph_circle([-1 0],1.5, npoints, sigma);
    circle2 = graph_circle([1 0],1, npoints, sigma);

      %circle1 = graph_arc([-0.5 0],1.5, [0 2*pi], npoints, sigma);
    %circle2 = graph_arc([1 0],1, [pi/15   2*pi-pi/15], npoints, sigma);
    g2{i}=[circle1; circle2];
end

%two circles vertically
for i=1:nGroup3
    circle1 = graph_circle([-1 0],1.5, npoints, sigma);
    circle2 = graph_arc([1.5 0],1, [pi/10 2*pi-pi/10], npoints, sigma);

    %circle1 = graph_arc([-0.5 0],1.5, [pi+pi/20 pi-pi/20+2*pi], npoints, sigma);
    %circle2 = graph_arc([1 0],1, [pi/15   2*pi-pi/15], npoints, sigma);
    g3{i}=[circle1; circle2];
end

for i=1:nGroup4
    circle1 = graph_arc([-1 0],1.5, [pi/12 2*pi-pi/12], npoints, sigma);
    circle2 = graph_arc([1.5 0],1, [pi/10 2*pi-pi/10], npoints, sigma);

    %circle1 = graph_arc([-0.5 0],1.5, [pi/20 2*pi-pi/20], npoints, sigma);
    %circle2 = graph_arc([1 0],1, [pi+pi/20   pi-pi/20+ 2*pi], npoints, sigma);
    g4{i}=[circle1; circle2];
end


% for i=1:nGroup4
%     circle1 = graph_circle([0.5 0],1.5, 60, sigma);
%     circle2 = graph_circle([-0.5 0],1.5, 60, sigma);
%     g4{i}=[circle1; circle2];
% end

% for i=1:nGroup1
%     circle1 = graph_arc([-0.5 0],1.5, [0 2*pi], npoints, sigma)
%     circle2 = graph_arc([1 0],1, [0 2*pi], npoints, sigma)
%     obs =[circle1; circle2];
%     g1{i}=obs;
% end
% 
% for i=1:nGroup2
%     circle1 = graph_arc([-0.5 0],1.5, [0 2*pi], npoints, sigma)
%     circle2 = graph_arc([1 0],1, [pi/15   2*pi-pi/15], npoints, sigma)
%     obs =[circle1; circle2];
%     g2{i}=obs;
% end
% 
% for i=1:nGroup3
%     circle1 = graph_arc([-0.5 0],1.5, [pi+pi/20 pi-pi/20+2*pi], npoints, sigma)
%     circle2 = graph_arc([1 0],1, [pi/15   2*pi-pi/15], npoints, sigma)
%     obs =[circle1; circle2];
%     g3{i}=obs;
% end
% 
% for i=1:nGroup4
%     circle1 = graph_arc([-0.5 0],1.5, [pi/20 2*pi-pi/20], npoints, sigma)
%     circle2 = graph_arc([1 0],1, [pi+pi/20   pi-pi/20+ 2*pi], npoints, sigma)
%     obs =[circle1; circle2];
%     hold on; plot(obs(:,1), obs(:,2),'.k');
%     coord=[obs(:,1)  obs(:,2)];
%     g4{i}=obs;
% end

g=[g1 g2 g3 g4];