% Fourier Analysis of a Time Series
% (C) 2025 Moo K. Chung
% University of Wisconsin-Madison
%
% Update history
% 2025 Febuary 2: created

% Nyquist-Shannon Sampling Theorem states that a continuous 
% signal can be completely reconstructed from its sampled 
% version if it is sampled at a rate at least twice its 
% highest frequency component. 

% Generate a sample time series (sum of sinusoids with noise)
fs = 500;  % Sampling frequency in Hertz (Hz) represents 
% the number of cycles per second of a periodic signal. 
%% Hence we can model time series data with up to 250 HZ. 
% It describes how fast a signal oscillates over time. 
% A frequency of 1 Hz means that a wave completes one 
% full cycle per second, while a frequency of 50 Hz means
% the wave repeats 50 times per second.

T = 1;      % Total duration in seconds
t = 0:1/fs:(T-1/fs); % Time points where time series x will be analyzed
x = sin(2*pi*50*t) + 0.5*sin(2*pi*120*t) + 0.2*randn(size(t)); % Signal with noise

figure;
plot(t, x, 'LineWidth', 2);
xlabel('Time (s)');
ylabel('Amplitude');
title('Time Series');
figure_bigger(30)


% Discrete Fourier Transform
X = fft(x); 
N = length(x); 
freq = (0:N-1)*(fs/N); % Frequency vector

% Compute the magnitude of the spectrum
X_mag = abs(X)/N; % Normalize by N
X_mag = X_mag(1:N/2); % Take the first half (positive frequencies)
freq = freq(1:N/2);   % Corresponding frequency axis

% Identify multiple prominent frequencies using findpeaks
num_peaks = 2; % Number of prominent frequencies to detect
[pks, locs] = findpeaks(X_mag, 'SortStr', 'descend', 'NPeaks', num_peaks);
dominant_freqs = freq(locs);

% Plot the Fourier Transform magnitude spectrum
figure
plot(freq, X_mag, 'b', 'LineWidth', 1.5);
xlabel('Frequency (Hz)');
ylabel('Magnitude: Fourier Transform');
grid on; hold on;

% Mark the most prominent frequencies
plot(dominant_freqs, pks, 'ro', 'MarkerSize', 8, 'LineWidth', 2);
for i = 1:num_peaks
    text(dominant_freqs(i), pks(i), sprintf(' %.1f Hz', dominant_freqs(i)), 'VerticalAlignment', 'bottom', 'FontSize', 30);
end
hold off; figure_bigger(30)


% Define STFT parameters
window_length = 50;  
% Window size in samples (defines how much of the signal is analyzed at a time)
% A larger window gives better frequency resolution but worse time resolution.
% A smaller window improves time resolution but results in poor frequency resolution.

overlap = window_length - 1; %one time point at a time. 

%overlap = window_length / 2; 
nfft = 512;  
% Number of FFT points (defines frequency resolution)
% This determines how finely frequencies are resolved in 
% the spectrogram. Choosing `nfft` greater than `window_length` 
% results in zero-padding, which can provide better spectral 
% interpolation but does not increase actual frequency resolution.
% Choosing `nfft` smaller than `window_length` may cause 
% aliasing or resolution loss.

% Compute the spectrogram
[S, F, T_S, P] = spectrogram(x, window_length, overlap, nfft, fs);

% Convert power to dB scale
% The power in decibels (dB) is computed using the logarithm 
% of the power spectrum:
% decibel = 10 * log10 (Power spectrum)

P_dB = 10*log10(abs(P) + eps); % Adding eps to avoid log(0)
% eps = 2.2204e-16; numerical accuracy of MATLAB. 
% This can be adjusted manually.

% Plot the spectrogram
figure;
imagesc(T_S, F, P_dB);
axis xy; % Ensure frequency is on the y-axis
xlabel('Time (s)');
ylabel('Frequency (Hz)');
title('Spectrogram');
figure_bigger(30)
colorbar; colormap jet;
ylim([0 250]); 