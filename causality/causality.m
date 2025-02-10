% MATLAB Example: Fit a VAR Model to Randomly Generated Time Series
%% Set random seed for reproducibility. 
%% Otherwise, your simulation will be constantly changing
clear; clc; rng(1); 

%% Step 1: Generate Random Multivariate Time Series
N = 2;  % Number of time series (dimensions)
T = 100; % Number of time points
P = 2;  % Order of the VAR model to be estimated

% Simulated data is blind to end users
% Define true VAR(2) process to generate structured data
A1 = [0.6, -0.3; 0.2, 0.5];  % Coefficients for lag 1
A2 = [-0.4, 0.1; 0.3, -0.2]; % Coefficients for lag 2
epsilon = 0.1 * randn(N, T); % White noise (Gaussian noise)
% Initialize time series
X = zeros(N, T);
X(:, 1:P) = randn(N, P); % Random initial values
% Generate data using a true VAR(2) process
for t = P+1:T
    X(:, t) = A1 * X(:, t-1) + A2 * X(:, t-2) + epsilon(:, t);
end

% Plot the generated random time series
figure;
subplot(2,1,1); plot(X(1, :), 'b', 'LineWidth', 1.5);
title('Time Series - X_1(t)'); xlabel('Time'); ylabel('X_1(t)');
subplot(2,1,2); plot(X(2, :), 'r', 'LineWidth', 1.5);
title('Time Series - X_2(t)'); xlabel('Time'); ylabel('X_2(t)');

%% Step 2: Fit a VAR(P) Model to the Data

Y = X(:, P+1:T); % Target values (dependent variables)
X_regressors = []; % Construct design matrix for regression

for p = 1:P
    X_regressors = [X_regressors; X(:, P+1-p:T-p)]; % Stack lagged values
end

% Solve the least squares problem: Y = A * X_regressors
A_est = Y * pinv(X_regressors); % Estimated coefficient matrices

A_est =

    0.5772   -0.2001   -0.4657   -0.0320
    0.1797    0.5959    0.2305   -0.2204
% 

%% Step 3: Predict Using the Estimated VAR Model
X_pred = zeros(N, T);
X_pred(:, 1:P) = X(:, 1:P); % Use initial values

for t = P+1:T
    X_pred(:, t) = A_est * X_regressors(:, t-P);
end

% Plot actual vs. predicted values
figure;
subplot(2,1,1);
plot(X(1, :), 'b', 'LineWidth', 1.5); hold on;
plot(X_pred(1, :), '--r', 'LineWidth', 1.5);
title('VAR Model Fit - X_1(t)'); xlabel('Time'); ylabel('X_1(t)');
legend('Actual', 'Predicted');

subplot(2,1,2);
plot(X(2, :), 'b', 'LineWidth', 1.5); hold on;
plot(X_pred(2, :), '--r', 'LineWidth', 1.5);
title('VAR Model Fit - X_2(t)'); xlabel('Time'); ylabel('X_2(t)');
legend('Actual', 'Predicted');

