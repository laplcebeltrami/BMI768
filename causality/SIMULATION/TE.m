function out = TE(Z)
% TE  Pairwise Transfer Entropy (TE) for a Markov process of order 1
%
% INPUT
%   Z : [K x T] multivariate time series
%
% OUTPUT (struct out)
%   out.TE           : [K x K] raw TE matrix, TE(i,j) = i -> j
%   out.connectivity : [K x K] bias-corrected TE matrix
%
% (c) 2026 Moo K. Chung

lagTE    = 1;
nBins    = 4;
nShuffle = 20;

[K,T] = size(Z);
X = Z.';   % [T x K]

% discretize
B = zeros(T,K);
for j = 1:K
    B(:,j) = quantile_bins_internal(X(:,j), nBins);
end

idx0 = 1:(T-lagTE);
idx1 = (1+lagTE):T;

TE = zeros(K,K);
connectivity = zeros(K,K);

for i = 1:K
    x0 = B(idx0,i);
    
    for j = 1:K
        if i == j
            continue
        end
        
        y  = B(idx1,j);
        y0 = B(idx0,j);
        
        TEobs = te_discrete_internal(x0, y, y0, nBins);
        TE(i,j) = TEobs;
        
        % shuffled null bias correction
        TEnull = zeros(nShuffle,1);
        for s = 1:nShuffle
            x0s = x0(randperm(numel(x0)));
            TEnull(s) = te_discrete_internal(x0s, y, y0, nBins);
        end
        
        connectivity(i,j) = TEobs - mean(TEnull);
        if connectivity(i,j) < 0
            connectivity(i,j) = 0;
        end
    end
end

TE(1:K+1:end) = 0;
connectivity(1:K+1:end) = 0;

out.TE           = TE;
out.connectivity = connectivity;

end


function b = quantile_bins_internal(x, nBins)
x = x(:);
q = quantile(x, linspace(0,1,nBins+1));
q(1) = -inf;
q(end) = inf;

b = zeros(size(x));
for k = 1:nBins
    b(x > q(k) & x <= q(k+1)) = k;
end
b(b==0) = 1;
end


function te = te_discrete_internal(x0, y, y0, nBins)

C = accumarray([y, y0, x0], 1, [nBins, nBins, nBins]);

P_y_y0_x0 = C / sum(C(:));
P_y0_x0   = squeeze(sum(P_y_y0_x0,1));
P_y_y0    = squeeze(sum(P_y_y0_x0,3));
P_y0      = sum(P_y_y0,1);

eps0 = 1e-12;
te = 0;

for yy = 1:nBins
    for yy0 = 1:nBins
        for xx0 = 1:nBins
            p = P_y_y0_x0(yy,yy0,xx0);
            if p < eps0
                continue
            end
            p1 = p / (P_y0_x0(yy0,xx0) + eps0);
            p2 = P_y_y0(yy,yy0) / (P_y0(yy0) + eps0);
            te = te + p * log((p1 + eps0) / (p2 + eps0));
        end
    end
end

end