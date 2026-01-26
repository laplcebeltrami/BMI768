function Y = LaplaceT_OUmean(X, lambda)
% LaplaceT_OUmean: Ornstein–Uhlenbeck mean (exponential / Laplace) smoothing
%
% Solves the deterministic OU mean equation for vector-valued data:
%   dY/dt + lambda*Y = lambda*X
%
% Discrete-time recursion:
%   Y(k,:) = (1-lambda)*Y(k-1,:) + lambda*X(k,:)
%
% Inputs:
%   X      : N x d matrix (time series; each column is a variable)
%            e.g., X = [CVX_Close, XOM_Close]
%   lambda : smoothing rate (time constant = 1/lambda)
%
% Output:
%   Y      : N x d smoothed time series
%
% Notes:
% - This is the OU *mean* equation without stochastic term.
% - Equivalent to a first-order Laplace resolvent / EWMA filter.
%
% (c) 2026 Moo K. Chung chung@wisc.edu
% University of Wisconsin–Madison

X = double(X);
[N,d] = size(X);

Y = zeros(N,d);
Y(1,:) = X(1,:);        % initial condition

for k = 2:N
    Y(k,:) = Y(k-1,:) + lambda*(X(k,:) - Y(k-1,:));
end
end