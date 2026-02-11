function [F, EdgesLex] = adj2flows(Ytau_all)
% ADJ2FLOWS  Convert antisymmetric adjacency tensor to edge-flow tensor (upper triangle only).
%
% INPUT
%   Ytau_all : [p x p x nT x nSub] antisymmetric adjacency (Y(i,j) = -Y(j,i), diag=0)
%
% OUTPUT
%   F        : [E x nT x nSub] edge-flow tensor for undirected base edges (i<j)
%   EdgesLex : [E x 2] base edge list [i j] with i<j in lexicographic order
%              (1,2),(1,3),...,(1,p),(2,3),...,(p-1,p)
%
% Notes
%   - For antisymmetric input, Y(i,j) completely determines Y(j,i)=-Y(i,j),
%     so only the upper triangle is stored.
%   - This is a pure indexing transform; no thresholding, no sparsification.
%
% (C) 2026 Moo K. Chung
% University of Wisconsin–Madison

[p,~,nT,nSub] = size(Ytau_all);

% -------------------- build upper-triangular lexicographic edge list --------------------
I = repelem((1:p)', p);
J = repmat((1:p)',  p, 1);
keep = (I < J);                          

EdgesLex = [I(keep) J(keep)];
idx = sub2ind([p p], EdgesLex(:,1), EdgesLex(:,2));

E = size(EdgesLex,1);

% -------------------- vectorized extraction --------------------
Y2 = reshape(Ytau_all, p*p, nT*nSub);
F2 = Y2(idx, :);
F  = reshape(F2, E, nT, nSub);

F = single(F);                          
end