function Sremoved = cellcomplex_remove_edges(S, p, seed)
% CELLCOMPLEX_REMOVE_EDGES
%
% Randomly remove edges from a cell complex with probability p, then
% recompute face orientation sign on the surviving faces using the CURRENT
% edge directions.
%
% Face sign convention (per face):
%   +1 : all 4 boundary edges follow clockwise traversal TL->TR->BR->BL->TL
%   -1 : all 4 boundary edges follow counterclockwise traversal
%    0 : mixed orientation or missing edge
%
% INPUT
%   S : cell complex with fields
%       S.nodes : [K x 2]
%       S.edges : [E x 2]
%       S.faces : struct with fields
%           .vertices : [F x 4]
%           .edges    : [F x 4]
%           .sign     : [F x 1]
%
%   p : probability of removing each edge (0 <= p <= 1)
%
% OUTPUT
%   Sremoved : cell complex with randomly removed edges
%       Sremoved.nodes stays the same
%       Sremoved.edges is subset of S.edges
%       Sremoved.faces keeps only faces whose 4 boundary edges survive,
%                      with edge indices re-indexed to Sremoved.edges.
%
% (C) 2026 Moo K. Chung

rng(seed);
Sremoved = S;

Edges = S.edges;
E     = size(Edges,1);

% ---- decide which edges to KEEP
keep = rand(E,1) > p;                                  % <— each edge removed with prob p

Sremoved.edges = Edges(keep,:);                        % <— remove edges

% ---- update faces
if isfield(S,'faces') && ~isempty(S.faces) && isstruct(S.faces) ...
        && isfield(S.faces,'edges') && ~isempty(S.faces.edges)

    oldF = size(S.faces.edges,1);

    % build mapping: old edge index -> new edge index (0 if removed)
    map = zeros(E,1);
    map(keep) = 1:sum(keep);

    % face is kept only if all 4 of its edges are kept
    keepF = true(oldF,1);
    for f = 1:oldF
        e4 = S.faces.edges(f,:);                       % [1 x 4] old edge indices
        if any(~keep(e4))
            keepF(f) = false;
        end
    end

    % restrict faces (vertices + reindexed edges)
    Sremoved.faces.vertices = S.faces.vertices(keepF,:);      % keep vertices
    Sremoved.faces.edges    = map(S.faces.edges(keepF,:));    % <— reindex to new edge list
    % Sremoved.faces.sign   = S.faces.sign(keepF,:);          % <— remove (stale)  <— FIX

    % ---- recompute face sign using CURRENT (post-removal) edges  <— FIX
    Ed2 = Sremoved.edges;
    F2  = size(Sremoved.faces.vertices,1);
    fs  = zeros(F2,1);

    for f = 1:F2
        v = Sremoved.faces.vertices(f,:);                     % [TL TR BR BL]
        a = [v(1) v(2) v(3) v(4)];
        b = [v(2) v(3) v(4) v(1)];

        eids = Sremoved.faces.edges(f,:);                     % [1 x 4] new edge ids
        sgnE = zeros(1,4);

        for k = 1:4
            eid = eids(k);
            if Ed2(eid,1)==a(k) && Ed2(eid,2)==b(k)
                sgnE(k) = 1;                                  % matches CW traversal
            else
                sgnE(k) = -1;                                 % opposite
            end
        end

        if all(sgnE==1)
            fs(f) = 1;                                        % CW
        elseif all(sgnE==-1)
            fs(f) = -1;                                       % CCW
        else
            fs(f) = 0;                                        % mixed
        end
    end

    Sremoved.faces.sign = fs;                                  % <— FIX: correct orientation sign

end

end