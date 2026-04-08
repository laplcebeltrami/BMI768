function out = CCD(Z, Edges)
% Cyclic Causal Disveroty (CCD)
% This is a practical constraint-based implementation 
% that performs:
%
%   1) Gaussian CI-based skeleton discovery
%   2) collider (v-structure) identification
%   3) a small number of conservative orientation rules
%
%
% INPUT
%   Z     : [T x K] data matrix, rows=time/samples, 
%           cols=variables
%   Edges : [E x 2] edge list used only for constructing 
%           out.flows
%
% OUTPUT
%   out.connectivity : [K x K] weighted adjacency proxy (0/1 oriented matrix)
%   out.flows        : [E x 1] edge weights aligned with Edges
%   out.model.Adj    : undirected skeleton
%   out.model.orient : oriented adjacency, orient(i,j)=1 means i->j
%   out.model.SepSet : separating sets
%   out.model.V      : collider triples [i k j]
%   out.model.alpha  : CI level
%   out.model.maxK   : maximum conditioning size
%
%
% (C) 2026 Moo K. Chung

[T,K] = size(Z);
Y = zscore(Z);

alpha = 0.01;
maxK  = min(2, K-2);   % <--- keep small for speed and stability

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
% 4) Build reviewer-facing connectivity
% ============================================================
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
% 5) Edge flow output
% ============================================================
E = size(Edges,1);
flows = zeros(E,1);
for e = 1:E
    i = Edges(e,1);
    j = Edges(e,2);
    flows(e) = C(i,j);
end

%% ============================================================
% 6) Pack outputs
% ============================================================
out = struct();
out.connectivity = C;
out.flows = flows;

out.model = struct();
out.model.Adj    = Adj;
out.model.orient = orient;
out.model.SepSet = SepSet;
out.model.V      = unique(V,'rows');
out.model.alpha  = alpha;
out.model.maxK   = maxK;

end


function [rho,pval] = partialcorr_ijS_fast(R, i, j, S, n)
% Gaussian CI test via partial correlation + Fisher z.
% Fast and numerically stabilized.

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
