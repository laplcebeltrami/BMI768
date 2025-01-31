function g = coord2dist(coord)
%function g = coord2dist(coord)
%Converts the coordinates to distance matrices


%nN: number of networks
%NC: number of clusters
[nN nC] = size(coord); 
g = cell(nN, nC);

for j=1:nC
    for i=1:nN
        nodes= coord{i,j};
        %C = pdist2(nodes,nodes);

        C = pdist(nodes);
        C=squareform(C);
        g{i,j}=C;
    end
end


