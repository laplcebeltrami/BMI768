function TL = TS2timelagged(X, lag, winSize, stepSize)
% TS2timelagged - Computes time-lagged correlation at a fixed lag using 
% a sliding window.
%
% INPUTS
%   X        : [T x R] time series data
%              - T = number of time points (rows)
%              - R = number of brain regions (columns)
%              Each column X(:,r) is the signal for region r.
%
%   lag      : positive integer (in time points)
%              - The fixed temporal shift applied between signals.
%              - For correlation of region i → j, we correlate X_i(t) 
%                with X_j(t+lag).
%              - This introduces asymmetry since corr(i→j) ≠ corr(j→i).
%
%   winSize  : positive integer
%              - Number of consecutive time points in each sliding window.
%              - Within each window, correlation is computed between 
%                X(i,t : t+winSize-1) and X(j,t+lag : t+winSize-1+lag).
%
%   stepSize : positive integer
%              - The step size (stride) to move the sliding window forward in time.
%              - For example, stepSize=1 gives maximal overlap (shift by 1 sample),
%                while stepSize=winSize gives non-overlapping windows.
%
% OUTPUT
%   TL       : [R x R x N] array of time-lagged correlation matrices
%              - TL(:,:,w) is the correlation matrix for window w.
%              - Entry TL(i,j,w) = corr( X_i(t : t+winSize-1), X_j(t+lag : t+winSize-1+lag) ).
%              - Note: TL(:,:,w) is asymmetric for lag>0.
%
% NOTES
%   - X is z-scored (mean 0, std 1) across time before correlation.
%   - For lag=0, TL(:,:,w) is symmetric (ordinary Pearson correlation).
%   - To convert TL(:,:,w) into antisymmetric edge-flow matrices
%     (one dominant direction per pair), apply adj_AntiSymmetric.m.
%
% (C) 2025 Moo K. Chung, University of Wisconsin-Madison
%
% Update history:
%   Created 2024
%   Simplified 2024 August
%

X = zscore(X);                          % Normalize each region across time
[T, R] = size(X);
nWin = floor((T - winSize - lag) / stepSize) + 1;  % number of valid windows
TL = zeros(R, R, nWin);

for w = 1:nWin
    i0 = (w - 1) * stepSize + 1;        % window start index
    i1 = i0 + winSize - 1;              % window end index (before lag)

    % Extract lagged pairs of windows, normalize within window
    X1 = zscore(X(i0:i1, :));           % [winSize x R] time series segment
    X2 = zscore(X(i0+lag:i1+lag, :));   % [winSize x R] lagged segment

    % Compute correlation (matrix of R x R)
    A = (X1' * X2) / (winSize - 1);

    TL(:, :, w) = A;
end


% Previious Version
% function timeLaggedCorrMatrices = TS2timelagged(x, maxLag, windowSize, stepSize)
%     % TS2timelagged - Computes the time-lagged correlation matrices over sliding windows
%     % 
%     % Syntax:  timeLaggedCorrMatrices = TS2timelagged(x, maxLag, windowSize, stepSize)
%     %
%     % Inputs:
%     %    x - Input data matrix of size (time points x regions)
%     %    maxLag - Maximum lag to consider for correlation
%     %    windowSize - Size of the sliding window
%     %    stepSize - Step size for the sliding window
%     %
%     % Outputs:
%     %    timeLaggedCorrMatrices - 3D array of time-lagged correlation matrices of size (regions x regions x windows)
% 
%     % Normalize the data
%     x = (x - mean(x)) ./ std(x);
% 
%     % Get the number of time points and regions
%     [numTimePoints, numRegions] = size(x);
% 
%     % Calculate the number of windows
%     numWindows = floor((numTimePoints - windowSize) / stepSize) + 1;
% 
%     % Initialize the 3D array to hold time-lagged correlation matrices
%     timeLaggedCorrMatrices = zeros(numRegions, numRegions, numWindows);
% 
%     % Compute the time-lagged correlation matrices for each window
%     for windowIdx = 1:numWindows
%         % Define the start and end points of the current window
%         windowStart = (windowIdx - 1) * stepSize + 1;
%         windowEnd = windowStart + windowSize - 1;
% 
%         % Extract the data for the current window
%         windowData = x(windowStart:windowEnd, :);
% 
%         % Initialize the time-lagged correlation matrix for the current window
%         timeLaggedCorrMatrix = zeros(numRegions, numRegions);
% 
%         % Compute the time-lagged correlation matrix
%         for regionIdx1 = 1:numRegions
%             for regionIdx2 = 1:numRegions
%                 % Extract the time series for the current regions
%                 timeSeries1 = windowData(:, regionIdx1);
%                 timeSeries2 = windowData(:, regionIdx2);
% 
%                 % Compute cross-correlation between the two regions
%                 [c, lags] = xcorr(timeSeries1, timeSeries2, maxLag, 'coeff');
% 
%                 % Find the maximum absolute correlation value for positive and negative lags
%                 maxPositiveCorr = max(c(lags > 0));
%                 maxNegativeCorr = max(c(lags < 0));
% 
%                 % Store the maximum correlation values in the matrix
%                 timeLaggedCorrMatrix(regionIdx1, regionIdx2) = maxPositiveCorr;
%                 timeLaggedCorrMatrix(regionIdx2, regionIdx1) = maxNegativeCorr;
%             end
%         end
% 
%         % Store the computed matrix in the 3D array
%         timeLaggedCorrMatrices(:, :, windowIdx) = timeLaggedCorrMatrix;
%     end
% end
% 
% 
% 
% end

