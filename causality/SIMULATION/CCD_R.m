function out = CCD_R(Z, Edges)
% Cyclic Causal Discovery (CCD)
% This is a practical constraint-based implementation that performs:
%
%   1) Gaussian CI-based skeleton discovery
%   2) collider (v-structure) identification
%   3) a small number of conservative orientation rules
%   4) explicit cycle detection on the oriented graph
%   5) Wrapper for packing the output
%
% INPUT
%   Z     : [T x K] data matrix, rows=time/samples,
%           cols=variables
%   Edges : [E x 2] edge list used only for constructing
%           out.flows
%
% OUTPUT
%   out.connectivity        : [K x K] weighted adjacency proxy
%   out.flows               : [E x 1] edge weights aligned with Edges
%   out.model.Adj           : undirected skeleton
%   out.model.orient        : oriented adjacency, orient(i,j)=1 means i->j
%   out.model.SepSet        : separating sets
%   out.model.V             : collider triples [i k j]
%   out.model.alpha         : CI level
%   out.model.maxK          : maximum conditioning size
%   out.model.hasCycle      : 1 if directed cycle exists
%   out.model.SCC           : strongly connected components
%   out.model.cycles        : detected simple directed cycles
%   out.model.nCycles       : number of detected cycles
%
%   Up to step 3 is based on
%   Richardson, T.S. 1996 A discovery algorithm for directed cyclic graphs.
%   UAI'96: Proceedings of the Twelfth international conference on
%   Uncertainty in artificial intelligence, Pages 454 - 46
%   arXiv preprint arXiv:1302.3599 (2013).
%
% Richardson (1996) allows cyclic structures but does not provide a 
% simple or explicit procedure for enumerating cycles; the resulting 
% representation (PAG) encodes cyclic equivalence classes implicitly. 
% Thus, in Step 4, we replace this step with a standard 
% graph-theoretic cycle detection based on strongly connected 
% components (Tarjan, 1972) and depth-first search enumeration 
% (Johnson, 1975). This provides an explicit and computationally
% efficient way to identify directed cycles in the estimated graph.
%
% Tarjan, R. 1972, Depth-first search and linear graph algorithms.
% SIAM journal on computing 1:146-160.
% https://epubs.siam.org/doi/pdf/10.1137/0201010?casa_token=7V90Kbkh3xUAAAAA:CY6g88dii0l-LjJ7q_FCZXGUMxo3c01K33kJEW6_gSkITaLYl9gXbnT2v3G3Sa8GII5boOlzif4Z
%
% Johnson, D.B. 1975, Finding all the elementary circuits of a directed graph.
% SIAM Journal on Computing 4:77-84.
% https://epubs.siam.org/doi/pdf/10.1137/0204007?casa_token=IuUAdZ3NrvsAAAAA:VT4xjZq8X1TQ6MOsu4nX3TtW8qPdJj1yHFmcFj4L5qjj8QnKS6QyKaC1ccNj3RGVhDLLXrHaBA3b
%
% (C) 2026 Moo K. Chung

[T,K] = size(Z);
Y = zscore(Z);

alpha = 0.01;
maxK  = min(100, K-2);  %The size of Set S. 
Adj    = ones(K,K) - eye(K);   % undirected skeleton
SepSet = cell(K,K);
R      = corrcoef(Y);

%% ============================================================
% 1) Skeleton discovery
% ============================================================
for k = 0:maxK
    done = false;
    while ~done
        done = true;
        [ii,jj] = find(triu(Adj,1));
        for m = 1:length(ii)
            i = ii(m); j = jj(m);
            if Adj(i,j)==0
                continue
            end

            Ni = find(Adj(i,:)==1);
            Nj = find(Adj(j,:)==1);
            Cand = union(Ni, Nj);
            Cand(Cand==i | Cand==j) = [];

            if numel(Cand) < k
                continue
            end

            Slist = nchoosek(Cand, k);
            for s = 1:size(Slist,1)
                S = Slist(s,:);
                [~, pval] = partialcorr_ijS_fast(R, i, j, S, T);
                if pval > alpha
                    Adj(i,j) = 0;
                    Adj(j,i) = 0;
                    SepSet{i,j} = S;
                    SepSet{j,i} = S;
                    done = false;
                    break
                end
            end
        end
    end
end

%% ============================================================
% 2) Collider discovery
% ============================================================
orient = zeros(K,K);     % orient(i,j)=1 means i -> j
V = zeros(0,3);

for k = 1:K
    Nk = find(Adj(k,:)==1);
    if numel(Nk) < 2
        continue
    end

    pairs = nchoosek(Nk,2);
    for r = 1:size(pairs,1)
        i = pairs(r,1);
        j = pairs(r,2);

        if Adj(i,j)==0
            Sij = SepSet{i,j};
            if isempty(Sij) || ~any(Sij==k)
                orient(i,k) = 1;
                orient(j,k) = 1;
                V(end+1,:) = [i k j]; %#ok<AGROW>
            end
        end
    end
end

%% ============================================================
% 3) Conservative propagation rules
% ============================================================
% Rule A:
% If i -> j - k and i not adjacent k, orient j -> k
%
% Rule B:
% If i - j and there is a directed path i -> ... -> j, orient i -> j
%
% Repeat until convergence.

changed = true;
while changed
    changed = false;

    % ---------------- Rule A ----------------
    for j = 1:K
        into_j = find(orient(:,j)==1);
        und_j  = find(Adj(j,:)==1 & orient(j,:)==0 & orient(:,j)'==0);

        for a = 1:numel(into_j)
            i = into_j(a);
            for b = 1:numel(und_j)
                k = und_j(b);
                if k==i
                    continue
                end
                if Adj(i,k)==0 && orient(j,k)==0 && orient(k,j)==0
                    orient(j,k) = 1;
                    changed = true;
                end
            end
        end
    end

    % ---------------- Rule B ----------------
    for i = 1:K
        for j = 1:K
            if i==j
                continue
            end
            if Adj(i,j)==1 && orient(i,j)==0 && orient(j,i)==0
                if has_directed_path(orient, i, j)
                    orient(i,j) = 1;
                    changed = true;
                elseif has_directed_path(orient, j, i)
                    orient(j,i) = 1;
                    changed = true;
                end
            end
        end
    end

    % keep consistency: oriented edge must belong to skeleton
    orient = orient .* Adj;
end

%% ============================================================
% 4) Explicit cycle detection on oriented graph
% ============================================================
SCC = find_SCC(orient);
cycles = find_directed_cycles(orient);
hasCycle = ~isempty(cycles);

%% ============================================================
% 5) Build connectivity
% ============================================================
%Up to this point, the algorithm maintains two structures: 
% the undirected skeleton A and the directed edge matrix orient, 
% where orient(i,j)=1 --> i -> j.
% Use oriented adjacency where available.
% Keep undirected edges symmetric as weak dependencies.
C = zeros(K,K);

for i = 1:K
    for j = 1:K
        if i==j
            continue
        end

        if orient(i,j)==1 && orient(j,i)==0
            C(i,j) = 1;
        elseif Adj(i,j)==1 && orient(i,j)==0 && orient(j,i)==0
            C(i,j) = 1;
            C(j,i) = 1;
        end
    end
end

C(1:K+1:end) = 0;

%% ============================================================
% 6) Edge flow output
% ============================================================
E = size(Edges,1);
flows = zeros(E,1);
for e = 1:E
    i = Edges(e,1);
    j = Edges(e,2);
    flows(e) = C(i,j);
end

%% ============================================================
% 7) Pack outputs
% ============================================================
out = struct();
out.connectivity = C;
out.flows = flows;

out.model = struct();
out.model.Adj      = Adj;
out.model.orient   = orient;
out.model.SepSet   = SepSet;
out.model.V        = unique(V,'rows');
out.model.alpha    = alpha;
out.model.maxK     = maxK;
out.model.hasCycle = hasCycle;
out.model.SCC      = SCC;
out.model.cycles   = cycles;
out.model.nCycles  = numel(cycles);

end


function [rho,pval] = partialcorr_ijS_fast(R, i, j, S, n)
% Gaussian CI test via partial correlation + Fisher z.

if isempty(S)
    rho = R(i,j);
    rho = max(min(rho, 0.999999), -0.999999);
    z = 0.5*log((1+rho)/(1-rho));
    se = 1/sqrt(max(n-3,1));
    T  = abs(z)/se;
    pval = 2*(1-normcdf(T));
    return
end

idx  = [i j S(:)'];
Rsub = R(idx,idx);

Rsub = (Rsub + Rsub')/2;
Rsub = Rsub + 1e-6*eye(size(Rsub));

Psub = pinv(Rsub);

rho = -Psub(1,2) / sqrt(max(Psub(1,1)*Psub(2,2), eps));
rho = max(min(rho, 0.999999), -0.999999);

df = max(n - numel(S) - 3, 1);
z  = 0.5*log((1+rho)/(1-rho));
se = 1/sqrt(df);
T  = abs(z)/se;
pval = 2*(1-normcdf(T));

end


function tf = has_directed_path(G, s, t)
% Return true if directed path s -> ... -> t exists in adjacency G.

K = size(G,1);
visited = false(1,K);
queue = s;
visited(s) = true;
tf = false;

while ~isempty(queue)
    u = queue(1);
    queue(1) = [];

    if u == t
        tf = true;
        return
    end

    nbrs = find(G(u,:)==1);
    for v = nbrs
        if ~visited(v)
            visited(v) = true;
            queue(end+1) = v; %#ok<AGROW>
        end
    end
end

end


function SCC = find_SCC(G)
% Strongly connected components of directed graph G.

K = size(G,1);
visited = false(1,K);
order = zeros(1,K);
idx = 0;

for v = 1:K
    if ~visited(v)
        [visited, order, idx] = dfs_finish_order(G, v, visited, order, idx);
    end
end

GT = G';
visited = false(1,K);
SCC = {};

for r = K:-1:1
    v = order(r);
    if ~visited(v)
        comp = [];
        [visited, comp] = dfs_collect_component(GT, v, visited, comp);
        SCC{end+1,1} = comp; %#ok<AGROW>
    end
end

end


function [visited, order, idx] = dfs_finish_order(G, v, visited, order, idx)
visited(v) = true;
nbrs = find(G(v,:)==1);
for u = nbrs
    if ~visited(u)
        [visited, order, idx] = dfs_finish_order(G, u, visited, order, idx);
    end
end
idx = idx + 1;
order(idx) = v;
end


function [visited, comp] = dfs_collect_component(G, v, visited, comp)
visited(v) = true;
comp(end+1) = v; %#ok<AGROW>
nbrs = find(G(v,:)==1);
for u = nbrs
    if ~visited(u)
        [visited, comp] = dfs_collect_component(G, u, visited, comp);
    end
end
end


function cycles = find_directed_cycles(G)
% Enumerate simple directed cycles from oriented adjacency G.

K = size(G,1);
SCC = find_SCC(G);
cycles = {};
maxCycleLen = K;

for c = 1:numel(SCC)
    nodes = SCC{c};
    if numel(nodes) == 1
        v = nodes(1);
        if G(v,v)==1
            cycles{end+1,1} = v; %#ok<AGROW>
        end
        continue
    end

    Gsub = G(nodes,nodes);

    for a = 1:numel(nodes)
        s = nodes(a);
        path = s;
        visited = false(1,K);
        visited(s) = true;
        cycles = dfs_cycles_from_start(G, nodes, Gsub, s, s, path, visited, cycles, maxCycleLen);
    end
end

cycles = unique_cycles(cycles);

end


function cycles = dfs_cycles_from_start(G, nodes, Gsub, s, u, path, visited, cycles, maxCycleLen)
if numel(path) > maxCycleLen
    return
end

loc_u = find(nodes==u,1);
nbrs_local = find(Gsub(loc_u,:)==1);
nbrs = nodes(nbrs_local);

for v = nbrs
    if v == s && numel(path) >= 2
        cyc = path;
        cycles{end+1,1} = canonical_cycle(cyc); %#ok<AGROW>
    elseif ~visited(v) && v >= s
        visited2 = visited;
        visited2(v) = true;
        cycles = dfs_cycles_from_start(G, nodes, Gsub, s, v, [path v], visited2, cycles, maxCycleLen); %#ok<AGROW>
    end
end

end


function cyc = canonical_cycle(cyc)
% Canonicalize directed cycle up to cyclic rotation.

m = numel(cyc);
rots = zeros(m,m);
for r = 1:m
    rots(r,:) = cyc([r:m 1:r-1]);
end
[~,ix] = min(rots(:,1));
cand = rots(ix,:);

for r = 2:m
    idx = find(rots(:,1:r-1)==cand(1:r-1));
    idx = idx(all(rots(idx,1:r-1)==cand(1:r-1),2));
    if numel(idx) > 1
        [~,j] = min(rots(idx,r));
        cand = rots(idx(j),:);
    else
        break
    end
end

cyc = cand;
end


function cycles2 = unique_cycles(cycles)
if isempty(cycles)
    cycles2 = {};
    return
end

keys = cell(numel(cycles),1);
for i = 1:numel(cycles)
    c = cycles{i};
    keys{i} = sprintf('%d_', c);
end

[~,ia] = unique(keys,'stable');
cycles2 = cycles(ia);

end