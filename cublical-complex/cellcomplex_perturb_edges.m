function Srp = cellcomplex_perturb_edges(S, p, seed)
% CELLCOMPLEX_PERTURB_EDGES
% ER-type randomization of edge directions.
% Each edge is independently re-oriented (ignoring the previous orientation)
% at random with probability p. After perturbation, update S.faces.sign so
% that face coloring reflects the CURRENT edge directions:
%   +1 if all 4 boundary edges follow clockwise traversal TL->TR->BR->BL->TL
%   -1 if all 4 boundary edges follow counterclockwise traversal
%    0 otherwise (mixed or missing edges).
%
%  An Erdős–Rényi (ER) random graph model introduces randomness by deciding 
% whether each edge is present independently with a fixed probability p. 
% In the classical G(n,p) model, any pair of nodes amng n-nodes can be 
% connected with probability p. In our setting, randomness is applied in 
% an ER-type manner by independently removing each edge of a fixed grid with 
% probability p.
%
% Each edge is independently re-oriented (ignoring the previous oridentation)
% at random with probability p.
%
% (C) 2026 Moo K. Chung

rng(seed);
Srp = S;

Edges = S.edges;
E     = size(Edges,1);

% ---- decide which edges to RANDOMIZE (not just flip)
randEdge = rand(E,1) < p;                       % <— ER-type decision

% ---- for selected edges, assign random orientation (fair coin)
flip = rand(E,1) < 0.5;                         % independent fair coin

idx = randEdge & flip;                          % edges that will be swapped
Edges(idx,:) = Edges(idx,[2 1]);

Srp.edges = Edges;

% ---- handle flow consistently (if present)
if isfield(S,'flow') && ~isempty(S.flow)
    flow = S.flow;
    flow(idx) = -flow(idx);                     % <— keep convention
    Srp.flow = flow;
end

% ---- FIX: update face sign to match CURRENT edge directions
if isfield(Srp,'faces') && ~isempty(Srp.faces) && isstruct(Srp.faces) ...
        && isfield(Srp.faces,'vertices') && ~isempty(Srp.faces.vertices)

    Nodes = Srp.nodes;
    K     = size(Nodes,1);

    F = size(Srp.faces.vertices,1);

    % undirected pair -> edge index lookup for CURRENT edges
    uu = min(Edges(:,1), Edges(:,2));
    vv = max(Edges(:,1), Edges(:,2));
    EdgeID = sparse(uu, vv, (1:E), K, K);                       % (no error checking by request)

    fs = zeros(F,1);

    for f = 1:F
        v = Srp.faces.vertices(f,:);                            % [TL TR BR BL]
        a = [v(1) v(2) v(3) v(4)];
        b = [v(2) v(3) v(4) v(1)];

        sgnE = zeros(1,4);
        ok   = true;

        for k = 1:4
            aa  = min(a(k), b(k));
            bb  = max(a(k), b(k));
            eid = EdgeID(aa,bb);
            if eid==0
                ok = false; break                               % missing edge
            end
            if Edges(eid,1)==a(k) && Edges(eid,2)==b(k)
                sgnE(k) = 1;                                    % matches CW traversal
            else
                sgnE(k) = -1;                                   % opposite
            end
        end

        if ~ok
            fs(f) = 0;
        elseif all(sgnE==1)
            fs(f) = 1;                                          % CW
        elseif all(sgnE==-1)
            fs(f) = -1;                                         % CCW
        else
            fs(f) = 0;                                          % mixed
        end
    end

    Srp.faces.sign = fs;                                      
end

end