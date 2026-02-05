function eeg256_timeseries_overlay(EEGchannel, eegSeg)
% EEG256_TIMESERIES_OVERLAY  Overlay per-channel EEG time series on the 2D scalp layout.
% Call this AFTER you have already drawn the layout, e.g.
%   eeg256_layout_plot(EEGchannel); hold on;
%   eeg256_timeseries_overlay(EEGchannel, PatientsEC(:,:,k,s), 250);
%
% Inputs
%   EEGchannel : 1x256 struct with fields .labels and either (.theta,.radius) or (.X,.Y)
%   eegSeg      : [256 x T] matrix
%
% (C) 2026 Moo K. Chung
% University of Wisonsin-Madison


labels = {EEGchannel.labels};
N = numel(labels);
T = size(eegSeg,2);

% ---------- (1) 2D coordinates from EEGchannel ----------
x = nan(N,1); y = nan(N,1);
for i = 1:N
    c = EEGchannel(i);
    [xi, yi] = theta_radius_to_xy_(c);          % prefer theta/radius
    if ~isfinite(xi) || ~isfinite(yi)
        if isfield(c,'X') && isfield(c,'Y') && ~isempty(c.X) && ~isempty(c.Y)
            xi = c.X; yi = c.Y;                 % fallback to X/Y
        end
    end
    x(i) = xi; y(i) = yi;
end

good = isfinite(x) & isfinite(y);

% normalize to unit head circle (same as layout)
if any(good)
    rmax = max(hypot(x(good), y(good)));
    if rmax > 0
        x = x / rmax;
        y = y / rmax;
    end
end

% ---------- (2) Put M1/M2 at ears (visual convention) ----------
m1 = strcmpi(labels,'M1');
m2 = strcmpi(labels,'M2');
x(m1) = -1.10; y(m1) = 0.00;
x(m2) =  1.10; y(m2) = 0.00;

% ---------- (3) Choose a reasonable micro-trace size from electrode spacing 
% If this looks too crowded, reduce traceScale below.
traceScale = 0.8;   % <— controls overall trace footprint

xg = x(good); yg = y(good);
D = hypot(xg - xg.', yg - yg.');                % pairwise distance
D(D==0) = inf;
nn = min(D,[],2);                               % nearest-neighbor distances
d0 = median(nn);                                % typical spacing

traceW = traceScale * 0.55 * d0;                % width of each micro-trace
traceH = traceScale * 0.40 * d0;                % height of each micro-trace

% ---------- (4) Time axis mapped to local horizontal span ----------
t = (0:T-1); %creates a time axis corresponding to the samples. 
% This does not change eegSeg in any way.
t0 = t - mean(t); %recenters time around zero so the waveform is symmetric left–right.
t0 = 1.5* t0 / max(abs(t0));  %rescales time to [-1.5 ,1.5].                 
tx = (traceW/2) * t0;  %maps that normalized time axis into a small 
% horizontal span around each electrode location.                 

% ---------- (5) Robust per-channel amplitude normalization ----------
% (No error checking; assumes eegSeg is 256 x T in microvolts or arbitrary units.)
X = double(eegSeg);
med = median(X,2);
Xc  = X - med;                                  % center each channel
sc  = median(abs(Xc),2) + eps;                  % robust scale (MAD-like)
Xn  = Xc ./ sc;                                 % normalize
Xn  = max(min(Xn, 4), -4);                      % clip extremes for readability

% ---------- (6) Draw micro-traces at each electrode ----------
ax = gca; hold(ax,'on');

for i = 1:N
    if ~good(i), continue; end

    % local waveform (vertical offsets)
    yy = y(i) + (traceH/2) * Xn(i,:);
    xx = x(i) + tx;

    plot(ax, xx, yy, 'g', 'LineWidth', 0.5);

    % optional: mark electrode center lightly (if not already visible)
    % plot(ax, x(i), y(i), '.k', 'MarkerSize', 6);
end

end

% ===== helper: theta/radius -> x,y 
% From EEGLAB convention 
function [x,y] = theta_radius_to_xy_(c)
x = nan; y = nan;
% theta: degrees, 0 at nose; radius: 0..1 (topoplot convention)
% mapping keeps "nose up": y is cos(theta), x is sin(theta)
if isfield(c,'theta') && isfield(c,'radius') && ~isempty(c.theta) && ~isempty(c.radius)
    th = c.theta * pi/180;
    r  = c.radius;
    x  = r * sin(th);
    y  = r * cos(th);
end
end