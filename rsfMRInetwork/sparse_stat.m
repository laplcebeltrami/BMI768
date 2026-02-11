function sparse_stat(F)
% DISPLAY_SPARSITY  Print sparsity (percentage of zeros) to command window.
%
% INPUT
%   F : numeric array of any size (e.g., Freduced)
%
% Zeros are counted using exact equality (== 0).
%
% (C) 2025 Moo K. Chung
% University of Wisconsin-Madison
% Last update: 2026 Feb 10

nTotal = numel(F);
nZero  = nnz(F == 0);
perc   = 100 * nZero / nTotal;

fprintf('Sparsity: %.2f%% zeros (%d / %d entries)\n', ...
        perc, nZero, nTotal);
end