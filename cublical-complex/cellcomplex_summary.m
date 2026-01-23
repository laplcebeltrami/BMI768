function T = cellcomplex_summary(S)
% CELLCOMPLEX_SUMMARY  Topological summary of a 2D cell complex.
%
% INPUT:
%   S.nodes : [K x 2]
%   S.edges : [E x 2]
%   S.faces : struct with fields (optional but supported)
%             .vertices : [F x 4]
%             .edges    : [F x 4]
%             .sign     : [F x 1]
%
% OUTPUT:
%   T : struct with basic topological counts and diagnostics
%       .K, .E, .F
%       .chi             Euler characteristic = K - E + F
%       .nConnComp       # connected components (undirected)
%       .cyclomatic      Betti-1 number, Cycle rank = E - K + nConnComp  
%                        (graph cycle space dimension)
%                        https://en.wikipedia.org/wiki/Cyclomatic_number
%
%       .nFacesCW, .nFacesCCW, .nFacesInconsistent
%       .hasFlow, .hasCycles
%
% (C) 2026 Moo K. Chung
% University of Wisconsin

T = struct();

% ---- counts
if isfield(S,'nodes') && ~isempty(S.nodes)
    K = size(S.nodes,1);
else
    K = 0;
end

if isfield(S,'edges') && ~isempty(S.edges)
    E = size(S.edges,1);
else
    E = 0;
end

F = 0;
nCW = 0; nCCW = 0; nInc = 0;
if isfield(S,'faces') && ~isempty(S.faces) && isstruct(S.faces)
    if isfield(S.faces,'vertices') && ~isempty(S.faces.vertices)
        F = size(S.faces.vertices,1);
    elseif isfield(S.faces,'edges') && ~isempty(S.faces.edges)
        F = size(S.faces.edges,1);
    end
    if isfield(S.faces,'sign') && ~isempty(S.faces.sign)
        nCW  = sum(S.faces.sign ==  1);
        nCCW = sum(S.faces.sign == -1);
        nInc = sum(S.faces.sign ==  0);
    end
end

T.K = K;
T.E = E;
T.F = F;

% ---- Euler characteristic (2D cell complex)
T.chi = K - E + F;

% ---- connectivity & cycle rank (graph-theoretic)
if E > 0 && K > 0
    uu = min(S.edges(:,1), S.edges(:,2));
    vv = max(S.edges(:,1), S.edges(:,2));
    G  = graph(uu, vv, ones(E,1), K);
    bins = conncomp(G);
    nConnComp = max(bins);
else
    nConnComp = K;                          % isolated vertices
end
T.nConnComp = nConnComp;

% cyclomatic number (dimension of undirected graph cycle space)
T.cyclomatic = E - K + nConnComp;

% ---- face orientation diagnostics
T.nFacesCW = nCW;
T.nFacesCCW = nCCW;
T.nFacesInconsistent = nInc;

%% OPTIIONAL: fields presence
T.hasFlow = isfield(S,'flows') && ~isempty(S.flows);
T.hasCycles = isfield(S,'cycles') && ~isempty(S.cycles);

% ---- print human-readable summary
fprintf('\nCELL COMPLEX SUMMARY\n');
fprintf('  #nodes (K)  : %d\n', T.K);
fprintf('  #edges (E)  : %d\n', T.E);
fprintf('  #faces (F)  : %d\n', T.F);
fprintf('  Euler chi   : %d  (K - E + F)\n', T.chi);
fprintf('  #components : %d\n', T.nConnComp);
fprintf('  Betti-1 (cycle rank)  : %d  (E - K + #components)\n', T.cyclomatic);

if F > 0 && (nCW + nCCW + nInc) > 0
    fprintf('  faces CW    : %d\n', T.nFacesCW);
    fprintf('  faces CCW   : %d\n', T.nFacesCCW);
    fprintf('  faces mixed : %d\n', T.nFacesInconsistent);
end

if T.hasFlow
    fprintf('  flow field  : yes (size %d x 1)\n', numel(S.flow));
else
    fprintf('  flow field  : no\n');
end

if T.hasCycles
    if iscell(S.cycles)
        fprintf('  cycles      : yes (# %d)\n', numel(S.cycles));
    elseif isstruct(S.cycles)
        fprintf('  cycles      : yes (# %d)\n', numel(S.cycles));
    else
        fprintf('  cycles      : yes\n');
    end
else
    fprintf('  cycles      : no\n');
end
fprintf('\n');

end