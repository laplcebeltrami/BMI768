function flows = adj2edgeflow(Edges, adj)
% ADJ2EDGEFLOW  Output edge flows directly from adjacency matrix.
%
%   flows = adj2edgeflow(Edges, adj)
%
% Inputs:
%   Edges : m x 2 list of node pairs [i j], order preserved
%   adj   : R x R adjacency/flow matrix (not forced antisymmetric)
%
% Output:
%   flows : m x 3 array [i j w] where w = adj(i,j)
%
% (C) 2025 Moo K. Chung
% University of Wisconsin-Madison
% mkchung@wisc.edu
%
% The code is downloaded from
% https://github.com/laplcebeltrami/hodge
% If you are using the code, refernce one of Hodge papers listed in GitHub.
%
% Update history: November 7, 2025


    w = adj(sub2ind(size(adj), Edges(:,1), Edges(:,2)));
    flows = [Edges, w];
end