function out = SEM_nonlinear(Z)
% SEM_nonlinear
%   
% Input:
% Z : n x p data matrix
%     n = number of samples / time points
%     p = number of variables / nodes
%
% Output:
% out.W_inst : p x p weighted directed adjacency matrix
%              W(i,j) measures nonlinear predictive contribution i -> j
%
% Nonlinear SEM implemented through node-wise 
% additive regression. This implementation uses the nonlinear 
% structural equation models (SEMs), additive-noise / 
% additive-function formulations discussed in:

%
% Additional refences on SEM.
%   1) Hoyer et al. (2009),
%      "Nonlinear causal discovery with additive noise models"
%   2) Peters, Janzing, Schölkopf (2017),
%      "Elements of Causal Inference"
%   3) Bühlmann et al. on Causal Additive Models (CAM)
%
%
%
% Each variable X_j is represented as
%
%       X_j = f_j(X_{-j}) + e_j
%
% where f_j is a nonlinear function of the other variables. 
% Here we approximate f_j by an additive generalized 
% additive model (GAM), fitted separately for each node j.
%
% For each target node j, we treat column j as the response y.
% Use all remaining columns as predictors, Fit a nonlinear 
% additive regression model using fitrgam.m. Quantify directed 
% importance i -> j by permutation importance: permute predictor 
% i, recompute prediction error, and measure the increase in MSE.
%
% This yields a directed weighted adjacency matrix W, where
%       W(i,j)  = strength of directed dependency i -> j
% The matrix is then normalized for comparability across runs.
%
% Relation to standard CAM / nonlinear SEM
% Standard CAM fits nonlinear additive regressions to model
% node-wise dependencies. The present implementation keeps 
% that same basic modeling idea, but uses permutation-based 
% feature importance as a simple, stable, and scalable way 
% to extract directed edge weights from the fitted
% nonlinear model.
%
% (C) 2026 Moo K. Chung
% University of Wisconsin-Madison




[n,p] = size(Z);
Z = zscore(Z);

W = zeros(p,p);
numPerm = 1;

for j = 1:p
    
    y = Z(:,j);
    X = Z;
    X(:,j) = 0;   % <--- exclude self predictor
    
    % use fitrgam with no extra options
    mdl = fitrgam(X, y);
    
    yhat = predict(mdl, X);
    mse0 = mean((y - yhat).^2);
    
    for i = 1:p
        if i == j
            continue
        end
        
        imp = 0;
        for r = 1:numPerm
            Xp = X;
            Xp(:,i) = Xp(randperm(n), i);   % permute predictor i
            yhatp = predict(mdl, Xp);
            mse1 = mean((y - yhatp).^2);
            imp = imp + max(mse1 - mse0, 0);
        end
        
        W(i,j) = imp / numPerm;
    end
end

mx = max(W(:));
if mx > 0
    W = W / mx;
end

W(1:p+1:end) = 0;

out.W_inst = W;
end

