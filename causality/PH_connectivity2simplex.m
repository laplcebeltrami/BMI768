function S = PH_connectivity2simplex(C, tau, maxDim)
% PH_connectivity2simplex constructs a simplicial complex from a correlation matrix.
%
%   S = PH_connectivity2simplex(C, tau, maxDim) builds a simplicial complex 
%   from the weighted connectivity matrix C (p x p) as follows:
%
%       - Nodes (0-simplices): Each of the p time series (or brain regions) is a node.
%
%       - Edges (1-simplices): An edge between nodes i and j is included if 
%         C(i,j) > tau.
%
%       - Triangles (2-simplices): A triangle among nodes i, j, and k is included if 
%         every pair among {i, j, k} has C > tau.
%
%       - Tetrahedra (3-simplices): A tetrahedron among nodes i, j, k, and l is included if
%         every pair among {i, j, k, l} has C > tau.
%
%       - And so on, up to the maximum simplex dimension maxDim.
%
%   The function returns a cell array S of simplices:
%       S{1}: p x 1 vector of nodes.
%       S{2}: Matrix of edges. Each row contains the indices of the two nodes
%             forming an edge.
%       S{3}: Matrix of triangles. Each row contains the indices of the three nodes 
%             forming a triangle.
%       S{4}: Matrix of tetrahedra. Each row contains the indices of the four nodes 
%             forming a tetrahedron.
%       etc.
%
%   Inputs:
%       C      - p x p correlation matrix (assumed symmetric with ones on the diagonal).
%       tau    - scalar threshold used uniformly for including simplices.
%       maxDim - maximum dimension of the simplicial complex (e.g., maxDim = 3 
%                builds up to tetrahedra).
%
%   Output:
%       S      - Cell array representing the simplicial complex.
%
% (C) 2025 Moo K. Chung, University of Wisconsin-Madison
%     Email: mkchung@wisc.edu

% Get the number of nodes.
p = size(C, 1);

%% Build the Simplicial Complex S

% S{1}: 0-simplices (nodes)
% Each node is simply represented by its index.
S{1} = (1:p)';

% S{2}: 1-simplices (edges)
% Include an edge (i,j) with i < j if C(i,j) > tau.
edges = [];
for i = 1:p-1
    for j = i+1:p
        if C(i,j) > tau
            edges = [edges; i, j];  %#ok<AGROW>
        end
    end
end
S{2} = edges;

% S{d+1} for d >= 2: Higher-dimensional simplices.
% A candidate simplex (of dimension d) is included if every pair of nodes 
% in the candidate has correlation greater than tau.
for d = 2:maxDim
    % Generate all combinations of (d+1) nodes.
    combs = nchoosek(1:p, d+1);
    
    % Initialize a logical vector to mark valid simplices.
    valid = false(size(combs, 1), 1);
    
    % Check each candidate simplex.
    for i = 1:size(combs, 1)
        nodes = combs(i, :);
        % Generate all pairs from these nodes.
        pairs = nchoosek(nodes, 2);
        % Check if all pairwise correlations exceed tau.
        if all(arrayfun(@(row) C(pairs(row,1), pairs(row,2)) > tau, (1:size(pairs,1))'))
            valid(i) = true;
        end
    end
    
    % Store the valid simplices in S{d+1}.
    S{d+1} = combs(valid, :);
end

end