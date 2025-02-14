%% Granger Causality 
% (C) 2025 Moo K. Chung
% University of Wisconsin-Madison
% mkchung@wisc.edu

%% Set random seed for reproducibility. 
%% Otherwise, your simulation will be constantly changing
rng(1); 

%% Step 1: Generate Random Multivariate Time Series
%% based on VAR(p). 

% Simulated data is blind to end users
% Define true VAR(3) process to generate structured data
N=4; % Number of time series (dimensions)
T=100; % Number of time points
P=10; % Order of the VAR model
noise_level = 1;
[X, A_true] = VAR_simulate(N, T, P, noise_level);

% Display simulted time series
figure; VAR_plot(X, 'k')

% Estimate wtih VAR model
%% We combine all the above steps into a function
[A_est, X_pred, GC_matrix] = VAR_fit(X, 2);
hold on; VAR_plot(X_pred, 'r')

[A_est, X_pred, GC_matrix] = VAR_fit(X, 3);
hold on; VAR_plot(X_pred, 'g')

% Plot Granger causality results
figure;
imagesc(-log10(GC_matrix));
colorbar;
title('Granger Causality (p-values in log10)');
xlabel('Target Variable'); ylabel('Predictor Variable');
xticks(1:N); yticks(1:N);
xticklabels(strcat('X', string(1:N))); yticklabels(strcat('X', string(1:N)));


%% Application to rs-fMRI signals (6 regions)

load rsfMRI.mat

[T, N, ~] = size(rsfMRI)
%=    time points    regions    subjects
%        1200           6         100

figure; plot(rsfMRI(:,1,1), 'k'); 
hold on; plot(rsfMRI(:,2,1), 'r');
legend('Left interior frontal gyrus', 'Right interior frontal gyrus')
title('Subject 1')


X = rsfMRI(:,:,1); 
%size(X)
%ans =
%        1200           6

X=X';
P=3;
[A_est, X_pred, GC_matrix] = VAR_fit(X, P);

figure; VAR_plot(X, '+k');
hold on; VAR_plot(X_pred, 'r')

%Fitting error in terms of Mean Squared Error (MSE)
MSE = mean(mean((X(:, P+1:T) - X_pred(:, P+1:T)).^2))

%Resisual error
figure; VAR_plot(X-X_pred, '-k');

%Granger Causality
figure;
imagesc(-log10(GC_matrix));
colorbar;
title('Granger Causality (p-values in log10)');
xlabel('Target Variable'); ylabel('Predictor Variable');
xticks(1:N); yticks(1:N);
xticklabels(strcat('X', string(1:N))); yticklabels(strcat('X', string(1:N)));

% Exercise: So far we only did model fit. See if you can use
% the method to do prediction of future event. 
% Observing time points 1 to 1100, can you predict time points
% 1101 to 1200?