function F = EEG_Fourier(data)
% EEG_FOURIER  Compute per-condition Fourier coefficients for multi-subject EEG.
%
% Input
%   data : [256 x T x nCond x nSub]
%
% Output
%   F.F     : [256 x Ncoeff x nCond x nSub] complex Fourier coefficients
%   F.k     : [1 x Ncoeff] frequency indices (FFT bins)
%
% (C) 2026 Moo K. Chung
% University of Wisonsin-Madison

[~, T, nCond, nSub] = size(data);

Nfft = T;
keepAll = 1:floor(Nfft/2)+1;     % nonnegative bins
Ncoeff = min(1000, numel(keepAll));
keep = keepAll(1:Ncoeff);

Fcoef = zeros(256, Ncoeff, nCond, nSub);  % complex

for s = 1:nSub
    for c = 1:nCond
        Y = fft(data(:,:,c,s), Nfft, 2);
        Fcoef(:,:,c,s) = Y(:, keep);
    end
end

F.F = Fcoef;
F.k = keep;   % FFT bin indices


end