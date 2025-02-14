function [X, A_true] = VAR_simulate(N, T, P, noise_level)
% SIMULATE_BRAIN_SIGNALS - Simulates brain signals using a VAR(P) model.
%
% Inputs:
%   N           - Number of nodes (brain regions)
%   T           - Number of time points
%   P           - Order of the VAR model (lags)
%   noise_level - Standard deviation of Gaussian noise
%
% Outputs:
%   X        - (N x T) Simulated multivariate time series
%   A_true   - (N x N*P) True VAR coefficient matrices (ground truth)
%
% (C) 2025 Moo K. Chung
% University of Wisconsin-Madison

 rng(1); % Set random seed for reproducibility

    % Step 1: Generate P sparse coefficient matrices
    A_true = zeros(N, N, P); % Store all VAR lag matrices
    
    for p = 1:P
        A_true(:,:,p) = (0.5 - 0.1*p) * (randn(N, N) .* (rand(N, N) > 0.7)); % Sparse A_p
    end

    % Step 2: Ensure Stability by Scaling Eigenvalues
    max_eigen = max(abs(eig([reshape(A_true, N, N*P); eye(N*(P-1)), zeros(N*(P-1), N)])));
    if max_eigen >= 1
        A_true = A_true / (1.1 * max_eigen); % Scale for stability
    end

    % Step 3: Generate Gaussian Noise
    epsilon = noise_level * randn(N, T);

    % Step 4: Initialize Time Series
    X = zeros(N, T);
    X(:, 1:P) = randn(N, P); % Random initial values

    % Step 5: Simulate VAR(P) Process
    for t = P+1:T
        X(:, t) = epsilon(:, t); % Start with noise
        for p = 1:P
            X(:, t) = X(:, t) + A_true(:,:,p) * X(:, t-p); % Apply VAR recursion
        end
    end

end