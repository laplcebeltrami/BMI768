function S = cellcomplex_build_checkerbaord(n, m)
% CELLCOMPLEX_BUILD_CHECKERBOARD  Generate a rectangular n-by-m grid (n rows, m cols) as
% a 2D cell complex with a CHECKERBOARD pattern of oriented cycles.
%
% Goal:
%   Start with the first face (TL,TR,BR,BL) = (1,2,m+2,m+1) having CCW
%   circulation, then alternate CCW/CW in a checkerboard pattern so that
%   EVERY cell boundary is a consistent directed cycle.
%
% OUTPUT (structured array):
%   S.nodes : [K x 2] integer coordinates
%   S.edges : [E x 2] directed edge list (stored orientation per row)
%   S.faces : struct with fields
%               .vertices : [F x 4] vertex indices (TL TR BR BL)
%               .edges    : [F x 4] edge indices aligned with boundary order
%               .sign     : [F x 1] +1 (CW), -1 (CCW), 0 (inconsistent)
%
% Convention:
%   Vertex grid is (n+1) by (m+1).
%   Coordinates: x increases left->right; y decreases top->bottom.
%   Face vertex order stored: [TL TR BR BL].
%   Face boundary order used for edges field: TL->TR->BR->BL->TL (CW order).
%
% (C) 2026 Moo K. Chung

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

%% undirected edge set (unique)
E = (nRowV*(nColV-1)) + ((nRowV-1)*nColV);
uEdges = zeros(E,2);

e = 0;

% horizontal undirected edges
for r = 1:nRowV
    for c = 1:(nColV-1)
        i = idx(r,c);
        j = idx(r,c+1);
        e = e + 1;
        uEdges(e,:) = [i j];
    end
end

% vertical undirected edges
for r = 1:(nRowV-1)
    for c = 1:nColV
        i = idx(r,c);
        j = idx(r+1,c);
        e = e + 1;
        uEdges(e,:) = [i j];
    end
end

% lookup: unordered pair -> edge id
uu = min(uEdges(:,1), uEdges(:,2));
vv = max(uEdges(:,1), uEdges(:,2));
EdgeID = sparse(uu, vv, (1:E), K, K);

    function eid = edge_id(a,b)
        aa = min(a,b);
        bb = max(a,b);
        eid = EdgeID(aa,bb);
    end

%% assign directed orientations to realize checkerboard cycles
% We will fill edges(e,:) in the SAME ordering as uEdges, but oriented.
edges = uEdges;

% mark whether an edge orientation has been assigned already
assigned = false(E,1);

% checkerboard face sign:
%   first face (r=1,c=1) is CCW  => sign = -1
%   alternate by parity: if mod(r+c,2)==0 => CCW (-1), else CW (+1)
%
% For each face, we impose its boundary directions. The checkerboard
% pattern ensures shared edges receive consistent directions.

for r = 1:n
    for c = 1:m

        TL = idx(r,   c);
        TR = idx(r,   c+1);
        BL = idx(r+1, c);
        BR = idx(r+1, c+1);

        if mod(r+c,2)==0
            sFace = -1; % CCW
            % CCW traversal: TL->BL->BR->TR->TL
            a = [TL BL BR TR];
            b = [BL BR TR TL];
        else
            sFace =  1; % CW
            % CW traversal: TL->TR->BR->BL->TL
            a = [TL TR BR BL];
            b = [TR BR BL TL];
        end

        for k = 1:4
            eid = edge_id(a(k), b(k));

            if ~assigned(eid)
                edges(eid,:) = [a(k) b(k)];     % <— set stored orientation
                assigned(eid) = true;
            end
        end

    end
end

%% faces (single struct with [F x 4] arrays)
F = n * m;

faces = struct('vertices', zeros(F,4), ...
               'edges',    zeros(F,4), ...
               'sign',     zeros(F,1));

f = 0;
for r = 1:n
    for c = 1:m
        f = f + 1;

        TL = idx(r,   c);
        TR = idx(r,   c+1);
        BL = idx(r+1, c);
        BR = idx(r+1, c+1);

        faces.vertices(f,:) = [TL TR BR BL];

        % boundary order stored in faces.edges is ALWAYS CW order:
        % TL->TR->BR->BL->TL
        a = [TL TR BR BL];
        b = [TR BR BL TL];

        eids = zeros(1,4);
        sgnE = zeros(1,4);

        for k = 1:4
            eid = edge_id(a(k), b(k));
            eids(k) = eid;

            if edges(eid,1)==a(k) && edges(eid,2)==b(k)
                sgnE(k) = 1;
            else
                sgnE(k) = -1;
            end
        end

        faces.edges(f,:) = eids;

        if all(sgnE==1)
            faces.sign(f,1) = 1;            % CW
        elseif all(sgnE==-1)
            faces.sign(f,1) = -1;           % CCW
        else
            faces.sign(f,1) = 0;            % inconsistent (should not happen here)
        end
    end
end

%% output
S.nodes = nodes;
S.edges = edges;
S.faces = faces;

end