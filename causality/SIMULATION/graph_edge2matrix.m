function Emat = graph_edge2matrix(Edges, X)
% GRAPH_EDGE2MATRIX  Convert edge flows into anti-symmetric matrix form to
% be used in the Hodge decompostion and boundary matrix computation, which
% inherently assume anti-symmetric matrix. 
%
%
%   Emat = graph_edge2matrix(Edges, X)
%
% Inputs
%   Edges : m x 2 list of directed edges [i,j] (i->j)
%   X     : m x 1 vector of edge flows/weights
%
% Output
%   Emat  : n x n antisymmetric matrix where Emat(i,j) = X(k), Emat(j,i) = -X(k) if Edges(k,:) = [i,j],
%           then scaled so that the maximum absolute off-diagonal entry equals 1.
%
% (c) 2025 Moo K. Chung
% University of Wisconsin-Madison
% mkchung@wisc.edu 
% 
% The code is downloaded from 
% https://github.com/laplcebeltrami/hodge
% If you are using the code, refernce one of Hodge papers listed in GitHub.  
%
% Update history: November 7, 2025


    n = max(Edges(:));
    Emat = zeros(n);

    for k = 1:size(Edges,1)
        i = Edges(k,1);
        j = Edges(k,2);
        Emat(i,j) = X(k);
        Emat(j,i) = -X(k);  % antisymmetric fill
    end

   
end