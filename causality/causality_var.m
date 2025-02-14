function [A_est, X_pred, GC_matrix] = VAR_fit(X, P)
% causality_var - Estimates a VAR(P) model, predicts time series, 
% and tests Granger causality
% 
% Inputs: 
%   X      - (N x T) Multivariate time series matrix
%   P      - Order of the VAR model (number of lags)
%
% Outputs:
%   A_est      - (N x N*P) Estimated VAR coefficients
%   X_pred     - (N x T) Predicted time series
%   GC_matrix  - (N x N) Matrix of p-values for Granger causality
%
% (C) 2025 Moo K. Chung
% Univeristy of Wisconsin-Madison


% Get dimensions
[N, T] = size(X);

Y = X(:, P+1:T); % Target values (dependent variables)
X_regressors = []; % Construct design matrix for regression

for p = 1:P
    X_regressors = [X_regressors; X(:, P+1-p:T-p)]; % Stack lagged values
end

% Solve the least squares problem: Y = A * X_regressors
A_est = Y * pinv(X_regressors); % Estimated coefficient matrices

%A_est =
%
%    0.5772   -0.2001   -0.4657   -0.0320
%    0.1797    0.5959    0.2305   -0.2204
% 

%% Step 3: Predict Using the Estimated VAR Model
X_pred = zeros(N, T);
X_pred(:, 1:P) = X(:, 1:P); % Use initial values

for t = P+1:T
    X_pred(:, t) = A_est * X_regressors(:, t-P);
end

%% Step 4: Granger Causality Testing
GC_matrix = zeros(N, N); % Store p-values for Granger causality

for i = 1:N
    for j = 1:N
        if i ~= j
            % Full model: X_i depends on all predictors
            Y_full = Y(i, :)';
            X_full = X_regressors';

            % Restricted model: Remove X_j from predictors
            X_restricted = X_regressors;
            X_restricted((j-1)*P+1:j*P, :) = []; % Remove columns related to X_j
            X_restricted = X_restricted';

            % Compute RSS for both models
            beta_full = X_full \ Y_full;
            Y_hat_full = X_full * beta_full;
            RSS_full = sum((Y_full - Y_hat_full).^2);

            beta_restricted = X_restricted \ Y_full;
            Y_hat_restricted = X_restricted * beta_restricted;
            RSS_restricted = sum((Y_full - Y_hat_restricted).^2);

            % Compute F-statistic
            df1 = P; % Number of restrictions
            df2 = T - P - P*N^2; % Degrees of freedom
            F_stat = ((RSS_restricted - RSS_full) / df1) / (RSS_full / df2);

            % Compute p-value
            p_value = 1 - fcdf(F_stat, df1, df2);
            GC_matrix(i, j) = p_value; % Store p-value
        end
    end
end

end

