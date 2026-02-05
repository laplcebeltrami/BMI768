function Fperm = EEG_Fourier_permute(Fout)
% EEG_FOURIER_PERMUTE  Channel-and-frequency-wise subject permutation of Fourier coefficients.
%
% Purpose
%   For each channel i and frequency bin f, independently permute the subject
%   dimension. This creates synthetic spectra where, for a fixed (i,s),
%   the coefficient vector across frequency bins is assembled from multiple donors.
%
% Input
%   Fout.F : [Ch x Nfreq x nSub] complex Fourier coefficients
%   Fout.k : [1 x Nfreq] (optional; copied)
%   Fout.T : (optional; copied)
%
% Output
%   Fperm.F : [Ch x Nfreq x nSub] permuted coefficients
%             For each (i,f), there exists a permutation pi_{i,f} such that
%               Fperm.F(i,f,s) = Fout.F(i,f, pi_{i,f}(s)).
%   Fperm.k : copied if present
%   Fperm.T : copied if present
%
% Notes
%   This breaks cross-frequency structure within each channel by design.
%
% (C) 2026 Moo K. Chung
% University of Wisonsin-Madison

F0 = Fout.F;
[Ch, Nfreq, nSub] = size(F0);

F1 = zeros(Ch, Nfreq, nSub, 'like', F0);

for i = 1:Ch
    for f = 1:Nfreq
        idx = randperm(nSub);
        F1(i,f,:) = F0(i,f,idx);
    end
end

Fperm.F = F1;
if isfield(Fout,'k'); Fperm.k = Fout.k; end
if isfield(Fout,'T'); Fperm.T = Fout.T; end

end

