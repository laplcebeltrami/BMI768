function S = cellcomplex_build(n, m)
% CELLCOMPLEX_BUILD  Generate a rectangular n-by-m grid (n rows, m cols) as 
% a 2D cell complex.
% 
% INPUT:
%   n : number of rows of cells (>=1)
%   m : number of cols of cells (>=1)
%
% OUTPUT (structured array):
%   S.nodes : [K x 2] integer coordinates (x,y)
%   S.edges : [E x 2] directed edge list (stored orientation per row)
%   S.faces : structured array containing 
%               .vertices : [F x 4] vertex indices (Top Left(TL), TR BR BL)
%               .edges    : [F x 4] edge indices aligned with boundary order
%               .sign     : [F x 4] orientation sign (+1 if all 4 edges follow clockwise,
%                            -1 if all 4 edges follow counterclockwise,
%                             0 if some edges are inconsistent)
%
% Convention:
%   Vertex grid is (n+1) by (m+1).
%   Coordinates: x increases left->right; y decreases top->bottom (Nodes(ii,:)=[c-1, -(r-1)]).
%   Face boundary order: TL -> TR -> BR -> BL -> TL (clockwise in this coordinate system).
%
% (C) 2026 Moo K. Chung 
% University of Wisconsin
% https://github.com/laplcebeltrami

%% nodes
nRowV = n + 1;
nColV = m + 1;
K     = nRowV * nColV;

idx = @(r,c) (r-1)*nColV + c;

nodes = zeros(K,2);
for r = 1:nRowV
    for c = 1:nColV
        ii = idx(r,c);
        nodes(ii,:) = [c-1, -(r-1)];
    end
end

%% edges (store a fixed default orientation)
% horizontal: left -> right
% vertical  : top  -> bottom
E = (nRowV*(nColV-1)) + ((nRowV-1)*nColV);
edges = zeros(E,2);

e = 0;

% horizontal edges
for r = 1:nRowV
    for c = 1:(nColV-1)
        i = idx(r,c);
        j = idx(r,c+1);
        e = e + 1;
        edges(e,:) = [i j];
    end
end

% vertical edges
for r = 1:(nRowV-1)
    for c = 1:nColV
        i = idx(r,c);
        j = idx(r+1,c);
        e = e + 1;
        edges(e,:) = [i j];
    end
end

% edge lookup: unordered node pair -> edge index
uu = min(edges(:,1), edges(:,2));
vv = max(edges(:,1), edges(:,2));
EdgeID = sparse(uu, vv, (1:E), K, K);                         % <— FIX: safe sizing

    function eid = edge_id(a,b)
        aa = min(a,b);
        bb = max(a,b);
        eid = EdgeID(aa,bb);                                  % (no error checking by request)
    end

%% faces (single struct with [F x 4] arrays, per your convention)
F = n * m;

faces = struct('vertices', zeros(F,4), ...
               'edges',    zeros(F,4), ...
               'sign',     zeros(F,1));                       % <— sign per face (scalar) per your text

f = 0;
for r = 1:n
    for c = 1:m
        f = f + 1;

        TL = idx(r,   c);
        TR = idx(r,   c+1);
        BL = idx(r+1, c);
        BR = idx(r+1, c+1);

        % vertex order: TL TR BR BL
        vtx = [TL TR BR BL];
        faces.vertices(f,:) = vtx;

        % boundary traversal pairs (CW): TL->TR->BR->BL->TL
        a = [TL TR BR BL];
        b = [TR BR BL TL];

        eids = zeros(1,4);
        sgnE = zeros(1,4);

        for k = 1:4
            eid = edge_id(a(k), b(k));
            eids(k) = eid;

            % +1 if stored edge direction matches traversal a->b, else -1
            if edges(eid,1)==a(k) && edges(eid,2)==b(k)
                sgnE(k) = 1;
            else
                sgnE(k) = -1;
            end
        end

        faces.edges(f,:) = eids;

        % face sign: +1 if all match CW, -1 if all match CCW, else 0
        if all(sgnE==1)
            faces.sign(f,1) = 1;                               % <— CW
        elseif all(sgnE==-1)
            faces.sign(f,1) = -1;                              % <— CCW
        else
            faces.sign(f,1) = 0;                               % <— inconsistent
        end

    end
end

%% output
S.nodes = nodes;
S.edges = edges;
S.faces = faces;

end

