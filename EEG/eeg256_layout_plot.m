function eeg256_layout_plot(EEGchannel, mode)
% EEG256_LAYOUT_PLOT  Publication-style 2D scalp plot for dense EEG using chanlocs coords.
% Labels are taken directly from EEGchannel (no external label list needed).
%
% Inputs
%   EEGchannel : 1xN struct array with fields like labels, theta, radius, X, Y, Z, ...
%   mode        : 'theta_radius' (default) or 'xy'
%
% Notes
%   - Uses EEGchannel(k).theta and .radius if present (EEGLAB convention).
%   - Falls back to EEGchannel(k).X and .Y if theta/radius are missing.
%   - Adds an outward (non-inverted) nose marker at the top of the head.
%
% (C) 2026 Moo K. Chung
% University of Wisonsin-Madison

if nargin < 2 || isempty(mode)
    mode = 'theta_radius';
end

labels = {EEGchannel.labels};                 
N = numel(labels);

x = nan(N,1);
y = nan(N,1);

% ---------- 1) read coordinates ----------
for i = 1:N
    c = EEGchannel(i);

    if strcmpi(mode,'xy')
        if isfield(c,'X') && isfield(c,'Y') && ~isempty(c.X) && ~isempty(c.Y) && all(isfinite([c.X c.Y]))
            x(i) = c.X;
            y(i) = c.Y;
        else
            [x(i), y(i)] = theta_radius_to_xy_(c);
        end
    else
        [x(i), y(i)] = theta_radius_to_xy_(c);
        if ~isfinite(x(i)) || ~isfinite(y(i))
            if isfield(c,'X') && isfield(c,'Y') && ~isempty(c.X) && ~isempty(c.Y)
                x(i) = c.X;
                y(i) = c.Y;
            end
        end
    end
end

% ---------- 2) normalize to unit head circle ----------
good = isfinite(x) & isfinite(y);
if any(good)
    rmax = max(hypot(x(good), y(good)));
    if rmax > 0
        x = x / rmax;
        y = y / rmax;
    end
end

% Optional: place M1/M2 outside the head circle (common in EEG plots)
m1 = strcmpi(labels,'M1');
m2 = strcmpi(labels,'M2');
x(m1) = -1.10; y(m1) = 0.00;   % <— if you want them on-circle, comment these 2 lines
x(m2) =  1.10; y(m2) = 0.00;

% ---------- 3) label policy ----------
labelPolicy = 'all';   % 'all' or 'anchors'
anchorSet = {'FP1','FPZ','FP2','AFZ','FZ','FCZ','CZ','CPZ','PZ','POZ','OZ', ...
             'F3','F4','C3','C4','P3','P4','O1','O2','T7','T8','M1','M2'};
doLabel = false(N,1);
switch lower(labelPolicy)
    case 'anchors'
        doLabel = ismember(upper(labels), anchorSet);
    otherwise
        doLabel(:) = true;
end

% ---------- 4) plot ----------
labelRadOffset = 0.040;
fontSize       = 9;
boxMargin      = 0.10;


figure('Color','w'); hold on;

% head circle
th = linspace(0,2*pi,600);
plot(cos(th), sin(th), 'k', 'LineWidth', 2);

% nose (correct: outward anterior marker, NOT inverted)
% nose (single V-shape, pointing upward / anterior)   <— FIX
%noseX = [ -0.06   0   0.06 ];
%noseY = [  1.02  1.10 1.02 ];
%plot(noseX, noseY, 'k', 'LineWidth', 2);

% nose (single larger V-shape, pointing upward / anterior)   <— FIX: bigger nose
noseX = [ -0.10    0    0.10 ];
noseY = [  1.02  1.16  1.02 ];
plot(noseX, noseY, 'k', 'LineWidth', 2.5);

%noseX = [ 0     0.06   0   -0.06   0 ];
%noseY = [ 1.00  1.08  1.04  1.08  1.00 ];
%plot(noseX, noseY, 'k', 'LineWidth', 2);     % <— FIX: corrected nose orientation/shape

% ears
te = linspace(-pi/2, pi/2, 150);
xe = 1.02 + 0.08*cos(te);
ye = 0.15*sin(te);
plot( xe, ye, 'k', 'LineWidth', 2);
plot(-xe, ye, 'k', 'LineWidth', 2);

% nodes
%nodeSize       = 1;
%scatter(x(good), y(good), nodeSize, 'k', 'filled');

% labels with outward offset + deterministic tangential jitter to reduce overlap
for i = 1:N
    if ~doLabel(i), continue; end
    if ~isfinite(x(i)) || ~isfinite(y(i)), continue; end

    r = hypot(x(i), y(i));
    if r < 1e-6
        ux = 0; uy = 1;
    else
        ux = x(i)/r; uy = y(i)/r;
    end

    jitter = 0.012 * (hash01_(labels{i}) - 0.5);   % [-0.006,0.006]
    tx = -uy; ty = ux;                              % tangent

    xt = x(i) + labelRadOffset*ux + jitter*tx;
    yt = y(i) + labelRadOffset*uy + jitter*ty;

    text(xt, yt, labels{i}, ...
        'FontSize', fontSize, ...
        'HorizontalAlignment','center', ...
        'VerticalAlignment','middle', ...
        'BackgroundColor',[1 1 1], ...
        'Margin', boxMargin, ...
        'EdgeColor',[0.85 0.85 0.85]);
end

axis equal off;
xlim([-1.22 1.22]); ylim([-1.14 1.20]);


end

% ===== helper: theta/radius -> x,y (EEGLAB convention) =====
function [x,y] = theta_radius_to_xy_(c)
x = nan; y = nan;
if isfield(c,'theta') && isfield(c,'radius') && ~isempty(c.theta) && ~isempty(c.radius)
    th = c.theta * pi/180;    % degrees -> radians
    r  = c.radius;
    x  = r * sin(th);
    y  = r * cos(th);
end
end

% ===== helper: deterministic "hash" in [0,1] from string =====
function u = hash01_(s)
s = double(s);
u = mod(sum((1:numel(s)).*s), 1000) / 1000;
end