function H = flow2matrix(Nodes, Edges, Yh)
% FLOW2MATRIX  Build an antisymmetric connectivity matrix from edge flows.

%
% Inputs:
%   Edges : m x 2 list of directed edges [i j] (flow is along i -> j)
%   Yh    : m x 1 vector of signed edge flows (same row order as Edges)

%
% Output:
%   H     : n x n antisymmetric matrix where
%             H(i,j) = Yh(k),  H(j,i) = -Yh(k)  for edge k = [i j]
%           Diagonal is zero. If multiple rows map to the same pair, flows
%           are summed.
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

    n = size(Nodes,1);
    H = zeros(n);
    
    % accumulate flows (supports repeated edges)
    for k = 1:size(Edges,1)
        i = Edges(k,1);
        j = Edges(k,2);
        w = Yh(k);
        if i==j, continue; end           % ignore self-edges if any
        H(i,j) = H(i,j) + w;
        H(j,i) = H(j,i) - w;
    end

    % enforce exact antisymmetry and zero diagonal
    H = (H - H.')/2;
    H(1:n+1:end) = 0;
end