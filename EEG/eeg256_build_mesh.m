function S = eeg256_build_mesh(EEGchannel, alpha)
% EEG256_BUILD_MESH  Planar non-crossing mesh + 3D pruning (exclude M1/M2).
%
% This function constructs a neighborhood mesh for high-density EEG sensors by
% combining a planar triangulation in 2D with pruning based on true 3D sensor
% distances. The resulting graph is non-crossing in the 2D scalp layout while
% preserving local physical adjacency on the scalp surface.
%
% Processing steps:
%   1) Extract 2D scalp coordinates for visualization using the EEGLAB
%      (theta, radius) convention, with fallback to (X,Y) if needed.
%   2) Extract true 3D sensor coordinates (X,Y,Z) in centimeters.
%   3) Remove mastoid references (M1/M2) and channels with missing coordinates.
%   4) Normalize 2D coordinates to a unit head circle for stable triangulation.
%   5) Compute a 2D Delaunay triangulation to obtain a planar, non-crossing
%      candidate edge set.
%   6) Convert triangulation faces to an undirected edge list.
%   7) Prune edges using 3D Euclidean distances, retaining only edges shorter
%      than alpha times the median nearest-neighbor distance in 3D.
%
% Input
%   EEGchannel : 1xN struct with .labels and .theta/.radius or .X/.Y/.Z
%   alpha       : pruning factor in 3D (cm): keep edges with length <= alpha * median(NN_3D)
%                 (typical: alpha = 1.8 ~ 2.5)
%
% Output
%   S.vertices  : [Nv x 2] 2D coords for plotting
%   S.vertices3 : [Nv x 3] 3D coords (cm)
%   S.edges     : [Ne x 2] undirected planar-pruned edges
%   S.labels    : {Nv x 1}
%
% (C) 2026 Moo K. Chung
% University of Wisonsin-Madison

if nargin < 2 || isempty(alpha)
    alpha = 2.2;
end

labels = {EEGchannel.labels}';
N = numel(labels);

% ---- 2D coords for plotting ----
x = nan(N,1); y = nan(N,1);
for i = 1:N
    c = EEGchannel(i);
    [xi, yi] = theta_radius_to_xy_(c);
    if ~isfinite(xi) || ~isfinite(yi)
        xi = c.X; yi = c.Y;
    end
    x(i) = xi; y(i) = yi;
end

% ---- 3D coords (cm) ----
X = nan(N,1); Y = nan(N,1); Z = nan(N,1);
for i = 1:N
    X(i) = EEGchannel(i).X;
    Y(i) = EEGchannel(i).Y;
    Z(i) = EEGchannel(i).Z;
end

% ---- remove M1/M2 and any missing ----
isMastoid = strcmpi(labels,'M1') | strcmpi(labels,'M2');
keep = isfinite(x) & isfinite(y) & isfinite(X) & isfinite(Y) & isfinite(Z) & ~isMastoid;

x = x(keep); y = y(keep);
X = X(keep); Y = Y(keep); Z = Z(keep);
labels = labels(keep);

Nv = numel(x);

% ---- normalize 2D for stable triangulation/plot ----
rmax = max(hypot(x,y));
x = x / rmax;
y = y / rmax;
V2 = [x y];
V3 = [X Y Z];

% ---- planar triangulation in 2D (no crossings in 2D) ----
DT = delaunayTriangulation(V2);
T  = DT.ConnectivityList;
E0 = [T(:,[1 2]); T(:,[2 3]); T(:,[1 3])];
E0 = sort(E0,2);
E0 = unique(E0,'rows');

% ---- prune edges using 3D distance so mesh looks like physical net ----
d = sqrt(sum((V3(E0(:,1),:) - V3(E0(:,2),:)).^2, 2));   % cm

% robust 3D nearest-neighbor scale
D3 = squareform(pdist(V3));
D3(D3==0) = inf;
nn = min(D3,[],2);
rho = alpha * median(nn);

E  = E0(d <= rho, :);

% ---- output ----
S.vertices  = V2;
S.vertices3 = V3;
S.edges     = E;
S.labels    = labels;

end

function [x,y] = theta_radius_to_xy_(c)
x = nan; y = nan;
if isfield(c,'theta') && isfield(c,'radius') && ~isempty(c.theta) && ~isempty(c.radius)
    th = c.theta * pi/180;
    r  = c.radius;
    x  = r * sin(th);
    y  = r * cos(th);
end
end