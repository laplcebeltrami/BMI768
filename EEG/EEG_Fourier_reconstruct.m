function Xout = EEG_Fourier_reconstruct(Fin, Tpoints)
% EEG_FOURIER_RECONSTRUCT  Reconstruct real EEG time series from truncated nonnegative Fourier coefficients.
%
% Input (either form)
%   (A) struct with fields:
%       Fin.F : [256 x K x nSub] complex Fourier coefficients (nonnegative bins, truncated)
%       Fin.k : [1 x K] FFT bin indices (optional)
%   (B) numeric array:
%       Fin : [256 x K x nSub] complex Fourier coefficients
%
% Input
%   Tpoints : number of time points in reconstructed signal (FFT length)
%
% Output 
%   Xout  : [256 x Tpoints x nSub] real reconstructed EEG time series
%
%
% (C) 2026 Moo K. Chung
% University of Wisonsin-Madison

if isstruct(Fin)                                  
    F0 = Fin.F;                                   
else
    F0 = Fin;                                     
end

[Ch, K, nSub] = size(F0);

Nfft = Tpoints;
Npos = floor(Nfft/2) + 1;                         % DC..Nyquist

% Nonnegative spectrum with zero-padding/truncation
Ypos = zeros(Ch, Npos, nSub, 'like', F0);          
Ypos(:,1:min(K,Npos),:) = F0(:,1:min(K,Npos),:);

% Real DC and Nyquist bins for real-valued IFFT
Ypos(:,1,:) = real(Ypos(:,1,:));
if mod(Nfft,2)==0
    Ypos(:,Npos,:) = real(Ypos(:,Npos,:));        
end

% Full conjugate-symmetric spectrum
Yfull = zeros(Ch, Nfft, nSub, 'like', F0);        
Yfull(:,1:Npos,:) = Ypos;

if Npos >= 3
    Yfull(:,Npos+1:Nfft,:) = conj(Ypos(:,Npos-1:-1:2,:));
end

% Reconstruct time series
Xout = real(ifft(Yfull, Nfft, 2));

end