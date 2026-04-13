function S = adj2simplex(C, maxDim)
% ADJ2SIMPLEX  Build an oriented simplicial complex (up to maxDim) from an
% antisymmetric edge–flow matrix C (already thresholded BEFORE this call).
%
% INPUT
%   C      : p×p antisymmetric matrix (C' = -C)
%   maxDim : maximum simplex dimension to build (≥1; typical 2).
%
% OUTPUT
%   S{1} : [#V × 1]  vertex list: (1:p)'
%   S{2} : [#E × 3]  edges in reference orientation [i j ω_ij], i<j, ω_ij = C(i,j)
%   S{3} : [#T × 4]  directed triangles [i j k w_ijk], i<j<k, kept only if 3-cycle 
%                    coherence holds, weight w_ijk = min(|C(i,j)|,|C(j,k)|,|C(k,i)|),
%                   which is dominant edge flow among 3 edges.
%
%
% NOTE: Currently, we only KEEP a triangle (i,j,k) only if the three directed 
%       edges form a coherent 3-cycle (all clockwise or all counterclockwise):
%         (C(i,j)>0 && C(j,k)>0 && C(k,i)>0)  OR
%         (C(i,j)<0 && C(j,k)<0 && C(k,i)<0).
%       This can be modified accoreding to applications.
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

p = size(C,1);

% Vertices
S = cell(maxDim+1,1);
S{1} = (1:p)';

% Undirected support: presence of an edge if |C(i,j)|>0
Aund = (abs(C) > 0);
Aund(1:p+1:end) = false;

% Edges (store once per unordered pair, i<j) with signed weight C(i,j)
[iu,ju] = find(triu(Aund,1));
omega   = C(sub2ind([p p], iu, ju));
keepE   = abs(omega) > 0;
S{2}    = [iu(keepE), ju(keepE), omega(keepE)];

if maxDim < 2, return; end

% Build candidate triangles from undirected support (all three pairs present)
tri = [];
adjList = cell(p,1);
for v = 1:p
    adjList{v} = find(Aund(v,:));
end
for i = 1:p-2
    Ni = adjList{i}; Ni = Ni(Ni > i);
    for j = Ni
        Nj = adjList{j};
        K  = intersect(Ni, Nj);
        K  = K(K > j);   % i<j<k
        if ~isempty(K)
            tri = [tri; [repmat(i,numel(K),1), repmat(j,numel(K),1), K(:)]]; %#ok<AGROW>
        end
    end
end
if isempty(tri)
    S{3} = zeros(0,4);
    return
end

% Direction-coherence filter: keep only 3-cycles (all signs equal on (i->j, j->k, k->i))
s1 = C(sub2ind([p p], tri(:,1), tri(:,2))); % C(i,j)
s2 = C(sub2ind([p p], tri(:,2), tri(:,3))); % C(j,k)
s3 = C(sub2ind([p p], tri(:,3), tri(:,1))); % C(k,i)
dir_ok = (s1>0 & s2>0 & s3>0) | (s1<0 & s2<0 & s3<0);

tri = tri(dir_ok,:);
if isempty(tri)
    S{3} = zeros(0,4);
    return
end

% Triangle weight = min magnitude of the three directed edges used in the cycle
w_ijk = min([abs(s1(dir_ok)), abs(s2(dir_ok)), abs(s3(dir_ok))], [], 2);

S{3} = [tri, w_ijk];
end