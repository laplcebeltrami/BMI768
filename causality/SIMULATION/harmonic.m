function out = harmonic(X)
% HARMONIC Harmonic (cycle) projection of a directed edge flow.
%
% For a pure 1-skeleton (no triangles), the Hodge split is
%   edge-flow = gradient + harmonic,
% and the curl component is identically zero.
%
% INPUT
%   X     : [E x 1] flow on edges (aligned with lexicological Edges)
%
% OUTPUT (baseline style)
%   out.connectivity : [|V| x |V|] antisymmetric harmonic matrix H
%                      out.connectivity(i,j) = harmonic flow i->j
%   out.flows        : [|E| x 1] edge-aligned harmonic flow vector
%                      out.flows(e) = out.connectivity(i,j) for Edges(e,:)=[i j]
%   out.Edges        : [|E| x 2] lexicologically ordered edge list
%
% (C) 2026 Moo K. Chung

% infer number of nodes from number of edges in a complete graph
E = length(X);                              
p = (1 + sqrt(1 + 8*E))/2;

% construct lexicological edge list i -> j, i < j
Edges = zeros(E,2);
cnt = 0;
for i = 1:p-1
    for j = i+1:p
        cnt = cnt + 1;
        Edges(cnt,:) = [i j];
    end
end

Nodes = (1:p)';

% flow to antisymmetric flow matrix
TE_as = flow2matrix(Nodes, Edges, X);    

% Build 1-skeleton simplicial complex
S = adj2simplex(TE_as, 1);

% Boundary operator
B = PH_boundary(S);

% extract edge list used by boundary operator
if isstruct(S) && isfield(S,'edges')
    EdgesB = S.edges;
else
    EdgesB = S{2,1};
end

% edge flow aligned with boundary operator ordering
flowB = adj2edgeflow(EdgesB, TE_as);

% Hodge decomposition
[~, ~, flowH_B] = Hodge_decompose_edgeflow(flowB, B);

% Build harmonic antisymmetric matrix
H = zeros(p,p,'single');

iB = EdgesB(:,1);
jB = EdgesB(:,2);

H(sub2ind([p p], iB, jB)) = single(flowH_B);
H(sub2ind([p p], jB, iB)) = -single(flowH_B);

% map back to original lexicological ordering
flowH = H(sub2ind([p p], Edges(:,1), Edges(:,2)));

% outputs
out.connectivity = H;
out.flows        = flowH;
out.Edges        = Edges;

end


